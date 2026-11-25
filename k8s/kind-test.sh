#!/usr/bin/env bash
# Crea un clúster efímero y valida los cinco manifiestos con una credencial de laboratorio.
set -euo pipefail
img=${1:?Se requiere la imagen aprobada por digest}
dest=${2:-evidence/k8s}
[[ "$img" =~ ^ghcr\.io/miguelbriceno-sys/midama-securebank-api(-lab)?@sha256:[0-9a-f]{64}$ ]]
mkdir -p "$dest"
dest=$(realpath "$dest")
tmp=$(mktemp -d)
name="securebank-${GITHUB_RUN_ID:-local}"
trap 'kind delete cluster --name "$name" >/dev/null 2>&1 || true; rm -rf "$tmp"' EXIT
umask 077
cat > "$tmp/encryption.yaml" <<CONF
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources: [secrets]
    providers:
      - aescbc:
          keys:
            - name: laboratorio
              secret: $(openssl rand -base64 32)
      - identity: {}
CONF
cat > "$tmp/kind.yaml" <<CONF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: $tmp/encryption.yaml
        containerPath: /etc/securebank/encryption.yaml
    kubeadmConfigPatches:
      - |
        kind: ClusterConfiguration
        apiServer:
          extraArgs:
            - name: encryption-provider-config
              value: /etc/securebank/encryption.yaml
          extraVolumes:
            - name: claves-etcd
              hostPath: /etc/securebank
              mountPath: /etc/securebank
              readOnly: true
              pathType: Directory
CONF
kind create cluster --name "$name" --config "$tmp/kind.yaml" --image kindest/node:v1.35.0@sha256:986401fce0e567a9860075ba9df8c8459bd99a35f79024d8a682773fb40f0753 --wait 150s
cp -r k8s/hardened "$tmp/manifests"
for f in "$tmp"/manifests/*deployment*.yaml; do
  sed -i -E "s|^( +image: ).*$|\1$img|" "$f"
  kubesec scan "$f" > "$dest/$(basename "$f").json"
  jq -e 'length > 0 and all(.[]; .valid == true and .score > 0)' "$dest/$(basename "$f").json" >/dev/null
done
kubectl apply -f "$tmp/manifests/namespace.yaml"
kubectl apply -f "$tmp/manifests/serviceaccount.yaml" -f "$tmp/manifests/db-secret.yaml"
# La clave solo se materializa en el Secret del clúster y en el proceso que la genera.
openssl rand -hex 32 | tr -d '\n' | kubectl -n securebank create secret generic securebank-runtime --from-file=jwt-key=/dev/stdin --dry-run=client -o yaml | kubectl apply -f - >/dev/null
if [[ -f "${DOCKER_CONFIG:-$HOME/.docker}/config.json" ]]; then
  kubectl -n securebank create secret generic lectura-registro --type=kubernetes.io/dockerconfigjson --from-file=".dockerconfigjson=${DOCKER_CONFIG:-$HOME/.docker}/config.json" >/dev/null
fi
kubectl apply -f "$tmp/manifests/config.yaml"
kubectl apply -f "$tmp/manifests/deployment.hardened.yaml" -f "$tmp/manifests/frontend-deployment.yaml" -f "$tmp/manifests/worker-deployment.yaml"
for svc in api frontend worker; do kubectl -n securebank rollout status deployment/securebank-"$svc" --timeout=120s; done
kubectl -n securebank get pods -o wide > "$dest/pods.txt"
kubectl -n securebank exec deploy/securebank-api -- /nodejs/bin/node -e '
 const fs=require("node:fs");
 const st=fs.readFileSync("/proc/self/status","utf8");
 if(process.getuid()!==10001 || !/^CapEff:\s+0+$/m.test(st)) process.exit(1);
 if(fs.existsSync("/var/run/secrets/kubernetes.io/serviceaccount/token")) process.exit(1);
 console.log("UID",process.getuid(),"CapEff=0; token de ServiceAccount ausente");
' > "$dest/identidad.txt"
kubectl -n securebank exec deploy/securebank-api -- /nodejs/bin/node -e '
fetch("http://127.0.0.1:3000/health").then(async r=>{if(!r.ok)process.exit(1); console.log(await r.text())})' > "$dest/health.json"
kubectl -n kube-system exec "etcd-$name-control-plane" -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key get /registry/secrets/securebank/securebank-runtime --print-value-only | grep -aq '^k8s:enc:aescbc:v1:' 
echo 'Secret de laboratorio cifrado en etcd con aescbc.' > "$dest/cifrado.txt"

#!/usr/bin/env bash
# Controlador Sigstore del clúster de laboratorio. Cada política debe cumplirse.
set -euo pipefail
img=${1:?}
dest=${2:?}
identity="https://github.com/$GITHUB_REPOSITORY/.github/workflows/supply-chain.yml@$GITHUB_REF"
repo=${img%@*}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
chart=policy-controller-0.10.8
curl -fsSL --retry 3 "https://github.com/sigstore/helm-charts/releases/download/$chart/$chart.tgz" -o "$tmp/chart.tgz"
echo "71ecc9f1168dd7ad04b2f7456c2d492b5ca3e09a31883bb71f6369213ceeb814  $tmp/chart.tgz" | sha256sum -c -
helm upgrade --install policy-controller "$tmp/chart.tgz" --namespace cosign-system --create-namespace --wait --timeout 4m
for tipo in firma inventario; do
  cat > "$tmp/politica.yaml" <<YAML
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: securebank-$tipo
spec:
  images:
    - glob: "$repo**"
  authorities:
    - name: identidad-del-pipeline
      keyless:
        url: https://fulcio.sigstore.dev
        identities:
          - issuer: https://token.actions.githubusercontent.com
            subject: "$identity"
      ctlog:
        url: https://rekor.sigstore.dev
      source:
        - oci: "$repo"
          signaturePullSecrets:
            - name: lectura-registro
YAML
  if [[ "$tipo" == inventario ]]; then
    cat >> "$tmp/politica.yaml" <<'YAML'
      attestations:
        - name: sbom-cyclonedx
          predicateType: https://cyclonedx.org/bom
YAML
  fi
  kubectl apply -f "$tmp/politica.yaml"
done
kubectl label namespace securebank policy.sigstore.dev/include=true --overwrite
kubectl get clusterimagepolicy securebank-firma securebank-inventario -o name > "$dest/politicas.txt"

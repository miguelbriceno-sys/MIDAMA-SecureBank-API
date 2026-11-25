#!/usr/bin/env bash
# Instala únicamente las versiones y los binarios Linux amd64 especificados.
set -euo pipefail
case "${1:-}" in
  gitleaks) repo=gitleaks/gitleaks; tag=v8.24.3; asset=gitleaks_8.24.3_linux_x64.tar.gz; sha=9991e0b2903da4c8f6122b5c3186448b927a5da4deef1fe45271c3793f4ee29c; member=gitleaks ;;
  opa) repo=open-policy-agent/opa; tag=v1.9.0; asset=opa_linux_amd64_static; sha=66fa66f3b730b2fb086003863428b382b2898d343adb4b5dfab5598b4d739eed; member=opa ;;
  trivy) repo=aquasecurity/trivy; tag=v0.76.2; asset=trivy_0.76.2_Linux-64bit.tar.gz; sha=bc0fc726e017b8927a62b2d3531d7a84ee01769daf5c99ed866dced54089fdbf; member=trivy ;;
  *) echo "Herramienta desconocida" >&2; exit 2 ;;
esac
dest=${2:-"$HOME/.local/bin"}
mkdir -p "$dest"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl --fail --silent --show-error --location --retry 3 "https://github.com/$repo/releases/download/$tag/$asset" -o "$tmp/download"
echo "$sha  $tmp/download" | sha256sum -c - >&2
if [[ "$asset" == *.tar.gz ]]; then
  tar -xzf "$tmp/download" -C "$tmp" "$member"
  install -m 0755 "$tmp/$member" "$dest/$1"
else
  install -m 0755 "$tmp/download" "$dest/$1"
fi

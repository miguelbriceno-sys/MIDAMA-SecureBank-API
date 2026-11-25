#!/usr/bin/env bash
# Instala únicamente las versiones y los binarios Linux amd64 especificados.
set -euo pipefail
case "${1:-}" in
  gitleaks) repo=gitleaks/gitleaks; tag=v8.24.3; asset=gitleaks_8.24.3_linux_x64.tar.gz; sha=9991e0b2903da4c8f6122b5c3186448b927a5da4deef1fe45271c3793f4ee29c; member=gitleaks ;;
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

#!/usr/bin/env bash
set -euo pipefail
dest=${1:?Indicar la ruta del reporte}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$(dirname "$dest")"
printf '%s-%s-%08d\n' CONTROL REVOCADO 1 > "$tmp/marcador.txt"
# El código de Gitleaks se propaga al job que demuestra el bloqueo.
gitleaks dir --no-banner --redact=100 --config=.gitleaks.toml --report-format=json --report-path="$dest" "$tmp"

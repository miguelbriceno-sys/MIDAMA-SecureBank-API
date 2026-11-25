#!/usr/bin/env bash
# Baseline pasiva sobre la instancia desechable creada por este mismo job.
set -euo pipefail
dest=${1:-evidence/dast}
mkdir -p "$dest"
dest=$(realpath "$dest")
image='ghcr.io/zaproxy/zaproxy@sha256:c2d63bbb2d907a5c5257914fb20e26e969c92b25f265def7f89f08203f912882'
appimage="securebank-dast:${GITHUB_RUN_ID:-local}"
instance=$(docker build -q -t "$appimage" .)
container=$(docker run -d --rm -p 127.0.0.1:38080:3000 -e JWT_SECRET="$(openssl rand -hex 32)" "$instance")
trap 'docker rm -f "$container" >/dev/null 2>&1 || true' EXIT
for _ in {1..30}; do
  if curl --silent --fail http://127.0.0.1:38080/health > /dev/null; then break; fi
  sleep 1
done
curl --fail --silent http://127.0.0.1:38080/health > "$dest/health.json"
chmod 0777 "$dest"
date -u +%FT%TZ > "$dest/inicio-utc.txt"
set +e
docker run --rm --network=host -v "$dest:/zap/wrk:rw" "$image" zap-baseline.py \
  -t http://127.0.0.1:38080/health -m 1 -T 5 -r report.html -J report.json
status=$?
set -e
# ZAP usa 2 si solo hay advertencias. La severidad se decide con el reporte.
if [[ "$status" != 0 && "$status" != 2 ]]; then exit "$status"; fi
jq -e '.site | type == "array" and length > 0' "$dest/report.json" >/dev/null

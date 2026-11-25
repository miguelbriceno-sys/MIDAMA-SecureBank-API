#!/usr/bin/env bash
set -euo pipefail
dest=${1:-reports/sast/sast-after.sarif}
mkdir -p "$(dirname "$dest")"
semgrep scan --metrics=off --disable-version-check --strict --no-rewrite-rule-ids \
  --config "${OWASP_RULES:-p/owasp-top-ten}" --config security/semgrep.yml \
  --sarif-output "$dest" --json-output "${dest%.sarif}.json" src
python3 - "${dest%.sarif}.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1]))
if not data.get('paths',{}).get('scanned'):
    raise SystemExit('El analizador no cubrió archivos.')
failures=[r['check_id'] for r in data['results'] if r['extra']['severity'] in {'ERROR','HIGH','CRITICAL'}]
print(f"{len(data['results'])} hallazgos; {len(failures)} bloqueantes")
raise SystemExit(bool(failures))
PY

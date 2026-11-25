"""Normaliza resultados del mismo SHA. Ausencia de evidencia es error."""
import json
import re
import sys
from pathlib import Path

base, output = map(Path, sys.argv[1:])
def read(pattern):
    matches = list(base.glob(pattern))
    if len(matches) != 1:
        raise ValueError(f'Se esperaba un solo informe: {pattern}')
    return matches[0]

secrets = json.loads(read('secrets-*/gitleaks.json').read_text())
sast = json.loads(read('sast-*/sast-after.json').read_text())
sca = json.loads(read('sca-*/sca-decision.json').read_text())['counts']
dast = json.loads(read('dast-*/report.json').read_text())
coverage = re.search(r'all files\s*\|\s*([\d.]+)', read('tests-*/coverage-summary.txt').read_text())
if not isinstance(secrets, list) or not sast['paths']['scanned'] or not dast['site'] or not coverage:
    raise ValueError('Falta evidencia de ejecución.')
findings = [x['extra']['severity'] for x in sast['results']]
alerts = [int(a['riskcode']) for site in dast['site'] for a in site['alerts']]
if set(findings) - {'CRITICAL','HIGH','ERROR','WARNING','MEDIUM','INFO','LOW'} or set(alerts) - {0,1,2,3}:
    raise ValueError('Severidad desconocida.')
metrics = {'context': 'banca-publica', 'secrets': len(secrets), 'sast_critical': findings.count('CRITICAL'),
           'sast_high': findings.count('ERROR') + findings.count('HIGH'), 'sca_critical': sca['critical'],
           'sca_high': sca['high'], 'dast_high': alerts.count(3), 'medium': sca['moderate'] + alerts.count(2)
           + findings.count('WARNING') + findings.count('MEDIUM'), 'coverage': float(coverage[1])}
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(metrics, indent=2) + '\n')

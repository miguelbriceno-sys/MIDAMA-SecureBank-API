"""Genera inventario y decisión sobre la instalación npm de producción."""
import html
import json
import subprocess
import sys
from pathlib import Path

dest = Path(sys.argv[1] if len(sys.argv) > 1 else 'reports')
dest.mkdir(parents=True, exist_ok=True)

def output(command, allowed):
    run = subprocess.run(command.split(), stdout=subprocess.PIPE, text=True)
    if run.returncode not in allowed:
        raise SystemExit(f'Falló {command} ({run.returncode})')
    return json.loads(run.stdout)

def save(name, obj):
    (dest / name).write_text(json.dumps(obj, ensure_ascii=False, indent=2) + '\n')

bom = output('npm sbom --package-lock-only --omit=dev --sbom-format=cyclonedx', {0})
if bom.get('bomFormat') != 'CycloneDX' or bom.get('specVersion') != '1.5':
    raise SystemExit('Se requiere CycloneDX 1.5 para esta entrega.')
save('securebank-sbom.cdx.json', bom)
audit = output('npm audit --package-lock-only --omit=dev --json', {0, 1})
if 'error' in audit or 'vulnerabilities' not in audit or 'metadata' not in audit:
    raise SystemExit('No se recibió un informe válido de npm audit.')
save('securebank-vulns.json', audit)
lock = json.loads(Path('package-lock.json').read_text())['packages']
findings = []
for name, vuln in audit['vulnerabilities'].items():
    versions = sorted({lock[node]['version'] for node in vuln.get('nodes', []) if node in lock})
    for adv in vuln['via']:
        if isinstance(adv, str):
            continue  # La alerta original se contabiliza en el componente que la introduce.
        score = (adv.get('cvss') or {}).get('score')
        sev = adv['severity']
        if isinstance(score, (int, float)) and score > 0:
            sev = 'critical' if score >= 9 else 'high' if score >= 7 else 'moderate' if score >= 4 else 'low'
        if sev not in {'critical', 'high', 'moderate', 'low', 'info'}:
            raise SystemExit(f'Severidad sin clasificar en {name}')
        findings.append(dict(package=name, versions=versions, id=adv.get('url') or str(adv['source']),
                             cvss=score or None, severity=sev))
if audit['vulnerabilities'] and not findings:
    raise SystemExit('El informe tiene alertas sin detalle suficiente.')
counts = {s: sum(f['severity'] == s for f in findings) for s in ('critical', 'high', 'moderate', 'low', 'info')}
decision = 'BLOQUEAR' if counts['critical'] else 'REVISIÓN' if counts['high'] else 'CONTINUAR'
save('sca-decision.json', {'counts': counts, 'decision': decision, 'findings': findings})
rows = ''.join('<tr>' + ''.join('<td>' + html.escape(str(x)) + '</td>' for x in
     (f['package'], ', '.join(f['versions']), f['id'], f['cvss'] or 'Sin puntaje', f['severity'])) + '</tr>' for f in findings)
summary = f"{len(findings)} avisos en el árbol npm de producción. Decisión: {decision}."
page = f"""<!doctype html><html lang="es"><meta charset="utf-8"><title>Componentes de SecureBank</title>
<style>body{{max-width:900px;margin:4em auto;font:18px/1.55 system-ui;color:#163a43}}th,td{{padding:.45em;text-align:left}}h1{{color:#124d46}}</style>
<h1>Auditoría de componentes npm</h1><p>{summary}</p><table><tr><th>Componente</th><th>Versión</th><th>Aviso</th><th>CVSS</th><th>Severidad</th></tr>
{rows or '<tr><td colspan="5">El escáner no informó componentes vulnerables.</td></tr>'}</table>
<p>Un CVSS desde 9 bloquea. Desde 7 se exige revisión independiente. Los avisos restantes pasan al seguimiento del equipo.
Cuando falta puntaje se conserva la severidad del proveedor. La imagen de sistema se evalúa por separado.</p></html>"""
(dest/'securebank-vulns.html').write_text(page)
print(summary)
if decision == 'BLOQUEAR':
    raise SystemExit(1)

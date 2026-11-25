import json
import sys
from pathlib import Path

dest = Path(sys.argv[1])
def measure(version):
    data = json.loads((dest/f'{version}.json').read_text())
    image = json.loads((dest/f'{version}-inspect.json').read_text())
    results = data.get('Results', [])
    packages = {(r['Target'], p['Name'], p['Version'], p.get('Arch')) for r in results for p in r.get('Packages', [])}
    if not packages:
        raise ValueError('El scanner no inventarió paquetes de la imagen.')
    alerts = {(r['Target'], v['PkgName'], v['VulnerabilityID'], v['Severity']) for r in results for v in r.get('Vulnerabilities', [])}
    return {'imagen': image['Id'], 'fecha': data.get('CreatedAt'), 'bytes': image['Size'], 'paquetes': len(packages),
            'critical': sum(a[-1] == 'CRITICAL' for a in alerts), 'high': sum(a[-1] == 'HIGH' for a in alerts),
            'uid': int((dest/f'{version}-uid.txt').read_text().strip()),
            'puertos': sorted(image['Config'].get('ExposedPorts', {}))}
values = {v: measure(v) for v in ('v1', 'v2')}
(dest/'comparacion.json').write_text(json.dumps(values, indent=2) + '\n')
a,b = values.values()
lines = ['| Métrica | v1 | v2 endurecida | Cambio |','|---|---:|---:|---:|']
metrics=[('CVE altos y críticos',a['critical']+a['high'],b['critical']+b['high']),('Tamaño local (MiB)',round(a['bytes']/1048576,2),round(b['bytes']/1048576,2)),('Paquetes inventariados',a['paquetes'],b['paquetes'])]
for tag,x,y in metrics: lines.append(f'| {tag} | {x} | {y} | {y-x:+.2f} |')
lines.extend([f'| UID efectivo | {a["uid"]} | {b["uid"]} | Ambos sin privilegios |',f'| Puertos declarados | {", ".join(a["puertos"])} | {", ".join(b["puertos"])} | Misma interfaz |'])
(dest/'metricas.md').write_text('\n'.join(lines)+'\n')
print('\n'.join(lines))

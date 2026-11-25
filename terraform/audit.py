"""Compara el mismo conjunto de controles en un escenario de aula y en el módulo."""
import argparse
import json
import re
import subprocess
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('dest', type=Path)
parser.add_argument('--probar-bloqueo', action='store_true')
args = parser.parse_args()
args.dest.mkdir(exist_ok=True, parents=True)
profile = json.loads((root / 'profile.json').read_text())
severity = {rule: level for level, rules in profile.items() for rule in rules}

def scenario(files):
    # El escenario se analiza en un directorio temporal, sin proveedor ni estado AWS.
    def change(name, pattern, replacement):
        files[name], n = re.subn(pattern, replacement, files[name])
        if not n:
            raise ValueError('El escenario dejó de corresponder al módulo: ' + pattern)
    change('main.tf', r'(from_port|to_port)(\s*=\s*)443', r'\1\g<2>22')
    change('main.tf', r'(cidr_blocks\s*=\s*)\["10.42.0.0/16"\]', r'\1["0.0.0.0/0"]')
    change('main.tf', r'(storage_encrypted|enable_log_file_validation|is_multi_region_trail|enable_key_rotation)(\s*=\s*)true', r'\1\2false')
    change('support.tf', r'(block_public_acls|block_public_policy|ignore_public_acls|restrict_public_buckets)(\s*=\s*)true', r'\1\2false')
    change('support.tf', r'Action\s*=\s*\["dynamodb:PutItem"\],\s*Resource\s*=\s*aws_dynamodb_table.txn.arn', 'Action = ["*"], Resource = "*"')
    return files

def scan(label, files):
    with tempfile.TemporaryDirectory() as temp:
        for name, value in files.items():
            (Path(temp) / name).write_text(value)
        cmd = ['checkov', '-d', '.', '--framework', 'terraform', '--check', ','.join(severity),
               '--compact', '--output', 'json']
        run = subprocess.run(cmd, cwd=temp, capture_output=True, text=True)
        if run.returncode not in (0, 1):
            raise RuntimeError(run.stderr[-1800:])
        raw = json.loads(run.stdout)
    items = raw['results']
    if items.get('parsing_errors') or raw['summary'].get('parsing_errors') or items.get('skipped_checks'):
        raise ValueError('Existen omisiones o errores de lectura.')
    passes, failures = items['passed_checks'], items['failed_checks']
    observed = {r['check_id'] for r in passes + failures}
    if set(severity) - observed:
        raise ValueError('No se evaluaron: ' + str(set(severity)-observed))
    # Directorios temporales del runner carecen de significado fuera de esta ejecución.
    for row in passes + failures:
        row.pop('file_abs_path', None)
    (args.dest / (label + '.json')).write_text(json.dumps(raw, ensure_ascii=False, separators=(',', ':'))+'\n')
    total = len(passes) + len(failures)
    urgent = [r for r in failures if severity[r['check_id']] in ('critical', 'high')]
    return {'passed':len(passes), 'failed':len(failures), 'total':total,
            'score':round(100*len(passes)/total,2), 'graves':len(urgent),
            'decision':'BLOQUEAR' if urgent or len(passes)/total < .85 else 'CONTINUAR'}

source = {p.name:p.read_text() for p in root.glob('*.tf')}
before = scan('before', scenario(source.copy()))
after = scan('after', source)
if before['decision'] != 'BLOQUEAR':
    raise ValueError('La prueba negativa no ejercitó el gate.')
report = {'alcance':'Perfil docente versionado en terraform/profile.json','before':before,'after':after}
(args.dest/'score.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(report, ensure_ascii=False, indent=2))
raise SystemExit((before if args.probar_bloqueo else after)['decision'] != 'CONTINUAR')

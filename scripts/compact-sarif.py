"""Compacta el catálogo SARIF sin quitar resultados ni alterar sus ubicaciones."""
import json
import sys
from pathlib import Path

for arg in sys.argv[1:]:
    path = Path(arg)
    report = json.loads(path.read_text())
    for run in report['runs']:
        driver = run['tool']['driver']
        used = {item['ruleId'] for item in run['results']}
        rules = [rule for rule in driver.get('rules', []) if rule['id'] in used]
        indexes = {rule['id']: i for i, rule in enumerate(rules)}
        for result in run['results']:
            if 'ruleIndex' in result:
                result['ruleIndex'] = indexes[result['ruleId']]
        driver['rules'] = rules
    path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')

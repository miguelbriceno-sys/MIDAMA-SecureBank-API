package securepipeline.gate_test

import data.securepipeline.gate
import rego.v1

base := {"context": "banca-publica", "secrets": 0, "sast_critical": 0, "sast_high": 0, "sca_critical": 0, "sca_high": 0, "dast_high": 0, "medium": 0, "coverage": 80}
test_pasa_limite if gate.allow with input as base
test_debate_bloqueado if not gate.allow with input as object.union(base, {"sca_high": 3, "medium": 12})
test_secreto if not gate.allow with input as object.union(base, {"secrets": 1})
test_cobertura if not gate.allow with input as object.union(base, {"coverage": 79.99})
test_critico if not gate.allow with input as object.union(base, {"sca_critical": 1})
test_dast if not gate.allow with input as object.union(base, {"dast_high": 1})
test_datos_ausentes if not gate.allow with input as {}
test_tipo_invalido if not gate.allow with input as object.union(base, {"medium": "0"})
test_contexto_desconocido if not gate.allow with input as object.union(base, {"context": "indefinido"})
test_medios if not gate.allow with input as object.union(base, {"medium": 13})

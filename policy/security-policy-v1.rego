package securepipeline.gate

import rego.v1

default allow := false

valid if {
	input.context in {"banca-publica", "interno"}
	every key in {"secrets", "sast_critical", "sast_high", "sca_critical", "sca_high", "dast_high", "medium"} {
		is_number(input[key])
		input[key] >= 0
		floor(input[key]) == input[key]
	}
	is_number(input.coverage)
	input.coverage >= 0
	input.coverage <= 100
}

deny contains "Faltan métricas válidas o contexto reconocido" if not valid
deny contains "Se encontró una credencial" if input.secrets > 0
deny contains "Se detectó un hallazgo crítico" if input.sast_critical + input.sca_critical > 0
deny contains "Existe un hallazgo alto de código o de ejecución" if input.sast_high + input.dast_high > 0

deny contains "La API bancaria pública tiene dependencias de riesgo alto" if {
	input.context == "banca-publica"
	input.sca_high > 0
}

deny contains "Más de dos avisos altos en un ambiente interno" if input.sca_high > 2

deny contains "Se requiere revisión de dependencias altas en el ambiente interno" if {
	input.context == "interno"
	input.sca_high > 0
}

deny contains "Más de doce avisos medios requieren priorización antes de promover" if input.medium > 12
deny contains "Cobertura de líneas inferior a 80 %" if input.coverage < 80

allow if {
	valid
	count(deny) == 0
}

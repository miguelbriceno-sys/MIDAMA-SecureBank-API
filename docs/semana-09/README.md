# Sesión 9 · Security Quality Gate

La política formaliza el criterio de la sesión 6 para la API bancaria y reúne las cuatro familias de análisis. La salida queda asociada al mismo commit que produjo las pruebas. El caso de salida urgente está resuelto en la política. Las pruebas cubren umbrales, fuentes incompletas y el caso de tres hallazgos altos.

[Política y justificación](../../policy/README.md) · [Resultado de OPA](../../reports/gate/pruebas.txt) · [Presentación](sesion-09.pptx)

En el [run evaluado](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688850012), el gate recibió cero secretos, cero altos o críticos de aplicación y una cobertura de líneas del 96,28 %. La salida de OPA permitió empaquetar el artefacto.

[Métricas del runner](../../reports/gate/metrics.json) · [Decisión de OPA](../../reports/gate/decision.json)

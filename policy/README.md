# Política de promoción v1.0

El resultado se calcula sobre la misma revisión de Git. Rego recibe los informes de Gitleaks, Semgrep, npm audit y ZAP, junto con la cobertura de líneas de Node. Una fuente ausente, duplicada o incompleta interrumpe la normalización. El trabajo obligatorio `build-test` comprueba el éxito de todos sus prerrequisitos antes de publicar la distribución.

| Condición | Decisión del equipo | Justificación |
|---|---|---|
| Credenciales o críticos > 0 | Bloquear | Comprometen la identidad del servicio o un componente de alto impacto. |
| Alto SAST o DAST > 0 | Bloquear | El hallazgo afecta al código o a la aplicación observada. |
| Alto SCA en banca pública > 0 | Bloquear y corregir | Login y transferencias están en el perímetro expuesto. |
| Alto SCA en interno | De 1 a 2 queda retenido para revisión, con más de 2 el límite queda excedido | La versión 1.0 mantiene el despliegue retenido hasta una corrección o un cambio de política revisado por PR. |
| Medios ≤ 12 | Registrar y asignar al próximo sprint | El equipo puede priorizarlos según la ruta afectada y su exposición. Sobre 12 se bloquea para revisar la acumulación. |
| Cobertura de líneas < 80 % | Bloquear | Una caída deja rutas críticas sin suficiente observación. Las pruebas de propiedad y saldo siguen siendo obligatorias. |

En el caso del PPT, 0 críticos, 3 altos y 12 medios justifican postergar la salida del producto bancario. El equipo debe identificar los componentes altos y dónde se usan, comprobar la exposición y respaldar los controles compensatorios. La urgencia comercial no constituye una excepción. Un cambio de umbral exige PR, dueño del riesgo y fecha de revisión. El equipo registra avisos aceptados y vigila su vencimiento.

[Reglas](security-policy-v1.rego) · [Pruebas ejecutables](tests/gate_test.rego)

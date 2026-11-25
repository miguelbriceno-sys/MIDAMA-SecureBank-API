# Sesión 8 · DAST y seguridad de API

El análisis dinámico observó respuestas públicas de la API en una instancia efímera. La primera medición usó ZAP 2.16.1 y la de cierre usó ZAP 2.17.0, ambas en modo pasivo. Las pruebas HTTP verificaron la separación de perfiles con usuarios ficticios. El informe describe el alcance del rastreo, las cabeceras, los responsables y el resultado de ambas mediciones. El JSON conserva la salida original de la herramienta.

[Informe para el aula virtual, dos páginas](reporte-dast-MIDAMA.pdf) · [JSON adjunto](../../reports/dast/report.json) · [Tablero HTML](../../reports/dast/report.html) · [Pruebas HTTP](../../tests/http.test.js) · [Presentación](sesion-08.pptx)

La primera línea base del runner registró dos alertas bajas y una informativa. Después de fijar ZAP 2.17.0 y las cabeceras de aislamiento quedó el aviso informativo asociado a Cache-Control: no-store. La API mantiene ese control para evitar almacenar respuestas bancarias.

[Análisis inicial](../../reports/dast/antes.json) · [Run con la corrección](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688850012)

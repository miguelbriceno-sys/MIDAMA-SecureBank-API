# Sesión 6 · Dependencias, CVE y SBOM

El lockfile de SecureBank declara la aplicación raíz y cero paquetes npm externos. Para esta arquitectura elegimos npm audit y npm sbom. Ambos leen el mismo lockfile de producción. El inventario CycloneDX 1.5 registra el componente raíz y su PURL. El conjunto de dependencias directas y transitivas está vacío. El proyecto no declara una licencia de distribución en su manifiesto. Node.js, la SQLite que incorpora y las bibliotecas del sistema se cubren en el análisis de imagen de la sesión 10.

| Puntaje CVSS | Decisión y responsable | Aplicación al laboratorio |
|---|---|---|
| 9,0–10 | Bloqueo automático. Desarrollo identifica una versión corregida y vuelve a escanear. | El script termina con error y conserva la evidencia. |
| 7,0–8,9 | Seguridad o el lead revisa exposición y mitigación antes de promover. | La entrega queda retenida. Para esta API expuesta la política de la sesión 9 exige resolver el alto antes de promover. |
| Menor que 7,0 | Continuar y registrar. El equipo incorpora componente, versión y acción al siguiente sprint. | El JSON de decisión guarda los avisos y su puntuación. |
| Sin puntaje | Se conserva la severidad informada por el proveedor. | Una respuesta inválida del escáner hace fallar el job. |

El informe del 25 de noviembre registró cero avisos en este alcance. Bloquear desde 5,0 puede acumular revisiones por problemas con impacto marginal. Esperar a 10,0 dejaría pasar fallos graves en operaciones expuestas. Ante el mismo puntaje priorizamos si el componente interviene en login o transferencias, qué entradas recibe y qué mitigación está probada.

El job `sca` depende de `sast`. Ejecuta `python3 scripts/sca.py evidence/sca` y conserva los cuatro archivos del mismo run.

[SBOM](../../reports/securebank-sbom.cdx.json) · [Informe legible](../../reports/securebank-vulns.html) · [JSON nativo](../../reports/securebank-vulns.json) · [Decisión](../../reports/sca-decision.json) · [Presentación](sesion-06.pptx)

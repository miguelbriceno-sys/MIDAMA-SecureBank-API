# Sesión 4 · CI/CD y arquitectura del pipeline

**MIDAMA · Pipeline CI v1.0 · 01-10-2026.** [Workflow real](../../.github/workflows/ci.yml).

## CI, entrega y despliegue continuo

CI valida automáticamente cambios y genera un artefacto probado. Continuous Delivery prepara una versión desplegable y conserva una decisión humana antes de producción. Continuous Deployment publica automáticamente todo cambio que supera sus controles. Esta entrega implementa **CI**: no despliega a staging ni a producción.

## Arquitectura y vocabulario

| Elemento | Aplicación en MIDAMA |
|---|---|
| Workflow | `.github/workflows/ci.yml`, definición versionada |
| Trigger | Push a cualquier rama, PR hacia main y ejecución manual |
| Runner | VM hospedada `ubuntu-latest`; no reutiliza entorno local |
| Job | `secrets-scan`; `build-test` depende de su éxito |
| Step | Checkout, instalación, build, pruebas, publicación y resumen |
| Artifact | `dist-<SHA>` y `tests-<SHA>`, retención de 7 días |
| Environment | No hay destino de despliegue en esta versión; dev local |
| Secret | Token temporal de GitHub con contents:read; sin credenciales bancarias en CI |

El runner primero escanea el historial. Si Gitleaks falla, no comienza el job que produce el artefacto. Después checkout obtiene el código, `npm ci --ignore-scripts` respeta el lockfile, build valida sintaxis y copia archivos de distribución, y `npm run test:ci` ejecuta pruebas reales con cobertura y JUnit. `set -o pipefail` evita ocultar fallos al usar `tee`. `dist/` solo se publica cuando las pruebas pasan. La evidencia de pruebas se intenta conservar también si falla el job.

`node-version: 24` mantiene la línea mayor de desarrollo local. Las acciones checkout, setup-node, upload-artifact y Gitleaks están fijadas por SHA consultado en sus repositorios oficiales. No se ejecutan comandos descargados por HTTP ni scripts de instalación npm. No existen dependencias npm externas que auditar en esta versión; esto no equivale a asegurar que Node, SQLite, acciones o la imagen carezcan de vulnerabilidades. SCA de runtime e imagen queda para sesiones posteriores.

## Ejercicio: cuatro riesgos del pipeline inseguro

| Riesgo del PPT | Vulnerabilidad | Qué haría un atacante | STRIDE | Corrección concreta |
|---|---|---|---|---|
| R1 `permissions: write-all` | Token con privilegios innecesarios | Alterar código, releases o paquetes desde un job comprometido | E | `permissions: contents: read`; permisos adicionales solo en job justificado |
| R2 `curl http://…/setup.sh` ejecutado con sudo | Código remoto sin integridad y canal sin TLS | Sustituir script y ejecutar comandos privilegiados | T / E | Eliminar descarga y sudo; setup-node oficial fijado por SHA; verificar firma/hash si un binario externo es indispensable |
| R3 `npm install express body-parser jsonwebtoken` sin versiones | Dependencias flotantes y build no reproducible | Introducir código mediante paquete comprometido | T | Versiones revisadas, lockfile y `npm ci`; SCA con umbral high cuando existan dependencias |
| R4 contraseña literal en YAML | Secreto expuesto en historial, clones y logs | Acceder al sistema usando la credencial | I / S | Revocar y rotar primero; retirar literal y usar gestor de secretos por entorno; escanear historial |

Además, el ejemplo presenta `env` como un step sin acción/comando y usa una variable en un paso anterior a su definición. Un ejemplo conceptual con raíz `pipeline/stages` tampoco es sintaxis de GitHub Actions. Se corrigió usando `on`, `jobs`, `steps`, permisos a nivel de workflow y variables dentro del paso que las consume. No se guardó una contraseña de ejemplo que pudiera confundirse con un secreto real.

## Definition of Done y evidencia

| Criterio del PPT | Verificación |
|---|---|
| YAML versionado mediante feature + PR | Esta entrega se propone en PR, sin push directo a main |
| Push automático a toda rama | `on: push` sin filtro de branches |
| Checkout/install/build/test/artifact | Steps reales en build-test |
| Build reproducible | Lockfile npm; build y 12 pruebas pasan localmente |
| Última ejecución verde | Consultar el run asociado al SHA del PR; no sustituir por pruebas locales |
| Artefacto descargable con hash y ≥7 días | Upload `dist-${github.sha}`, retention-days 7; comprobar existencia en el run |
| Checks obligatorios para main | Activados y verificados para main, restringidos a GitHub Actions; la integración exige ambos aprobados |
| Sin secretos versionados | Job Gitleaks del historial y variables externas |
| README con badge y descripción | Incluidos en la raíz |

## Preparación sesión 5: SAST

SAST analiza código sin levantar la aplicación. Detecta patrones como inyección, secretos y validación insegura; no reemplaza pruebas dinámicas o de autorización. En la siguiente sesión se agregará un job con una herramienta y reglas revisadas, umbral de bloqueo y reporte trazable. Gitleaks cubre secretos; no representa un análisis SAST completo de toda la API.

## Actualización de configuración

La [regla de main](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/settings/branch_protection_rules/84077806) está activa con aprobación independiente, Code Owner review, firmas y checks obligatorios. El PR #2 conserva las entregas hasta que otro integrante revise y se confirme la firma del commit que se integrará. La ejecución se repite tras cada nuevo cambio; verificar siempre el último head antes de merge.

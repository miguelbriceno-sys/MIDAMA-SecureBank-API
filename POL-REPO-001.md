# POL-REPO-001 · Política de repositorios seguros

**v1.0 · MIDAMA · 01-10-2026 · Próxima revisión: 01-11-2026.** Alcance: código, documentación, CI e infraestructura preproductiva/productiva de una fintech de 40 desarrolladores en cinco equipos, un líder de seguridad, un SRE y dos revisores externos. Esta es la política del escenario académico; su activación real se verifica por separado.

## 1. Roles y responsabilidades

Developers trabajan en `feature/*` o `hotfix/*`, agregan pruebas y corrigen hallazgos. Reviewers verifican lógica, seguridad y evidencia sin aprobar cambios propios. Cada equipo designa un Code Owner para sus rutas. El líder de seguridad es dueño de autenticación, permisos y controles. El SRE mantiene CI e infraestructura. El Release Manager publica versiones aprobadas. Solo dos Secret Custodians modifican secretos; el resto recibe uso por entorno y sin lectura innecesaria.

Adaptación propuesta a MIDAMA: Daniel (desarrollo), Antonella (seguridad y revisión), Allen (SRE/CI) y Miguel (release y QA). Custodios: Antonella y Allen. Miguel administra el repositorio mediante la cuenta verificada `miguelbriceno-sys`; las cuentas GitHub restantes deben confirmarse antes de asignar permisos o CODEOWNERS.

## 2. Reglas obligatorias

MFA y claves individuales; permisos mínimos, revisión trimestral y baja inmediata al terminar la colaboración. `main` exige PR, al menos una aprobación independiente, aprobación de Code Owner, descarte de aprobaciones tras nuevos commits, conversaciones resueltas, commits con firma verificada y checks `build-test` y `secrets-scan` aprobados sobre el último SHA. Prohibir push directo, force push, borrado y bypass incluso a administradores. `develop` integra trabajo; toda entrada a `main`, incluidos hotfix, pasa por PR. Tags de release firmados e inmutables.

Secretos fuera de Git e imágenes, inyectados desde un vault por entorno. `.gitignore`, escaneo de historial en cada push/PR y rotación ante filtración. PR de fork sin secretos, sin `pull_request_target` ejecutando código no confiable; nunca aprobar automáticamente un workflow desconocido. Acciones fijadas por SHA y dependencias con lockfile. Modificar CODEOWNERS requiere revisión de seguridad.

## 3. Quién puede qué

| Acción | Autorización | Condiciones |
|---|---|---|
| Merge | Lead del equipo o Release Manager con permiso efectivo | Autor distinto del aprobador; ≥1 aprobación + dueño de rutas; todos los checks verdes. Forks y dependencias cumplen las mismas reglas; sin auto-merge irrestricto. |
| Cambiar pipelines | SRE propone; seguridad y revisor técnico aprueban | Dos aprobaciones distintas para CI crítico, una de seguridad; acciones verificadas, sin ampliación injustificada de permisos. CODEOWNERS solo exige uno de los dueños: la segunda revisión se controla adicionalmente. |
| Crear releases | Release Manager | Ventana semanal jueves; tag firmado, changelog, ticket y SHA de CI verde, artefactos revisados; emergencia documentada. |
| Modificar secretos | Dos custodios nombrados: Antonella y Allen en MIDAMA | Separación dev/prod, registro sin valor del secreto, revisión mutua; rotación cada 90 días o inmediata ante incidente. |

En la fintech, dos revisores externos tienen acceso temporal de lectura/revisión, sin merge, releases ni administración de secretos. Cinco leads distribuyen revisiones y evitan un único cuello de botella.

## 4. Cobertura de los siete riesgos

| Riesgo | Control verificable |
|---|---|
| R01 secretos | Vault + ignore + Gitleaks + rotación |
| R02 código malicioso | PR + revisión independiente + CODEOWNERS |
| R03 borrado de ramas | Protección contra borrado y force push; respaldos verificables |
| R04 autoría suplantada | Firmas verificadas, MFA y auditoría de accesos |
| R05 externos/exintegrantes | Mínimo privilegio, caducidad, revisión trimestral y offboarding |
| R06 PR hostil | Checks, revisión de CI y aislamiento de forks |
| R07 pérdida de confianza del negocio | Evidencia por release, restauración ensayada y responsable del riesgo |

## 5. Excepciones y revisión

Solicitar excepción por issue: regla afectada, motivo, riesgo, control compensatorio, responsables y caducidad ≤7 días. Seguridad y SRE autorizan antes de aplicar; no hay excepción para secretos en Git ni entrada a `main` sin PR revisado. Un hotfix acelera la revisión, conserva pruebas y genera retrospectiva dentro de 48 horas. Si falta un revisor, convocar al suplente; no simular una aprobación. Revisar la política mensualmente y después de incidentes; guardar decisiones en el historial y cerrar las excepciones vencidas.

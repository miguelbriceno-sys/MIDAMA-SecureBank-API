# Validación y estado de la entrega

**Fecha: 02-10-2026 · MIDAMA.**

Esta página distingue evidencia local de configuración real de GitHub y registra el estado actualizado de la entrega después de la integración del Pull Request #2.

## Revisión inicial

El repositorio contenía README y tres archivos de la sesión 1, sin `src`, `tests`, `Dockerfile` ni workflows. `main` estaba inicialmente sin protección.

El PR original #1 no tenía comentarios con correcciones específicas del docente. Se corrigieron omisiones respecto de las actividades indicadas en los PPT; no se inventaron observaciones del profesor.

## Verificación local

Entorno Node.js v24.19.0, npm 11.9.0.

Los comandos:

- `npm ci --ignore-scripts`
- `npm run build`
- `npm run test:ci`

terminaron con código 0.

Resultado:

- **12 pruebas aprobadas**
- **0 pruebas fallidas**
- **95,91% de cobertura de líneas**
- **89,84% de cobertura de ramas**

La cobertura se utiliza como evidencia de pruebas y no como garantía absoluta de seguridad.

Se probó:

- registro y login;
- rechazo de credenciales inválidas;
- BOLA en cuentas, movimientos y transferencias;
- débito y crédito atómico;
- rollback por saldo insuficiente o destino inválido;
- validación de monto entero y rango;
- SQL Injection;
- JWT alterado, `none` y expirado;
- rechazo de rol `admin` enviado por cliente;
- auditoría sin tokens ni contraseñas;
- límites de JSON/payload;
- rate limiting.

Se conserva JUnit como artefacto del pipeline CI.

## Controles reales y pendientes

| Control | Estado |
|---|---|
| Base API, SQLite parametrizada, autorización por objeto y transacciones | Implementado y probado localmente |
| Hash scrypt, JWT firmado/expiración y rechazo de role cliente | Implementado y probado; MFA de aplicación pendiente |
| Usuario no root en Dockerfile | Configurado; Docker no disponible para construir y escanear localmente |
| Rate limit, tamaño JSON y timeouts | Configurado; límites/payload probados; prueba de carga pendiente |
| Auditoría mínima con hash encadenado | Implementada; storage externo, retención e integridad anclada pendientes |
| CI con build/test/artefactos y Gitleaks | Verificado en GitHub Actions: `secrets-scan` y `build-test` aprobados, artefactos publicados |
| CODEOWNERS | Configurado; revisar distribución de responsabilidades entre integrantes |
| `main` protegida y checks obligatorios | Activado y verificado: PR obligatorio, ≥1 aprobación, Code Owners, stale reviews, conversaciones resueltas, firmas, rama actualizada y checks `build-test` / `secrets-scan`; sin bypass, force push ni borrado sobre `main` |
| Revisión independiente de la entrega | **Cumplido:** PR #2 revisado y aprobado por Allen2109 antes de su integración |
| Commits firmados | **Cumplido para la integración del PR #2:** la rama fue regularizada para satisfacer la política de firmas requerida por `main` |
| MFA de integrantes de GitHub | Pendiente de verificación individual; no es comprobable mediante el contenido público del repositorio |
| Repositorio privado en organización UBO | Pendiente: el repositorio actual continúa público y bajo una cuenta personal |
| TLS, red privada, cloud, backups, WAF y monitoreo | Arquitectura propuesta; no desplegada |
| SAST/SCA/DAST completos, SBOM y firma de artefactos | Corresponden a etapas posteriores del semestre |

No se declara producción segura ni cumplimiento regulatorio.

No se reasigna autoría de commits a integrantes que no realizaron originalmente esas acciones.

## Evidencia remota verificada

El Pull Request #2:

**“Completar sesiones 1–4: política, Threat Model y CI de SecureBank”**

fue sometido a revisión independiente, aprobado por `Allen2109` y posteriormente integrado a `main`.

GitHub registró:

- aprobación independiente;
- 3 commits en el Pull Request;
- 4 checks aprobados;
- integración final a `main`;
- merge realizado el 02-10-2026.

PR:

https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/pull/2

Durante el proceso, la rama `feature/entregas-sesiones-1-4` fue reescrita para regularizar los commits antes de la integración. GitHub registró el cambio del historial de la rama y posteriormente permitió el merge bajo las reglas de protección configuradas.

El commit de integración registrado en `main` es:

`d5c9e14`

### Ejecución CI previa

Run del PR #2:

https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/36929878110

Los jobs:

- `secrets-scan`
- `build-test`

finalizaron en **success**.

Las 12 pruebas pasaron con la misma cobertura observada localmente.

El run original probó la integración temporal:

`55931cafdf21e9f94671fc5ee56fb40b926a1a47`

del head:

`73e28e47ad866959200d534b7d1d2d25f7f0cf9c`

sobre `main`.

En eventos de Pull Request, `github.sha` corresponde al commit de integración temporal, por lo que los artefactos de esa ejecución utilizan dicho hash.

Artefactos:

- `dist-55931caf…`
- `tests-55931caf…`

Ambos fueron configurados con retención de 7 días.

## Protección activada

El 01-10-2026 se configuró y verificó la protección de la rama `main`.

La regla exige:

- Pull Request antes de integrar;
- mínimo 1 aprobación;
- revisión de Code Owners;
- descarte de aprobaciones obsoletas;
- resolución de conversaciones;
- commits firmados;
- rama actualizada;
- check `build-test`;
- check `secrets-scan`.

Además:

- no se permite bypass de las reglas;
- no se permite `force push` sobre `main`;
- no se permite borrar `main`.

El PR #2 cumplió las condiciones exigidas y fue integrado sin desactivar las protecciones de la rama.

## Pendientes administrativos

A la fecha de esta actualización quedan pendientes:

1. Verificar MFA individual de todos los integrantes.
2. Revisar y distribuir CODEOWNERS entre los integrantes del equipo.
3. Resolver con el docente el requisito de repositorio privado dentro de la organización `UBO-DevSecOps`.
4. Mantener los commits futuros firmados individualmente por cada integrante.
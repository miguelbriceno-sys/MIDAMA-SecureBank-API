# Validación y estado de la entrega

**Fecha: 01-10-2026 · MIDAMA.** Esta página distingue evidencia local de configuración real de GitHub.

## Revisión inicial

El repositorio contenía README y tres archivos de la sesión 1, sin src, tests, Dockerfile ni workflows. Main estaba sin protección. El PR original #1 no tenía comentarios con correcciones específicas del docente. Se corrigieron omisiones respecto de las actividades de los PPT; no se inventaron observaciones del profesor.

## Verificación local

Entorno Node.js v24.19.0, npm 11.9.0. `npm ci --ignore-scripts`, `npm run build` y `npm run test:ci` terminaron con código 0. Resultado: **12 pruebas aprobadas, 0 fallidas**. Cobertura observada: **95,91% líneas, 89,84% ramas**, sin considerarla una garantía de seguridad.

Se probó registro/login, rechazo de credenciales inválidas, BOLA en cuentas/movimientos y transferencias, débito/crédito atómico, rollback por saldo/destino, monto entero/rango, SQLi, JWT alterado/none/expirado, rol admin enviado por cliente, auditoría sin tokens ni contraseñas, JSON/payload y rate limit. Se conserva JUnit como artefacto de CI y no como un resultado local inventado del profesor.

## Controles reales y pendientes

| Control | Estado |
|---|---|
| Base API, SQLite parametrizada, autorización por objeto y transacciones | Implementado y probado localmente |
| Hash scrypt, JWT firmado/expiración y rechazo de role cliente | Implementado y probado; MFA pendiente |
| Usuario no root en Dockerfile | Configurado; Docker no disponible para construir y escanear localmente |
| Rate limit, tamaño JSON y timeouts | Configurado; límites/payload probados; prueba de carga pendiente |
| Auditoría mínima con hash encadenado | Implementada; storage externo, retención e integridad anclada pendientes |
| CI con build/test/artefactos y Gitleaks | Verificado en GitHub Actions: Gitleaks y build-test aprobados, artefactos publicados |
| CODEOWNERS | Cuenta de Miguel confirmada; verificar cuentas restantes y permisos |
| Main protegida, revisión independiente, firmas y checks obligatorios | Pendiente de configuración/validación administrativa |
| MFA de integrantes | Pendiente de verificación individual; no accesible mediante contenido del repo |
| Repositorio privado en organización UBO | El repo recibido es público y personal; decisión y acceso docente pendientes |
| TLS, red privada, cloud, backups, WAF y monitoreo | Arquitectura propuesta; no desplegada |
| SAST/SCA/DAST completos, SBOM y firma de artefactos | Etapas posteriores del semestre |

No se declara producción segura ni cumplimiento regulatorio. No se reasigna autoría de commits a integrantes que no realizaron esas acciones. Una aprobación humana independiente debe conservarse en el PR antes de integrarlo a main.

## Evidencia remota verificada

[Run del PR #2](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/36929878110): `secrets-scan` y `build-test` finalizaron en **success**. Node del runner: v24.21.0. Las 12 pruebas pasaron con la misma cobertura de líneas y ramas observada localmente.

El run probó la integración temporal `55931cafdf21e9f94671fc5ee56fb40b926a1a47` del head `73e28e47ad866959200d534b7d1d2d25f7f0cf9c` sobre main. En eventos de PR, `github.sha` corresponde al commit de integración temporal, por eso los artefactos usan ese hash:

- [dist-55931caf…](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/36929878110/artifacts/11195093407), 8.260 bytes.
- [tests-55931caf…](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/36929878110/artifacts/11195118291), 1.752 bytes.

Ambos expiran el 08-10-2026, cumpliendo los 7 días. Los cambios posteriores en esta página generan una ejecución nueva; antes del merge comprobar siempre el run del último head.

El commit creado mediante la API devuelve `verification.reason=unsigned`; no se presenta como firmado. Antes de integrar con una regla de firma, preparar un commit firmado por el integrante real o utilizar el procedimiento de squash firmado permitido por GitHub y comprobar la firma resultante. No generar una identidad falsa del equipo ni cargar claves privadas en este flujo.

[PR #2 pendiente de revisión](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/pull/2). [Issue #3: protección y revisión](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/issues/3).

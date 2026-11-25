# Configuración de GitHub requerida por las sesiones 2 y 4

La revisión inicial del 01-10-2026 devolvió `main.protected=false`. Después se activó y verificó la [regla de main](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/settings/branch_protection_rules/84077806), con los requisitos siguientes. La revisión del adelanto corresponde a octubre. El PR #2 se integró y el PR #15 reúne el cierre de las trece sesiones.

## Regla de main

Settings → Rules → Rulesets o Branches → Add protection rule; objetivo `main`:

- Require a pull request before merging; mínimo 1 aprobación independiente.
- Dismiss stale approvals, require Code Owner review y conversation resolution.
- Require signed commits.
- Require status checks: nombres exactos `build-test` y `secrets-scan`; rama actualizada.
- Prohibir force pushes y deletions; sin bypass para administradores.

El archivo CODEOWNERS distribuye las rutas entre Miguel, Allen, Antonella y Daniel. La revisión de noviembre comprobó los nombres de las cuentas declaradas en el archivo. Cada integrante verifica su propio MFA. Si el autor es Miguel, su propia aprobación no sustituye la revisión independiente.

Para pipelines críticos, la política pide revisión adicional de seguridad y técnica. Dos owners en una línea CODEOWNERS no obligan a ambos a aprobar: exige uno de ellos. Controlar esa separación con reglas de revisión y procedimiento específico.

## Firmas y acceso

Cada integrante configura una clave GPG o SSH propia, registra la clave pública en GitHub, activa `commit.gpgsign` y verifica la insignia Verified. No compartir claves privadas. MFA es configuración de cuenta; en una organización se exige desde su administración.

## Evidencia a conservar

Enlace al PR, aprobador distinto del autor, SHA final, checks verdes, artefacto `dist-<SHA>`, estado de protección y firmas. Crear una política no acredita su cumplimiento. La protección se configuró y verificó desde Settings con acceso autorizado. MFA es configuración de cuenta y sigue pendiente de verificación para cada integrante. El [PR #2](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/pull/2) se integró. El [PR #15](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/pull/15) conserva la revisión de la entrega final.

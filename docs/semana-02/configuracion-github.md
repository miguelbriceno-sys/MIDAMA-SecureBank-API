# Configuración de GitHub requerida por las sesiones 2 y 4

La revisión inicial del 01-10-2026 devolvió `main.protected=false`. No confundir los archivos de política con reglas activas en GitHub.

## Regla de main

Settings → Rules → Rulesets o Branches → Add protection rule; objetivo `main`:

- Require a pull request before merging; mínimo 1 aprobación independiente.
- Dismiss stale approvals, require Code Owner review y conversation resolution.
- Require signed commits.
- Require status checks: nombres exactos `build-test` y `secrets-scan`; rama actualizada.
- Prohibir force pushes y deletions; sin bypass para administradores.

Agregar colaboradores reales con permisos de escritura y su MFA; confirmar las cuentas de Antonella, Allen y Daniel. El CODEOWNERS inicial usa únicamente la cuenta conocida de Miguel y debe ampliarse con los dueños verificados. Si el autor es Miguel, su propia aprobación no sustituye la revisión independiente.

Para pipelines críticos, la política pide revisión adicional de seguridad y técnica. Dos owners en una línea CODEOWNERS no obligan a ambos a aprobar: exige uno de ellos. Controlar esa separación con reglas de revisión y procedimiento específico.

## Firmas y acceso

Cada integrante configura una clave GPG o SSH propia, registra la clave pública en GitHub, activa `commit.gpgsign` y verifica la insignia Verified. No compartir claves privadas. MFA es configuración de cuenta; en una organización se exige desde su administración.

## Evidencia a conservar

Enlace al PR, aprobador distinto del autor, SHA final, checks verdes, artefacto `dist-<SHA>`, estado de protección y firmas. Crear una política no acredita su cumplimiento. El conector disponible permite archivos, commits y PR, pero no configurar protección ni MFA; estos pasos permanecen pendientes hasta validarlos en Settings.

# Sesión 2 · Git, repositorios y desarrollo seguro

**Entregable:** [POL-REPO-001](../../POL-REPO-001.md), documento breve para el desafío de 40 desarrolladores.

## Conceptos y flujo resuelto

Commit guarda un estado y su relación con commits anteriores; la firma es opcional en Git y debe activarse para cumplir la política. Branch es una referencia móvil a un commit. Merge integra historias. PR propone la integración y conserva revisión y checks. Un tag marca una versión, pero puede modificarse si no se protege. Release agrega notas y artefactos a una versión.

El flujo propuesto es `feature/* → develop → PR → main`, con hotfix mediante PR a `main` y reintegración posterior a `develop`. Para esta entrega inicial se propone directamente `feature/entregas-sesiones-1-4 → main`, porque el repositorio recibido solo tenía `main` y no se requiere inventar historia del equipo.

## Ejercicio: borrar un secreto no elimina la exposición

Un commit anterior sigue conservando el contenido del archivo eliminado. También puede existir en clones, forks, cachés, logs y artefactos. No se añadieron credenciales reales para resolver el ejercicio.

1. Revocar y rotar la credencial inmediatamente en su proveedor.
2. Determinar alcance, accesos, usos sospechosos y artefactos afectados.
3. Coordinar la limpieza con mantenedores y clonar una copia de trabajo específica.
4. Utilizar `git filter-repo --path config/.env --invert-paths` en esa copia, con plan de respaldo y publicación coordinada.
5. Rehacer clones afectados, revisar forks/cachés y escanear todo el historial.
6. Registrar el incidente sin copiar el valor del secreto y activar controles preventivos.

La reescritura cambia los SHAs y no revoca el secreto. No se ejecutó sobre este repositorio: no se encontró una filtración que la justificara.

## Laboratorio: estructura y controles

Se incorporan `src/`, `tests/`, `Dockerfile`, `.github/workflows/`, CODEOWNERS, plantilla de PR y `.gitignore`. Se usa Node.js 24 según la sesión 4; `requirements.txt` no aplica a esta implementación, pues no usa Python. El repositorio existente se conserva con su nombre y visibilidad pública; crear una organización UBO o cambiarlo a privado requiere decisión del equipo y acceso del docente.

[Configuración exacta de GitHub](configuracion-github.md) · [Estado verificable](../validacion.md).

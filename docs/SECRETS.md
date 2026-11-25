# Procedimiento de gestión y rotación de secretos

**MIDAMA · versión 1.0 · 25 de noviembre de 2026**

## 1. Inventario

| Credencial | Uso actual | Custodia |
|---|---|---|
| Clave HMAC de sesiones | Firma y verifica los JWT de SecureBank | En pruebas, bytes aleatorios por instancia. En producción la API exige JWT_SECRET de al menos 32 bytes. |
| GITHUB_TOKEN | Acceso temporal durante un job | GitHub Actions lo emite al comienzo y lo invalida al finalizar. |
| Credencial del proveedor cloud | Futuro plan y despliegue autorizado | Identidad federada OIDC de corta duración y rol por ambiente. |
| Credenciales bancarias de prueba | Registro de usuarios ficticios | La base guarda sal y hash scrypt. Las pruebas generan sus contraseñas al ejecutarse. |

## 2. Almacenamiento por ambiente

Cada desarrollador inyecta variables en su proceso local. Git excluye los archivos de entorno. CI usa el token efímero de GitHub. Para un ambiente persistente el custodio mantiene la clave bancaria en un gestor del entorno y la entrega al proceso como secreto. Un Secret de Kubernetes requiere protección del almacenamiento y RBAC. Los logs registran identidad de operación y fecha, con los valores de credenciales redactados.

## 3. Controles preventivos

Instalar Gitleaks 8.24.3 y activar el hook con `git config core.hooksPath .githooks`. El hook analiza el índice. En GitHub, el primer job revisa el historial con las reglas predeterminadas más el marcador de laboratorio. El binario se verifica por SHA-256. Un código distinto de cero impide construir y empaquetar la aplicación.

## 4. Rotación

| Tipo | Plazo y responsable | Verificación |
|---|---|---|
| Clave HMAC | Custodio del servicio, cada 90 días y de inmediato ante exposición | Inyectar una clave aleatoria nueva en todos los procesos, reiniciarlos coordinadamente y verificar que el token anterior se rechaza. En esta versión de clave única los clientes vuelven a iniciar sesión. |
| Token de CI | GitHub en cada job, mantenedor ante incidente | Cancelar la ejecución afectada, revisar los permisos y auditar las operaciones. |
| Rol cloud | Operaciones revisa la confianza cada trimestre y al cambiar el equipo | Comprobar emisor, audiencia, repositorio y entorno permitidos. Revocar sesiones si corresponde. |

## 5. Respuesta a una exposición

1. SecOps registra hora, tipo de credencial, alcance y primer commit afectado.
2. El dueño del servicio revoca en el proveedor. La meta de respuesta es 15 minutos.
3. Operaciones distribuye el reemplazo y comprueba disponibilidad y rechazo de la clave anterior.
4. El mantenedor coordina la limpieza del historial y de cachés, artefactos y copias accesibles. Reescribir un historial compartido requiere coordinación con quienes mantienen clones.
5. El lead informa a los afectados, revisa auditoría y registra el cierre. Borrar una línea de la rama actual deja intactas las copias históricas.

## 6. Evidencia

Gitleaks devolvió 1 ante el marcador inerte y 0 al analizar el historial revisado. La prueba negativa genera el valor en un directorio temporal. Su regla representa un dato de ensayo sin acceso a ningún servicio. La evidencia conserva el identificador de regla y la línea.

[Resultado de bloqueo](../reports/secrets/control-negativo.json) · [Historial analizado](../reports/secrets/historial.json) · [Ejecución negativa en GitHub](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/workflows/control-secretos.yml)

El [run de bloqueo](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45677827493) terminó en rojo por el marcador del laboratorio. La [captura de la ejecución](../reports/secrets/bloqueo-github.png) conserva la asociación con el commit. El workflow habitual se evalúa por separado.

### Ensayo de rotación en SQLite

Desde la raíz, ejecutar `node --test tests/rotation.test.js`. El ensayo registra un titular ficticio, emite un token y reinicia el servicio sobre la misma base con una clave nueva. El token anterior recibe 401. Un nuevo inicio de sesión recupera la cuenta original. La prueba genera ambas claves en memoria, elimina su base temporal al terminar y se ejecuta también en el job de pruebas. [Prueba de rotación](../tests/rotation.test.js).

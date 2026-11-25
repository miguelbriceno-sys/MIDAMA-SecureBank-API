# Sesión 11 · Auditoría de infraestructura

El profesor describió veinte recursos y no entregó el módulo SecureBank-Infra. A partir de esa consigna se modelaron los veinte recursos principales en Terraform, con bloques auxiliares para subred, permisos, registros y protección de buckets. El perfil de clase contiene 23 reglas de Checkov y produce 32 evaluaciones por la repetición de controles entre recursos. Las severidades corresponden a la política local publicada.

| Misma selección de controles | Aprobados | Fallidos | Críticos o altos abiertos | Security Score | Gate |
|---|---:|---:|---:|---:|---|
| Escenario inicial reconstruido | 18 | 14 | 13 | 56,25 % | Bloquear |
| Módulo corregido | 32 | 0 | 0 | 100 % | Continuar |

El puntaje subió **43,75 puntos porcentuales**. Se divide el número de controles aprobados por la suma de aprobados y fallidos. El gate exige al menos 85 %, cero casos graves y evidencia de cada regla del perfil. La línea base se genera en un directorio temporal con el mismo módulo. El escáner analiza texto antes de iniciar Terraform.

| Riesgo prioritario | Qué cambió | Control de Checkov |
|---|---|---|
| Administración SSH expuesta | La única entrada web permite HTTPS desde la red del laboratorio. La base acepta PostgreSQL desde el grupo de aplicación. | CKV_AWS_24 |
| Objetos y políticas públicas | Los dos buckets bloquean ACL y políticas públicas, ignoran ACL públicas y restringen acceso público. | CKV_AWS_53 a 56 |
| Base de datos sin cifrado | RDS usa una clave administrada por el cliente y subredes privadas. | CKV_AWS_16 |
| Auditoría incompleta | CloudTrail cubre todas las regiones y valida la integridad de los ficheros de log. | CKV_AWS_36 y 67 |
| Rol con acceso administrativo | La función puede registrar eventos en la tabla específica y escribir en su grupo de logs. | CKV_AWS_62 |

La guía asocia CKV_AWS_40 con comodines. La regla que detectó efectivamente esa política fue CKV_AWS_62. El informe conserva los identificadores devueltos por la versión instalada. Un 100 % se refiere a estas 32 evaluaciones. El flujo ejecuta además un plan con proveedor simulado. La aplicación real exige un entorno AWS aprobado, estado remoto y autorización desde main.

[Antes](../../reports/iac/before.json) · [Después](../../reports/iac/after.json) · [Score](../../reports/iac/score.json) · [Definición del perfil](../../terraform/profile.json) · [Informe técnico](informe-iac-MIDAMA.pdf) · [Presentación](sesion-11.pptx)

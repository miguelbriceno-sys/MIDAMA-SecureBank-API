# Comparación de imágenes · SecureBank

La referencia es el Dockerfile de la entrega de octubre, recuperado del commit `c8e48a8`. Ya declaraba el usuario `node`, una base slim y el puerto 3000. El material muestra una imagen de ejemplo con root y SSH. Usar esos valores como línea base habría exagerado el beneficio del cambio.

| Cambio aplicado | Relación con el riesgo y con las métricas |
|---|---|
| Dos etapas y base final distroless | npm y herramientas de construcción quedan en la primera etapa. El recuento de paquetes y el tamaño dependen de las capas finales. |
| Referencias versionadas y por digest para linux/amd64 | El constructor obtiene el contenido seleccionado para esa arquitectura. La base original de octubre conserva su tag mutable. |
| USER 10001:10001 | El runtime puede verificar el UID sin resolver un nombre. En ambas variantes el proceso es no privilegiado. |
| Contexto de construcción limitado | El Dockerfile copia el manifiesto, lockfile, dependencias de producción y fuente. El contexto excluye secretos, evidencia y herramientas locales. |
| Puerto 3000/tcp | Coincide con el servicio HTTP de Node. Las dos imágenes exponen el mismo puerto. |
| Dependencias por lockfile y runtime sin gestores de paquetes | El artefacto que se promueve conserva únicamente lo necesario para arrancar. |

## Medición reproducible

`docker/compare.sh` construye las dos versiones con Docker, lee el tamaño local sin comprimir, ejecuta Node para obtener el UID y revisa los puertos declarados. Trivy 0.76.2 registra tanto componentes del sistema como bibliotecas. Una alerta se cuenta por destino, paquete y CVE. La salida incluye el número de paquetes distintos inventariados. La tabla muestra diferencias absolutas y usa MiB para tamaño.

Los JSON nativos y el inventario están en el artefacto `imagenes-<SHA>` del workflow. La base de avisos cambia entre fechas. Un digest fija la versión y también impide recibir parches mientras el equipo no lo actualice. El mantenimiento consiste en proponer un digest nuevo, revisar el diferencial de componentes y repetir la medición antes de promover.

[Workflow de imágenes](../.github/workflows/imagenes.yml) · [Resultados en Actions](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/workflows/imagenes.yml)

## Resultados observados el 25 de noviembre de 2026

| Métrica | v1 | v2 endurecida | Cambio |
|---|---:|---:|---:|
| CVE altos y críticos | 45 | 3 | -42.00 |
| Tamaño local (MiB) | 77.82 | 52.94 | -24.88 |
| Paquetes inventariados | 235 | 15 | -220.00 |
| UID efectivo | 1000 | 10001 | Ambos sin privilegios |
| Puertos declarados | 3000/tcp | 3000/tcp | Misma interfaz |

La v1 registró un crítico y 44 altos. La v2 registró cero críticos y tres altos. Dos corresponden a libssl3t64 sin versión reparada indicada en este informe. Para libzstd1 el proveedor indica una revisión corregida. Operaciones debe incorporar la revisión al actualizar la base y repetir Trivy antes de autorizar una promoción productiva. La imagen académica se conserva por digest para reproducir la comparación.

[Salida completa v1](../reports/docker/v1.json.gz) · [Salida completa v2](../reports/docker/v2.json.gz) · [Mediciones](../reports/docker/comparacion.json) · [Ejecución verificada](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45677913889)

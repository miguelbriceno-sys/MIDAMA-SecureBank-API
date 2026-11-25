# Registro de la imagen firmada

La [ejecución 45688850036](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688850036) construyó la imagen de laboratorio para linux/amd64 y completó los controles, la firma, la verificación, el despliegue en Kind y el etiquetado v1. El digest utilizado en esta ejecución queda fijado en los tres Deployments de la entrega.

| Comprobación | Resultado observado | Archivo del runner |
|---|---|---|
| Identidad de la imagen | sha256:bc53427c67f3c20da8dbe46441ee156e04d83be8bb6c2138dcd90448c6db9f27 | [Referencia OCI](digest.txt) |
| Inventario publicado por Syft | CycloneDX 1.6, 1.295 componentes inventariados en la imagen | [SBOM](sbom.cdx.json) |
| Firma de la imagen | Cosign verificó el digest, la identidad del workflow y el emisor OIDC de GitHub. Índice Rekor 4110313908 | [Firma verificada](firma.json) · [Log de firma](firma.log) |
| Inventario firmado | El sujeto de la declaración coincide con el digest OCI y el contenido del predicado coincide con el SBOM publicado. Índice Rekor 4110315420 | [Sobre de la attestation](attestation.jsonl.gz) · [Log](attestation.log) |
| Admisión y disponibilidad | Políticas securebank-firma y securebank-inventario activas. La API, el frontend y el worker quedaron disponibles | [Políticas](politicas.txt) · [Pods](pods.txt) · [Salud](health.json) |
| Estado en ejecución | UID 10001, cero capacidades efectivas, secreto cifrado en etcd | [Identidad](identidad.txt) · [Cifrado](cifrado.txt) |

El inventario de la sesión 6 mide el proyecto npm. El inventario de esta sesión cubre la imagen publicada, incluido su sistema base. El sobre comprimido conserva la salida JSONL de la verificación para poder recuperar el predicado firmado. La [prueba de imagen sin firma](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688398403) registró el rechazo de Cosign. [Captura del bloqueo](bloqueo.png).

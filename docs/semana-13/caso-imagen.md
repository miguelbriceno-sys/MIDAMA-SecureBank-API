# Si cambia la imagen asociada a v1

En SecureBank la etiqueta v1 identifica la entrega de laboratorio. El registro puede volver a asociar esa etiqueta con otra imagen. Para determinar qué versión se instaló necesitamos el digest aprobado y la identidad de quien lo firmó.

El job de construcción publica el digest OCI del commit. Syft inventaría los componentes de la plataforma linux/amd64. Cosign firma ese digest y adjunta el inventario en una attestation. El verificador comprueba el emisor de GitHub, la identidad exacta del workflow y la coincidencia del digest con el sujeto de la attestation. Una firma válida de otra persona o proyecto no satisface esa política.

Si v1 cambia, Operaciones contrasta el digest actual con el que figura en el registro de la entrega. El clúster recibe la referencia aprobada por digest. El controlador de admisión exige las dos políticas del laboratorio, firma e inventario, antes de aceptar los pods. El control negativo usa un registro efímero con una imagen accesible que carece de firma. El fallo de verificación deja evidencia y detiene esa ruta.

Ante una discrepancia se detiene la promoción, se conserva el evento del registro, se revisan los permisos de escritura y se restaura el digest aprobado después de verificarlo. La firma acredita identidad e integridad. La evaluación de vulnerabilidades continúa con Trivy y la política de promoción.

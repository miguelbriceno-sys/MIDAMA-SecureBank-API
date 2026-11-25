# Sesión 13 · Cadena de suministro

La entrega vincula un commit revisable, una imagen OCI, un inventario CycloneDX y la identidad del workflow que firma en GitHub Actions. Los permisos para publicar paquetes y pedir identidad OIDC se conceden a los jobs que los necesitan. La construcción fija las bases y usa la fecha del commit para normalizar las marcas temporales. La identidad de laboratorio y el registro GHCR del equipo permiten una demostración sin instalar servicios en producción.

[Pipeline de construcción, firma y verificación](../../.github/workflows/supply-chain.yml) · [Rechazo controlado de imagen sin firma](../../.github/workflows/control-firma.yml) · [Análisis del caso](caso-imagen.md) · [Presentación](sesion-13.pptx)

La [prueba negativa de firma](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688398403) publicó una imagen en el registro efímero y verificó su digest. Cosign devolvió «no signatures found». El job conservó el código de rechazo y terminó en rojo. La [captura](../../reports/supply-chain/bloqueo.png) muestra el estado de ese workflow.

En la [ejecución completa](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688850036), el SBOM CycloneDX de Syft registró 1.295 componentes. La imagen y el inventario quedaron inscritos en Rekor con los índices 4110313908 y 4110315420. El controlador de admisión aplicó ambas políticas y los tres pods arrancaron con el digest verificado. La última etapa publicó la etiqueta v1. [Digest, firma, inventario y evidencia del clúster](../../reports/supply-chain/README.md).

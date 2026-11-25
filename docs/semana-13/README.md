# Sesión 13 · Cadena de suministro

La entrega vincula un commit revisable, una imagen OCI, un inventario CycloneDX y la identidad del workflow que firma en GitHub Actions. Los permisos para publicar paquetes y pedir identidad OIDC se conceden a los jobs que los necesitan. La construcción fija las bases y usa la fecha del commit para normalizar las marcas temporales. La identidad de laboratorio y el registro GHCR del equipo permiten una demostración sin instalar servicios en producción.

[Pipeline de construcción, firma y verificación](../../.github/workflows/supply-chain.yml) · [Rechazo controlado de imagen sin firma](../../.github/workflows/control-firma.yml) · [Análisis del caso](caso-imagen.md) · [Presentación](sesion-13.pptx)

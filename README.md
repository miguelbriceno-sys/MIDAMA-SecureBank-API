# SecureBank API · Bitácora DevSecOps de MIDAMA

[![Estado de integración continua](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/workflows/ci.yml/badge.svg)](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/workflows/ci.yml)

**Ingeniería Informática, Universidad Bernardo O’Higgins · Sistemas Automatizados DevSecOps · 2026**

Antonella Mancilla, Allen Ramírez, Daniel Silva y Miguel Briceño.

SecureBank es una API bancaria de laboratorio. Registra usuarios ficticios, autentica sesiones, permite consultar cuentas y movimientos y procesa transferencias en pesos enteros. La bitácora sigue los trece PPT en orden. Las cuatro primeras sesiones conservan el adelanto de octubre. A partir de la quinta, cada carpeta identifica el problema estudiado, la decisión técnica y la evidencia.

## Entregas por sesión

| Sesión | Trabajo resuelto | Entregable principal | Presentación del equipo |
|---|---|---|---|
| [01 · Ciclo seguro](docs/semana-01/README.md) | Ocho fases con herramientas y responsables, activos, amenazas y controles | [Diagrama de una página](docs/semana-01/ciclo-devsecops.pdf) | [PPT 01](docs/semana-01/sesion-01.pptx) |
| [02 · Git](docs/semana-02/README.md) | Aprobaciones, propiedad del código, accesos y excepciones | [Política del repositorio](POL-REPO-001.md) | [PPT 02](docs/semana-02/sesion-02.pptx) |
| [03 · STRIDE](docs/semana-03/README.md) | Doce amenazas, tres fronteras de confianza y doce historias de seguridad | [Modelo](docs/threat-model.md) · [DFD](docs/semana-03/securebank-dfd.drawio) · [Backlog](docs/semana-03/backlog.md) | [PPT 03](docs/semana-03/sesion-03.pptx) |
| [04 · Integración continua](docs/semana-04/README.md) | Build, pruebas y artefacto identificable por commit | [Primera ejecución revisada](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/36956801856) | [PPT 04](docs/semana-04/sesion-04.pptx) |
| [05 · SAST](docs/semana-05/README.md) | Revisión de cinco casos y corrección de la comparación de firmas de sesión | [SARIF inicial y final](reports/sast/) | [PPT 05](docs/semana-05/sesion-05.pptx) |
| [06 · SCA](docs/semana-06/README.md) | Inventario de dependencias npm y decisión por severidad | [SBOM](reports/securebank-sbom.cdx.json) · [Informe legible](reports/securebank-vulns.html) · [JSON](reports/securebank-vulns.json) | [PPT 06](docs/semana-06/sesion-06.pptx) |
| [07 · Secretos](docs/semana-07/README.md) | Escaneo anterior al commit, bloqueo de un marcador y respuesta a una fuga | [Procedimiento](docs/SECRETS.md) · [Evidencia](reports/secrets/) | [PPT 07](docs/semana-07/sesion-07.pptx) |
| [08 · DAST](docs/semana-08/README.md) | ZAP Baseline, dos correcciones, pruebas de propiedad del perfil y cierre | [Informe PDF](docs/semana-08/reporte-dast-MIDAMA.pdf) · [JSON adjunto](reports/dast/report.json) | [PPT 08](docs/semana-08/sesion-08.pptx) |
| [09 · Quality Gates](docs/semana-09/README.md) | Política Rego, diez pruebas y decisión sobre la promoción | [Política](policy/README.md) · [Decisión del runner](reports/gate/decision.json) | [PPT 09](docs/semana-09/sesion-09.pptx) |
| [10 · Docker](docs/semana-10/README.md) | Dos construcciones medidas con Trivy y ejecución sin privilegios | [Comparativo de imágenes](docker/REPORT.md) | [PPT 10](docs/semana-10/sesion-10.pptx) |
| [11 · Terraform](docs/semana-11/README.md) | Auditoría de veinte recursos principales y plan con proveedor simulado | [Informe PDF](docs/semana-11/informe-iac-MIDAMA.pdf) · [Checkov antes y después](reports/iac/) | [PPT 11](docs/semana-11/sesion-11.pptx) |
| [12 · Kubernetes](docs/semana-12/README.md) | Cinco manifiestos de laboratorio, permisos efectivos y cifrado de Secrets | [Deployment](k8s/hardened/deployment.hardened.yaml) · [Evidencia de Kind](reports/kubernetes/) | [PPT 12](docs/semana-12/sesion-12.pptx) |
| [13 · Cadena de suministro](docs/semana-13/README.md) | Imagen por digest, SBOM, firma, verificación y control de admisión | [Pipeline](.github/workflows/supply-chain.yml) · [Análisis del caso](docs/semana-13/caso-imagen.md) · [Evidencias](reports/supply-chain/) | [PPT 13](docs/semana-13/sesion-13.pptx) |

Las presentaciones de referencia de la asignatura están disponibles por separado. El índice de material identifica las láminas adaptadas en los casos de seguridad. [PPT del ramo, sesiones 1 a 13](material/README.md).

## Origen del caso y alcance

El repositorio inicial de octubre y el material del curso sirvieron de base. El equipo trabajó sobre la implementación Node.js ya disponible. La rama docente con cinco defectos y el módulo SecureBank-Infra no se distribuyeron con los PPT. La sesión 5 documenta qué se encontró en el código del equipo. La 11 contrasta una línea base reconstruida con el módulo corregido bajo el mismo perfil de auditoría.

El laboratorio usa Node.js 24 y SQLite integrada. La API emite tokens de sesión por quince minutos, valida el propietario de la cuenta antes de efectuar un débito y registra cada denegación. La imagen y el clúster de prueba corresponden a linux/amd64. Para la demostración se usa un clúster efímero Kind y un registro OCI de laboratorio. El plan de AWS utiliza el proveedor simulado de Terraform.

## Ejecutar la API y las pruebas

Desde la raíz del repositorio, con Node.js 24 instalado:

```sh
npm ci --ignore-scripts
npm run build
npm test
npm start
```

La aplicación escucha en `http://127.0.0.1:3000`. La ruta `GET /health` devuelve `{"status":"ok"}`. La base usa memoria salvo que se indique `DB_PATH`. La ejecución en modo producción exige una clave `JWT_SECRET` de al menos 32 bytes inyectada por el entorno.

| Método y ruta | Propósito | Identidad |
|---|---|---|
| GET /health | Disponibilidad del proceso | Pública |
| POST /users y POST /login | Registro y emisión de sesión | Pública, con límites |
| GET /users/{id} | Perfil mínimo | Titular autenticado |
| GET /accounts y GET /accounts/{id} | Cuentas y saldo | Titular autenticado |
| GET /accounts/{id}/movements | Historial de movimientos | Titular autenticado |
| POST /transfer | Débito y crédito atómicos | Titular de la cuenta de origen |

## Evidencia y revisión

Las bitácoras incluyen enlaces a ejecuciones concretas. Los reportes seleccionados quedan versionados para poder consultarlos después de que caduquen los artefactos de GitHub. Los ejercicios negativos de secretos, infraestructura e imagen sin firma tienen ejecuciones rojas previstas y su motivo se explica en la sesión correspondiente. El PR de entrega se evalúa con los controles regulares.

La sesión 2 pide un repositorio privado en la organización UBO-DevSecOps. Este repositorio personal es público. El equipo debe confirmar con el docente la modalidad de entrega, y cada integrante comprueba su segundo factor. La revisión independiente forma parte del flujo de integración a main. [Historial del adelanto](docs/validacion.md).

El [PR de entrega con el historial por sesión](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/pull/15) reúne las correcciones y su revisión. El aula virtual recibe el PDF y el JSON de la sesión 8. Las guías de las sesiones 7 y 8 piden parejas y grupos de dos a tres, respectivamente. En las sesiones 11 y 12 el ejercicio es individual. El equipo debe identificar a quienes corresponda cuando el aula solicite nombres.

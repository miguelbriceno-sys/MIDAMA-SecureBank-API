# MIDAMA · SecureBank API

[![CI v1.0](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/workflows/ci.yml/badge.svg)](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/workflows/ci.yml)

Proyecto académico de **Ingeniería Informática, Universidad Bernardo O’Higgins**, asignatura **Sistemas Automatizados DevSecOps**, 2026.

**Equipo MIDAMA:** Antonella Mancilla, Allen Ramirez, Daniel Silva y Miguel Briceño. aaaaaaaaaaaaaaaaaaaa

## Entregas por sesión

| Sesión | Actividad resuelta | Documento |
|---|---|---|
| 1 | Ciclo de ocho fases, controles, herramientas, roles; ejercicio de activos y discusión | [Semana 01](docs/semana-01/README.md) |
| 2 | Política para fintech de 40 desarrolladores, Git seguro y secreto en el historial | [POL-REPO-001](POL-REPO-001.md) · [Semana 02](docs/semana-02/README.md) |
| 3 | DFD con tres fronteras, 12 amenazas STRIDE y 12 historias de seguridad | [Threat Model](docs/threat-model.md) · [DFD editable](docs/semana-03/securebank-dfd.drawio) · [Backlog](docs/semana-03/backlog.md) |
| 4 | CI v1.0, pruebas, artefacto y análisis de cuatro riesgos de pipeline | [Semana 04](docs/semana-04/README.md) · [Workflow](.github/workflows/ci.yml) |

## Alcance y decisiones

El repositorio original solo contenía documentación y el diagrama de la sesión 1. No se recibió el código de la API vulnerable del docente ni una pauta individual de correcciones. Esta implementación es una **base académica construida por MIDAMA a partir de los PPT**, con usuarios y fondos ficticios. Los ejemplos vulnerables del material se analizan como escenarios, sin atribuir hallazgos a un código inexistente.

Se utiliza **Node.js 24 y SQLite integrada**, sin dependencias npm externas. La sesión 2 muestra una estructura Python y la sesión 4 una implementación Node; se adopta Node para contar con `package.json`, lockfile, build, tests y `dist/` reales. `npm run build` valida sintaxis y empaqueta JavaScript, que no necesita transpilación. El despliegue cloud y la interfaz web del DFD son arquitectura propuesta, no componentes ya desplegados.

## Ejecutar desde VS Code o terminal

Requisito: Node.js 24.x y Git.

```bash
git clone https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API.git
cd MIDAMA-SecureBank-API
npm ci --ignore-scripts
npm run build
npm test
npm start
```

En desarrollo escucha en `http://127.0.0.1:3000`; `GET /health` responde `{ "status": "ok" }`. SQLite usa memoria por defecto: los usuarios, saldos y movimientos desaparecen al reiniciar. Para persistencia local puede configurarse `DB_PATH` hacia un archivo fuera del repositorio. La clave JWT se genera aleatoriamente al iniciar si no se suministra una; los tokens duran 15 minutos y quedan invalidados tras ese reinicio. `NODE_ENV=production` exige `JWT_SECRET` externo de al menos 32 bytes.

| Método y ruta | Acceso y resultado |
|---|---|
| GET /health | Público, estado del proceso |
| POST /users | Público, `{username,password}`; cuenta nueva con saldo cero; rechaza rol enviado por el cliente |
| POST /login | Público, credenciales; devuelve JWT firmado y duración |
| GET /accounts | Bearer JWT, solo cuentas del usuario |
| GET /accounts/{id} | Bearer JWT, verifica propietario; 403 para acceso ajeno |
| GET /accounts/{id}/movements | Bearer JWT y propiedad; últimos 100 movimientos |
| POST /transfer | Bearer JWT, `{originAccount,targetAccount,amount}`; propietario de origen, saldo suficiente y transacción atómica |

`amount` es un entero en pesos chilenos ficticios, de 1 a 1.000.000. No hay endpoint de carga de fondos: las pruebas usan un fixture interno. Los datos personales reales no forman parte del laboratorio.

## CI y controles

Cada push a cualquier rama y cada PR a `main` ejecuta checkout, `npm ci`, build, pruebas con cobertura y publicación de `dist-<SHA>`. El artefacto se conserva 7 días; el reporte JUnit y cobertura quedan como evidencia. Un segundo job ejecuta Gitleaks sobre el historial. Los jobs tienen permisos mínimos y las acciones están fijadas por SHA. No hay despliegue automático.

Consultar [validación y pendientes](docs/validacion.md) para distinguir controles implementados, propuestos y configuración administrativa pendiente. Una política escrita o un archivo CODEOWNERS no activa por sí solo protección de ramas.

## Docker

```bash
docker build -t midama-securebank:local .
```

El contenedor usa `USER node`; para ejecutarlo, inyectar `JWT_SECRET` desde un archivo local de entorno excluido de Git (`docker run --env-file ruta-local -p 127.0.0.1:3000:3000 midama-securebank:local`). No incluir secretos en comandos versionados, imágenes ni documentación. El Dockerfile usa una etiqueta de Node 24: fijar el digest aprobado y escanear la imagen corresponde al endurecimiento posterior. La construcción Docker aún debe validarse en un entorno con Docker.

## Límites del laboratorio

Esta base no está preparada para un banco real: faltan MFA, gestor central de secretos, TLS mediante gateway, auditoría externa inmutable, idempotencia de transferencias, monitoreo, respaldos, pruebas de carga, SAST/SCA/DAST completos y despliegue cloud. Los controles futuros se identifican en el backlog. La auditoría encadenada detecta alteraciones verificables por comparación, pero no equivale a almacenamiento WORM ni prueba legal de no repudio.

## Fuentes

Material del curso: sesiones 1 a 4 adjuntas. Referencias técnicas: [Node.js SQLite](https://nodejs.org/docs/latest-v24.x/api/sqlite.html), [GitHub CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners), [protección de ramas](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches), [STRIDE](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats).

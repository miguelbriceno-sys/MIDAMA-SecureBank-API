# MIDAMA - SecureBank API

Proyecto académico desarrollado para la asignatura **Sistemas Automatizados - DevSecOps**.

El objetivo del proyecto es trabajar durante el semestre sobre una aplicación real y deliberadamente vulnerable, **SecureBank API**, incorporando progresivamente controles de seguridad hasta construir una plataforma DevSecOps completa y automatizada.

## Equipo

- Daniel Silva
- Antonella Mancilla
- Allen Ramirez
- Miguel Briceño

## Proyecto

SecureBank API simula un backend bancario con funcionalidades como:

- Autenticación de usuarios.
- Consulta de cuentas.
- Transferencias de dinero.
- Creación de usuarios.
- Consulta de movimientos.
- Uso de contenedores Docker.
- Despliegue automatizado.
- Pipeline CI/CD.

## Objetivo DevSecOps

Integrar seguridad durante todo el ciclo de vida del desarrollo de software, aplicando principios como:

- Security as Code.
- Shift Left Security.
- Shift Right Security.
- Continuous Security.
- Security Automation.
- Shared Responsibility.
- Continuous Feedback.

## Vulnerabilidades iniciales

SecureBank API contiene vulnerabilidades deliberadas que serán abordadas progresivamente durante el semestre:

1. Credenciales almacenadas directamente en el código.
2. Dependencias vulnerables.
3. SQL Injection.
4. Autorización insuficiente.
5. Contenedor ejecutándose como usuario root.
6. Gestión insegura de secretos.
7. Configuraciones cloud deficientes.
8. Ausencia de monitoreo y trazabilidad.
9. Pipeline CI/CD sin controles de seguridad.

## Ciclo DevSecOps propuesto

El proyecto considera las siguientes fases:

1. Plan
2. Code
3. Build
4. Test
5. Release
6. Deploy
7. Operate
8. Monitor

Cada fase incorpora controles de seguridad, herramientas automatizadas y responsables definidos.

## Entregables

### Semana 01 - Ciclo DevSecOps

Se desarrolló el ciclo DevSecOps propuesto para SecureBank API.

Incluye:

- Las 8 fases del Secure SDLC.
- Controles de seguridad por fase.
- Herramientas propuestas.
- Roles responsables.
- Diagrama del ciclo DevSecOps.
- Documentación de la actividad.

Archivos:

- `docs/semana-01/README.md`
- `docs/semana-01/ciclo-devsecops.pdf`
- `docs/semana-01/ciclo-devsecops.png`

### Semana 02

Pendiente de incorporación.

### Semana 03

Pendiente de incorporación.

## Estructura del repositorio

```text
MIDAMA-SecureBank-API/
│
├── docs/
│   └── semana-01/
│       ├── README.md
│       ├── ciclo-devsecops.pdf
│       └── ciclo-devsecops.png
│
└── README.md

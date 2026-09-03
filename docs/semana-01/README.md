# Semana 01 - Ciclo DevSecOps

## Proyecto
SecureBank API

## Objetivo

Diseñar un ciclo DevSecOps aplicable a SecureBank API, integrando controles de seguridad durante todo el ciclo de vida del desarrollo de software.

## Ciclo DevSecOps propuesto

El ciclo considera las siguientes fases:

1. Plan
2. Code
3. Build
4. Test
5. Release
6. Deploy
7. Operate
8. Monitor

## Controles propuestos por fase

| Fase | Control de seguridad | Herramienta | Responsable |
|---|---|---|---|
| Plan | Modelado de amenazas y requisitos de seguridad | OWASP Threat Dragon | Arquitecto / Product Owner |
| Code | SAST y detección de secretos | Semgrep / Gitleaks | Desarrollador |
| Build | Análisis de dependencias e imágenes | Trivy | Dev / DevOps |
| Test | DAST y pruebas de autorización | OWASP ZAP | QA / Security |
| Release | SBOM y firma de artefactos | Syft / Cosign | DevOps |
| Deploy | Escaneo IaC y políticas de seguridad | Checkov | DevOps / Cloud |
| Operate | Gestión de secretos y hardening | Vault | Operations / SRE |
| Monitor | Logging, SIEM, telemetría y alertas | Wazuh / Grafana | SOC / SRE |

## Principios DevSecOps considerados

- Security as Code
- Shift Left Security
- Shift Right Security
- Continuous Security
- Security Automation
- Shared Responsibility
- Continuous Feedback

## Entregable

El entregable de esta semana corresponde a un diagrama de una página del ciclo DevSecOps propuesto para SecureBank API.

El diagrama debe incluir:

- Las 8 fases del ciclo.
- Al menos un control de seguridad por fase.
- Una herramienta por fase.
- El rol responsable de cada control.

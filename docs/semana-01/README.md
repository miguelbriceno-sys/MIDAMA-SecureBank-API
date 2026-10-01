# Sesión 1 · Introducción a DevSecOps

**MIDAMA:** Antonella Mancilla, Allen Ramirez, Daniel Silva y Miguel Briceño. Ingeniería Informática, UBO. Revisión: 01-10-2026.

## Entregable original conservado

[Diagrama PDF de una página](ciclo-devsecops.pdf) · [Imagen del ciclo](ciclo-devsecops.png).

El diagrama original contiene las ocho fases, una o más herramientas por fase y los roles de control requeridos. Los controles del gráfico son una propuesta para el semestre, no evidencia de instalación de esas herramientas.

| Fase | Control propuesto | Herramienta | Rol / integrante propuesto |
|---|---|---|---|
| Plan | Modelar amenazas y requisitos | OWASP Threat Dragon | Arquitectura: Antonella |
| Code | SAST y detección de secretos | Semgrep / Gitleaks | Desarrollo: Daniel |
| Build | SCA y análisis de imágenes | Trivy | DevOps: Allen |
| Test | DAST y pruebas de autorización | OWASP ZAP / node:test | QA y seguridad: Miguel |
| Release | SBOM, firma y aprobación | Syft / Cosign | Release: Miguel |
| Deploy | IaC scan y políticas | Checkov | Operaciones: Allen |
| Operate | Secretos y hardening | Vault | Operaciones y seguridad: Allen / Antonella |
| Monitor | Logs, alertas y feedback | Wazuh / Grafana | Monitoreo: Miguel |

Los integrantes son una distribución de trabajo propuesta para el laboratorio. Todos colaboran y un autor no aprueba su propio cambio.

## Ejercicio: al menos cinco elementos de cada categoría

| Activo | Amenaza | Vulnerabilidad del escenario | Control y fase |
|---|---|---|---|
| Credenciales y sesiones | Suplantación mediante credenciales filtradas | Contraseñas reutilizadas y ausencia de MFA | Hash robusto, MFA, rate limiting; Code / Operate |
| Saldos y transferencias | Cliente debita una cuenta ajena | Falta de autorización por objeto (BOLA) | Comparar identidad y dueño; pruebas 403; Code / Test |
| Datos de clientes y BD | Atacante lee o altera registros por SQLi | SQL construido por concatenación | Consultas parametrizadas y SAST; Code / Test |
| Servidor API y contenedor | Atacante explota proceso con privilegios | Contenedor root, puertos innecesarios | Usuario no root y segmentación; Build / Deploy |
| Secretos y artefactos del CI | Colaborador o PR malicioso extrae claves | Secretos en Git y permisos amplios | Gestor de secretos, Gitleaks y mínimo privilegio; Code / Release |
| Movimientos y reputación | Usuario niega una operación o borra evidencia | Ausencia de auditoría íntegra y alertas | Logs externos protegidos, correlación y alertas; Operate / Monitor |

Las vulnerabilidades describen la aplicación del PPT; el repositorio recibido no contenía código para demostrar esos nueve defectos.

## Discusión: plataforma de pagos revisada una semana antes de producción

Una revisión tardía concentra reparaciones en el momento más caro: modificar el diseño obliga a repetir pruebas y puede retrasar el lanzamiento. Encontrar un fallo crítico exige detener la salida y no aceptar el riesgo solo para cumplir una fecha. Los multiplicadores de costo del PPT son ilustrativos, no mediciones de MIDAMA.

Introducir requisitos de seguridad y modelado en Plan; análisis estático y secretos en Code; dependencias e imágenes en Build; autorización y DAST en Test. Release exige evidencia y aprobaciones. Deploy valida infraestructura y permisos. Operate mantiene secretos, parches y respaldos. Monitor detecta abuso y genera nuevos tickets.

La responsabilidad se distribuye entre desarrollo, QA, operaciones y seguridad. El pipeline conserva resultados, pero no acredita por sí mismo cumplimiento regulatorio: hacen falta alcance, controles organizacionales y revisión del marco aplicable. La seguridad automatizada reduce riesgo, sin garantizar ausencia total de vulnerabilidades.

## Correcciones de documentación

Se completó el ejercicio omitido, se explicitaron los responsables y se cerró correctamente el bloque de estructura que estaba abierto en el README anterior. La portada del proyecto y el índice de sesiones ahora se encuentran en el README de la raíz.

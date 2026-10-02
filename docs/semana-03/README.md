# Sesión 3 · Threat Modeling y requisitos

Entregables: [Threat Model: 12 amenazas](../threat-model.md), [DFD editable](securebank-dfd.drawio) y [12 historias de seguridad priorizadas](backlog.md).

El DFD presenta usuario, frontend/gateway, API, autenticación, base de datos y auditoría. Marca TB1, TB2 y TB3, identifica F1–F5 y añade el contexto de CI mediante F6 en el modelo. La implementación de laboratorio concentra varios procesos; la arquitectura privada y gateway son un objetivo posterior.

Se resuelve el caso BOLA de `POST /transfer` con identidad validada y comprobación de propiedad del origen. El backlog cubre cada amenaza y cada función bancaria principal. Fecha de próxima revisión: 01-11-2026, o antes de un cambio de arquitectura.

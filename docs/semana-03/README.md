# Sesión 3 · Threat Modeling y requisitos

Entregables: [Threat Model: 12 amenazas](../threat-model.md), [DFD editable](securebank-dfd.drawio) y [12 historias de seguridad priorizadas](backlog.md).

El DFD presenta usuario, frontend/gateway, API, autenticación, base de datos y auditoría. Marca TB1, TB2 y TB3, identifica F1–F5 y añade el contexto de CI mediante F6 en el modelo. La implementación de laboratorio concentra varios procesos; la arquitectura privada y gateway son un objetivo posterior.

Se resuelve el caso BOLA de `POST /transfer` con identidad validada y comprobación de propiedad del origen. El backlog cubre cada amenaza y cada función bancaria principal. Fecha de próxima revisión: 01-11-2026, o antes de un cambio de arquitectura.

## Revisión del adelanto

La revisión del 25 de noviembre mantiene las doce historias del adelanto. El acceso a cuentas y la autorización de transferencias se verifican en [las pruebas de dominio](../../tests/bank.test.js). Para los siguientes controles se incorporan el registro de imágenes, la identidad del runner y el clúster como fronteras adicionales. Revisar nuevamente antes de promover la primera imagen firmada y, como máximo, el 25 de diciembre de 2026.

[Presentación de la sesión 3](sesion-03.pptx)

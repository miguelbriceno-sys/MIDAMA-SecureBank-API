# Backlog · Historias de seguridad

**MIDAMA · 01-10-2026.** Responsables propuestos; no representan aprobación ni trabajo previo atribuido a cada integrante. P1 primero (fondos, identidad, secretos), P2 después (resiliencia y evidencias); todos los controles son necesarios antes de producción.

## Relación con historias funcionales

| Historia funcional | Historias de seguridad |
|---|---|
| HF01 Crear usuario | SS01, SS11 |
| HF02 Iniciar sesión | SS01, SS02, SS08 |
| HF03 Consultar cuentas | SS04, SS06 |
| HF04 Transferir fondos | SS03, SS05, SS09, SS10 |
| HF05 Consultar movimientos | SS06, SS12 |
| HF06 Construir y publicar artefacto | SS07 |

## SS01 · Credenciales filtradas

**Amenaza:** T01 · **Prioridad:** P1 · **Responsable propuesto:** Antonella.

Como cliente quiero impedir que credenciales robadas permitan usar mi cuenta.

**Criterio de aceptación:** Contraseña errónea devuelve 401; exceso de solicitudes 429; MFA rechaza el acceso sin segundo factor al implementarse.

**Estado:** Parcial: pruebas login/rate limit; MFA pendiente.

## SS02 · JWT falsificado

**Amenaza:** T02 · **Prioridad:** P1 · **Responsable propuesto:** Daniel.

Como cliente quiero que solo tokens auténticos y vigentes habiliten mis operaciones.

**Criterio de aceptación:** Token alterado, alg none o expirado devuelve 401 sin efecto financiero.

**Estado:** Implementado: pruebas JWT.

## SS03 · Monto alterado en tránsito

**Amenaza:** T03 · **Prioridad:** P2 · **Responsable propuesto:** Allen.

Como cliente quiero que el monto autorizado se procese sin alteración.

**Criterio de aceptación:** Monto negativo, decimal o superior al límite devuelve 400; gateway rechaza HTTP externo cuando exista.

**Estado:** Parcial: validación probada; TLS pendiente.

## SS04 · SQL Injection

**Amenaza:** T04 · **Prioridad:** P1 · **Responsable propuesto:** Daniel.

Como responsable de datos quiero que las entradas nunca cambien la estructura SQL.

**Criterio de aceptación:** Payload de inyección en login devuelve 401; ID malicioso no revela cuentas ni modifica tablas.

**Estado:** Implementado: prueba SQLi; SAST pendiente.

## SS05 · Repudio de transferencia

**Amenaza:** T05 · **Prioridad:** P2 · **Responsable propuesto:** Miguel.

Como auditor quiero reconstruir una operación sin poder alterar sus evidencias.

**Criterio de aceptación:** Transferencia genera evento correlacionable y almacén externo impide borrado por la API al implementarse.

**Estado:** Parcial: hash encadenado; persistencia/WORM pendiente.

## SS06 · Lectura de cuenta ajena / IDOR

**Amenaza:** T06 · **Prioridad:** P1 · **Responsable propuesto:** Daniel.

Como cliente quiero que mis saldos y movimientos sean accesibles solo por mí.

**Criterio de aceptación:** Cuenta o movimientos ajenos devuelve 403; listado solo contiene cuentas del usuario.

**Estado:** Implementado: pruebas BOLA de lectura.

## SS07 · Secretos en historial Git

**Amenaza:** T07 · **Prioridad:** P1 · **Responsable propuesto:** Antonella.

Como custodio quiero detectar y revocar claves expuestas antes de usarlas en un release.

**Criterio de aceptación:** Escaneo del historial falla ante credencial real detectada; incidente exige evidencia de revocación sin publicar el valor.

**Estado:** Parcial: job CI; vault administrado pendiente.

## SS08 · Fuerza bruta y saturación

**Amenaza:** T08 · **Prioridad:** P2 · **Responsable propuesto:** Allen.

Como operador quiero mantener la API disponible ante intentos repetidos.

**Criterio de aceptación:** En laboratorio, superar 60 solicitudes/minuto por IP devuelve 429 y Retry-After.

**Estado:** Parcial: probado; cuotas distribuidas pendientes.

## SS09 · Payload masivo

**Amenaza:** T09 · **Prioridad:** P2 · **Responsable propuesto:** Allen.

Como operador quiero rechazar cargas que excedan el presupuesto del servicio.

**Criterio de aceptación:** POST con más de 16 KiB devuelve 413; tipo distinto de JSON devuelve 415.

**Estado:** Implementado: pruebas HTTP; carga pendiente.

## SS10 · BOLA de transferencia

**Amenaza:** T10 · **Prioridad:** P1 · **Responsable propuesto:** Daniel.

Como titular quiero que nadie pueda debitar mi cuenta aunque conozca su identificador.

**Criterio de aceptación:** Usuario B usa origen de A: 403, evento denied y ningún cambio en saldos ni movimientos.

**Estado:** Implementado: pruebas unitarias y HTTP.

## SS11 · Escalada a admin

**Amenaza:** T11 · **Prioridad:** P1 · **Responsable propuesto:** Antonella.

Como responsable de seguridad quiero que un cliente no pueda autoconcederse privilegios.

**Criterio de aceptación:** Registro con role admin devuelve 400; claim alterado devuelve 401.

**Estado:** Implementado: pruebas de rol; RBAC administrativo futuro.

## SS12 · Datos sensibles en logs

**Amenaza:** T12 · **Prioridad:** P2 · **Responsable propuesto:** Miguel.

Como cliente quiero trazabilidad sin que mis credenciales aparezcan en registros.

**Criterio de aceptación:** Pruebas verifican que auditoría no contiene contraseña ni token; colector externo limita lectura y retención.

**Estado:** Parcial: minimización probada; retención externa pendiente.

## Seguimiento en GitHub Issues

| Historia / pendiente | Issue |
|---|---|
| Protección de main y revisión independiente | [#3](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/issues/3) |
| SS01: MFA | [#4](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/issues/4) |
| SS03: TLS y gateway | [#5](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/issues/5) |
| SS05/SS12: auditoría externa | [#6](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/issues/6) |
| SS07: secretos y rotación | [#7](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/issues/7) |

Las historias restantes conservan sus criterios y estado en este documento. No se marcaron como terminadas las partes que requieren infraestructura externa.

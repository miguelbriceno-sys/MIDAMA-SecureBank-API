# Sesión 5 · Análisis estático

La línea base es el código Node.js del adelanto, identificado por `c8e48a8`. Semgrep 1.145.0 examinó los dos archivos de `src/` con el paquete OWASP Top Ten y una regla del equipo para la firma de sesión. Ambos escaneos usaron la misma copia del paquete. Antes de la corrección hubo una alerta de severidad ERROR, clasificada como alta por el proyecto. Después hubo cero. Los SARIF versionados conservan todos los resultados y sus ubicaciones. Se omitieron las definiciones de reglas sin coincidencias para facilitar la revisión.

| Caso pedido por el PPT | Categoría y severidad de la consigna | Qué encontramos en MIDAMA y control |
|---|---|---|
| Consulta del login | A03, crítica | El login utiliza una sentencia SQLite con parámetro enlazado. El texto del usuario llega al motor como dato. |
| Exportador de informes | A03, crítica | La API carece de exportador. El build usa `execFileSync` con argumentos separados y un ejecutable conocido. |
| Bienvenida HTML | A03, alta | La API devuelve JSON. Una futura vista HTML debe codificar la salida según su contexto. |
| Contraseñas con MD5 | A02, alta | El registro usa scrypt con sal aleatoria por usuario y el login compara el resultado en tiempo constante. |
| Cálculo mediante eval | A03, crítica | La API valida montos enteros y calcula con aritmética. No hay intérprete de expresiones. |

La rama didáctica con los cinco defectos no formaba parte de la entrega. Los cinco renglones explican la evaluación del código disponible. El hallazgo efectivamente medido fue adicional. El verificador decodificaba el segmento final del JWT con una conversión permisiva. La corrección compara los bytes de la representación base64url canónica de la firma. La prueba de regresión exige un 401 ante una representación distinta y las pruebas existentes siguen aceptando el token emitido por el banco. El cambio protege la unicidad de la representación y no implica que una persona pudiera firmar tokens sin conocer la clave.

El job `sast` corre después de las pruebas y antes de publicar `dist`. Los informes quedan como artefactos del mismo SHA. Un error del analizador o un resultado alto detienen la entrega.

[Antes](../../reports/sast/sast-before.sarif) · [Después](../../reports/sast/sast-after.sarif) · [Código corregido](../../src/bank.js) · [CI de la entrega](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/pull/15/checks) · [Presentación](sesion-05.pptx)

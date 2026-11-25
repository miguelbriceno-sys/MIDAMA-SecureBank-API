# Sesión 12 · Seguridad de Kubernetes

Se modelaron los cinco ejercicios sobre la API de MIDAMA y su imagen de laboratorio publicada por digest. El frontend ofrece una página de estado. El worker consulta salud y registra disponibilidad. Ambos usan el mismo runtime que la API. La réplica bancaria utiliza SQLite en un volumen temporal, por lo que se prueba con una sola instancia y datos descartables.

| Manifiesto del ejercicio | Corrección específica | Evidencia esperada |
|---|---|---|
| M1 · Frontend | Imagen por digest, proceso sin privilegios, raíz de solo lectura y puerto 8080. | Deployment disponible y respuesta de readiness. |
| M2 · API | UID y GID 10001, seccomp RuntimeDefault, capacidades descartadas, sin escalada. La escritura se limita a los volúmenes de datos y temporales. | El proceso informa UID 10001, CapEff=0 y salud correcta. |
| M3 · Secret | El manifiesto declara el recurso sin valores. La credencial de laboratorio se genera al desplegar; la API la recibe por secretKeyRef. | El laboratorio verifica en etcd el prefijo de cifrado sin imprimir el secreto. |
| M4 · Worker | Solicitudes y límites de CPU y memoria; sin token de Kubernetes ni escritura en la raíz. | Pod disponible y escaneo de su manifiesto. |
| M5 · ServiceAccount | Identidad propia sin RoleBinding ni cluster-admin. La descarga del registro y el acceso a la API de Kubernetes usan mecanismos separados. | Sin token de cuenta de servicio montado. |

El clúster Kind usa cifrado de Secrets en reposo y el perfil Pod Security restricted. La regla del pod y los límites de recursos ocupan campos distintos en la API de Kubernetes. El script crea el entorno, instala la configuración, espera los tres rollouts, comprueba permisos y consulta salud. El clúster se elimina al finalizar. La identidad de lectura del registro se usa para descargar la imagen desde GHCR.

[Deployment evaluado](../../k8s/hardened/deployment.hardened.yaml) · [Cinco manifiestos y configuración](../../k8s/hardened/) · [Prueba de runtime](../../k8s/kind-test.sh) · [Presentación](sesion-12.pptx)

En el [run de Kind](https://github.com/miguelbriceno-sys/MIDAMA-SecureBank-API/actions/runs/45688292394), los tres pods alcanzaron el estado Ready. El proceso de la API informó UID 10001, cero capacidades efectivas y ausencia de token de ServiceAccount. El endpoint respondió con estado ok y la comprobación de etcd confirmó que el valor estaba cifrado.

[Pods](../../reports/kubernetes/pods.txt) · [Permisos efectivos](../../reports/kubernetes/identidad.txt) · [Cifrado](../../reports/kubernetes/cifrado.txt) · [Resultados de Kubesec](../../reports/kubernetes/)

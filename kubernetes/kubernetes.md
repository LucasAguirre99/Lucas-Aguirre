# Kubernetes - Referencia completa

## Contextos y configuracion

```bash
# Ver contextos disponibles
kubectl config get-contexts

# Cambiar contexto
kubectl config use-context <nombre>

# Ver contexto actual
kubectl config current-context

# Ver configuracion completa
kubectl config view

# Cambiar namespace por defecto en el contexto
kubectl config set-context --current --namespace=<namespace>
```

---

## Informacion y listado

```bash
# Listar recursos
kubectl get pods -n <namespace>
kubectl get deployments -n <namespace>
kubectl get services -n <namespace>
kubectl get nodes
kubectl get all -n <namespace>
kubectl get pvc -n <namespace>
kubectl get ingress -n <namespace>
kubectl get configmap -n <namespace>
kubectl get secret -n <namespace>
kubectl get hpa -n <namespace>

# Con mas detalle
kubectl get pods -n <namespace> -o wide       # ver IP y nodo
kubectl get pods -n <namespace> -o yaml       # output YAML completo
kubectl get pods -n <namespace> --watch        # modo watch

# Describir un recurso (muy util para troubleshooting)
kubectl describe pod <pod> -n <namespace>
kubectl describe node <nodo>
kubectl describe deployment <deploy> -n <namespace>

# Explicar la estructura de un recurso
kubectl explain pod.spec.containers
kubectl explain deployment.spec
```

---

## Pods

```bash
# Conectarse a un pod
kubectl exec -it <pod> -n <namespace> -- /bin/bash
kubectl exec -it <pod> -n <namespace> -- /bin/sh   # si no tiene bash

# Ejecutar un comando sin entrar al pod
kubectl exec <pod> -n <namespace> -- cat /etc/resolv.conf

# Ver logs
kubectl logs <pod> -n <namespace>
kubectl logs <pod> -n <namespace> -f             # follow (en vivo)
kubectl logs <pod> -n <namespace> --tail=100     # ultimas 100 lineas
kubectl logs <pod> -n <namespace> --previous     # pod anterior (si restarted)
kubectl logs <pod> -n <namespace> -c <container> # pod con multiples containers

# Copiar archivos hacia y desde un pod
kubectl cp archivo.txt <namespace>/<pod>:/ruta/destino
kubectl cp <namespace>/<pod>:/ruta/origen ./archivo-local.txt

# Port-forward (exponer un puerto localmente)
kubectl port-forward pod/<pod> 8080:80 -n <namespace>
kubectl port-forward svc/<service> 8080:80 -n <namespace>
kubectl port-forward deployment/<deploy> 8080:80 -n <namespace>

# Pod de debug temporal
kubectl run debug --image=nicolaka/netshoot -it --rm -n <namespace> -- bash
kubectl run debug --image=busybox -it --rm -- sh

# Transferir archivos entre pods (diferente namespace)
kubectl exec -n <ns1> <pod1> -- tar cf - /ruta | \
  kubectl exec -i -n <ns2> <pod2> -- tar xf - -C /destino
```

---

## Deployments

```bash
# Escalar
kubectl scale deployment/<nombre> --replicas=3 -n <namespace>
kubectl scale deployment --all --replicas=0 -n <namespace>   # apagar todo

# Rollout
kubectl rollout status deployment/<nombre> -n <namespace>
kubectl rollout history deployment/<nombre> -n <namespace>
kubectl rollout undo deployment/<nombre> -n <namespace>                  # volver al anterior
kubectl rollout undo deployment/<nombre> --to-revision=2 -n <namespace> # volver a revision especifica
kubectl rollout restart deployment/<nombre> -n <namespace>               # restart limpio

# Editar en vivo
kubectl edit deployment/<nombre> -n <namespace>

# Forzar un redeploy sin cambios (patch en annotation)
kubectl patch deployment <nombre> -n <namespace> \
  -p '{"spec":{"template":{"metadata":{"annotations":{"restart":"'$(date +%s)'"}}}}}'
```

---

## Services e Ingress

```bash
# Ver endpoints de un service
kubectl get endpoints <service> -n <namespace>

# Exponer un deployment como service
kubectl expose deployment <nombre> --port=80 --target-port=8080 -n <namespace>

# Ver ingress detallado
kubectl describe ingress <nombre> -n <namespace>
```

---

## ConfigMaps y Secrets

```bash
# Crear ConfigMap desde archivo
kubectl create configmap <nombre> --from-file=config.properties -n <namespace>
kubectl create configmap <nombre> --from-literal=key=value -n <namespace>

# Crear Secret
kubectl create secret generic <nombre> --from-literal=password=123 -n <namespace>
kubectl create secret generic <nombre> --from-file=.dockerconfigjson=~/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson -n <namespace>

# Ver el contenido de un secret (decodificado)
kubectl get secret <nombre> -n <namespace> -o jsonpath='{.data.password}' | base64 -d

# Ver todos los datos de un secret decodificados
kubectl get secret <nombre> -n <namespace> -o json | \
  jq '.data | map_values(@base64d)'
```

---

## Namespaces

```bash
kubectl get namespaces
kubectl create namespace <nombre>
kubectl delete namespace <nombre>

# Ejecutar algo en todos los namespaces
kubectl get pods --all-namespaces
kubectl get pods -A   # shorthand
```

---

## Recursos: CPU y Memoria

```bash
# Ver uso real de recursos
kubectl top pods -n <namespace>
kubectl top nodes

# Ver requests/limits definidos
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'
```

---

## RBAC

```bash
# Ver roles y permisos
kubectl get roles -n <namespace>
kubectl get rolebindings -n <namespace>
kubectl get clusterroles
kubectl get clusterrolebindings

# Ver que puede hacer un usuario/serviceaccount
kubectl auth can-i list pods --as=system:serviceaccount:<namespace>:<sa> -n <namespace>
kubectl auth can-i '*' '*' --as=<usuario>

# Describir permisos de un serviceaccount
kubectl describe rolebinding <nombre> -n <namespace>
```

---

## PVCs y Almacenamiento

```bash
kubectl get pvc -n <namespace>
kubectl get pv                           # cluster-wide
kubectl describe pvc <nombre> -n <namespace>

# Cambiar capacidad de un PVC (si el StorageClass lo permite)
kubectl edit pvc <nombre> -n <namespace>
```

---

## Aplicar y gestionar manifiestos

```bash
# Aplicar un manifiesto
kubectl apply -f manifiesto.yaml
kubectl apply -f ./carpeta/          # aplica todos los yaml de la carpeta

# Eliminar recursos
kubectl delete -f manifiesto.yaml
kubectl delete pod <pod> -n <namespace>
kubectl delete pod <pod> -n <namespace> --force --grace-period=0   # forzar

# Dry-run (ver que haria sin aplicar)
kubectl apply -f manifiesto.yaml --dry-run=client
kubectl apply -f manifiesto.yaml --dry-run=server   # mas completo

# Diff entre lo aplicado y lo nuevo
kubectl diff -f manifiesto.yaml
```

---

## Troubleshooting

```bash
# Pod en estado Pending: ver eventos
kubectl describe pod <pod> -n <namespace>
# Buscar en Events: scheduling, image pull errors, resource issues

# Pod en CrashLoopBackOff
kubectl logs <pod> -n <namespace> --previous   # logs de la ejecucion anterior

# Pod que no puede conectar a un servicio
kubectl exec -it <pod> -n <namespace> -- curl http://<service>.<namespace>.svc.cluster.local

# DNS no funciona dentro del pod
kubectl exec -it <pod> -n <namespace> -- nslookup kubernetes.default

# Ver eventos del namespace ordenados por tiempo
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Nodo con problemas: ver condiciones
kubectl describe node <nodo> | grep -A5 Conditions

# Forzar borrado de pod stuck en Terminating
kubectl delete pod <pod> -n <namespace> --force --grace-period=0
```

---

## HPA (Horizontal Pod Autoscaler)

```bash
kubectl get hpa -n <namespace>
kubectl describe hpa <nombre> -n <namespace>

# Crear HPA basico
kubectl autoscale deployment <nombre> --min=2 --max=10 --cpu-percent=70 -n <namespace>
```

---

## Atajos utiles

```bash
# Alias recomendados para .zshrc / .bashrc
alias k='kubectl'
alias kn='kubectl -n'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kd='kubectl describe'
alias kl='kubectl logs'

# Ver pods con su estado resumido
kubectl get pods -n <namespace> -o custom-columns=\
'NAME:.metadata.name,STATUS:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount,NODE:.spec.nodeName'

# Buscar pods por label
kubectl get pods -l app=<nombre> -n <namespace>

# Forzar un refresco de imagen (imagePullPolicy: Always)
kubectl rollout restart deployment/<nombre> -n <namespace>
```

---

## Herramientas complementarias

| Herramienta | Uso                                 | Instalacion              |
|-------------|-------------------------------------|--------------------------|
| k9s         | UI en terminal para K8s             | `brew install k9s`       |
| kubectx     | Cambiar contexto rapido             | `brew install kubectx`   |
| kubens      | Cambiar namespace rapido            | (viene con kubectx)      |
| stern       | Logs de multiples pods a la vez     | `brew install stern`     |
| kube-score  | Analizar calidad de manifiestos     | `brew install kube-score`|
| validkube   | Validar manifiestos online          | https://validkube.com/   |

---

## k9s - Atajos principales

| Shortcut     | Accion                      |
|--------------|-----------------------------|
| `:`          | Command mode (ej: `:pod`)   |
| `0`          | Ver todos los namespaces    |
| `l`          | Ver logs del pod            |
| `d`          | Describir recurso           |
| `e`          | Editar recurso              |
| `ctrl+d`     | Eliminar recurso            |
| `s`          | Shell en el pod             |
| `f`          | Port-forward                |
| `/`          | Filtrar                     |
| `esc`        | Volver                      |

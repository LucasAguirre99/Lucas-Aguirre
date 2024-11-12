# 📜 Holy Bible (Lucas Edition)

Guía rápida de comandos esenciales para Kubernetes, Git, Docker, y Argo CLI.

---

## 🐳 Docker
- **Conectarse a un contenedor**:
  ```bash
  docker exec -it <container_id> /bin/bash
  ```

- **Obtener información de una imagen o contenedor**:
  ```bash
  docker <image|container> inspect <ID>
  ```

- **Listar todos los contenedores activos**:
  ```bash
  docker ps
  ```

- **Eliminar todos los contenedores parados**:
  ```bash
  docker container prune
  ```

---

## ☸️ Kubernetes
- **Copiar archivos hacia y desde un pod**:
  ```bash
  kubectl cp <archivo_local> <namespace>/<pod>:<ruta_destino>
  kubectl cp <namespace>/<pod>:<ruta_origen> <archivo_local>
  ```

- **Conectarse a un pod**:
  ```bash
  kubectl exec -it <pod> -n <namespace> -- /bin/bash
  ```

- **Escalar servicios**:
  ```bash
  kubectl scale <tipo_servicio>/<nombre_servicio> --replicas=<n> -n <namespace>
  ```

- **Listar todos los pods en un namespace**:
  ```bash
  kubectl get pods -n <namespace>
  ```

---

## 🧑‍💻 Git
- **Combinar *n* commits en uno solo**:
  ```bash
  git reset --soft HEAD~<n>
  ```

- **Volver *n* commits atrás**:
  ```bash
  git reset --hard HEAD~<n>
  ```

- **Limpiar archivos no rastreados**:
  ```bash
  git clean -fd
  ```

- **Mostrar el historial de commits en una sola línea**:
  ```bash
  git log --oneline
  ```

---

## 🚀 Argo CLI
- **Iniciar sesión en Argo**:
  ```bash
  argocd login <IP> --core
  ```

- **Ver logs de una tarea**:
  ```bash
  argo logs -n <namespace> <workflow_name> --follow
  ```

- **Listar todos los workflows en un namespace**:
  ```bash
  argo list -n <namespace>
  ```

---


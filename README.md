# 📜 Holy Bible (Lucas Edition)

Guía rápida de comandos esenciales para Kubernetes, Git, Docker, Argo CLI y tecnologías varias.

--- 
## 🌐 Páginas webs interesantes
**[Limpiar y corregir manifiestos de kubernetes](https://validkube.com/)**

**[Actualizaciónes sobre tecnologías](https://app.daily.dev/)**

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

- **Crear una imagen y subirla a dockerhub**: 
  ```bash
  docker build -t imagen:tag . 
  docker push imagen:tag
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

- **Escalar todo un tipo de servicio en un namespace**
  ```bash
  kubectl scale <tipo_servicio> --all --replicas=<n> -n <namespace>
  ```

- **Pasar Archivos de un pod a otro, sin importar el namespace**
  ```bash
  kubectl exec -n <namespace> <pod> -- tar cf - <archivo> \
  | kubectl exec -i -n <namespace> <pod> -- tar xf - -C <archivo>
  ```
---

## 🧑‍💻 Git
- **Combinar *n* commits en uno solo**:
  ```bash
  git reset --soft HEAD~<n>
  ```

Esto también se puede lograr haciendo un rebase -i y poner squash en los commits que se quieran juntar

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

- **Renombrar *n* commits**
  ```bash
  git rebase -i HEAD~n
  ```

- **Mover elementos entre ramas** 
  ```bash
  git restore --source <branch> carpeta_seleccionada/
  ```


Después de esto en la consola que se habre escribir *reword* en los commits que se quieran cambiar, acto seguido nos va a dejar poner el nuevo nombre, después hacemos un push con --force

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

# 🐧 Linux

## Apache 

- Para habilidar módulos en el servidor web de apache se utiliza el comando *a2enmod*, si queremos habilitar algún módulo en particular lo hacemos mediante:
  ```bash
  sudo a2enmod <Modulo>
  ``` 

Este comando va a crear un enlace simbólico entre el archivo de configuración del módulo dentro de (/etc/apache/mods-availables) al directorio de módulos habilitados(/etc/apache2/mod-enabled)

- En el caso que queramos desactivar un módulo simplemente hacemos:
  ```bash
  sudo a2dismod <Módulo>
  ``` 

Al ejecutar este comando se elimina el enlace simbólico en mod-enabled, lo que impide que apache cargue el módulo al reiniciar o cargar

- Si queremos habilitar un archivo de configuraciones de un sitio virtual en apache, lo hacemos con:
  ```bash
  sudo a2ensite <Mi-sitio>
  ```

Este comando habilita sitios adicionales definidos en un archivo dentro de /etc/apache2/sites-available/ para crear un enalce simbólico en sites-enabled

- Para deshabilitar un sitio virtual en apache se utiliza:
  ```bash
  sudo a2dissite <Mi-sitio>
  ```

Este comando elimina el enlace simbólico del sitio sites-enabled, deshabilitándolo sin borrar la configuración

- Habilitar un archivo de configuración general en Apache
  ```bash
  sudo a2enconf <Archivo-de-config>
  ```

Esto habilita configuraciones generales en /etc/apache2/conf-available, lo que permite configuraciones globales no especificas de un sitio

- Deshabilitar un archivo de configuración general en apache:
  ```bash
  sudo a2disconf <Archivo-de-config>
  ```

Elimina el enlace simbólico en conf-enabled, evitando que apache cargue la configuración global

### Crear y renovar certificados

- Instalamos certbot: 
  ```bash
  sudo apt update && apt install certbot python3-certbot-apache -y
  ```

- Habilitamos los puertos
  ```bash
    sudo ufw allow 80
    sudo ufw allow 443
  ```

- Obtener los certificados: 
  ```bash
  sudo certbot --apache -d sub.dominio.com
  ```

- Renovación automática:
  ```bash
  sudo certbot renew --dry-run
  ```
---

## Crear comandos

Para crear comandos simplemente podemos hacer un alias o un script

### alias

- zsh: 
  ```bash
  nano ~/.zshrc
  
  alias <nombre>=<ejecución>

  source ~/.bashrc
  ```

### Comando sed
- Reemplazar dentro del archivo:
  ```bash
  sed -i "s/Palabra_a_reemplazar/${Valor_a_reemplazar}/g" archivo_donde_se_reemplaza
  ```

---
# Base de datos (Postgres)

- Conectarse a la base de datos 
  ```bash
  psql -U usuario -h Ip-db -d base_de_datos
  ```

- frenar todas las conexiónes activas de etendo
  ```bash 
  psql -U postgres -d postgres -c "
  SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE datname = 'etendo' AND pid <> pg_backend_pid();
  "
  ```

- Restaurar base de datos en formato .dump
  ```bash
  pg_restore -U user -d base_de_datos -c backup.dump
  ```
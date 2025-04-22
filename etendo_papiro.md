# 📜 Etendo wisdom

En este papiro se encuentra el conocimiento sobre los comandos y etendo en general

--- 

## 🧑‍💻 Gradle 

Los comandos gradle tienen diferentes funciones

- ./gradlew expand *Después de clonar el repositorio, este nos permite amoldar nuestro proyecto con las dependencias definidas en build.gradle*

- echo "Y" | ./gradlew expand *Nos permite autoescribir el Y cuando se ejecuta el comadno*

- ./gradlew setup *Aplica las configuraciónes definidas dentro de gradle.properties*

- ./gradlew install *Hace una instalación dentro de la base de datos, con toda la configuración del proyecto*

- ./gradlew resources.up *Si tenemos servicios dockerizados, con este comando se configura y se levanta el docker compose* 

- ./gradlew antWar *Nos genera dentro de la carpeta /lib/ un .war del proyecto*

- ./gradlew smartbuild *Adapta todo lo compilado a tomcat*

- ./gradlew prepareConfig *Aplica los cambios del gradle.properties dentro de openbravo, esto es úil cuando queremos aplicar el allow.root, para que no falle la primera ejecución*

### Gradle.properties flags

Si necesitamos levantar entornos dentro de Argo, k8s o donde sólo tenemos acceso de usuario root, debemos de agregar el siguiente flag:
 
 - allow.root=true

Dockerizar servicios: 

 - docker_com.etendoerp.etendorx=true

 - docker_com.etendoerp.tomcat=true

 - docker_com.etendoerp.docker_db=true

 Esto es opcional, pero si necesitamos tener un puerto exclusivo para tomcat y la base de datos (Esto en caso de que ya tengamos dentro de nuestro entorno el servicio de tomcat y de postgres levantado), tenemos que configurarles un puerto:

  - docker_com.etendoerp.tomcat_port=<port>

  - docker_com.etendoerp.db_port=<port>
---

### RX

Para poder tener RX son necesarios 2 cosas, primero tenemos el etendo_base, al mismo debemos de ponerle el módulo de com.etendoerp.etendorx dentro de la carpeta de modulos. 

Nos podemos clonar el entorno etendo_rx para preparlo debemos de hacer lo siguiente: 

- ./gradlew generate.entities --info

- ./gradlew :com.etendorx.<Servicio>:build -x test -> Este comando nos va a generar los .jar de cada uno de lo servicios, para ir a buscar dicho jar, dentro de la carpeta de etendo_rx se encuentra en modules_core/com.etendorx.<Servicio>/build/libs

## 🌐 Bibliografía y enlaces importantes

**[Documentación(wiki etendo)](https://docs.etendo.software/latest/)**

**[Futit staff](https://futit-staff.etendo.cloud/etendo/security/Login)** 

**[Etendo Demo](https://demo.etendo.cloud/)**

**[Argo Workflow Digital Ocean](https://workflowsargodo.lab.etendo.cloud/)**

**[Argo Workflow ScaleWay](https://argoworkflows.labs.etendo.cloud/workflows)**

**[Imputador](https://developer-client.futit.cloud/)**

---

### Hacer Backups en entornos de etendo 

Primero tenemos que configurar el archivo '/etc/openbravo-backups.config'

Después simplemente habilidar el crontab. Si queremos hacer el backup de manera manual tenemos que hacer

  - etendo-backup

Esto nos va a generar un backup dentro de /backups/backup-manual
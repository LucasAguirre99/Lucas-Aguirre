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

## 🌐 Bibliografía y enlaces importantes

**[Documentación(wiki etendo)](https://docs.etendo.software/latest/)**

**[Futit staff](https://futit-staff.etendo.cloud/etendo/security/Login)** 

**[Etendo Demo](https://demo.etendo.cloud/)**

**[Argo Workflow Digital Ocean](https://workflowsargodo.lab.etendo.cloud/)**

**[Argo Workflow ScaleWay](https://argoworkflows.labs.etendo.cloud/workflows)**

---
# 📜 Etendo wisdom

En este papiro se encuentra el conocimiento sobre los comandos y etendo en general

--- 

## 🧑‍💻 Gradle 

Los comandos gradle tienen diferentes funciones

- ./gradlew expand *Después de clonar el repositorio, este nos permite amoldar nuestro proyecto con las dependencias definidas en build.gradle*

- ./gradlew setup *Aplica las configuraciónes definidas dentro de gradle.properties*

- ./gradlew install *Hace una instalación dentro de la base de datos, con toda la configuración del proyecto*

- ./gradlew resources.up *Si tenemos servicios dockerizados, con este comando se configura y se levanta el docker compose* 

- ./gradlew antWar *Nos genera dentro de la carpeta /lib/ un .war del proyecto*

- ./gradlew smartbuild *Adapta todo lo compilado a tomcat*

### Gradle.properties flags

Si necesitamos levantar entornos dentro de Argo, k8s o donde sólo tenemos acceso de usuario root, debemos de agregar el siguiente flag:
 
 - allow.root=true

---

## 🌐 Bibliografía y enlaces importantes

**[Documentación(wiki etendo)](https://docs.etendo.software/latest/)**

**[Futit staff](https://futit-staff.etendo.cloud/etendo/security/Login)** 

**[Etendo Demo](https://demo.etendo.cloud/)**

**[Argo Workflow Digital Ocean](https://workflowsargodo.lab.etendo.cloud/)**

**[Argo Workflow ScaleWay](https://argoworkflows.labs.etendo.cloud/workflows)**

---
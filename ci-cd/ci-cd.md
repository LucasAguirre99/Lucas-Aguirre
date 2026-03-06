# CI/CD - Jenkins y GitHub Actions

---

# Jenkins

## Comandos CLI

```bash
# Descargar el CLI de Jenkins
curl -O http://<jenkins-url>/jnlpJars/jenkins-cli.jar

# Ejecutar comandos
java -jar jenkins-cli.jar -s http://<jenkins-url> -auth usuario:token <comando>

# Comandos utiles
java -jar jenkins-cli.jar -s http://<jenkins-url> -auth user:token list-jobs
java -jar jenkins-cli.jar -s http://<jenkins-url> -auth user:token build <job-name>
java -jar jenkins-cli.jar -s http://<jenkins-url> -auth user:token console <job-name> <build-num>
java -jar jenkins-cli.jar -s http://<jenkins-url> -auth user:token disable-job <job-name>
java -jar jenkins-cli.jar -s http://<jenkins-url> -auth user:token enable-job <job-name>
```

---

## Jenkinsfile - Estructura base

```groovy
pipeline {
    agent any

    // Variables de entorno
    environment {
        REGISTRY = 'registry.ejemplo.com'
        IMAGE    = 'mi-app'
        TAG      = "${env.BUILD_NUMBER}"
    }

    // Parametros configurables desde la UI
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Rama a construir')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Desplegar en produccion?')
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Entorno')
    }

    // Disparadores
    triggers {
        cron('H 2 * * 1-5')       // lunes a viernes a las 2AM
        pollSCM('H/5 * * * *')    // revisar cambios cada 5 minutos
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t ${REGISTRY}/${IMAGE}:${TAG} .'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
            post {
                always {
                    junit 'test-results/*.xml'   // publicar resultados de tests
                }
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'registry-creds',
                    usernameVariable: 'REGISTRY_USER',
                    passwordVariable: 'REGISTRY_PASS'
                )]) {
                    sh '''
                        docker login ${REGISTRY} -u ${REGISTRY_USER} -p ${REGISTRY_PASS}
                        docker push ${REGISTRY}/${IMAGE}:${TAG}
                    '''
                }
            }
        }

        stage('Deploy') {
            when {
                expression { params.DEPLOY == true }
            }
            steps {
                sh "kubectl set image deployment/mi-app mi-app=${REGISTRY}/${IMAGE}:${TAG} -n ${params.ENV}"
            }
        }
    }

    post {
        success {
            echo "Pipeline completado con exito. Build: ${TAG}"
            // slackSend channel: '#devops', message: "Build exitoso: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline fallido"
            // slackSend channel: '#devops', message: "FALLO: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        always {
            // Limpiar workspace e imagenes
            sh 'docker rmi ${REGISTRY}/${IMAGE}:${TAG} || true'
            cleanWs()
        }
    }
}
```

---

## Patrones utiles en Jenkinsfile

```groovy
// Ejecutar en paralelo
stage('Tests paralelos') {
    parallel {
        stage('Unit tests') {
            steps { sh 'npm run test:unit' }
        }
        stage('Integration tests') {
            steps { sh 'npm run test:integration' }
        }
    }
}

// Timeout
stage('Deploy') {
    options { timeout(time: 10, unit: 'MINUTES') }
    steps {
        sh 'helm upgrade --install ...'
    }
}

// Reintentos
stage('Build') {
    options { retry(3) }
    steps {
        sh 'docker build ...'
    }
}

// Aprobar manualmente antes de continuar
stage('Aprobar produccion') {
    steps {
        input message: 'Desplegar en produccion?', ok: 'Si, adelante'
    }
}

// Credenciales tipo secret text
withCredentials([string(credentialsId: 'mi-token', variable: 'TOKEN')]) {
    sh 'curl -H "Authorization: Bearer ${TOKEN}" ...'
}

// Credenciales tipo archivo
withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
    sh 'kubectl get pods --kubeconfig=${KUBECONFIG}'
}

// Variables de entorno de credenciales
withCredentials([sshUserPrivateKey(
    credentialsId: 'ssh-key',
    keyFileVariable: 'SSH_KEY',
    usernameVariable: 'SSH_USER'
)]) {
    sh 'ssh -i ${SSH_KEY} ${SSH_USER}@servidor.com "ls"'
}
```

---

# GitHub Actions

## Estructura de un workflow

```yaml
# .github/workflows/ci.yml

name: CI/CD Pipeline

# Cuando se dispara
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1-5'    # lunes a viernes a las 2AM UTC
  workflow_dispatch:           # boton manual en GitHub
    inputs:
      environment:
        description: 'Entorno de deploy'
        required: true
        default: 'staging'

# Permisos del workflow
permissions:
  contents: read
  packages: write

# Variables globales
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest

    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}

    steps:
      - name: Checkout codigo
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Instalar dependencias
        run: npm ci

      - name: Ejecutar tests
        run: npm test

      - name: Login en Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extraer metadatos de imagen
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-
            type=ref,event=branch
            type=semver,pattern={{version}}

      - name: Build y push de imagen
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: production      # requiere aprobacion manual configurada en GitHub

    steps:
      - name: Deploy en Kubernetes
        uses: actions-hub/kubectl@master
        env:
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
        with:
          args: set image deployment/mi-app mi-app=${{ needs.build.outputs.image-tag }}
```

---

## Patrones comunes de GitHub Actions

```yaml
# Jobs en paralelo
jobs:
  test-unit:
    runs-on: ubuntu-latest
    steps: [...]

  test-e2e:
    runs-on: ubuntu-latest
    steps: [...]

  build:
    needs: [test-unit, test-e2e]   # espera que ambos terminen
    runs-on: ubuntu-latest
    steps: [...]

# Matrix: correr en multiples versiones/OS
jobs:
  test:
    strategy:
      matrix:
        node: [18, 20, 22]
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}

# Condiciones
steps:
  - name: Deploy solo en main
    if: github.ref == 'refs/heads/main'
    run: echo "desplegando en produccion"

  - name: Solo si el job anterior fallo
    if: failure()
    run: echo "algo salio mal"

# Cache de dependencias
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

# Subir artefactos
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/
    retention-days: 7

# Descargar artefactos en otro job
- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/

# Usar secretos y variables de entorno
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
    DB_HOST: ${{ vars.DB_HOST }}     # vars son para valores no sensibles
  run: ./deploy.sh
```

---

## Actions utiles

| Action | Uso |
|--------|-----|
| `actions/checkout@v4` | Clonar el repositorio |
| `actions/setup-node@v4` | Configurar Node.js |
| `actions/setup-python@v5` | Configurar Python |
| `actions/setup-java@v4` | Configurar Java |
| `actions/cache@v4` | Cache de dependencias |
| `actions/upload-artifact@v4` | Subir artefactos |
| `docker/build-push-action@v5` | Build y push Docker |
| `docker/login-action@v3` | Login en registry |
| `docker/metadata-action@v5` | Metadatos de imagen |
| `hashicorp/setup-terraform@v3` | Configurar Terraform |
| `azure/setup-kubectl@v3` | Configurar kubectl |

---

## Secretos y configuracion

```bash
# Secretos en GitHub Actions se configuran en:
# Settings > Secrets and variables > Actions

# Tipos:
# secrets.*   : valores encriptados (API keys, passwords)
# vars.*      : variables de entorno no sensibles
# GITHUB_TOKEN: token automatico con permisos al repo

# Secretos de entorno (para aprobar deploys):
# Settings > Environments > Crear entorno > Agregar reviewers
```

---

## Workflow de GitOps tipico

```yaml
# Pipeline completo: test -> build -> push -> update manifest -> argocd sync

name: GitOps Pipeline

on:
  push:
    branches: [main]

jobs:
  pipeline:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Tests
        run: npm test

      - name: Build y push imagen
        run: |
          docker build -t ${{ env.REGISTRY }}/mi-app:${{ github.sha }} .
          docker push ${{ env.REGISTRY }}/mi-app:${{ github.sha }}

      - name: Actualizar manifiesto de K8s
        run: |
          git config user.email "ci@ejemplo.com"
          git config user.name "CI Bot"
          sed -i "s|image: .*|image: ${{ env.REGISTRY }}/mi-app:${{ github.sha }}|" k8s/deployment.yaml
          git add k8s/deployment.yaml
          git commit -m "ci: actualizar imagen a ${{ github.sha }}"
          git push
```

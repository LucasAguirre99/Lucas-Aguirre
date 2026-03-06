# Argo - Referencia completa

---

# Argo CD

## Instalacion y configuracion

```bash
# Instalar Argo CD en K8s
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Acceder a la UI localmente
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Obtener password inicial
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Login via CLI
argocd login localhost:8080
argocd login <IP> --core
argocd login <IP> --username admin --password <password> --insecure
```

---

## Aplicaciones

```bash
# Listar aplicaciones
argocd app list

# Ver estado de una aplicacion
argocd app get <app>

# Sincronizar (deployar)
argocd app sync <app>
argocd app sync <app> --force             # forzar sync aunque no haya cambios
argocd app sync <app> --prune             # eliminar recursos que no estan en git
argocd app sync <app> --dry-run           # ver que cambiaria sin aplicar

# Sincronizar solo recursos especificos
argocd app sync <app> --resource apps:Deployment:mi-deployment

# Ver diferencias entre el estado deseado (git) y el real (cluster)
argocd app diff <app>

# Ver historial de deploys
argocd app history <app>

# Rollback a una revision especifica
argocd app rollback <app> <revision-id>

# Crear aplicacion
argocd app create mi-app \
  --repo https://github.com/org/repo.git \
  --path k8s/overlays/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace produccion \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Eliminar aplicacion
argocd app delete <app>
argocd app delete <app> --cascade         # elimina tambien los recursos en K8s

# Forzar refresh (actualizar desde git sin esperar)
argocd app get <app> --refresh
```

---

## Gestionar repos y clusters

```bash
# Agregar repositorio privado
argocd repo add https://github.com/org/repo.git \
  --username <user> \
  --password <token>

# Agregar repo con SSH
argocd repo add git@github.com:org/repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa

# Listar repos configurados
argocd repo list

# Agregar cluster externo
argocd cluster add <context-name>
argocd cluster list
```

---

## Manifiestos de Application (GitOps)

```yaml
# Application basica con sync manual
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mi-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo.git
    targetRevision: HEAD
    path: k8s/
  destination:
    server: https://kubernetes.default.svc
    namespace: produccion
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```

```yaml
# Application con sync automatico
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mi-app-auto
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo.git
    targetRevision: main
    path: k8s/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: produccion
  syncPolicy:
    automated:
      prune: true          # eliminar recursos borrados en git
      selfHeal: true       # corregir cambios manuales en el cluster
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
```

```yaml
# Application con Helm
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mi-chart
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: nginx
    targetRevision: 15.1.0
    helm:
      values: |
        replicaCount: 2
        service:
          type: ClusterIP
  destination:
    server: https://kubernetes.default.svc
    namespace: mi-namespace
  syncPolicy:
    automated:
      selfHeal: true
```

---

## AppProject (multi-tenant)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: equipo-backend
  namespace: argocd
spec:
  description: Proyecto del equipo backend
  sourceRepos:
    - 'https://github.com/org/backend-*'
  destinations:
    - namespace: 'backend-*'
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
```

---

---

# Argo Workflows

## Comandos CLI

```bash
# Login
argo auth token                          # ver token actual
argo login <url>

# Listar workflows
argo list -n <namespace>
argo list -n <namespace> --running       # solo en ejecucion
argo list -n <namespace> --failed        # solo fallidos
argo list -n <namespace> --completed     # solo completados

# Ver detalle de un workflow
argo get <workflow> -n <namespace>
argo get @latest -n <namespace>          # el ultimo

# Ver logs
argo logs <workflow> -n <namespace>
argo logs <workflow> -n <namespace> --follow
argo logs <workflow>/<pod> -n <namespace>   # logs de un pod especifico

# Ejecutar workflow
argo submit workflow.yaml -n <namespace>
argo submit workflow.yaml -n <namespace> --watch          # ver progreso
argo submit workflow.yaml -n <namespace> --wait           # esperar a que termine
argo submit workflow.yaml -n <namespace> -p param=valor   # con parametro

# Eliminar workflows
argo delete <workflow> -n <namespace>
argo delete --completed -n <namespace>   # eliminar todos los completados
argo delete --all -n <namespace>         # eliminar todos

# Reenviar workflow fallido
argo resubmit <workflow> -n <namespace>

# Resumir workflow suspendido
argo resume <workflow> -n <namespace>

# Suspender workflow
argo suspend <workflow> -n <namespace>
```

---

## Templates de Workflows

### Workflow simple

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hola-mundo-
  namespace: argo
spec:
  entrypoint: hola
  templates:
    - name: hola
      container:
        image: alpine:3.18
        command: [echo]
        args: ["Hola desde Argo Workflows"]
        resources:
          requests:
            memory: 64Mi
            cpu: 250m
```

### Workflow con pasos secuenciales

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: pipeline-
spec:
  entrypoint: pipeline
  templates:
    - name: pipeline
      steps:
        - - name: build
            template: docker-build
        - - name: test
            template: run-tests
        - - name: deploy
            template: k8s-deploy
            when: "{{steps.test.outputs.result}} == success"

    - name: docker-build
      container:
        image: docker:24
        command: [docker, build, -t, mi-app:latest, .]

    - name: run-tests
      container:
        image: node:20
        command: [npm, test]

    - name: k8s-deploy
      container:
        image: bitnami/kubectl
        command: [kubectl, apply, -f, k8s/]
```

### Workflow con DAG (Grafo dirigido)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-pipeline-
spec:
  entrypoint: mi-dag
  templates:
    - name: mi-dag
      dag:
        tasks:
          - name: build
            template: build-app
          - name: unit-tests
            dependencies: [build]
            template: run-unit-tests
          - name: integration-tests
            dependencies: [build]
            template: run-integration-tests
          - name: deploy
            dependencies: [unit-tests, integration-tests]
            template: deploy-app

    - name: build-app
      container:
        image: node:20
        command: [npm, run, build]

    - name: run-unit-tests
      container:
        image: node:20
        command: [npm, run, test:unit]

    - name: run-integration-tests
      container:
        image: node:20
        command: [npm, run, test:integration]

    - name: deploy-app
      container:
        image: bitnami/kubectl
        command: [kubectl, apply, -f, k8s/]
```

### WorkflowTemplate (reutilizable)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: docker-build-push
  namespace: argo
spec:
  templates:
    - name: build-and-push
      inputs:
        parameters:
          - name: image
          - name: tag
            value: "latest"
          - name: context
            value: "."
      container:
        image: gcr.io/kaniko-project/executor:latest
        args:
          - --dockerfile=Dockerfile
          - --context={{inputs.parameters.context}}
          - --destination={{inputs.parameters.image}}:{{inputs.parameters.tag}}
        volumeMounts:
          - name: docker-config
            mountPath: /kaniko/.docker
      volumes:
        - name: docker-config
          secret:
            secretName: registry-credentials
```

### CronWorkflow (equivalente a cron job)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: CronWorkflow
metadata:
  name: backup-diario
  namespace: argo
spec:
  schedule: "0 2 * * *"          # todos los dias a las 2AM
  timezone: "Europe/Madrid"
  concurrencyPolicy: Forbid        # no correr si ya hay uno en ejecucion
  startingDeadlineSeconds: 0
  workflowSpec:
    entrypoint: hacer-backup
    templates:
      - name: hacer-backup
        container:
          image: mi-backup-image:latest
          command: [/bin/bash, -c]
          args: ["./scripts/backup.sh"]
```

---

## Parametros y artefactos

```yaml
# Workflow con parametros de entrada
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: con-parametros-
spec:
  entrypoint: main
  arguments:
    parameters:
      - name: ambiente
        value: staging
      - name: version
        value: "1.0.0"

  templates:
    - name: main
      inputs:
        parameters:
          - name: ambiente
          - name: version
      container:
        image: alpine
        command: [sh, -c]
        args: ["echo Desplegando version {{inputs.parameters.version}} en {{inputs.parameters.ambiente}}"]
```

```bash
# Ejecutar con parametros desde CLI
argo submit workflow.yaml -n argo \
  -p ambiente=production \
  -p version=2.1.0
```

---

## Limpieza de workflows

```bash
# Script para limpiar workflows completados y fallidos
# (ver tools/argo/cleaner.sh y succes_cleaner.sh)

# Manual
argo delete --completed -n <namespace>
argo delete --failed -n <namespace>

# Con kubectl (para workflows muy viejos)
kubectl delete workflow -n <namespace> \
  $(kubectl get workflow -n <namespace> \
    --field-selector=status.phase=Succeeded \
    -o jsonpath='{.items[*].metadata.name}')
```

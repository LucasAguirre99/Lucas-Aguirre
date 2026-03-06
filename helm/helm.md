# Helm - Gestor de paquetes para Kubernetes

## Conceptos clave

- **Chart**: paquete de Kubernetes (templates + values)
- **Release**: instancia de un chart desplegada en el cluster
- **Repository**: repositorio de charts
- **Values**: configuracion que sobreescribe los defaults del chart

---

## Repositorios

```bash
# Agregar repositorio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add cert-manager https://charts.jetstack.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Actualizar repos
helm repo update

# Listar repos configurados
helm repo list

# Eliminar repo
helm repo remove bitnami
```

---

## Buscar charts

```bash
# Buscar en repos configurados
helm search repo nginx

# Buscar en Artifact Hub (publico)
helm search hub nginx

# Ver versiones disponibles de un chart
helm search repo bitnami/nginx --versions
```

---

## Instalar

```bash
# Instalacion basica
helm install mi-release bitnami/nginx -n mi-namespace

# Con values personalizados (archivo)
helm install mi-release bitnami/nginx -f values.yaml -n mi-namespace

# Con values personalizados (inline)
helm install mi-release bitnami/nginx \
  --set service.type=ClusterIP \
  --set replicaCount=2 \
  -n mi-namespace

# Crear namespace si no existe
helm install mi-release bitnami/nginx -n mi-namespace --create-namespace

# Version especifica del chart
helm install mi-release bitnami/nginx --version 15.1.0 -n mi-namespace

# Dry-run (ver que haria sin aplicar)
helm install mi-release bitnami/nginx --dry-run --debug -n mi-namespace

# Instalar desde carpeta local
helm install mi-release ./mi-chart/ -n mi-namespace

# Instalar desde archivo .tgz
helm install mi-release ./mi-chart-1.0.0.tgz -n mi-namespace
```

---

## Ver releases instalados

```bash
# Listar releases en un namespace
helm list -n mi-namespace

# Todos los namespaces
helm list -A

# Ver estado de una release
helm status mi-release -n mi-namespace

# Ver los values con los que fue instalada
helm get values mi-release -n mi-namespace
helm get values mi-release -n mi-namespace --all    # defaults + overrides

# Ver los manifiestos generados
helm get manifest mi-release -n mi-namespace

# Ver notas post-instalacion
helm get notes mi-release -n mi-namespace
```

---

## Actualizar

```bash
# Actualizar release con nuevos values
helm upgrade mi-release bitnami/nginx -f values.yaml -n mi-namespace

# Actualizar version del chart
helm upgrade mi-release bitnami/nginx --version 15.2.0 -n mi-namespace

# Install si no existe, upgrade si ya existe
helm upgrade --install mi-release bitnami/nginx -f values.yaml -n mi-namespace --create-namespace

# Forzar recreacion de pods
helm upgrade mi-release bitnami/nginx --force -n mi-namespace

# Atomic: si falla, hace rollback automatico
helm upgrade mi-release bitnami/nginx --atomic --timeout 5m -n mi-namespace
```

---

## Rollback

```bash
# Ver historial de revisiones
helm history mi-release -n mi-namespace

# Rollback a la revision anterior
helm rollback mi-release -n mi-namespace

# Rollback a revision especifica
helm rollback mi-release 2 -n mi-namespace
```

---

## Desinstalar

```bash
helm uninstall mi-release -n mi-namespace

# Mantener historial (para rollback futuro)
helm uninstall mi-release -n mi-namespace --keep-history
```

---

## Templates y debugging

```bash
# Renderizar templates sin instalar (ver los yaml finales)
helm template mi-release bitnami/nginx -f values.yaml -n mi-namespace

# Renderizar y guardar en archivo
helm template mi-release bitnami/nginx -f values.yaml > output.yaml

# Lint: verificar sintaxis del chart
helm lint ./mi-chart/

# Ver diferencias entre release instalada y lo nuevo
helm diff upgrade mi-release bitnami/nginx -f values.yaml -n mi-namespace
# Requiere plugin: helm plugin install https://github.com/databus23/helm-diff
```

---

## Crear un chart

```bash
# Crear estructura basica
helm create mi-chart

# Estructura generada:
# mi-chart/
#   Chart.yaml          - metadatos del chart
#   values.yaml         - valores por defecto
#   templates/          - templates de manifiestos
#     deployment.yaml
#     service.yaml
#     ingress.yaml
#     _helpers.tpl      - funciones de template reutilizables
#   charts/             - dependencias

# Empaquetar chart
helm package ./mi-chart/

# Verificar chart antes de empaquetar
helm lint ./mi-chart/
```

---

## values.yaml tipico

```yaml
replicaCount: 1

image:
  repository: mi-app
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

ingress:
  enabled: false
  className: nginx
  annotations: {}
  hosts:
    - host: mi-app.ejemplo.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70

env:
  - name: NODE_ENV
    value: production
```

---

## Helmfile - Gestionar multiples releases

```bash
# Instalar helmfile
# https://github.com/helmfile/helmfile

# Aplicar todas las releases del helmfile.yaml
helmfile apply

# Ver diferencias antes de aplicar
helmfile diff

# Solo sincronizar (mas agresivo que apply)
helmfile sync

# Destruir todo lo definido
helmfile destroy

# Aplicar solo una release especifica
helmfile apply --selector name=mi-release

# Actualizar dependencias
helmfile deps
```

### helmfile.yaml tipico

```yaml
repositories:
  - name: bitnami
    url: https://charts.bitnami.com/bitnami
  - name: ingress-nginx
    url: https://kubernetes.github.io/ingress-nginx

releases:
  - name: ingress-nginx
    namespace: ingress-nginx
    chart: ingress-nginx/ingress-nginx
    version: 4.10.0
    values:
      - values/ingress-nginx.yaml

  - name: mi-app
    namespace: produccion
    chart: ./charts/mi-app
    values:
      - values/mi-app-prod.yaml
    set:
      - name: image.tag
        value: {{ env "IMAGE_TAG" | default "latest" }}
```

---

## Plugins utiles

```bash
# Ver diferencias antes de upgrade
helm plugin install https://github.com/databus23/helm-diff

# Gestionar secrets encriptados con helm
helm plugin install https://github.com/jkroepke/helm-secrets

# Ver unitest en charts
helm plugin install https://github.com/helm-unittest/helm-unittest
```

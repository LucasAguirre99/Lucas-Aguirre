# Monitoring y Observabilidad

## Stack tipico de observabilidad

```
Metricas:   Prometheus -> Grafana
Logs:       Loki -> Grafana
Trazas:     Tempo / Jaeger -> Grafana
Alertas:    Alertmanager (con Prometheus)
```

---

# Prometheus

## Comandos y conceptos basicos

```bash
# Ver targets que esta scrapeando Prometheus
# UI: http://prometheus:9090/targets

# Recargar configuracion sin reiniciar
curl -X POST http://prometheus:9090/-/reload

# Chequear si la config es valida
promtool check config /etc/prometheus/prometheus.yml

# Chequear reglas de alertas
promtool check rules /etc/prometheus/rules/*.yml
```

## PromQL - Consultas basicas

```promql
# Ver una metrica
up

# Filtrar por label
up{job="mi-app"}
up{job="mi-app", instance="10.0.0.1:8080"}

# Regex en labels
http_requests_total{status=~"5.."}      # todos los 5xx
http_requests_total{status!~"2.."}      # todos los no 2xx

# Rate: tasa de cambio por segundo (para contadores)
rate(http_requests_total[5m])

# Irate: rate instantaneo (para graficas con muchos picos)
irate(http_requests_total[5m])

# Diferencia entre el valor actual y hace N tiempo
increase(http_requests_total[1h])

# Suma por label
sum(rate(http_requests_total[5m])) by (job)
sum(rate(http_requests_total[5m])) by (status)

# Percentil de latencia (histograma)
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job))

# Memoria usada en %
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# CPU usada en %
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Disco usado en %
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100

# Pods no listos en Kubernetes
kube_pod_status_ready{condition="false"}

# Restarts de pods en la ultima hora
increase(kube_pod_container_status_restarts_total[1h]) > 0
```

---

## Alertas (prometheus rules)

```yaml
# /etc/prometheus/rules/alertas.yml
groups:
  - name: infraestructura
    rules:
      - alert: ServicioDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Servicio {{ $labels.job }} caido"
          description: "{{ $labels.instance }} lleva mas de 1 minuto sin responder"

      - alert: AltaLatencia
        expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Latencia alta en {{ $labels.job }}"
          description: "P99 > 2 segundos en los ultimos 5 minutos"

      - alert: DiscoLleno
        expr: (node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disco lleno en {{ $labels.instance }}"
          description: "{{ $value | printf \"%.0f\" }}% usado en {{ $labels.mountpoint }}"
```

---

# Loki - Logs

## Consultas LogQL

```logql
# Ver todos los logs de una app
{app="mi-app"}

# Filtrar por texto
{app="mi-app"} |= "ERROR"
{app="mi-app"} |= "error" != "timeout"

# Regex
{app="mi-app"} |~ "error|exception|panic"
{namespace="produccion"} |= "ERROR"

# Parsear JSON y filtrar por campo
{app="mi-app"} | json | level="error"
{app="mi-app"} | json | duration > 500

# Parsear logfmt
{app="mi-app"} | logfmt | method="POST"

# Rate de logs por segundo
rate({app="mi-app"} |= "ERROR" [5m])

# Contar errores por minuto
count_over_time({app="mi-app"} |= "ERROR" [1m])

# Ver logs de un pod especifico en K8s
{namespace="produccion", pod="mi-app-7d9fb8"}

# Buscar en multiples namespaces
{namespace=~"produccion|staging"} |= "ERROR"
```

---

# kubectl - Metricas y monitoring

```bash
# Uso de recursos de pods
kubectl top pods -n <namespace>
kubectl top pods -n <namespace> --sort-by=cpu
kubectl top pods -n <namespace> --sort-by=memory

# Uso de recursos de nodos
kubectl top nodes

# Ver eventos recientes del cluster (ultimos 1h)
kubectl get events -A --sort-by='.lastTimestamp' | tail -30

# Ver eventos de un namespace
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Monitorear un pod en tiempo real
watch kubectl get pods -n <namespace>

# Logs de varios pods a la vez (con stern)
stern mi-app -n <namespace>
stern mi-app -n <namespace> --tail=50
stern . -n <namespace>             # todos los pods del namespace
```

---

# k9s - UI en terminal

```bash
# Iniciar k9s
k9s
k9s -n mi-namespace
k9s --context mi-contexto

# En k9s: comandos principales
# :pod          - ver pods
# :deploy       - ver deployments
# :svc          - ver services
# :ns           - ver namespaces
# :node         - ver nodos
# :pvc          - ver PVCs
# :hpa          - ver HPAs
# :secret       - ver secrets
# :cm           - ver configmaps
# :ing          - ver ingress
# :event        - ver eventos

# Atajos en k9s
# l     - logs del pod
# d     - describe el recurso
# e     - editar el recurso (YAML)
# s     - shell en el pod
# f     - port-forward
# ctrl+d - eliminar recurso
# /     - filtrar
# 0     - todos los namespaces
# esc   - volver atras
```

---

# Grafana

## Atajos y tips de uso

```
# Crear dashboard
+ -> Add visualization

# Editar un panel
Hacer clic en el titulo -> Edit

# Variables de dashboard (para filtros dinamicos)
Settings -> Variables -> Add variable

# Explorar datos (sin crear dashboard)
Explore (icono brujula en el menu lateral)

# Alertas en Grafana
Alerting -> Alert rules -> New alert rule
```

## Provisioning de dashboards via archivos

```yaml
# /etc/grafana/provisioning/dashboards/default.yaml
apiVersion: 1
providers:
  - name: Default
    folder: Dashboards
    type: file
    options:
      path: /var/lib/grafana/dashboards
```

---

# Alertmanager

## Configuracion basica

```yaml
# alertmanager.yml
global:
  slack_api_url: 'https://hooks.slack.com/services/XXXXX'

route:
  receiver: 'slack-devops'
  group_by: ['alertname', 'job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
      continue: true

receivers:
  - name: 'slack-devops'
    slack_configs:
      - channel: '#alertas'
        title: '{{ if eq .Status "firing" }}🔥{{ else }}✅{{ end }} {{ .CommonAnnotations.summary }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}'

  - name: 'pagerduty'
    pagerduty_configs:
      - routing_key: 'MI_ROUTING_KEY'

inhibit_rules:
  # Si el cluster esta caido, no mandar alertas de los servicios
  - source_match:
      alertname: ClusterDown
    target_match:
      severity: warning
    equal: ['cluster']
```

---

# Node Exporter (metricas de host)

```bash
# Instalar en Ubuntu
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz
tar xvf node_exporter-*.tar.gz
sudo mv node_exporter-*/node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter

# Servicio systemd: /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

sudo systemctl enable --now node_exporter
# Metricas disponibles en :9100/metrics

# Agregar target en prometheus.yml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['servidor1:9100', 'servidor2:9100']
```

---

# Stack completo con Helm

```bash
# Instalar kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f values-monitoring.yaml

# Acceder a Grafana localmente
kubectl port-forward svc/kube-prometheus-grafana 3000:80 -n monitoring
# Default credentials: admin / prom-operator

# Acceder a Prometheus localmente
kubectl port-forward svc/kube-prometheus-kube-prome-prometheus 9090:9090 -n monitoring

# Acceder a Alertmanager localmente
kubectl port-forward svc/kube-prometheus-kube-prome-alertmanager 9093:9093 -n monitoring
```

# DevOps Holy Bible

Referencia personal de comandos, herramientas y conceptos para el trabajo diario de DevOps.

---

## Indice

| Tema | Archivo | Descripcion |
|------|---------|-------------|
| **Kubernetes** | [kubernetes/kubernetes.md](kubernetes/kubernetes.md) | kubectl, contextos, pods, deployments, RBAC, troubleshooting, k9s |
| **Docker** | [docker/docker.md](docker/docker.md) | imagenes, contenedores, compose, Dockerfile, redes, volumenes |
| **Helm** | [helm/helm.md](helm/helm.md) | install, upgrade, rollback, templates, helmfile |
| **Git** | [git/git.md](git/git.md) | branches, rebase, stash, cherry-pick, worktrees, bisect |
| **CI/CD** | [ci-cd/ci-cd.md](ci-cd/ci-cd.md) | Jenkins pipelines, GitHub Actions workflows |
| **Terraform** | [terraform/terraform.md](terraform/terraform.md) | plan, apply, state, modulos, workspaces, providers |
| **Monitoring** | [monitoring/monitoring.md](monitoring/monitoring.md) | Prometheus, PromQL, Loki, Grafana, k9s, Alertmanager |
| **Databases** | [databases/databases.md](databases/databases.md) | PostgreSQL, MySQL, Redis, MongoDB |
| **Networking** | [networking/networking.md](networking/networking.md) | SSH, DNS, firewall, tcpdump, nginx, puertos |
| **Linux Sysadmin** | [sysadmin-linux.md](sysadmin-linux.md) | checklist servidor nuevo, CPU, memoria, procesos |
| **Linux Cheatsheet** | [Ciberseguridad/linux/apuntes-linux.md](Ciberseguridad/linux/apuntes-linux.md) | permisos, bash, find, awk/sed/grep, cron, scripting |
| **AWS CLI** | [tools/aws/aws-cli.md](tools/aws/aws-cli.md) | EC2, S3, IAM, ECR, EKS, CloudWatch, Secrets |
| **AWS Guias** | [tools/aws/](tools/aws/) | LoadBalancer, ELB storage, crear AMI |
| **Argo** | [tools/argo/argo.md](tools/argo/argo.md) | Argo CD y Argo Workflows completo |
| **Ansible** | [ansible/ansible.md](ansible/ansible.md) | playbooks, roles, vault, modulos |
| **Etendo** | [etendo_papiro.md](etendo_papiro.md) | Gradle, RX, backups, configuracion |
| **ZSH/Terminal** | [install-zsh-power10k.md](install-zsh-power10k.md) | instalacion de zsh + powerlevel10k |
| **VMs** | [tools/VMs/qemu-guide.md](tools/VMs/qemu-guide.md) | QEMU/KVM, virt-manager |
| **Observabilidad** | [tools/observabilidad/README.md](tools/observabilidad/README.md) | helmfile para stack de observabilidad |

---

## Links utiles

- [Validar/limpiar manifiestos K8s](https://validkube.com/)
- [Daily.dev - noticias tech](https://app.daily.dev/)
- [Explicar comandos bash](https://explainshell.com/)
- [Documentacion Etendo](https://docs.etendo.software/latest/)

---

## Cheatsheet rapido

### Docker

```bash
docker exec -it <container> /bin/bash
docker logs <container> -f
docker ps -a
docker build -t imagen:tag . && docker push imagen:tag
docker system prune -a        # limpiar TODO (imagenes, contenedores parados, etc)
docker stats --no-stream      # uso de recursos de todos los contenedores
```

### Kubernetes

```bash
kubectl get pods -n <namespace>
kubectl exec -it <pod> -n <namespace> -- /bin/bash
kubectl logs <pod> -n <namespace> -f
kubectl scale deployment/<nombre> --replicas=3 -n <namespace>
kubectl rollout restart deployment/<nombre> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl top pods -n <namespace>
# Copiar archivos
kubectl cp <namespace>/<pod>:/ruta ./local
# Port-forward
kubectl port-forward svc/<servicio> 8080:80 -n <namespace>
```

### Git

```bash
git reset --soft HEAD~<n>           # juntar n commits
git reset --hard HEAD~<n>           # volver n commits atras (destruye cambios)
git clean -fd                        # limpiar archivos no rastreados
git log --oneline --graph --all
git rebase -i HEAD~n                 # rebase interactivo
git stash && git stash pop
git cherry-pick <hash>
git worktree add ../<carpeta> <rama> # multiples copias del repo
```

### Argo CD

```bash
argocd login <IP> --core
argocd app list
argocd app sync <app>
argocd app get <app>
argocd app delete <app>
```

### Argo Workflows

```bash
argo list -n <namespace>
argo logs -n <namespace> <workflow> --follow
argo submit workflow.yaml -n <namespace>
argo delete <workflow> -n <namespace>
```

### SSH

```bash
ssh usuario@host
ssh -L 8080:localhost:80 usuario@host    # forward puerto remoto a local
scp archivo.txt usuario@host:/destino/
ssh-copy-id usuario@host                 # copiar clave publica
```

### Linux rapido

```bash
ps aux --sort=-%cpu | head -5           # procesos por CPU
df -h                                    # espacio en disco
du -sh /ruta/*                          # tamanio de carpetas
lsof -i :80                             # que usa el puerto 80
journalctl -u servicio -f               # logs de un servicio systemd
sudo systemctl status|start|stop|restart servicio
tail -f /var/log/syslog
```

### PostgreSQL

```bash
psql -U usuario -h host -d base_de_datos
pg_dump -U postgres -Fc -f backup.dump mi_db
pg_restore -U postgres -d mi_db -c backup.dump
```

### Helm

```bash
helm upgrade --install <release> <chart> -f values.yaml -n <namespace> --create-namespace
helm list -A
helm history <release> -n <namespace>
helm rollback <release> -n <namespace>
helm template <release> <chart> -f values.yaml   # ver yamls sin aplicar
```

### Terraform

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform state list
terraform destroy -target=recurso.nombre
```

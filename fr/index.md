---
hide:
  - toc
---

<div class="cv-header" markdown>

# Lucas Aguirre

**Ingénieur DevOps & Infrastructure Cloud**

Kubernetes · Jenkins · Argo CD · Docker · Terraform · Helm · AWS

<div class="lang-switcher" markdown>
**:material-web:** &nbsp; [ES](../) &nbsp;·&nbsp; [EN](../en/) &nbsp;·&nbsp; **FR**
</div>

[:fontawesome-brands-linkedin: LinkedIn](https://linkedin.com/in/lucas-aguirre-99-ar){ .md-button .md-button--primary }
[:fontawesome-brands-github: GitHub](https://github.com/LucasAguirre99){ .md-button .md-button--primary }
[:fontawesome-solid-envelope: Email](mailto:aguirrelucas.unrc@gmail.com){ .md-button }
[:fontawesome-solid-file-pdf: Télécharger CV](../assets/CV-2026-DevOps-ENG.pdf){ .md-button }

</div>

---

## Profil

Ingénieur en Télécommunications spécialisé en DevOps avec plus de 2 ans d'expérience dans la gestion d'infrastructure cloud en production. Je travaille quotidiennement avec Kubernetes, Jenkins, Argo CD, Argo Workflows, Docker, Helm, Terraform et AWS, en appliquant les pratiques d'Infrastructure as Code (IaC), GitOps et observabilité complète pour automatiser les processus, garantir la disponibilité des services et optimiser les pipelines CI/CD de bout en bout.

---

## Compétences

<div class="skills-grid" markdown>

<div class="skill-card" markdown>
**Orchestration et Conteneurs**

- Kubernetes (k9s, Helm, Helmfile)
- Docker / Docker Compose
- Gestion de registres d'images (ECR)
- HPAs, PVCs, Ingress, ConfigMaps, Secrets
</div>

<div class="skill-card" markdown>
**CI/CD et GitOps**

- Jenkins (Declarative Pipelines)
- Argo CD (sync automatique, self-heal, rollbacks)
- Argo Workflows (DAGs, CronWorkflows, Templates)
- GitHub Actions
</div>

<div class="skill-card" markdown>
**Cloud et IaC**

- AWS : EC2, S3, IAM, ECR, EKS
- Terraform
- DigitalOcean, Scaleway
- Secrets Manager, Parameter Store
</div>

<div class="skill-card" markdown>
**Observabilité**

- Prometheus + PromQL
- Grafana (dashboards, alertes)
- Loki + LogQL
- Alertmanager
</div>

<div class="skill-card" markdown>
**Systèmes et Automatisation**

- Linux (Ubuntu / Debian / RHEL)
- Scripts Bash
- Python
- Ansible (playbooks, rôles, vault)
- PostgreSQL
</div>

<div class="skill-card" markdown>
**Langues**

- Espagnol — Langue maternelle
- Anglais — Intermédiaire (B1)
- Français — Intermédiaire supérieur (B2)
</div>

</div>

---

## Expérience

<div class="timeline" markdown>

<div class="timeline-item" markdown>
### :material-briefcase: Futit Services
**Ingénieur DevOps** · Mars 2024 – Présent

Responsable de l'infrastructure DevOps des environnements de production et de développement. Gestion du cycle complet : du build de l'image au déploiement en production, en passant par le monitoring et les alertes.

**Kubernetes et Conteneurs**

- Administration de clusters Kubernetes chez DigitalOcean et Scaleway
- Gestion des Deployments, Services, Ingress, ConfigMaps, Secrets, PVCs et HPAs
- Diagnostic de pods et analyse des ressources avec k9s
- Builds d'images Docker multi-stage, gestion des tags et publication dans des registres privés

**CI/CD et GitOps**

- Conception et implémentation de pipelines CI/CD avec Jenkins (Declarative Pipelines) : build, test, push et déploiement
- GitOps avec Argo CD : gestion des Applications, synchronisation automatique, self-heal et rollbacks
- Automatisation des tâches planifiées avec Argo Workflows : DAGs, CronWorkflows et WorkflowTemplates réutilisables
- Automatisation des workflows avec GitHub Actions

**Déploiement d'Applications**

- Gestion du cycle de vie des applications avec Helm (install, upgrade, rollback)
- Gestion multi-releases et multi-environnements avec Helmfile
- Développement et maintenance de charts Helm personnalisés

**Observabilité**

- Stack de monitoring complète : Prometheus, Grafana et Loki
- Requêtes PromQL et LogQL pour dashboards et alertes
- Configuration d'Alertmanager : règles, routage et notifications

**Infrastructure Cloud et IaC (AWS)**

- Gestion des instances EC2, buckets S3, permissions IAM, dépôts ECR et clusters EKS
- Provisionnement d'infrastructure avec Terraform
- Création d'AMIs personnalisées pour standardiser les déploiements
- Gestion des secrets avec AWS Secrets Manager et SSM Parameter Store

**Systèmes et Automatisation**

- Administration de serveurs Linux : pare-feu (UFW), certificats SSL/TLS (certbot/OpenSSL), cron jobs, systemd
- Automatisation de la configuration d'infrastructure avec Ansible (playbooks, rôles, vault)
- Scripts Python et Bash pour les tâches opérationnelles et l'automatisation des processus
- Administration de bases de données PostgreSQL : sauvegardes, restauration, diagnostic de performances
- Sauvegardes automatisées d'applications dans Kubernetes
</div>

<div class="timeline-item" markdown>
### :material-domain: Emprinet 4.0
**Stage DevOps** · Février 2024 – Juin 2024

Déploiement de microservices en appliquant des stratégies DevOps et du clustering avec Kubernetes. Première expérience pratique avec Jenkins, Docker et l'écosystème CI/CD.
</div>

<div class="timeline-item" markdown>
### :material-school: Laboratoire de Radiocommunications — UNRC
**Assistant de Laboratoire** · 2021 – 2023

Participation au projet de virtualisation du laboratoire. Développement de projets de radiocommunications.
</div>

</div>

---

## Formation

<div class="education-grid" markdown>

<div class="edu-card" markdown>
### :material-school: Ingénierie en Télécommunications
**Universidad Nacional de Rio Cuarto (UNRC)**
2018 – 2024
</div>

<div class="edu-card" markdown>
### :material-school: Ingénierie en Télécommunications
**Institut National des Sciences Appliquées de Lyon (INSA Lyon)**
2023 – 2024 · Échange universitaire
</div>

</div>

---

## Certifications et Formations

- :material-certificate: Cybersecurity — Ethical Hacking *(En cours)*
- :material-certificate: AWS Certified Developer Associate DVA-C02 *(En cours)*
- :material-certificate: DevOps avec Docker, Jenkins, Kubernetes, Git, GitFlow, CI/CD
- :material-certificate: Linux pour utilisateurs avancés
- :material-certificate: Algorithmes et Développement de la Logique de Programmation

---

## DevOps Reference Bible

Ce site contient également mon guide de référence personnel avec les commandes et procédures du quotidien.

| Section | Description |
|---------|-------------|
| [Kubernetes](../kubernetes/kubernetes.md) | kubectl complet, k9s, RBAC, troubleshooting |
| [Docker](../docker/docker.md) | Images, conteneurs, compose, Dockerfile |
| [Helm](../helm/helm.md) | Install, upgrade, rollback, helmfile |
| [CI/CD](../ci-cd/ci-cd.md) | Pipelines Jenkins et GitHub Actions |
| [Monitoring](../monitoring/monitoring.md) | Prometheus, Grafana, Loki, Alertmanager |
| [AWS CLI](../tools/aws/aws-cli.md) | EC2, S3, IAM, EKS, ECR et plus |
| [Argo](../tools/argo/argo.md) | Argo CD et Argo Workflows |
| [Ansible](../ansible/ansible.md) | Playbooks, rôles, vault |
| [Databases](../databases/databases.md) | PostgreSQL, MySQL, Redis |
| [Networking](../networking/networking.md) | SSH, DNS, pare-feu, nginx |
| [Linux](../sysadmin-linux.md) | Sysadmin, systemd, disque, cron, SSL |

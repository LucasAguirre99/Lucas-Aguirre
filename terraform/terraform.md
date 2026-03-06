# Terraform - Infraestructura como codigo

## Comandos principales

```bash
# Inicializar directorio (descargar providers y modulos)
terraform init
terraform init -upgrade      # actualizar providers a ultima version permitida
terraform init -reconfigure  # reconfigurar backend

# Ver que va a hacer
terraform plan
terraform plan -out=tfplan         # guardar plan para aplicar despues
terraform plan -var-file=prod.tfvars

# Aplicar cambios
terraform apply
terraform apply tfplan              # aplicar plan guardado
terraform apply -auto-approve       # sin confirmacion interactiva
terraform apply -var-file=prod.tfvars

# Destruir infraestructura
terraform destroy
terraform destroy -auto-approve

# Destruir un recurso especifico
terraform destroy -target=aws_instance.mi_servidor

# Aplicar solo un recurso especifico
terraform apply -target=aws_instance.mi_servidor
```

---

## Estado (State)

```bash
# Ver el estado actual
terraform show
terraform show -json | jq .

# Listar recursos en el estado
terraform state list

# Ver un recurso especifico del estado
terraform state show aws_instance.mi_servidor

# Eliminar un recurso del estado (sin destruirlo en la nube)
terraform state rm aws_instance.mi_servidor

# Mover un recurso en el estado (refactor)
terraform state mv aws_instance.viejo aws_instance.nuevo

# Importar recurso existente al estado
terraform import aws_instance.mi_servidor i-1234567890abcdef0

# Forzar unlock del estado (si quedo bloqueado)
terraform force-unlock <LOCK_ID>

# Mostrar salidas (outputs)
terraform output
terraform output nombre_output
terraform output -json
```

---

## Workspaces

```bash
# Listar workspaces
terraform workspace list

# Crear workspace
terraform workspace new staging

# Cambiar workspace
terraform workspace select production

# Ver workspace actual
terraform workspace show

# Eliminar workspace
terraform workspace delete staging
```

---

## Formato y validacion

```bash
# Formatear codigo
terraform fmt
terraform fmt -recursive    # en todos los subdirectorios

# Validar sintaxis
terraform validate

# Ver grafo de dependencias
terraform graph | dot -Tsvg > grafo.svg
```

---

## Estructura tipica de un proyecto

```
proyecto/
├── main.tf           - recursos principales
├── variables.tf      - declaracion de variables
├── outputs.tf        - outputs del modulo/proyecto
├── versions.tf       - versiones de providers requeridas
├── terraform.tfvars  - valores de variables (NO commitear si tiene secretos)
├── backend.tf        - configuracion del backend (S3, GCS, etc.)
└── modules/
    └── mi-modulo/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Configuracion de providers

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

## Variables

```hcl
# variables.tf
variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "allowed_ips" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "tags" {
  type = map(string)
  default = {
    env = "dev"
  }
}

# Variable sensible (no se muestra en logs)
variable "db_password" {
  type      = string
  sensitive = true
}
```

```hcl
# terraform.tfvars
region         = "eu-west-3"
instance_count = 3
db_password    = "mi-password-seguro"
```

---

## Outputs

```hcl
# outputs.tf
output "instance_ip" {
  value       = aws_instance.servidor.public_ip
  description = "IP publica del servidor"
}

output "db_endpoint" {
  value     = aws_db_instance.postgres.endpoint
  sensitive = true
}
```

---

## Recursos comunes (AWS)

```hcl
# EC2
resource "aws_instance" "servidor" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.publica.id

  tags = {
    Name = "mi-servidor"
    Env  = var.env
  }
}

# S3 Bucket
resource "aws_s3_bucket" "backups" {
  bucket = "mis-backups-${random_id.suffix.hex}"
  tags   = var.tags
}

# Security Group
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.principal.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## Funciones y expresiones utiles

```hcl
# Condicional
instance_type = var.env == "prod" ? "t3.large" : "t3.micro"

# for_each: crear multiples recursos desde una lista/mapa
resource "aws_iam_user" "devops" {
  for_each = toset(["lucas", "maria", "carlos"])
  name     = each.value
}

# count: n copias de un recurso
resource "aws_instance" "workers" {
  count         = var.worker_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  tags = { Name = "worker-${count.index}" }
}

# Data source: referenciar recursos existentes
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

# Local values
locals {
  common_tags = {
    Project   = "mi-proyecto"
    ManagedBy = "terraform"
  }
}

resource "aws_instance" "app" {
  # ...
  tags = merge(local.common_tags, { Name = "app-server" })
}
```

---

## Backend remoto (S3 + DynamoDB)

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "mi-terraform-state"
    key            = "produccion/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"   # para evitar conflictos
  }
}
```

---

## Modulos

```hcl
# Usar un modulo local
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
  env        = var.env
}

# Usar un modulo del Registry de Terraform
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "mi-cluster"
  cluster_version = "1.29"
}

# Referenciar outputs de un modulo
resource "aws_instance" "app" {
  subnet_id = module.vpc.private_subnet_id
}
```

---

## Tips y buenas practicas

```bash
# Ver providers instalados
terraform providers

# Ver el plan en formato JSON (para parsing)
terraform plan -out=tfplan
terraform show -json tfplan | jq '.resource_changes[].change.actions'

# Refrescar estado sin aplicar cambios
terraform refresh   # deprecado, usar apply -refresh-only
terraform apply -refresh-only

# Ver version
terraform version
```

**Reglas de oro:**
- Nunca commitear `terraform.tfvars` si tiene secretos. Usar variables de entorno `TF_VAR_nombre`.
- Usar `.terraform.lock.hcl` en git para versiones consistentes de providers.
- Nunca editar el state file manualmente.
- Usar `terraform plan` siempre antes de `apply`.
- Separar state por entorno (dev/staging/prod) con workspaces o backends distintos.

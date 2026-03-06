# AWS CLI - Referencia completa

## Configuracion

```bash
# Configurar credenciales
aws configure
# Pide: Access Key ID, Secret Access Key, Region, Output format

# Configurar perfil especifico
aws configure --profile produccion

# Ver configuracion actual
aws configure list
aws configure list --profile produccion

# Usar un perfil especifico en un comando
aws s3 ls --profile produccion

# Exportar como variables de entorno (alternativa)
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="eu-west-1"
export AWS_PROFILE="produccion"

# Verificar identidad actual
aws sts get-caller-identity
```

---

## EC2

```bash
# Listar instancias
aws ec2 describe-instances
aws ec2 describe-instances --region eu-west-1

# Listar instancias con formato legible
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# Filtrar por estado
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
  --output table

# Iniciar/parar instancias
aws ec2 start-instances --instance-ids i-1234567890abcdef0
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Ver estado de una instancia
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Crear instancia (ejemplo)
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro \
  --key-name mi-keypair \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678 \
  --count 1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mi-servidor}]'

# Obtener IP publica de una instancia
aws ec2 describe-instances \
  --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text

# Conectar via SSM (sin necesidad de SSH/clave)
aws ssm start-session --target i-1234567890abcdef0
```

---

## S3

```bash
# Listar buckets
aws s3 ls

# Listar contenido de un bucket
aws s3 ls s3://mi-bucket
aws s3 ls s3://mi-bucket/carpeta/ --recursive
aws s3 ls s3://mi-bucket --recursive --human-readable --summarize

# Copiar archivos
aws s3 cp archivo.txt s3://mi-bucket/
aws s3 cp s3://mi-bucket/archivo.txt ./local/
aws s3 cp s3://origen/archivo.txt s3://destino/archivo.txt   # entre buckets

# Sincronizar directorio
aws s3 sync ./local/ s3://mi-bucket/carpeta/
aws s3 sync s3://mi-bucket/carpeta/ ./local/
aws s3 sync ./local/ s3://mi-bucket/ --delete     # mirror exacto (borra lo que no esta en local)
aws s3 sync ./local/ s3://mi-bucket/ --exclude "*.log"

# Mover archivo
aws s3 mv archivo.txt s3://mi-bucket/
aws s3 mv s3://mi-bucket/viejo.txt s3://mi-bucket/nuevo.txt

# Eliminar
aws s3 rm s3://mi-bucket/archivo.txt
aws s3 rm s3://mi-bucket/carpeta/ --recursive

# Crear bucket
aws s3 mb s3://mi-nuevo-bucket
aws s3 mb s3://mi-nuevo-bucket --region eu-west-1

# Eliminar bucket (debe estar vacio)
aws s3 rb s3://mi-bucket
aws s3 rb s3://mi-bucket --force     # forzar (vacia el bucket primero)

# Ver tamanio de un bucket
aws s3 ls s3://mi-bucket --recursive --human-readable --summarize | tail -2

# URL pre-firmada (acceso temporal sin autenticacion)
aws s3 presign s3://mi-bucket/archivo.txt --expires-in 3600   # 1 hora
```

---

## IAM

```bash
# Listar usuarios
aws iam list-users
aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table

# Crear usuario
aws iam create-user --user-name mi-usuario

# Crear access key para un usuario
aws iam create-access-key --user-name mi-usuario

# Listar access keys de un usuario
aws iam list-access-keys --user-name mi-usuario

# Desactivar/eliminar access key
aws iam update-access-key --access-key-id AKIAI... --status Inactive --user-name mi-usuario
aws iam delete-access-key --access-key-id AKIAI... --user-name mi-usuario

# Asignar politica a usuario
aws iam attach-user-policy \
  --user-name mi-usuario \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Ver politicas de un usuario
aws iam list-attached-user-policies --user-name mi-usuario

# Grupos
aws iam list-groups
aws iam create-group --group-name devops
aws iam add-user-to-group --group-name devops --user-name mi-usuario

# Roles
aws iam list-roles
aws iam get-role --role-name mi-rol
aws iam list-attached-role-policies --role-name mi-rol

# Asumir un rol (para cross-account o permissions elevadas)
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/mi-rol \
  --role-session-name mi-sesion
```

---

## ECR (Elastic Container Registry)

```bash
# Login en ECR
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com

# Crear repositorio
aws ecr create-repository --repository-name mi-app --region eu-west-1

# Listar repositorios
aws ecr describe-repositories

# Listar imagenes de un repositorio
aws ecr list-images --repository-name mi-app

# Eliminar imagen
aws ecr batch-delete-image \
  --repository-name mi-app \
  --image-ids imageTag=old-tag

# Eliminar imagenes sin tag (huerfanas)
aws ecr list-images --repository-name mi-app \
  --filter tagStatus=UNTAGGED \
  --query 'imageIds[*]' | \
  xargs -I {} aws ecr batch-delete-image --repository-name mi-app --image-ids {}

# Obtener la URL del registry
aws ecr describe-repositories --query 'repositories[0].repositoryUri'
```

---

## EKS (Elastic Kubernetes Service)

```bash
# Listar clusters
aws eks list-clusters

# Ver detalles de un cluster
aws eks describe-cluster --name mi-cluster

# Actualizar kubeconfig para acceder al cluster
aws eks update-kubeconfig --region eu-west-1 --name mi-cluster
aws eks update-kubeconfig --region eu-west-1 --name mi-cluster --profile produccion

# Listar node groups
aws eks list-nodegroups --cluster-name mi-cluster

# Escalar node group
aws eks update-nodegroup-config \
  --cluster-name mi-cluster \
  --nodegroup-name workers \
  --scaling-config minSize=2,maxSize=5,desiredSize=3

# Ver addons instalados
aws eks list-addons --cluster-name mi-cluster

# Instalar addon
aws eks create-addon \
  --cluster-name mi-cluster \
  --addon-name aws-ebs-csi-driver
```

---

## CloudWatch - Logs

```bash
# Listar log groups
aws logs describe-log-groups

# Ver log streams de un group
aws logs describe-log-streams --log-group-name /aws/lambda/mi-funcion

# Ver logs (ultimos eventos)
aws logs get-log-events \
  --log-group-name /aws/lambda/mi-funcion \
  --log-stream-name "2024/01/01/[$LATEST]abc123"

# Buscar en logs (muy util)
aws logs filter-log-events \
  --log-group-name /var/log/app \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s000)

# Tail de logs en tiempo real
aws logs tail /aws/lambda/mi-funcion --follow
aws logs tail /var/log/app --follow --filter-pattern "ERROR"
```

---

## Route 53 (DNS)

```bash
# Listar hosted zones
aws route53 list-hosted-zones

# Listar registros DNS de una zona
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890

# Crear/actualizar registro DNS
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890 \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.ejemplo.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "1.2.3.4"}]
      }
    }]
  }'
```

---

## Secretos (Secrets Manager y Parameter Store)

```bash
# Secrets Manager
aws secretsmanager list-secrets
aws secretsmanager get-secret-value --secret-id mi-secreto
aws secretsmanager get-secret-value --secret-id mi-secreto \
  --query SecretString --output text

aws secretsmanager create-secret \
  --name mi-secreto \
  --secret-string '{"username":"admin","password":"mi-pass"}'

aws secretsmanager update-secret \
  --secret-id mi-secreto \
  --secret-string '{"username":"admin","password":"nuevo-pass"}'

# Parameter Store (SSM)
aws ssm get-parameter --name /mi-app/prod/db-password
aws ssm get-parameter --name /mi-app/prod/db-password --with-decryption

aws ssm put-parameter \
  --name /mi-app/prod/db-password \
  --value "mi-password" \
  --type SecureString

aws ssm get-parameters-by-path \
  --path /mi-app/prod/ \
  --with-decryption \
  --query 'Parameters[*].[Name,Value]' \
  --output table
```

---

## Tips de productividad

```bash
# Output en diferentes formatos
--output json     # JSON completo
--output table    # tabla legible
--output text     # texto plano (util para scripts)
--output yaml     # YAML

# Queries JMESPath para filtrar output
--query 'Instances[?State.Name==`running`].PublicIpAddress'
--query 'length(Instances)'

# Paginar resultados grandes
aws ec2 describe-instances --page-size 10 --max-items 50

# Ver todos los recursos en una region (AWS Config)
aws configservice list-discovered-resources --resource-type AWS::EC2::Instance

# Dry-run (verificar permisos sin ejecutar)
aws ec2 run-instances --dry-run ...

# Alias util para obtener account ID
alias aws-account='aws sts get-caller-identity --query Account --output text'
```

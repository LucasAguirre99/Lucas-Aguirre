# 🐧 Comandos importantes para el control de los sistemas linux 🐧

Los crontabs se encuentran configurados en la siguiente carpeta ``` /etc/cron.d/ ``` , es importante revisarla ya que podremos ver las configuraciónes de todos los usuarios 

- Para ver los procesos que más cpu están utilizando
```bash
ps aux --sort=-%cpu | head -4

#Un formato más legible:
ps aux --sort=-%cpu | awk 'NR<=4 {printf "%-10s %-6s %-4s %-4s %-10s %s\n", $1, $2, $3, $4, $11, $12}'

# Los 3 que más usan de manera más detallada
ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "PID: %s\nUsuario: %s\nCPU: %s%%\nMemoria: %s%%\nComando: %s %s %s %s\n\n", $2, $1, $3, $4, $11, $12, $13, $14}'
```

- Si queremos ver las estadísticas de uso de cpu 
```bash 
sar -u 1 5

#Para ver el historico
pidstat -u 2 5
```

- Limitar el uso de cpu y memoria en un contenedor: 
```bash
docker update --cpus="1.0" --memory="512m" $CONTAINER_ID

#Ver la estadistica de un contenedor
docker stats --no-stream $CONTAINER_ID
```

## Primeros pasos en un servidor (checklist rápido)
A continuación una lista de acciones y comandos recomendados al abrir un servidor Linux por primera vez. Ajustar según la distribución (Debian/Ubuntu/RHEL/CentOS).

1. Actualizar el sistema
```bash
sudo apt update && sudo apt upgrade -y      # Debian/Ubuntu
sudo dnf update -y                          # RHEL/CentOS/Fedora
```

2. Crear un usuario no-root y darle sudo
```bash
sudo adduser usuario
sudo usermod -aG sudo usuario               # Debian/Ubuntu
# o para RHEL/CentOS:
# sudo usermod -aG wheel usuario
```

3. Habilitar autenticación por llave SSH y deshabilitar login de root
- En el cliente local: generar llave si no existe
```bash
ssh-keygen -t ed25519 -C "tu@correo"
ssh-copy-id usuario@servidor
```
- En el servidor: editar /etc/ssh/sshd_config y ajustar:
```text
PermitRootLogin no
PasswordAuthentication no    # Opcional: dejar en yes hasta verificar llaves
PubkeyAuthentication yes
```
Luego reiniciar ssh:
```bash
sudo systemctl restart sshd
```

4. Configurar firewall básico (UFW) y abrir puertos necesarios
```bash
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp    # HTTP si hace falta
sudo ufw allow 443/tcp   # HTTPS si hace falta
sudo ufw enable
sudo ufw status verbose
```

5. Habilitar actualizaciones automáticas de seguridad
```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

6. Instalar herramientas básicas de diagnóstico
```bash
sudo apt install -y htop curl wget git vim net-tools
```

7. Sincronizar hora y configurar zona horaria
```bash
sudo timedatectl set-timezone Europe/Madrid    # ajustar zona
sudo systemctl enable --now systemd-timesyncd
timedatectl status
```

8. Instalar y configurar Fail2Ban para proteger SSH
```bash
sudo apt install -y fail2ban
# Revisar /etc/fail2ban/jail.local y habilitar [sshd]
sudo systemctl enable --now fail2ban
```

9. Ajustes de kernel y sysctl comunes (ejemplo básico)
- Crear/editar /etc/sysctl.d/99-sysctl.conf
```text
# Mejor manejo de conexiones TCP
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
# Menos uso de swap si se desea
vm.swappiness = 10
```
Aplicar:
```bash
sudo sysctl --system
```

10. Ajustar límites de archivos (ulimits) si ejecutas servidores con muchas conexiones
- En /etc/security/limits.conf:
```text
* soft nofile 65536
* hard nofile 65536
```

11. Configurar hostname y /etc/hosts
```bash
sudo hostnamectl set-hostname mi-servidor
# Editar /etc/hosts para incluir IP y hostname si es necesario
```

12. Revisar servicios y puertos abiertos
```bash
ss -tuln
sudo systemctl list-unit-files --type=service --state=enabled
```

13. Backup y monitoreo básica
- Configurar copias (rsync, duplicity, snapshots) y algún agente de monitoreo (Prometheus node_exporter, Netdata, etc.)
```bash
sudo apt install -y rsync
# Instalar node_exporter o netdata según necesidad
```

Notas rápidas y seguridad:
- Probar siempre cambios en una sesión adicional antes de cerrar la SSH para evitar bloquearte.
- Mantener copias de seguridad de /etc (ssh, sudoers, fstab, network).
- Revisar logs con journalctl y /var/log/auth.log para detectar accesos sospechosos.

---

## systemd y servicios

```bash
# Gestionar servicios
sudo systemctl start <servicio>
sudo systemctl stop <servicio>
sudo systemctl restart <servicio>
sudo systemctl reload <servicio>       # recarga config sin matar el proceso
sudo systemctl status <servicio>
sudo systemctl enable <servicio>       # arrancar al inicio del sistema
sudo systemctl disable <servicio>
sudo systemctl enable --now <servicio> # habilitar + arrancar en un comando
sudo systemctl is-active <servicio>    # devuelve active/inactive (util en scripts)

# Listar servicios
sudo systemctl list-units --type=service
sudo systemctl list-units --type=service --state=running
sudo systemctl list-unit-files --type=service --state=enabled

# Crear servicio propio
# /etc/systemd/system/mi-app.service
[Unit]
Description=Mi aplicacion
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/mi-app
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production PORT=3000

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload            # despues de crear/modificar un .service
sudo systemctl enable --now mi-app
```

---

## journalctl - Logs del sistema

```bash
# Ver todos los logs
journalctl

# Logs de un servicio especifico
journalctl -u nginx
journalctl -u nginx -f                  # follow (en vivo)
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx --since "2024-01-01" --until "2024-01-02"

# Ultimas N lineas
journalctl -u nginx -n 50

# Prioridad (err, warning, info, debug)
journalctl -p err                       # solo errores
journalctl -p warning..err              # warning y errores

# Logs del arranque actual
journalctl -b

# Logs del arranque anterior
journalctl -b -1

# Ver logs del kernel
journalctl -k

# Buscar texto en logs
journalctl -u nginx | grep "error"

# Formato JSON para parsear
journalctl -u nginx -o json | jq .
```

---

## Disco y almacenamiento

```bash
# Ver uso de disco
df -h                                   # espacio de particiones
df -h /                                 # solo la raiz
du -sh /var/log/*                       # tamanio de cada subcarpeta
du -sh * | sort -rh | head -10          # los 10 directorios mas grandes

# Encontrar archivos grandes
find / -type f -size +100M 2>/dev/null
find /var/log -type f -name "*.log" -size +50M

# Listar particiones y discos
lsblk
lsblk -f                                # con filesystem info
fdisk -l                                # con mas detalle (requiere root)
parted -l

# Ver inodos (cuando el disco esta "lleno" pero df dice que hay espacio)
df -i

# Montar y desmontar
sudo mount /dev/sdb1 /mnt/datos
sudo umount /mnt/datos

# Ver montajes actuales
mount | grep -v "^sys\|^proc\|^devt\|^tmpfs"
cat /proc/mounts

# /etc/fstab - montaje permanente
# UUID=xxxx  /mnt/datos  ext4  defaults  0  2
# Obtener UUID de un disco
blkid /dev/sdb1

# Formatear disco (CUIDADO)
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.xfs /dev/sdb1

# Verificar sistema de archivos
sudo fsck /dev/sdb1                     # debe estar desmontado
sudo e2fsck -f /dev/sdb1

# Expandir sistema de archivos (despues de resize del disco)
sudo resize2fs /dev/sda1               # ext4
sudo xfs_growfs /mnt/datos             # xfs
```

---

## Memoria y swap

```bash
# Ver uso de memoria
free -h
free -h -s 5                           # refrescar cada 5 segundos
cat /proc/meminfo

# Ver uso detallado por proceso
ps aux --sort=-%mem | head -10

# Swap
swapon --show
sudo swapoff -a                        # deshabilitar swap
sudo swapon -a                         # habilitar swap segun /etc/fstab

# Crear swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# Para hacerlo permanente agregar en /etc/fstab:
# /swapfile none swap sw 0 0

# Limpiar cache de paginas (con cuidado en prod)
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

---

## Procesos y performance

```bash
# Ver procesos
top
htop                                   # version mejorada de top
ps aux
ps faux                                # con arbol de procesos

# Matar proceso
kill <PID>                             # SIGTERM (elegante)
kill -9 <PID>                          # SIGKILL (forzar)
killall nginx                          # matar por nombre
pkill -f "python script.py"            # matar por patron

# Ver arbol de procesos
pstree
pstree -p                              # con PIDs

# Strace: ver syscalls de un proceso (diagnostico avanzado)
strace -p <PID>
strace comando

# lsof: ver archivos abiertos
lsof -p <PID>                          # archivos abiertos por un proceso
lsof /var/log/nginx.log                # que proceso tiene abierto ese archivo
lsof -u usuario                        # todos los archivos de un usuario
lsof -i TCP:80                         # que proceso usa el puerto 80

# nice: prioridad de proceso (-20 max prioridad, 19 min prioridad)
nice -n 10 comando                     # ejecutar con prioridad baja
renice -n 5 -p <PID>                   # cambiar prioridad de proceso en ejecucion
```

---

## Cron

```bash
# Editar crontab del usuario actual
crontab -e

# Listar crontabs del usuario
crontab -l

# Editar crontab de otro usuario
sudo crontab -u ubuntu -e

# Ver todos los crontabs del sistema
ls /etc/cron.d/
cat /etc/crontab

# Formato: MIN HORA DIA MES DIA_SEMANA COMANDO
# *  *  *  *  *  comando
# |  |  |  |  |
# |  |  |  |  +- dia de semana (0-7, 0 y 7 = domingo)
# |  |  |  +---- mes (1-12)
# |  |  +------- dia del mes (1-31)
# |  +---------- hora (0-23)
# +------------- minuto (0-59)

# Ejemplos
# 0 2 * * *        -> todos los dias a las 2:00 AM
# */5 * * * *      -> cada 5 minutos
# 0 9 * * 1-5      -> lunes a viernes a las 9:00
# 0 0 1 * *        -> el primer dia de cada mes
# @reboot          -> al arrancar el sistema
```

---

## Logs importantes del sistema

```bash
/var/log/syslog          # log general del sistema (Ubuntu)
/var/log/messages        # log general (RHEL/CentOS)
/var/log/auth.log        # autenticaciones SSH, sudo (Ubuntu)
/var/log/secure          # autenticaciones (RHEL/CentOS)
/var/log/kern.log        # mensajes del kernel
/var/log/dpkg.log        # paquetes instalados/removidos (Debian)
/var/log/apt/history.log # historial de apt
/var/log/nginx/          # logs de nginx
/var/log/apache2/        # logs de apache

# Ver intentos de login fallidos
sudo grep "Failed password" /var/log/auth.log | tail -20
sudo grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# Ver ultimas sesiones
last
lastlog
who
w
```

---

## Certificados SSL/TLS con Certbot

```bash
# Instalar certbot
sudo apt update && sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado (nginx)
sudo certbot --nginx -d ejemplo.com -d www.ejemplo.com

# Obtener certificado (apache)
sudo certbot --apache -d ejemplo.com

# Obtener solo el certificado (sin modificar config del servidor)
sudo certbot certonly --webroot -w /var/www/html -d ejemplo.com

# Renovar manualmente
sudo certbot renew

# Probar renovacion sin aplicar
sudo certbot renew --dry-run

# Ver certificados gestionados
sudo certbot certificates

# Eliminar certificado
sudo certbot delete --cert-name ejemplo.com

# La renovacion automatica viene configurada en:
# /etc/cron.d/certbot  o  /lib/systemd/system/certbot.timer
```

---

## OpenSSL - certificados y llaves

```bash
# Ver informacion de un certificado
openssl x509 -in certificado.crt -text -noout
openssl x509 -in certificado.crt -noout -dates    # fechas de validez
openssl x509 -in certificado.crt -noout -subject  # quien es

# Ver certificado de un sitio remoto
echo | openssl s_client -connect ejemplo.com:443 2>/dev/null | openssl x509 -noout -dates
echo | openssl s_client -connect ejemplo.com:443 2>/dev/null | openssl x509 -text

# Verificar si un certificado y una clave privada hacen par
openssl x509 -noout -modulus -in cert.crt | md5sum
openssl rsa  -noout -modulus -in clave.key | md5sum
# Si los hashes coinciden, el par es correcto

# Generar clave privada y certificado autofirmado (dev/testing)
openssl req -x509 -newkey rsa:4096 -keyout clave.key -out cert.crt \
  -days 365 -nodes -subj "/CN=localhost"

# Convertir formatos
openssl pkcs12 -in certificado.p12 -out certificado.pem -nodes  # p12 -> pem
openssl pkcs12 -export -out cert.p12 -inkey clave.key -in cert.crt  # pem -> p12
```

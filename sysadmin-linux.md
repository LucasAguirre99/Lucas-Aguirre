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

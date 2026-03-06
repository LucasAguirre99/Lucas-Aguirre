# Networking - Referencia

---

## Diagnostico de red

```bash
# Ver interfaces de red
ip addr
ip addr show eth0
ifconfig              # forma antigua

# Ver tabla de rutas
ip route
ip route show
route -n              # forma antigua

# Ver conexiones activas y puertos en escucha
ss -tuln              # TCP/UDP, en escucha, sin resolver nombres
ss -tulnp             # + muestra el proceso
ss -s                 # resumen de estadisticas
netstat -tulpn        # equivalente (mas viejo, puede no estar instalado)

# Ver que proceso usa un puerto especifico
ss -tulnp | grep :80
lsof -i :80
lsof -i :443

# Ver conexiones establecidas
ss -tp
ss -tp | grep ESTAB
```

---

## DNS

```bash
# Resolver un dominio
nslookup google.com
nslookup google.com 8.8.8.8       # usando DNS especifico

# dig (mas detallado)
dig google.com
dig google.com A                   # solo registros A (IPv4)
dig google.com AAAA                # solo registros AAAA (IPv6)
dig google.com MX                  # registros de correo
dig google.com NS                  # name servers
dig google.com TXT                 # registros TXT (SPF, DKIM, etc.)
dig google.com CNAME               # registros CNAME
dig @8.8.8.8 google.com           # usar DNS especifico
dig +short google.com              # solo la IP (output limpio)
dig +trace google.com              # traza completa de DNS
dig -x 8.8.8.8                    # reverse DNS (IP -> hostname)

# Ver DNS configurado en el sistema
cat /etc/resolv.conf
resolvectl status                  # en sistemas con systemd-resolved

# Limpiar cache DNS
sudo systemd-resolve --flush-caches
sudo resolvectl flush-caches
```

---

## Conectividad

```bash
# Ping
ping google.com
ping -c 4 google.com              # solo 4 paquetes
ping -i 0.2 google.com            # cada 0.2 segundos

# Traceroute
traceroute google.com
tracepath google.com              # no requiere root
mtr google.com                    # traceroute interactivo + ping continuo

# Probar conectividad a un puerto especifico
telnet host 80                    # si telnet esta instalado
nc -zv host 80                    # netcat, preferible
nc -zv host 80-443               # rango de puertos
echo > /dev/tcp/host/80          # bash nativo (sin herramientas extra)

# Curl para diagnosticar HTTP
curl -v https://api.ejemplo.com/endpoint       # verbose (cabeceras, SSL)
curl -I https://ejemplo.com                    # solo cabeceras
curl -s -o /dev/null -w "%{http_code}" https://ejemplo.com  # solo el codigo HTTP
curl --resolve ejemplo.com:443:1.2.3.4 https://ejemplo.com # forzar IP

# Tiempo de respuesta HTTP desglosado
curl -w "\n\nDNS: %{time_namelookup}s\nConexion TCP: %{time_connect}s\nSSL: %{time_appconnect}s\nPrimer byte: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
  -o /dev/null -s https://ejemplo.com
```

---

## SSH

```bash
# Conexion basica
ssh usuario@host
ssh usuario@host -p 2222          # puerto no estandar
ssh -i ~/.ssh/mi-clave usuario@host

# Ejecutar comando remoto
ssh usuario@host "ls -la /var/log"
ssh usuario@host "sudo systemctl status nginx"

# Copiar archivos
scp archivo.txt usuario@host:/destino/
scp usuario@host:/origen/archivo.txt ./local/
scp -r carpeta/ usuario@host:/destino/    # recursivo

# rsync (mas eficiente que scp para multiples archivos)
rsync -avz carpeta/ usuario@host:/destino/
rsync -avz --delete carpeta/ usuario@host:/destino/   # mirror exacto
rsync -avz -e "ssh -p 2222" carpeta/ usuario@host:/destino/

# Port forwarding (tunneling)
# Local forward: acceder a un servicio remoto localmente
ssh -L 8080:localhost:80 usuario@host
# Despues accedes en localhost:8080 y llega al puerto 80 del servidor remoto

# Remote forward: exponer un servicio local en el servidor remoto
ssh -R 8080:localhost:3000 usuario@host
# Quien acceda al puerto 8080 del servidor remoto llegara a tu puerto 3000 local

# Dynamic SOCKS proxy (tunel para navegar)
ssh -D 1080 usuario@host
# Configurar el proxy SOCKS5 en localhost:1080

# Mantener conexion SSH activa
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 usuario@host

# Modo verboso para diagnosticar problemas
ssh -v usuario@host
ssh -vvv usuario@host             # super verbose

# Configuracion en ~/.ssh/config (muy util)
Host mi-servidor
    HostName 1.2.3.4
    User lucas
    Port 22
    IdentityFile ~/.ssh/mi-clave
    ServerAliveInterval 60

Host bastian
    HostName 10.0.0.1
    User admin
    ProxyJump usuario@bastion-publico.com   # salto via bastion host
```

## Gestion de claves SSH

```bash
# Generar par de claves
ssh-keygen -t ed25519 -C "lucas@ejemplo.com"
ssh-keygen -t rsa -b 4096 -C "lucas@ejemplo.com"   # RSA 4096

# Copiar clave publica al servidor
ssh-copy-id usuario@host
ssh-copy-id -i ~/.ssh/mi-clave.pub usuario@host

# Ver claves cargadas en el agente
ssh-add -l

# Agregar clave al agente
ssh-add ~/.ssh/mi-clave
ssh-add -t 3600 ~/.ssh/mi-clave   # expira en 1 hora

# Ver fingerprint de una clave
ssh-keygen -lf ~/.ssh/mi-clave.pub
```

---

## Firewall (UFW - Ubuntu)

```bash
# Estado
sudo ufw status
sudo ufw status verbose
sudo ufw status numbered          # con numero de reglas

# Habilitar/deshabilitar
sudo ufw enable
sudo ufw disable

# Permitir puertos
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080:8090/tcp      # rango de puertos

# Permitir por servicio
sudo ufw allow OpenSSH
sudo ufw allow http
sudo ufw allow https

# Permitir desde IP especifica
sudo ufw allow from 192.168.1.100
sudo ufw allow from 192.168.1.0/24 to any port 22

# Denegar
sudo ufw deny 23/tcp

# Eliminar regla
sudo ufw delete allow 80/tcp
sudo ufw delete 3                 # eliminar por numero

# Reset (cuidado: borra todo)
sudo ufw reset
```

## Firewall (firewalld - RHEL/CentOS)

```bash
# Estado
sudo firewall-cmd --state
sudo firewall-cmd --list-all

# Habilitar servicio/puerto
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8080/tcp

# Eliminar regla
sudo firewall-cmd --permanent --remove-port=8080/tcp

# Aplicar cambios permanentes
sudo firewall-cmd --reload
```

---

## iptables (bajo nivel)

```bash
# Ver reglas
sudo iptables -L -n -v
sudo iptables -L -n -v --line-numbers

# Permitir trafico entrante en un puerto
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Bloquear IP
sudo iptables -A INPUT -s 1.2.3.4 -j DROP

# Eliminar regla por numero
sudo iptables -D INPUT 3

# Guardar reglas
sudo iptables-save > /etc/iptables/rules.v4
sudo iptables-restore < /etc/iptables/rules.v4
```

---

## tcpdump (captura de trafico)

```bash
# Ver todo el trafico de red
sudo tcpdump

# Capturar en interfaz especifica
sudo tcpdump -i eth0

# Filtrar por host
sudo tcpdump host 1.2.3.4
sudo tcpdump src 1.2.3.4          # solo origen
sudo tcpdump dst 1.2.3.4          # solo destino

# Filtrar por puerto
sudo tcpdump port 80
sudo tcpdump port 443

# Capturar HTTP (sin SSL)
sudo tcpdump -i eth0 -A port 80   # -A muestra el contenido en ASCII

# Guardar captura en archivo para analizar con Wireshark
sudo tcpdump -i eth0 -w captura.pcap

# Leer archivo pcap
sudo tcpdump -r captura.pcap

# Ver solo cabeceras (mas legible)
sudo tcpdump -i eth0 port 80 -n -s 0 -A | grep -E "GET|POST|HTTP"
```

---

## Conceptos de red para DevOps

### Rangos de IP privadas (RFC 1918)
```
10.0.0.0/8        (10.0.0.0 - 10.255.255.255)
172.16.0.0/12     (172.16.0.0 - 172.31.255.255)
192.168.0.0/16    (192.168.0.0 - 192.168.255.255)
127.0.0.0/8       (loopback)
```

### Puertos comunes
```
22    SSH
25    SMTP
53    DNS (UDP/TCP)
80    HTTP
443   HTTPS
3306  MySQL
5432  PostgreSQL
6379  Redis
27017 MongoDB
8080  HTTP alternativo / Tomcat
9090  Prometheus
3000  Grafana
```

### CIDR notation
```
/8  = 255.0.0.0     = 16 millones de IPs
/16 = 255.255.0.0   = 65534 IPs
/24 = 255.255.255.0 = 254 IPs
/28 = 255.255.255.240 = 14 IPs
/32 = host especifico (1 IP)
```

---

## Nginx - Configuracion rapida

```bash
# Estado y control
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl reload nginx     # recarga config sin downtime
sudo systemctl restart nginx

# Verificar configuracion
sudo nginx -t
sudo nginx -T                   # mostrar config completa

# Ver logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Configuracion de proxy reverso basica

```nginx
# /etc/nginx/sites-available/mi-app
server {
    listen 80;
    server_name mi-app.ejemplo.com;

    # Redirigir HTTP -> HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name mi-app.ejemplo.com;

    ssl_certificate /etc/letsencrypt/live/mi-app.ejemplo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mi-app.ejemplo.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Habilitar el sitio
sudo ln -s /etc/nginx/sites-available/mi-app /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

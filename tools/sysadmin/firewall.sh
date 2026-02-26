#!/bin/bash

# =================================================================
# SCRIPT DE CONFIGURACIÓN DE SEGURIDAD ESCALABLE
# Puertos Permitidos: 22 (SSH), 80 (HTTP), 443 (HTTPS)
# Soporte: Ubuntu + Docker (Fix bypass)
# =================================================================

# 1. Asegurar privilegios de root
if [ "$EUID" -ne 0 ]; then 
  echo "Por favor, ejecuta como root (sudo ./setup-firewall.sh)"
  exit
fi

echo "--- Iniciando configuración de seguridad ---"

# 2. Resetear UFW a valores de fábrica (Limpieza preventiva)
echo "[1/5] Reseteando UFW..."
ufw --force reset

# 3. Configurar políticas por defecto
echo "[2/5] Estableciendo políticas: Deny Incoming / Allow Outgoing..."
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

# 4. Abrir puertos esenciales
echo "[3/5] Abriendo puertos 22, 80 y 443..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# 5. Parche para Docker (Bypass Fix)
echo "[4/5] Aplicando parche ufw-docker..."
wget -O /usr/local/bin/ufw-docker https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
chmod +x /usr/local/bin/ufw-docker

# Instalar la modificación en los archivos after.rules de UFW
ufw-docker install

# 6. Activar Firewall
echo "[5/5] Activando UFW..."
ufw --force enable

# 7. Verificación final
echo "-------------------------------------------"
echo "¡CONFIGURACIÓN COMPLETADA CON ÉXITO!"
echo "-------------------------------------------"
ufw status verbose
echo "-------------------------------------------"
echo "RECUERDA: Los puertos de Docker (3000, 8080, etc.) ahora están BLOQUEADOS desde afuera."
echo "Si necesitas abrir uno de Docker al mundo, usa: ufw-docker allow [NOMBRE_CONTENEDOR] [PUERTO]"
#!/bin/bash

set -e

echo "🧰 Actualizando e instalando dependencias..."
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "🔐 Agregando clave GPG oficial de Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "📦 Agregando repositorio de Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔄 Actualizando índice de paquetes..."
sudo apt update

echo "📥 Instalando Docker Engine, CLI y plugins..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Docker instalado correctamente. Verificando con 'hello-world'..."
sudo docker run --rm hello-world

echo "🔧 Agregando el usuario actual al grupo docker (para evitar sudo)..."
sudo usermod -aG docker $USER
echo "⚠️ Cierre y vuelva a iniciar sesión para aplicar los cambios de grupo."

echo "🧪 Verificando docker-compose..."
docker compose version || echo "➡️ Usa 'docker compose' (con espacio) en lugar de 'docker-compose'."

echo "🎉 ¡Docker y Docker Compose instalados exitosamente!"

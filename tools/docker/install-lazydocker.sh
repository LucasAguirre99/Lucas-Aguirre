#!/bin/bash

# Versión fija o dinámica
LAZYDOCKER_VERSION="0.24.1"
ARCH="Linux_x86_64"
FILE="lazydocker_${LAZYDOCKER_VERSION}_${ARCH}.tar.gz"
URL="https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/${FILE}"

echo "➡️ Descargando LazyDocker versión ${LAZYDOCKER_VERSION}..."

curl -Lo lazydocker.tar.gz "$URL"

echo "📦 Descomprimiendo..."
tar -xzf lazydocker.tar.gz

echo "🚚 Moviendo a /usr/local/bin..."
sudo mv lazydocker /usr/local/bin/

echo "🧹 Limpiando archivos..."
rm lazydocker.tar.gz

echo "✅ Instalación completada. Ejecutá lazydocker para comenzar."

#!/bin/bash

# Colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}--- Iniciando Configuración de Terminal ---${NC}"

# 1. Instalar dependencias base
echo -e "${GREEN}1. Instalando dependencias básicas...${NC}"
sudo apt update && sudo apt install -y zsh wget git curl

# 2. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}2. Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${BLUE}-> Oh My Zsh ya está instalado.${NC}"
fi

# 3. Temas y Plugins
echo -e "${GREEN}3. Instalando Powerlevel10k y Plugins...${NC}"
CUSTOM_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# P10k
[ ! -d "$CUSTOM_DIR/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$CUSTOM_DIR/themes/powerlevel10k"
# Autosuggestions
[ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_DIR/plugins/zsh-autosuggestions"
# Syntax Highlighting
[ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"

# 4. Sincronizar archivos de configuración
echo -e "${GREEN}4. Sincronizando archivos .zshrc y .p10k.zsh...${NC}"
# Copiamos del repositorio al HOME del usuario
cp .zshrc ~/
cp .p10k.zsh ~/

echo -e "${BLUE}--- ¡Todo listo! Reinicia tu terminal o ejecuta 'zsh' ---${NC}"

#!/usr/bin/env bash
cd "$(dirname "$0")/.."

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Instalando Prerrequisitos (Mac/Linux)                ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

OS="$(uname -s)"
DECK_VERSION="1.59.1"

if [ "$OS" = "Darwin" ]; then
    echo -e "${GREEN}Detectado macOS. Usando Homebrew...${NC}"
    
    # 1) Instalar herramientas base de Apple si no existen (solo advertencia)
    echo "Asegúrate de haber ejecutado: xcode-select --install"
    
    # 2) Instalar Homebrew si no está instalado
    if ! command -v brew &> /dev/null; then
        echo "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    echo "Actualizando Homebrew..."
    brew update
    
    echo "Instalando herramientas CLI..."
    for cmd in git curl jq node; do
        if ! command -v $cmd &> /dev/null; then
            brew install $cmd || true
        else
            echo "$cmd ya instalado"
        fi
    done
    
    if ! command -v python3 &> /dev/null; then brew install python@3.12 || true; else echo "python3 ya instalado"; fi
    
    echo "Instalando aplicaciones desktop (Docker, Insomnia, VS Code)..."
    if ! command -v docker &> /dev/null; then brew install --cask docker || true; else echo "docker ya instalado"; fi
    if ! brew list --cask insomnia &> /dev/null; then brew install --cask insomnia || true; else echo "insomnia ya instalado"; fi
    if ! command -v code &> /dev/null; then brew install --cask visual-studio-code || true; else echo "vscode ya instalado"; fi

elif [ "$OS" = "Linux" ]; then
    echo -e "${GREEN}Detectado Linux. Usando apt-get...${NC}"
    
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release git jq unzip python3 python3-pip
    
    # Docker
    if ! command -v docker &> /dev/null; then
        echo "Instalando Docker..."
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || true
        sudo chmod a+r /etc/apt/keyrings/docker.gpg || true
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker $USER || true
    fi
    
    # Terraform
    
    # Node.js
    if ! command -v node &> /dev/null; then
        echo "Instalando Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # decK
    
    echo -e "${YELLOW}Nota para Linux: Descarga Insomnia manualmente desde https://insomnia.rest/download${NC}"

else
    echo -e "${RED}Sistema Operativo no soportado por este script: $OS${NC}"
    exit 1
fi

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN} Validación Rápida de Herramientas${NC}"
echo -e "${GREEN}======================================================${NC}"

git --version || echo -e "${RED}git falló${NC}"
curl --version | head -n 1 || echo -e "${RED}curl falló${NC}"
jq --version || echo -e "${RED}jq falló${NC}"
python3 --version || python --version || echo -e "${RED}python falló${NC}"
node -v || echo -e "${RED}node falló${NC}"
npm -v || echo -e "${RED}npm falló${NC}"
docker version --format 'Docker Client: {{.Client.Version}}' || echo -e "${RED}docker falló (¿el daemon está corriendo?)${NC}"
docker compose version || echo -e "${RED}docker compose falló${NC}"

echo -e "\n${GREEN}¡Instalación y Validación Completada!${NC}"

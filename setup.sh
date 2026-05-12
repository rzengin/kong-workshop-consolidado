#!/usr/bin/env bash

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Preparando Entorno para Ejercicio Final Consolidado  ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

# 1. Validación de variables de entorno para Konnect
if [[ -z "$KONNECT_TOKEN" ]]; then
  echo -e "${RED}Error:${NC} La variable de entorno KONNECT_TOKEN no está definida."
  echo "Por favor define KONNECT_TOKEN antes de continuar:"
  echo 'export KONNECT_TOKEN="kpat_..."'
  exit 1
fi

# Usamos CONTROL_PLANE_NAME si existe en el entorno, sino CP_EXTERNAL, o por defecto 'Local Gateway'
if [[ -n "$CONTROL_PLANE_NAME" ]]; then
  CP_TARGET="$CONTROL_PLANE_NAME"
elif [[ -n "$CP_EXTERNAL" ]]; then
  CP_TARGET="$CP_EXTERNAL"
else
  echo -e "${YELLOW}Advertencia:${NC} No se definió CONTROL_PLANE_NAME ni CP_EXTERNAL. Usando 'Local Gateway' por defecto."
  CP_TARGET="Local Gateway"
fi

# 2. Levantar el mock backend (KongAir)
echo -e "\n${GREEN}[1/3] Levantando backend simulado (KongAir) con Docker Compose...${NC}"
docker compose up -d

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN} ¡Backend listo! Ya puedes continuar con la creación de infraestructura.${NC}"
echo -e " KongAir Backend: http://localhost:8081"
echo -e "${GREEN}======================================================${NC}\n"

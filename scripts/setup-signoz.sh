#!/usr/bin/env bash

cd "$(dirname "$0")/.."
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Inicializando Plataforma de Observabilidad (SigNoz)  ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

# 1. Verificar si Docker está corriendo
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}Error:${NC} Docker no está corriendo. Por favor inicia Docker Desktop o el demonio de Docker y vuelve a intentar."
  exit 1
fi

# 2. Levantar SigNoz
echo -e "\n${GREEN}[1/2] Levantando contenedores de SigNoz (esto puede tardar unos minutos la primera vez)...${NC}"
echo -e "${YELLOW}Limpiando cualquier instalación previa para asegurar un inicio limpio...${NC}"
cd signoz-deploy/
docker compose -f docker/docker-compose.yaml down -v
docker compose -f docker/docker-compose.yaml up -d

echo -e "\n${GREEN}[2/2] Verificando estado...${NC}"
echo -e "Esperando a que el frontend inicie correctamente..."
sleep 5

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN} ¡SigNoz está corriendo!${NC}"
echo -e " UI (Dashboard): http://localhost:8080"
echo -e " (Nota: En el primer ingreso a la UI se te pedirá crear una cuenta de administrador local)"
echo -e " OTLP Endpoint (Traces/Logs): http://localhost:4318 (HTTP)"
echo -e "${GREEN}======================================================${NC}\n"

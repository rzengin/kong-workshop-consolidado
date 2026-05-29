$ErrorActionPreference = "Stop"

Set-Location -Path $PSScriptRoot\..
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host -ForegroundColor Yellow " Inicializando Plataforma de Observabilidad (SigNoz)  "
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host ""



Write-Host -ForegroundColor Green "`n[1/2] Levantando contenedores de SigNoz (esto puede tardar unos minutos la primera vez)..."
Write-Host -ForegroundColor Yellow "Limpiando cualquier instalación previa para asegurar un inicio limpio..."
Set-Location "signoz-deploy"
docker compose -f docker/docker-compose.yaml down -v
docker compose -f docker/docker-compose.yaml up -d
Set-Location ".."

Write-Host -ForegroundColor Green "`n[2/2] Verificando estado..."
Write-Host "Esperando a que el frontend inicie correctamente..."
Start-Sleep -Seconds 5

Write-Host -ForegroundColor Green "`n======================================================"
Write-Host -ForegroundColor Green " ¡SigNoz está corriendo!"
Write-Host " UI (Dashboard): http://localhost:8080"
Write-Host " (Nota: En el primer ingreso a la UI se te pedirá crear una cuenta de administrador local)"
Write-Host " OTLP Endpoint (Traces/Logs): http://localhost:4318 (HTTP)"
Write-Host -ForegroundColor Green "======================================================"
Write-Host ""

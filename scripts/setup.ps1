$ErrorActionPreference = "Stop"

Set-Location -Path $PSScriptRoot\..
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host -ForegroundColor Yellow " Preparando Entorno para Ejercicio 001  "
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host ""

Write-Host -ForegroundColor Green "`n[1/1] Levantando backend simulado (KongAir) con Docker Compose..."
docker compose up -d

Write-Host -ForegroundColor Green "`n======================================================"
Write-Host -ForegroundColor Green " ¡Backend listo! Ya puedes continuar con la creación de infraestructura."
Write-Host " KongAir Backend: http://localhost:9081"
Write-Host -ForegroundColor Green "======================================================"
Write-Host ""

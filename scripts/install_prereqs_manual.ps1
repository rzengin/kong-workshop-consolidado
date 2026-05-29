Set-Location -Path $PSScriptRoot\..

Write-Host -ForegroundColor Yellow "======================================================"
Write-Host -ForegroundColor Yellow " Instalando Prerrequisitos (Windows PowerShell)       "
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host ""

Write-Host -ForegroundColor Green "Comprobando dependencias de virtualizacion (WSL)..."
if (!(wsl --status 2>$null)) {
    Write-Host -ForegroundColor Yellow "Instalando WSL (requerido para Docker)..."
    wsl --install --no-launch
    Write-Host -ForegroundColor Red "ATENCION: Es posible que necesites reiniciar tu equipo despues de instalar WSL."
} else {
    Write-Host "WSL ya esta habilitado."
}

Write-Host ""
Write-Host -ForegroundColor Green "Actualizando el catalogo de paquetes para obtener las ultimas versiones..."
winget source update | Out-Null

Write-Host ""
Write-Host -ForegroundColor Green "Usando winget para instalar paquetes..."
if (!(Get-Command git -ErrorAction SilentlyContinue)) { winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements } else { Write-Host 'git ya instalado' }
if (!(Get-Command docker -ErrorAction SilentlyContinue)) { winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements } else { Write-Host 'docker ya instalado' }
if (!(winget list --id Kong.Insomnia 2>$null)) { winget install --id Kong.Insomnia -e --accept-source-agreements --accept-package-agreements } else { Write-Host 'insomnia ya instalado' }
if (!(Get-Command node -ErrorAction SilentlyContinue)) { winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements } else { Write-Host 'node ya instalado' }
if (!(Get-Command code -ErrorAction SilentlyContinue)) { winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements --accept-package-agreements } else { Write-Host 'code ya instalado' }
if (!(Get-Command jq -ErrorAction SilentlyContinue)) { winget install --id jqlang.jq -e --accept-source-agreements --accept-package-agreements } else { Write-Host 'jq ya instalado' }


Write-Host ""
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host -ForegroundColor Yellow " Validacion Rapida de Herramientas                    "
Write-Host -ForegroundColor Yellow "======================================================"
Write-Host ""

git --version
curl.exe --version
jq --version
node -v
npm -v
docker version
docker compose version
wsl --status

Write-Host ""
Write-Host -ForegroundColor Green "======================================================"
Write-Host -ForegroundColor Green "¡Instalacion y Validacion Completada!"
Write-Host -ForegroundColor Green "(Es posible que necesites reiniciar la terminal para "
Write-Host -ForegroundColor Green " que los cambios de PATH hagan efecto para decK)"
Write-Host -ForegroundColor Green "======================================================"
Write-Host ""

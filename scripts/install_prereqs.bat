@ECHO OFF
cd /d %~dp0..
COLOR 0E

ECHO ======================================================
ECHO  Instalando Prerrequisitos (Windows CMD)
ECHO ======================================================
ECHO.
COLOR 0A

ECHO Comprobando dependencias de virtualizacion (WSL)...
wsl --status >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO Instalando WSL ^(requerido para Docker^)...
    wsl --install --no-launch
    ECHO ATENCION: Es posible que necesites reiniciar tu equipo despues de instalar WSL.
) ELSE (
    ECHO WSL ya esta habilitado.
)

ECHO.
ECHO Actualizando el catalogo de paquetes para obtener las ultimas versiones...
winget source update >nul 2>nul

ECHO.
ECHO Usando winget para instalar paquetes...
WHERE git >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO git ya instalado )
WHERE docker >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO docker ya instalado )
winget list --id Kong.Insomnia >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id Kong.Insomnia -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO insomnia ya instalado )
WHERE terraform >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id Hashicorp.Terraform -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO terraform ya instalado )
WHERE node >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO node ya instalado )
WHERE code >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO code ya instalado )
WHERE jq >nul 2>nul
IF %ERRORLEVEL% NEQ 0 ( winget install --id jqlang.jq -e --accept-source-agreements --accept-package-agreements ) ELSE ( ECHO jq ya instalado )

ECHO.
ECHO Descargando e instalando Kong decK...
IF EXIST "%USERPROFILE%\bin\deck.exe" (
    ECHO deck ya instalado
) ELSE (
    SET DECK_VERSION=1.59.1
    curl -L -o "%USERPROFILE%\Downloads\deck.tar.gz" "https://github.com/Kong/deck/releases/download/v1.59.1/deck_1.59.1_windows_amd64.tar.gz"
    IF NOT EXIST "%USERPROFILE%\bin" mkdir "%USERPROFILE%\bin"
    tar -xzf "%USERPROFILE%\Downloads\deck.tar.gz" -C "%USERPROFILE%\bin"
    setx PATH "%PATH%;%USERPROFILE%\bin"
)

ECHO.
COLOR 0E
ECHO ======================================================
ECHO  Validacion Rapida de Herramientas
ECHO ======================================================
COLOR 0A

git --version
curl.exe --version
jq --version
node -v
npm -v
docker version
docker compose version
"%USERPROFILE%\bin\deck.exe" version
terraform version
wsl --status

ECHO.
ECHO ======================================================
ECHO ¡Instalacion y Validacion Completada!
ECHO (Es posible que necesites reiniciar la terminal para
ECHO  que los cambios de PATH hagan efecto para decK)
ECHO ======================================================
ECHO.

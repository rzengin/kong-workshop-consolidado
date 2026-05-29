@ECHO OFF
cd /d %~dp0..
COLOR 0E
ECHO ======================================================
ECHO  Preparando Entorno para Ejercicio 001  
ECHO ======================================================
ECHO.
COLOR 0A
ECHO [1/1] Levantando backend simulado (KongAir) con Docker Compose...
docker compose up -d

ECHO.
ECHO ======================================================
ECHO  ¡Backend listo! Ya puedes continuar con la creacion de infraestructura.
ECHO  KongAir Backend: http://localhost:9081
ECHO ======================================================
ECHO.

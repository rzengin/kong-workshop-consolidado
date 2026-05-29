@ECHO OFF
cd /d %~dp0..
COLOR 0E
ECHO ======================================================
ECHO  Inicializando Plataforma de Observabilidad (SigNoz)  
ECHO ======================================================
ECHO.

COLOR 0A
ECHO [1/2] Levantando contenedores de SigNoz (esto puede tardar unos minutos la primera vez)...
COLOR 0E
ECHO Limpiando cualquier instalacion previa para asegurar un inicio limpio...
cd signoz-deploy
docker compose -f docker/docker-compose.yaml down -v
docker compose -f docker/docker-compose.yaml up -d
cd ..

COLOR 0A
ECHO.
ECHO [2/2] Verificando estado...
ECHO Esperando a que el frontend inicie correctamente...
timeout /t 5 /nobreak > NUL

ECHO.
ECHO ======================================================
ECHO  ¡SigNoz esta corriendo!
ECHO  UI (Dashboard): http://localhost:8080
ECHO  (Nota: En el primer ingreso a la UI se te pedira crear una cuenta de administrador local)
ECHO  OTLP Endpoint (Traces/Logs): http://localhost:4318 (HTTP)
ECHO ======================================================
ECHO.

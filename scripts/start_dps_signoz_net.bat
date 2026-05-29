@echo off
cd /d "%~dp0\.."

for /f "tokens=1* delims==" %%a in (endpoints.env) do (
    for /f "tokens=2" %%c in ("%%a") do set "%%c=%%b"
)

docker rm -f kong-dp-external kong-dp-internal 2>nul

echo Starting kong-dp-external...
docker run -d --name kong-dp-external ^
  --network signoz-net ^
  -p 28000:28000 -p 28443:28443 ^
  -e "KONG_ROLE=data_plane" ^
  -e "KONG_DATABASE=off" ^
  -e "KONG_CLUSTER_MTLS=pki" ^
  -e "KONG_CLUSTER_CONTROL_PLANE=%EXTERNAL_CONTROL%:443" ^
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=%EXTERNAL_TELEMETRY%:443" ^
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" ^
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" ^
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" ^
  -e "KONG_KONNECT_MODE=on" ^
  -e "KONG_VITALS=off" ^
  -e "KONG_TRACING_INSTRUMENTATIONS=all" ^
  -e "KONG_TRACING_SAMPLING_RATE=1.0" ^
  -e "KONG_PROXY_LISTEN=0.0.0.0:28000, 0.0.0.0:28443 ssl" ^
  -v "%cd%/certs/external:/certs" ^
  kong/kong-gateway:3.14.0.0

echo Starting kong-dp-internal...
docker run -d --name kong-dp-internal ^
  --network signoz-net ^
  -p 18000:18000 -p 18443:18443 ^
  -e "KONG_ROLE=data_plane" ^
  -e "KONG_DATABASE=off" ^
  -e "KONG_CLUSTER_MTLS=pki" ^
  -e "KONG_CLUSTER_CONTROL_PLANE=%INTERNAL_CONTROL%:443" ^
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=%INTERNAL_TELEMETRY%:443" ^
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" ^
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" ^
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" ^
  -e "KONG_KONNECT_MODE=on" ^
  -e "KONG_VITALS=off" ^
  -e "KONG_TRACING_INSTRUMENTATIONS=all" ^
  -e "KONG_TRACING_SAMPLING_RATE=1.0" ^
  -e "KONG_PROXY_LISTEN=0.0.0.0:18000, 0.0.0.0:18443 ssl" ^
  -v "%cd%/certs/internal:/certs" ^
  kong/kong-gateway:3.14.0.0

echo Done.

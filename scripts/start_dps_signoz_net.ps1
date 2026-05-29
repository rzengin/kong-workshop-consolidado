Set-Location -Path $PSScriptRoot\..

Get-Content endpoints.env | ForEach-Object {
    if ($_ -match '^export\s+(.*)=(.*)$') {
        Set-Item -Path "env:\$($matches[1])" -Value $matches[2]
    }
}

docker rm -f kong-dp-external kong-dp-internal 2>$null

Write-Host "Starting kong-dp-external..."
docker run -d --name kong-dp-external `
  --network signoz-net `
  -p 28000:28000 -p 28443:28443 `
  -e "KONG_ROLE=data_plane" `
  -e "KONG_DATABASE=off" `
  -e "KONG_CLUSTER_MTLS=pki" `
  -e "KONG_CLUSTER_CONTROL_PLANE=$env:EXTERNAL_CONTROL`:443" `
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=$env:EXTERNAL_TELEMETRY`:443" `
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" `
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" `
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" `
  -e "KONG_KONNECT_MODE=on" `
  -e "KONG_VITALS=off" `
  -e "KONG_TRACING_INSTRUMENTATIONS=all" `
  -e "KONG_TRACING_SAMPLING_RATE=1.0" `
  -e "KONG_PROXY_LISTEN=0.0.0.0:28000, 0.0.0.0:28443 ssl" `
  -v "$PWD/certs/external:/certs" `
  kong/kong-gateway:3.14.0.0

Write-Host "Starting kong-dp-internal..."
docker run -d --name kong-dp-internal `
  --network signoz-net `
  -p 18000:18000 -p 18443:18443 `
  -e "KONG_ROLE=data_plane" `
  -e "KONG_DATABASE=off" `
  -e "KONG_CLUSTER_MTLS=pki" `
  -e "KONG_CLUSTER_CONTROL_PLANE=$env:INTERNAL_CONTROL`:443" `
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=$env:INTERNAL_TELEMETRY`:443" `
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" `
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" `
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" `
  -e "KONG_KONNECT_MODE=on" `
  -e "KONG_VITALS=off" `
  -e "KONG_TRACING_INSTRUMENTATIONS=all" `
  -e "KONG_TRACING_SAMPLING_RATE=1.0" `
  -e "KONG_PROXY_LISTEN=0.0.0.0:18000, 0.0.0.0:18443 ssl" `
  -v "$PWD/certs/internal:/certs" `
  kong/kong-gateway:3.14.0.0

Write-Host "Done."

#!/bin/bash
cd "$(dirname "$0")/.."
set -e
source endpoints.env

echo "Starting kong-dp-external..."
docker run -d --name kong-dp-external --network host \
  -e "KONG_ROLE=data_plane" \
  -e "KONG_DATABASE=off" \
  -e "KONG_CLUSTER_MTLS=pki" \
  -e "KONG_CLUSTER_CONTROL_PLANE=$EXTERNAL_CONTROL:443" \
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=$EXTERNAL_TELEMETRY:443" \
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" \
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" \
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" \
  -e "KONG_KONNECT_MODE=on" \
  -e "KONG_VITALS=off" \
  -e "KONG_TRACING_INSTRUMENTATIONS=all" \
  -e "KONG_TRACING_SAMPLING_RATE=1.0" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:28000, 0.0.0.0:28443 ssl" \
  -v "$(pwd)/certs/external:/certs" \
  kong/kong-gateway:3.4.0.0

echo "Starting kong-dp-internal..."
docker run -d --name kong-dp-internal --network host \
  -e "KONG_ROLE=data_plane" \
  -e "KONG_DATABASE=off" \
  -e "KONG_CLUSTER_MTLS=pki" \
  -e "KONG_CLUSTER_CONTROL_PLANE=$INTERNAL_CONTROL:443" \
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=$INTERNAL_TELEMETRY:443" \
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" \
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" \
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" \
  -e "KONG_KONNECT_MODE=on" \
  -e "KONG_VITALS=off" \
  -e "KONG_TRACING_INSTRUMENTATIONS=all" \
  -e "KONG_TRACING_SAMPLING_RATE=1.0" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:18000, 0.0.0.0:18443 ssl" \
  -v "$(pwd)/certs/internal:/certs" \
  kong/kong-gateway:3.4.0.0

echo "Done."

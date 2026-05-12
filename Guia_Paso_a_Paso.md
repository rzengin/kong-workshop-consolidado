<div align="center">
  <h1>🚀 Kong API Gateway & Konnect</h1>
  <h2>Workshop Oficial: Ejercicio Final Consolidado</h2>
  <br>
  <p><strong>Edición GitOps & Observabilidad Avanzada (SigNoz)</strong></p>
  <p><em>Duración Estimada: 130 minutos</em></p>
  <br>
</div>

---

## 📑 Índice de Contenidos

- [A. Pre-requisitos y convención de puertos (10 min)](#a-pre-requisitos-y-convención-de-puertos-10-min)
  - [A.1 Pre-requisitos mínimos](#a1-pre-requisitos-mínimos)
  - [A.2 Variables para comandos (Ajustadas a tu entorno local)](#a2-variables-para-comandos-ajustadas-a-tu-entorno-local)
- [B. Secuencia de ejercicios (120 min)](#b-secuencia-de-ejercicios-120-min)
  - [B.1 Validación base del flujo de tráfico (5 min)](#b1-validación-base-del-flujo-de-tráfico-5-min)
  - [B.2 Gobierno: separación por Control Plane (External/Internal/Global) (10 min)](#b2-gobierno-separación-por-control-plane-external/internal/global-10-min)
  - [B.3 Creación de Data Planes y Convención de Puertos (15 min)](#b3-creación-de-data-planes-y-convención-de-puertos-15-min)
- [B.4 Observabilidad Global: Promoción de Estándares a través del Control Plane Global (10 min)](#b4-observabilidad-global-promoción-de-estándares-a-través-del-control-plane-global-10-min)
  - [B.5 Gobierno: Teams y RBAC (5 min)](#b5-gobierno-teams-y-rbac-5-min)
- [B.6 Sincronización del estado base de APIs (10 min)](#b6-sincronización-del-estado-base-de-apis-10-min)
- [B.7 Control de exposición: matching por método HTTP (5 min)](#b7-control-de-exposición-matching-por-método-http-5-min)
- [B.8 Seguridad: autenticación con Key Auth (10 min)](#b8-seguridad-autenticación-con-key-auth-10-min)
- [B.9 Seguridad: autorización con ACL (10 min)](#b9-seguridad-autorización-con-acl-10-min)
- [B.10 Control de tráfico: rate limiting diferenciado por Consumer (10 min)](#b10-control-de-tráfico-rate-limiting-diferenciado-por-consumer-10-min)
- [B.11 Transformación: Response Transformer (5 min)](#b11-transformación-response-transformer-5-min)
- [B.12 Transformación: Request Transformer (OPCIONAL) (10 min)](#b12-transformación-request-transformer-opcional-10-min)
- [B.13 Trazabilidad: request/correlation identifier (5 min)](#b13-trazabilidad-request/correlation-identifier-5-min)
- [B.14 Seguridad adicional: IP Restriction (5 min)](#b14-seguridad-adicional-ip-restriction-5-min)
- [B.15 Observabilidad: Konnect Analytics Explorer (5 min)](#b15-observabilidad-konnect-analytics-explorer-5-min)

---

```mermaid
flowchart TB
    subgraph SaaS ["Kong Konnect (Cloud SaaS)"]
        CP_G[Control Plane: Global]
        CP_E[Control Plane: External]
        CP_I[Control Plane: Internal]
    end

    subgraph Local ["Red Local (Laptop del Alumno)"]
        DP_E["Data Plane (Port 28000)"]
        DP_I["Data Plane (Port 18000)"]
        
        Mock_E["Backend Flights/Routes (Port 8081)"]
        Mock_I["Backend Customers/Bookings (Port 8081)"]
        
        SigNoz["SigNoz OTel Collector (Port 4318)"]
    end

    Client["Cliente / cURL"]

    CP_E -. "Sincroniza Políticas" .-> DP_E
    CP_I -. "Sincroniza Políticas" .-> DP_I
    CP_G -. "Promueve Observabilidad" .-> CP_E

    Client -- "Petición HTTP" --> DP_E
    DP_E -- "Proxy" --> Mock_E
    DP_E == "Envía Trazas y Logs" ==> SigNoz
```

A continuación, encontrarás la guía paso a paso para cumplir con el alcance del **Ejercicio Final Consolidado** de Kong. En este ejercicio aplicaremos políticas de exposición, seguridad, control de tráfico, transformaciones y observabilidad, gestionando la configuración a través de Kong Konnect y decK.

---

## A. Pre-requisitos y convención de puertos (10 min)

### A.1 Pre-requisitos mínimos

* Konnect accesible desde el navegador (usuario con permisos para administrar Control Planes, Services, Routes y Plugins).
* Data Plane local operativo y en estado In Sync en el Control Plane correspondiente.
* Backends de ejemplo disponibles ejecutándose como contenedores.
* Herramienta de prueba: cURL o Insomnia.
* CLI de `terraform` instalado localmente (se usará para crear la infraestructura base como Control Planes y Teams).
* decK instalado localmente (se usa para exportar/promover configuración de APIs).
* Verificar que tienen los contenedores backend de Kong Air funcionando. Se puede usar el script provisto para levantarlos (solamente el backend, la configuración de Kong se hará más adelante):

```bash
cd ./ejercicio-final-consolidado
./setup.sh
```

* **Instalar SigNoz como contenedor local** para la sección de observabilidad. Se provee un script que clona y levanta los contenedores oficiales:
```bash
./setup-signoz.sh
```

### A.2 Variables para comandos (Ajustadas a tu entorno local)

Dado que cuentas con una instancia de Kong configurada, asegúrate de tener estas variables de entorno en tu sistema operativo antes de operar con `decK`:

* `export KONNECT_ADDR="https://us.api.konghq.com"`
* `export KONNECT_TOKEN="kpat_***"`
* `export CONTROL_PLANE_ID="********-****-****-****-********"`
* `export CONTROL_PLANE_NAME='Local Gateway'`

*(Nota: En ejercicios donde se solicite usar `CP_EXTERNAL`, puedes utilizar directamente `$CONTROL_PLANE_NAME` apuntando a tu "Local Gateway")*

---

## B. Secuencia de ejercicios (120 min)

### B.1 Validación base del flujo de tráfico (5 min)
**Objetivo:** confirmar conectividad y establecer una línea base para comparar cambios de configuración.

1. En Konnect: Gateway Manager -> Control Plane -> Data Plane Nodes. Verificar estado In Sync.
2. En la terminal: confirmar contenedores y puertos:
   ```bash
   docker ps --format "table {{.Names}}\t{{.Ports}}"
   ```
3. Para validar que KongAir responde correctamente a través del Gateway, recomendamos probar el flujo:

#### Opción A: Usando Insomnia (Recomendado)
1. Abre **Insomnia** y crea un nuevo proyecto (por ejemplo, `Workshop KongAir`).
2. Haz clic en **Create** -> **Import** y selecciona el archivo de especificación OpenAPI (`kongair-openapi.yaml`).
3. Repite el proceso de **Import** para cargar la colección de pruebas (`kongair-postman-collection.json`).
4. Ejecuta la petición **1. GET /flights** para validar conectividad. En este estado base (sin seguridad aplicada), la ruta servirá para comprobar que Kong enruta el tráfico al backend.

#### Opción B: Usando cURL (Alternativa Sencilla)
Probar endpoint base (External):
```bash
curl -i http://localhost:8000/flights
```
> **Nota:** Dependiendo de la configuración de puertos de tu entorno (`8000` o `28000`), ajusta el puerto. Si falla, prueba con `28000`.

4. Registrar el resultado (HTTP status `200`) para usarlo como baseline.

---

### B.2 Gobierno: separación por Control Plane (External/Internal/Global) (10 min)
**Objetivo:** mostrar segmentación de configuración y permisos por dominio funcional, automatizando la infraestructura con **Terraform**.

En lugar de crear los Control Planes de forma manual, usaremos Infraestructura como Código (IaC) para asegurar repetibilidad y trazabilidad.

1. Abre tu terminal y navega al directorio `terraform` de este ejercicio:
   ```bash
   cd ./ejercicio-final-consolidado/terraform
   ```
2. Inicializa Terraform y valida el código:
   ```bash
   terraform init
   terraform validate
   ```
3. Aplica los cambios proporcionando tu token (la primera vez). Esto creará los Control Planes `KongAir_External`, `KongAir_Internal` y `KongAir_Global`:
   ```bash
   terraform apply -var="konnect_token=$KONNECT_TOKEN"
   ```
4. En Konnect: Confirma visualmente en **Gateway Manager** la creación de los tres Control Planes.

### B.3 Creación de Data Planes y Convención de Puertos (15 min)

Una vez que los Control Planes han sido creados (Paso B.2), deben conectarse a instancias físicas o virtuales que procesen el tráfico, conocidas como Data Planes.

En un laboratorio que emula tres ámbitos distintos (External, Internal y Global), cada Data Plane debe ejecutarse como un proceso o contenedor independiente y exponer puertos distintos en la máquina (host) para evitar conflictos de red.

1. En **Gateway Manager** (Konnect), ingresa al Control Plane `KongAir_External`.
2. Dirígete a **Data Plane Nodes** y haz clic en **New Data Plane Node**.
3. Selecciona tu plataforma (por ejemplo, Linux / Docker) y copia el script de inicio generado.
4. **Modificación del Script:** Pega el script en un editor de texto (como Notepad o VSCode) ANTES de ejecutarlo, para realizar dos ajustes críticos:
   * **Puertos:** Ajusta los puertos expuestos (`-p`) para que coincidan con la tabla de la convención de abajo (ej. `-p 28000:8000`).
   * **Observabilidad:** Inyecta las variables `KONG_TRACING_INSTRUMENTATIONS` y `KONG_TRACING_SAMPLING_RATE` para habilitar el traceo.

   **Ejemplo de cómo debería quedar tu comando para el Control Plane External:**
   ```bash
   docker run -d --name kong-dp-external \
     --network host \
     -e "KONG_ROLE=data_plane" \
     -e "KONG_DATABASE=off" \
     -e "KONG_VITALS_TTL_DAYS=732" \
     -e "KONG_CLUSTER_MTLS=pki" \
     -e "KONG_CLUSTER_CONTROL_PLANE=xxxxxxxxxx.us.cp.konghq.com:443" \
     -e "KONG_CLUSTER_SERVER_NAME=xxxxxxxxxx.us.cp.konghq.com" \
     -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=xxxxxxxxxx.us.tp.konghq.com:443" \
     -e "KONG_CLUSTER_TELEMETRY_SERVER_NAME=xxxxxxxxxx.us.tp.konghq.com" \
     -e "KONG_CLUSTER_CERT=-----BEGIN CERTIFICATE-----..." \
     -e "KONG_CLUSTER_CERT_KEY=-----BEGIN EC PRIVATE KEY-----..." \
     -e "KONG_TRACING_INSTRUMENTATIONS=all" \
     -e "KONG_TRACING_SAMPLING_RATE=1.0" \
     -p 28000:8000 \
     -p 28100:8100 \
     kong/kong-gateway:3.9.0.0-ubuntu
   ```

5. **Convención de Puertos a respetar:**

| Ámbito | Proxy HTTP (host) | Metrics / Status (host) |
| --- | --- | --- |
| External | `-p 28000:8000` | `-p 28100:8100` |
| Internal | `-p 18000:8000` | `-p 18100:8100` |
| Global | N/A | N/A |

6. Ejecuta tu comando modificado para el **External** y verifica que aparezca "In Sync" en la UI de Konnect.
7. (Opcional) Repite el proceso generando un nuevo certificado en el Control Plane `KongAir_Internal`, y adapta el script usando los puertos `18000` y `18100`.
---

## B.4 Observabilidad Global: Promoción de Estándares a través del Control Plane Global (10 min)
**Objetivo:** demostrar el valor arquitectónico de usar un Control Plane Global como repositorio central de políticas (sin Data Planes) y promover la política de observabilidad (SigNoz) a otros Control Planes mediante `deck gateway apply`.

1. Crea un nuevo archivo llamado `00-estado-base-global.yaml` (o usa la *Vía Rápida* con `archivos-deck/09-b15-estado-base-global.yaml`). Este archivo **solo** contendrá los plugins transversales, sin rutas ni servicios:
   ```yaml
   _format_version: "3.0"
   plugins:
     - name: opentelemetry
       config:
         traces_endpoint: http://host.docker.internal:4318/v1/traces
         logs_endpoint: http://host.docker.internal:4318/v1/logs
         resource_attributes:
           service.name: kong-api-gateway
   ```
2. **Sincroniza el estándar al Control Plane Global:** Esto guardará la configuración centralizada, aunque el Global CP no ejecute tráfico.
   ```bash
   deck gateway sync 00-estado-base-global.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "KongAir_Global"
   ```
3. **Promoción de Estándares (Previsualización):** Usa el comando `diff` contra tu Control Plane `External`. Verás que decK te indica que *añadirá* el plugin `opentelemetry`, sin destruir tus rutas y servicios existentes. (Si usáramos `sync` aquí, borraría todo tu trabajo anterior).
   ```bash
   deck gateway diff 00-estado-base-global.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "KongAir_External"
   ```
4. **Aplicar (Merge) el estándar al External:** Usa el comando `apply` para inyectar este plugin transversal en tu CP External de manera segura.
   ```bash
   deck gateway apply 00-estado-base-global.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "KongAir_External"
   ```
5. **Nota Importante:** Aún no podemos generar tráfico ni ver resultados en SigNoz porque el Control Plane External está vacío. En el paso B.6 cargaremos las APIs y haremos la primera validación.

### B.5 Gobierno: Teams y RBAC (5 min)
**Objetivo:** demostrar delegación de administración y aislamiento de permisos.

*(Nota: Terraform ya aplicó esta configuración en el paso anterior, aquí solo realizaremos la validación)*

1. En Konnect: Ve a **Organization -> Teams**. Verifica la creación de los dos equipos: `External Developers` e `Internal Developers`.
2. Haz clic en el equipo `External Developers` y revisa sus roles. Verás que tiene asignado `Control Plane Admin` únicamente para `KongAir_External`.
3. Haz lo mismo con `Internal Developers` y valida que solo tienen permisos sobre `KongAir_Internal`.
4. Con esto, confirmamos que los permisos están correctamente acotados por Control Plane y que la infraestructura base está lista para recibir las APIs.

---


## B.6 Sincronización del estado base de APIs (10 min)
**Objetivo:** poblar los Control Planes External e Internal con sus respectivos servicios base usando decK, respetando el aislamiento de dominios.

1. Abre tu terminal en el directorio raíz del ejercicio (`ejercicio-final-consolidado`).
2. **IMPORTANTE:** Como en el paso B.4 inyectamos una política global de observabilidad, si hacemos un `sync` ahora mismo borraríamos ese plugin. Para mantener la política global en nuestro repositorio local, abre `00-estado-base-external.yaml` y añade el plugin `opentelemetry` al inicio del archivo:
   ```yaml
   _format_version: "3.0"
   plugins:
     - name: opentelemetry
       config:
         traces_endpoint: http://host.docker.internal:4318/v1/traces
         logs_endpoint: http://host.docker.internal:4318/v1/logs
         resource_attributes:
           service.name: kong-api-gateway
   services:
   # ...
   ```
3. Sincroniza las APIs públicas (`flights`, `routes`) al Control Plane **External**:
   ```bash
   deck gateway sync 00-estado-base-external.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "KongAir_External"
   ```
4. Sincroniza las APIs privadas (`customers`, `bookings`) al Control Plane **Internal**:
   ```bash
   deck gateway sync 00-estado-base-internal.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "KongAir_Internal"
   ```
5. En Konnect: Verifica en **Gateway Manager** que `KongAir_External` tenga 2 servicios, y `KongAir_Internal` tenga otros 2 servicios.
6. Ahora que las APIs existen, valida que puedes consumir la ruta externa recién sincronizada a través de tu Data Plane External:
   ```bash
   curl -i http://localhost:28000/flights
   ```
7. **Primera Validación de Observabilidad:** Abre SigNoz (usualmente en `http://localhost:3301`). Ve a la sección **Traces** y verifica que aparezca la traza de tu llamada exitosa a `/flights`. A partir de ahora, usaremos SigNoz para ver el efecto de todas nuestras políticas de seguridad.

---

> [!TIP]
> **Vía Rápida vs Vía Manual:** Desde la sección B.6 en adelante, tienes dos opciones:
> 1. **Vía Manual:** Abrir tu propio archivo `00-estado-base-external.yaml` y editarlo a mano siguiendo los snippets (recomendado para aprender la sintaxis).
> 2. **Vía Rápida:** Si no quieres lidiar con la indentación de YAML, dentro de la carpeta `archivos-deck/` encontrarás la solución exacta para cada paso. Puedes simplemente ejecutar `deck gateway sync archivos-deck/XX-bY-nombre.yaml ...`

## B.7 Control de exposición: matching por método HTTP (5 min)
**Objetivo:** reducir la superficie expuesta restringiendo los métodos en una Route mediante configuración declarativa.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong Gateway
    participant B as Backend
    C->>K: HTTP GET /flights
    K->>B: Reenvía GET
    B-->>K: 200 OK
    K-->>C: 200 OK
    C->>K: HTTP POST /flights
    K-->>C: 404 No Route Matched
```

1. Abre el archivo `00-estado-base-external.yaml` y agrega `methods: ["GET"]` a la ruta `flights-route`:
   ```yaml
   services:
     - name: flights
       url: http://host.docker.internal:8081/anything/flights
       routes:
         - name: flights-route
           paths:
             - /flights
           methods:
             - GET
   ```
2. Sincroniza los cambios:
   ```bash
   deck gateway sync 00-estado-base-external.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "KongAir_External"
   ```
3. Probar el método permitido y uno no permitido:
   ```bash
   curl -i http://localhost:28000/flights
   curl -i -X POST http://localhost:28000/flights
   ```
   **Resultado esperado:** `200 OK` para el GET y `404 No Route Matched` para el POST.

---

## B.8 Seguridad: autenticación con Key Auth (10 min)
**Objetivo:** centralizar la autenticación en el Gateway declarando plugins y Consumers.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong (Key Auth)
    participant B as Backend
    C->>K: GET /flights
    K-->>C: 401 Unauthorized (No key found)
    C->>K: GET /flights + Header: apikey: xxx
    K->>K: Valida apikey contra Consumer
    K->>B: Reenvía petición
    B-->>C: 200 OK
```

1. En el archivo `00-estado-base-external.yaml`, agrega el plugin `key-auth` al servicio `flights` y define dos Consumers (`App-External` y `App-Internal`) con credenciales fijas al final del archivo:
   ```yaml
   services:
     - name: flights
       url: http://host.docker.internal:8081/anything/flights
       plugins:
         - name: key-auth
           config:
             key_names:
               - apikey
       routes: # ... (resto de la configuración)
       
   consumers:
     - username: App-External
       keyauth_credentials:
         - key: external-secret-123
     - username: App-Internal
       keyauth_credentials:
         - key: internal-secret-123
   ```
2. Sincroniza los cambios con `deck gateway sync`.
3. Probar sin credencial y con credencial:
   ```bash
   curl -i http://localhost:28000/flights
   curl -i http://localhost:28000/flights -H "apikey: external-secret-123"
   ```
   **Resultado esperado:** `401 Unauthorized` sin llave y `200 OK` con llave. (Verifica en SigNoz cómo Kong registra la traza del 401).

---

## B.9 Seguridad: autorización con ACL (10 min)
**Objetivo:** diferenciar autenticación de autorización y restringir acceso declarando grupos ACL.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong (ACL Plugin)
    participant B as Backend
    C->>K: GET /flights (apikey: internal-secret-123)
    K->>K: Identifica Consumer: App-Internal
    K->>K: Verifica Grupos: Consumer pertenece a 'internal'
    K->>K: ACL permite: 'external'
    K-->>C: 403 Forbidden (No puede consumir esta API)
```

1. Modifica `00-estado-base-external.yaml` para agregar el plugin `acl` al servicio `flights` y asignar los grupos a los Consumers:
   ```yaml
   services:
     - name: flights
       plugins:
         - name: key-auth
           config:
             key_names: [apikey]
         - name: acl
           config:
             allow:
               - external
   # ...
   consumers:
     - username: App-External
       acls:
         - group: external
       keyauth_credentials:
         - key: external-secret-123
     - username: App-Internal
       acls:
         - group: internal
       keyauth_credentials:
         - key: internal-secret-123
   ```
2. Sincroniza los cambios con `deck gateway sync`.
3. Probar con ambas credenciales:
   ```bash
   curl -i http://localhost:28000/flights -H "apikey: internal-secret-123"
   curl -i http://localhost:28000/flights -H "apikey: external-secret-123"
   ```
   **Resultado esperado:** `403 Forbidden` para App-Internal y `200 OK` para App-External. (Abre SigNoz y observa cómo la política ACL bloqueó el request).

---

## B.10 Control de tráfico: rate limiting diferenciado por Consumer (10 min)
**Objetivo:** aplicar límites distintos por perfil de consumo anidando plugins en Consumers.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong (Rate Limiting)
    C->>K: Request #1 (App-Internal)
    K->>K: Incrementa contador (1/3)
    K-->>C: 200 OK
    C->>K: Request #4 (App-Internal)
    K->>K: Incrementa contador (4/3) -> Límite excedido
    K-->>C: 429 Too Many Requests
```

1. En `00-estado-base-external.yaml`, agrega el plugin `rate-limiting` a cada Consumer:
   ```yaml
   consumers:
     - username: App-External
       plugins:
         - name: rate-limiting
           config:
             minute: 20
             policy: local
       # ... acls y credentials ...
     - username: App-Internal
       plugins:
         - name: rate-limiting
           config:
             minute: 3
             policy: local
       # ... acls y credentials ...
   ```
2. Sincroniza los cambios con `deck gateway sync`.
3. Generar tráfico para probar los límites:
   ```bash
   for i in {1..6}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:28000/flights -H "apikey: internal-secret-123"; done
   ```
   Verás que App-Internal llega a `429 Too Many Requests` muy rápido. Abre SigNoz para visualizar la explosión de requests bloqueados (429).

---

## B.11 Transformación: Response Transformer (5 min)
**Objetivo:** inyectar headers de respuesta sin modificar el backend.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong (Response Transformer)
    participant B as Backend
    C->>K: GET /flights
    K->>B: Reenvía GET
    B-->>K: 200 OK + Header: Via
    K->>K: Elimina Header 'Via'
    K->>K: Inyecta Header 'x-perceptiva: true'
    K-->>C: Respuesta Modificada
```

1. En `00-estado-base-external.yaml`, agrega el plugin a la ruta `flights-route`:
   ```yaml
       routes:
         - name: flights-route
           paths:
             - /flights
           methods:
             - GET
           plugins:
             - name: response-transformer
               config:
                 add:
                   headers:
                     - "x-perceptiva: true"
                 remove:
                   headers:
                     - "Via"
   ```
2. Sincroniza los cambios.
3. Probar y verificar los headers de respuesta:
   ```bash
   curl -i http://localhost:28000/flights -H "apikey: external-secret-123"
   ```

---

## B.12 Transformación: Request Transformer (OPCIONAL) (10 min)
**Objetivo:** enriquecer requests hacia el upstream creando nuevos servicios y rutas de prueba.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong (Request Transformer)
    participant B as Backend
    C->>K: GET /get
    K->>K: Inyecta Header 'x-inter-env: lab'
    K->>B: Petición Modificada
    B-->>C: 200 OK
```

1. Agrega el siguiente bloque al final de `services:` en `00-estado-base-external.yaml` (apuntando a `/get` en el mock backend):
   ```yaml
     - name: get-test
       url: http://host.docker.internal:8081/get
       routes:
         - name: get-route
           paths:
             - /get
           plugins:
             - name: request-transformer
               config:
                 add:
                   headers:
                     - "x-inter-env: lab"
   ```
2. Sincroniza los cambios.
3. Probar y validar en el JSON de respuesta que el backend recibió `X-Inter-Env: lab`:
   ```bash
   curl -s http://localhost:28000/get
   ```

---

## B.13 Trazabilidad: request/correlation identifier (5 min)
**Objetivo:** inyectar IDs de correlación globales agregando un plugin a nivel de Control Plane.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant K as Kong (Correlation ID)
    participant B as Backend
    C->>K: GET /flights
    K->>K: Genera UUID
    K->>B: Inyecta Header 'X-Correlation-Id: uuid-1234'
    B-->>K: 200 OK
    K->>K: echo_downstream = true
    K-->>C: 200 OK + Header 'X-Correlation-Id: uuid-1234'
```

1. Al principio de `00-estado-base-external.yaml`, antes o después de `services:`, agrega la declaración global de plugins:
   ```yaml
   _format_version: "3.0"
   plugins:
     - name: correlation-id
       config:
         header_name: x-correlation-id
         echo_downstream: true
         generator: uuid
   services:
     # ...
   ```
2. Sincroniza los cambios.
3. Ejecutar una llamada y observar el header `X-Correlation-Id` en la respuesta:
   ```bash
   curl -i http://localhost:28000/flights -H "apikey: external-secret-123"
   ```

---

## B.14 Seguridad adicional: IP Restriction (5 min)
**Objetivo:** aplicar restricción por IP directamente en una ruta.

```mermaid
sequenceDiagram
    participant C as Cliente (Otra IP)
    participant L as Cliente (localhost 127.0.0.1)
    participant K as Kong (IP Restriction)
    C->>K: GET /flights
    K-->>C: 403 Forbidden
    L->>K: GET /flights
    K->>K: Valida whitelist (127.0.0.1 permitida)
    K->>Backend: Reenvía petición
```

1. En la ruta `flights-route` de `00-estado-base-external.yaml`, agrega el plugin `ip-restriction`:
   ```yaml
           plugins:
             - name: response-transformer
               # ...
             - name: ip-restriction
               config:
                 allow:
                   - 127.0.0.1
   ```
2. Sincroniza los cambios.
3. Probar desde localhost y desde otra IP (si es posible) para ver el rechazo `403 Forbidden`. Revisa en SigNoz cómo la validación de IP corta la petición antes de llegar al upstream.

---

## B.15 Observabilidad: Konnect Analytics Explorer (5 min)
**Objetivo:** visualizar tráfico, errores y segmentación sin herramientas adicionales.

1. En Konnect, ve a **Analytics -> Explorer**. Selecciona el rango de los últimos 15 minutos.
2. Filtra por Service/Route `flights`.
3. Identifica patrones generados: `401` (sin apikey), `403` (ACL/IP restriction), `429` (rate limiting), `200` (tráfico permitido).

---

¡Felicidades! Has completado el laboratorio implementando un Gateway moderno, gestionado declarativamente (GitOps) y con observabilidad avanzada.

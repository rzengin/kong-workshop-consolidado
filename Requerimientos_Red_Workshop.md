# Requerimientos de Red - Workshop Kong Konnect

El siguiente documento detalla los requisitos de conectividad necesarios para la correcta ejecución del entorno del workshop, el cual incluye los Data Planes de Kong (Interno y Externo), la plataforma de observabilidad SigNoz y microservicios de prueba locales.

---

## 1. Reglas de Entrada (Inbound)
*Permitir que el tráfico llegue a la máquina/servidor donde se ejecuta el entorno del workshop.*

| Origen (Source) | Destino (Destination) | Puerto | Protocolo | Servicio / Proceso | Descripción (Justificación) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **18000** | TCP | Kong DP (Interno) | Tráfico HTTP entrante hacia el API Gateway Interno. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **18443** | TCP | Kong DP (Interno) | Tráfico HTTPS entrante hacia el API Gateway Interno. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **28000** | TCP | Kong DP (Externo) | Tráfico HTTP entrante hacia el API Gateway Externo. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **28443** | TCP | Kong DP (Externo) | Tráfico HTTPS entrante hacia el API Gateway Externo. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **8080** | TCP | SigNoz UI | Acceso a la interfaz web del dashboard de observabilidad. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **9081** | TCP | KongAir Backend | (Opcional) Acceso directo al microservicio backend de pruebas. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **8090** | TCP | KongAir Flights | (Opcional) Acceso directo al microservicio de vuelos. |

---

## 2. Reglas de Salida (Outbound) - CRÍTICAS
*Permitir que la máquina del workshop se comunique con Internet (SaaS y Repositorios).*

| Origen (Source) | Destino (Destination) | Puerto | Protocolo | Descripción (Justificación) |
| :--- | :--- | :---: | :---: | :--- |
| IP de la Máquina / Servidor | `*.konghq.com` | **443** | TCP (HTTPS) | **Esencial para Kong Konnect.** Los Data Planes locales necesitan conectarse al Control Plane en la nube para descargar configuración y enviar telemetría de forma continua. |
| IP de la Máquina / Servidor | `hub.docker.com` / `ghcr.io` | **443** | TCP (HTTPS) | Necesario para que Docker pueda descargar las imágenes de Kong, SigNoz y microservicios. |
| IP de la Máquina / Servidor | `github.com` / `*.githubusercontent.com` | **443** | TCP (HTTPS) | Necesario para la clonación de repositorios del workshop o descarga de scripts/ejercicios. |

---

### Notas Adicionales
* **Servicios Internos:** Los puertos de la base de datos interna de SigNoz (ClickHouse: `8123`, `9000` y Zookeeper: `2181`) y los de ingesta de OpenTelemetry (`4317`, `4318`) operan exclusivamente sobre la red privada virtual de Docker. No es necesario exponerlos a nivel del firewall corporativo.
* **Ejecución en Localhost:** Si este entorno se ejecuta estrictamente en la estación de trabajo personal de cada participante, las reglas *Inbound* solo deben garantizar que el firewall del SO (Windows Defender, macOS Firewall, o Antivirus) no bloquee los puertos de escucha locales. Las reglas *Outbound* siguen siendo obligatorias a nivel perimetral.

# ==============================================================================
# B.2 Gobierno: Separación por Control Plane
# ==============================================================================

# 1. Control Plane External
resource "konnect_gateway_control_plane" "kongair_external" {
  name         = "KongAir_External"
  description  = "Control Plane para tráfico externo de KongAir"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pinned_client_certs"
}

# 2. Control Plane Internal
resource "konnect_gateway_control_plane" "kongair_internal" {
  name         = "KongAir_Internal"
  description  = "Control Plane para tráfico interno de KongAir"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pinned_client_certs"
}

# 3. Control Plane Global (Repositorio de Estándares)
resource "konnect_gateway_control_plane" "kongair_global" {
  name         = "KongAir_Global"
  description  = "Control Plane Global como repositorio de estándares"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pinned_client_certs"
}


# ==============================================================================
# B.3 Gobierno: Teams y RBAC
# ==============================================================================

# 1. Equipos (Teams)
resource "konnect_team" "external_developers" {
  name        = "External Developers"
  description = "Equipo a cargo del desarrollo y mantenimiento de APIs externas"
}

resource "konnect_team" "internal_developers" {
  name        = "Internal Developers"
  description = "Equipo a cargo del desarrollo y mantenimiento de APIs internas"
}

# 2. Asignación de Roles (RBAC)

# El equipo External Developers administra el Control Plane External
resource "konnect_team_role" "external_devs_role" {
  team_id          = konnect_team.external_developers.id
  entity_id        = konnect_gateway_control_plane.kongair_external.id
  entity_region    = "us"
  role_name        = "Admin"
  entity_type_name = "Control Planes"
}

# El equipo Internal Developers administra el Control Plane Internal
resource "konnect_team_role" "internal_devs_role" {
  team_id          = konnect_team.internal_developers.id
  entity_id        = konnect_gateway_control_plane.kongair_internal.id
  entity_region    = "us"
  role_name        = "Admin"
  entity_type_name = "Control Planes"
}

data "google_compute_network" "network" {
  name    = var.network_name
  project = var.project_id
}

data "google_client_config" "default" {}

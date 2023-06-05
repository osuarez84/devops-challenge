

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_compute_subnetwork" "nodes" {
  ip_cidr_range = var.subnets["nodes"]
  name          = "nodes"
  network       = data.google_compute_network.network.id
}



resource "google_container_cluster" "cluster" {
  name                     = var.cluster_name
  description              = "Terraform managed"
  remove_default_node_pool = true
  networking_mode          = "VPC_NATIVE"
  location                 = var.region
  network                  = data.google_compute_network.network.self_link
  subnetwork               = google_compute_subnetwork.nodes.self_link
  project                  = var.project_id
  initial_node_count       = 1
  resource_labels = {
    "terraform" = "managed"
  }

  release_channel {
    channel = "UNSPECIFIED"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.subnets["pods"]
    services_secondary_range_name = var.subnets["services"]
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "09:00"
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.masters_cidr
  }
}

resource "google_container_node_pool" "pool" {
  for_each = var.pools_map

  cluster            = google_container_cluster.cluster.name
  location           = google_container_cluster.cluster.location
  project            = var.project_id
  name_prefix        = each.key
  node_locations     = each.value.zones
  initial_node_count = 1


  node_config {
    disk_type    = "pd-standard"
    disk_size_gb = each.value.disk_size
    image_type   = "cos_containerd"
    labels       = each.value.labels
    machine_type = each.value.machine_type
    preemptible  = each.value.preemptible
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    metadata = {
      "disable-legacy-endpoints" = true
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  autoscaling {
    max_node_count  = each.value.autoscaling.max
    min_node_count  = each.value.autoscaling.min
    location_policy = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [initial_node_count]
  }
}

resource "kubernetes_namespace" "namespace" {
  for_each = var.k8s_namespaces

  metadata {
    name        = each.key
    labels      = each.value.labels
    annotations = each.value.annotations
  }
}
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}


provider "helm" {
  kubernetes {
    host  = "https://${module.gke.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      module.gke.cluster_ca_certificate
    )
  }
}

provider "http" {}
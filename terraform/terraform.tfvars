cluster_name = "production"

project_id = "devops-challenge"

masters_cidr = "10.14.64.0/27"

# network_name      = "default"

subnets = {
  nodes    = "10.0.0.1/24"
  pods     = "10.0.1.0/24"
  services = "10.0.1.0/25"
}



k8s_namespaces = {
  apps = {
    labels      = {}
    annotations = {}
  }
  cert-manager = {
    labels      = {}
    annotations = {}
  }
}

####

timezone = "Europe/Madrid"
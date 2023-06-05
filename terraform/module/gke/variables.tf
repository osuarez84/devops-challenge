
variable "cluster_name" {
  type        = string
  description = "The name of the GKE cluster"
  default     = "my-cluster"
}

variable "project_id" {
  type        = string
  description = "The project id"
}

variable "masters_cidr" {
  type        = string
  description = "The CIDR value for the controlplane"
}

variable "network_name" {
  type        = string
  description = "Network name"
  default     = "default"
}

variable "pools_map" {
  type = map(object({
    machine_type = string
    disk_size    = string
    labels       = map(string)
    preemptible  = bool
    tags         = map(string)
    zones        = list(string)
    autoscaling = object({
      min = number
      max = number
    })
  }))
  description = "Pool configurations"
  default = {
    default = {
      machine_type = "e2-standard-8"
      disk_size    = "100"
      labels = {
        cloud  = "gcp"
        region = "eu"
        pool   = "default"
      }
      tags        = {}
      preemptible = true
      zones = [
        "europe-west1-b",
        "europe-west1-c",
        "europe-west1-d"
      ]
      autoscaling = {
        min = 1
        max = 3
      }
    }
  }
}

variable "k8s_namespaces" {
  type = map(object({
    labels      = map(string)
    annotations = map(string)
  }))
  description = "The default namespaces to be created"
  default     = {}
}

variable "subnets" {
  type = object({
    nodes    = string
    pods     = string
    services = string
  })
  description = "The CIDR values for nodes, pods and services"
}

variable "region" {
  type        = string
  description = "The region for the resources"
  default     = "europe-west2"
}
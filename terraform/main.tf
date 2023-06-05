
###########
# VARIABLES
###########
variable "timezone" {}

variable "cluster_name" {}

variable "project_id" {}

variable "masters_cidr" {}

variable "subnets" {
    type = object({
        nodes     = string
        pods      = string
        services  = string
    })
}

variable "k8s_namespaces" {
  type = map(object({
      labels      = map(string)
      annotations = map(string)
  }))
}

##############
# DATA SOURCES
##############

data "google_client_config" "default" {}


data "http" "time" {
  url = "https://timeapi.io/api/Time/current/zone?timeZone=${var.timezone}"
  /* Example output
    {
    "year": 2023,
    "month": 1,
    "day": 19,
    "hour": 3,
    "minute": 56,
    "seconds": 9,
    "milliSeconds": 364,
    "dateTime": "2023-01-19T03:56:09.3644979",
    "date": "01/19/2023",
    "time": "03:56",
    "timeZone": "America/Los_Angeles",
    "dayOfWeek": "Thursday",
    "dstActive": false
  }
  */
}

###########
# RESOURCES
###########
module "gke" {
    source = "./module/gke"

    cluster_name = var.cluster_name
    project_id = var.project_id
    masters_cidr = var.masters_cidr
    subnets = var.subnets
    k8s_namespaces = var.k8s_namespaces
}


resource "helm_release" "app1" {
  chart = "../app1"
  name  = "app1"

  set {
    name  = "time"
    value = jsondecode(data.http.time.response_body)["time"]
  }

  set {
    name  = "timezone"
    value = var.timezone
  }
}
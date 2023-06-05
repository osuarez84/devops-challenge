output "cluster_ca_certificate" {
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  description = "Certificate value from the GKE cluster"
}

output "endpoint" {
  value       = google_container_cluster.cluster.endpoint
  description = "Endpoint of the kube-apiserver"
}
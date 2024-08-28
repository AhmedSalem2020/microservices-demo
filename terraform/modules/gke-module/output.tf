output "cluster_name" {
  description = "The name of the created GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_master_version" {
  description = "The Kubernetes master version of the GKE cluster"
  value       = google_container_cluster.primary.master_version
}
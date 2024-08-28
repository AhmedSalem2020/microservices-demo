output "vpc_network_name" {
  description = "The name of the created VPC network"
  value       = google_compute_network.vpc_network.name
}

output "nodes_subnet_name" {
  description = "The name of the nodes subnet"
  value       = google_compute_subnetwork.nodes_subnet.name
}

output "pods_subnet_name" {
  description = "The name of the pods subnet"
  value       = "pods-subnet"
}

output "services_subnet_name" {
  description = "The name of the services subnet"
  value       = "services-subnet"
}
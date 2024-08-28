# Creates a VPC network for the microservices
resource "google_compute_network" "vpc_network" {
  name = var.vpc_name
}

# Creates a subnet for GKE nodes and adds secondary ranges for Pods and Services
resource "google_compute_subnetwork" "nodes_subnet" {
  name          = "nodes-subnet"
  ip_cidr_range = var.nodes_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id

  secondary_ip_range {
    range_name    = "pods-subnet"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services-subnet"
    ip_cidr_range = var.services_cidr
  }
}
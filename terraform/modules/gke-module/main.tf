# GKE Module: modules/gke_module/main.tf

# Enable necessary APIs
module "enable_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 15.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudprofiler.googleapis.com"
  ]
}

# Creates a GKE cluster to host the microservices application
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  network    = var.network_name
  subnetwork = var.subnetwork_name

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_subnet_name
    services_secondary_range_name = var.services_subnet_name
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  initial_node_count = 1
  deletion_protection = var.deletion_protection
}

# Get credentials for the GKE cluster and install necessary components like kubectl
module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.0"

  platform              = "linux"
  additional_components = ["kubectl", "beta"]

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = "container clusters get-credentials ${google_container_cluster.primary.name} --zone=${var.region} --project=${var.project_id}"
}

# Apply YAML kubernetes-manifest configurations
resource "null_resource" "apply_deployment" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "kubectl apply -k ${var.filepath_manifest} -n ${var.namespace}"
  }

  depends_on = [
    module.gcloud
  ]
}

# Wait condition for all Pods to be ready before finishing
resource "null_resource" "wait_conditions" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = <<-EOT
    kubectl wait --for=condition=AVAILABLE apiservice/v1beta1.metrics.k8s.io --timeout=180s
    kubectl wait --for=condition=ready pods --all -n ${var.namespace} --timeout=280s
    EOT
  }

  depends_on = [
    resource.null_resource.apply_deployment
  ]
}
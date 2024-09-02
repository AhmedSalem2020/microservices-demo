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
    "cloudprofiler.googleapis.com",
    "alloydb.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "aiplatform.googleapis.com",
    "generativelanguage.googleapis.com"
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
  # Increase the initial node count to handle more pods
  initial_node_count = var.initial_node_count
  
  # Disable the default node pool to allow a custom node pool
  remove_default_node_pool = true
  
  deletion_protection = var.deletion_protection
}

# Create a custom node pool with autoscaling enabled
resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = var.region
  name       = "primary-nodes"
  node_count = var.initial_node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
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

# Install Istio and configure the cluster
resource "null_resource" "install_istio" {
  provisioner "local-exec" {
    command = <<-EOT
      curl -L https://istio.io/downloadIstio | sh -
      cd istio-*
      export PATH=$PWD/bin:$PATH
      istioctl install --set profile=demo -y
      kubectl label namespace default istio-injection=enabled --overwrite
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml
      #kubectl apply -k /kustomize/components/service-mesh-istio/
      kubectl apply -f /Users/ahmedsalem/Desktop/microservices-demo/kustomize/components/service-mesh-istio/allow-egress-googleapis.yaml
      kubectl apply -f /Users/ahmedsalem/Desktop/microservices-demo/kustomize/components/service-mesh-istio/frontend-gateway.yaml
      kubectl apply -f /Users/ahmedsalem/Desktop/microservices-demo/kustomize/components/service-mesh-istio/frontend.yaml
    EOT
  }
  depends_on = [google_container_cluster.primary]
}

# Deploy the Shopping Assistant with RAG & AlloyDB
resource "null_resource" "deploy_shopping_assistant" {
  provisioner "local-exec" {
    command = <<-EOT
      #/Users/ahmedsalem/Desktop/microservices-demo/kustomize/components/shopping-assistant/scripts/1_deploy_alloydb_infra.sh
      #/Users/ahmedsalem/Desktop/microservices-demo/kustomize/components/shopping-assistant/scripts/2_create_populate_alloydb_tables.sh
      kubectl apply -f /Users/ahmedsalem/Desktop/microservices-demo/kustomize/components/shopping-assistant/shoppingassistantservice.yaml
      kubectl patch deployment frontend --patch '{
        "spec": {
          "template": {
            "spec": {
              "containers": [
                {
                  "name": "server",
                  "env": [
                    {
                      "name": "ENABLE_ASSISTANT",
                      "value": "true"
                    }
                  ]
                }
              ]
            }
          }
        }
      }'
    EOT
  }
  depends_on = [
    null_resource.install_istio,
    google_container_cluster.primary
  ]
}

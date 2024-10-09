# Assigns the 'container.admin' role to the service account for cluster administration
resource "google_project_iam_member" "k8s_cluster_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

# Assigns the 'container.developer' role to the service account for development tasks
# resource "google_project_iam_member" "k8s_developer" {
#   project = var.project_id
#   role    = "roles/container.developer"
#   member  = "serviceAccount:${var.service_account_email}"
# }
# Configure the GCP Provider
provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("terraform-admin-key.json")
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
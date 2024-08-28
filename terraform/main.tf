module "iam" {
  source              = "./modules/iam-module"
  project_id          = var.project_id
  service_account_email = var.service_account_email
}

module "networking" {
  source     = "./modules/networking-module"
  region     = var.region
}

module "gke" {
  source               = "./modules/gke-module"
  region               = var.region
  network_name         = module.networking.vpc_network_name
  subnetwork_name      = module.networking.nodes_subnet_name
  pods_subnet_name     = module.networking.pods_subnet_name
  services_subnet_name = module.networking.services_subnet_name
}
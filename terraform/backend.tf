terraform {
  backend "gcs" {
    bucket  = "ahmedsalem-terraform-state-bucket"
    prefix  = "terraform/state"
  }
}
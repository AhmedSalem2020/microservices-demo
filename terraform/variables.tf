variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "mythical-module-281204"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_account_email" {
  description = "The email of the service account to which roles will be assigned"
  type        = string
  default     = "terraform-admin@mythical-module-281204.iam.gserviceaccount.com"
}
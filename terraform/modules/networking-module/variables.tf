# Networking Module Variables: modules/networking_module/variables.tf

variable "vpc_name" {
  description = "The name of the VPC network to be created"
  type        = string
  default     = "microservices-vpc"
}

variable "nodes_cidr" {
  description = "CIDR block for the nodes subnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pods_cidr" {
  description = "CIDR block for the pods subnet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "CIDR block for the services subnet"
  type        = string
  default     = "10.2.0.0/16"
}

variable "region" {
  description = "The GCP region where the network and subnets will be created"
  type        = string
  default     = "us-central1"
}
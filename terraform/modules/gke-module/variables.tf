# GKE Module Variables: modules/gke_module/variables.tf

variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "mythical-module-281204"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "microservices-cluster"
}

variable "region" {
  description = "The GCP region where the GKE cluster will be deployed"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name of the VPC network to attach to the GKE cluster"
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork to use for the GKE cluster nodes"
  type        = string
}

variable "pods_subnet_name" {
  description = "The name of the secondary range for pods"
  type        = string
}

variable "services_subnet_name" {
  description = "The name of the secondary range for services"
  type        = string
}

variable "deletion_protection" {
  description = "Enable/Disable deletion protection for the GKE cluster"
  type        = bool
  default     = false
}

variable "machine_type" {
  description = "The machine type to use for GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "filepath_manifest" {
  description = "Path to the Kubernetes manifests"
  type        = string
  default     = "../kubernetes-manifests"
}

variable "namespace" {
  description = "Kubernetes namespace for deploying resources"
  type        = string
  default     = "default"
}

variable "initial_node_count" {
  description = "Initial number of nodes in the GKE cluster"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for cluster autoscaling"
  type        = number
  default     = 1
}
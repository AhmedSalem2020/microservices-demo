output "iam_roles_assigned" {
  description = "List of IAM roles assigned to the service account"
  value       = ["roles/container.admin", "roles/container.developer"]
}
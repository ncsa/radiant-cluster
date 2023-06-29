output "cluster" {
  description = "ArgoCD cluster definition"
  sensitive   = true
  value       = local.cluster
}

output "project" {
  description = "ArgoCD project and permissions"
  sensitive   = true
  value       = local.project
}

output "app" {
  description = "ArogCD app of apps"
  sensitive   = true
  value       = local.app
}

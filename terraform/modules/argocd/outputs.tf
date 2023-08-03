output "argocd_cluster" {
  description = "ArgoCD cluster definition"
  sensitive   = true
  value       = local.argocd_cluster
}

output "argocd_cluster_project" {
  description = "ArgoCD project and permissions"
  sensitive   = true
  value       = local.argocd_cluster_project
}

output "argocd_cluster_app" {
  description = "ArogCD app of apps"
  sensitive   = true
  value       = local.argocd_cluster_app
}

output "kubeconfig" {
  description = "KUBECONFIG file"
  sensitive   = true
  value       = local.kube.kube_config
}

output "kube" {
  description = "rancher cluster"
  value       = local.kube
}

output "import_command" {
  description = "command to import a cluster"
  value       = local.kube.cluster_registration_token[0].command
}

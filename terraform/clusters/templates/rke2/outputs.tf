output "private_key_ssh" {
  description = "Private SSH key"
  sensitive   = true
  value       = module.openstack_cluster.private_key_ssh
}

output "ssh_config" {
  description = "SSH Configuration, can be used to ssh into cluster"
  sensitive   = true
  value       = module.openstack_cluster.ssh_config
}

output "kubeconfig" {
  description = "Access to cluster as cluster owner"
  sensitive   = true
  value       = module.rancher_cluster.kubeconfig
}

output "floating_ip" {
  description = "Map for floating ips and associated private ips"
  value       = module.openstack_cluster.floating_ip
}

output "openstack_project" {
  description = "OpenStack project name"
  value       = module.openstack_cluster.project_name
}

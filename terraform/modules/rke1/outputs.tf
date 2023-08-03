output "project_name" {
  description = "OpenStack project name"
  value       = data.openstack_identity_auth_scope_v3.scope.project_name
}

output "machines" {
  description = "List of machines created"
  value       = local.machines
}

output "node_command" {
  description = "Command to join?"
  value       = rancher2_cluster.kube.cluster_registration_token[0].node_command
}

output "private_key_ssh" {
  description = "Private SSH key"
  sensitive   = true
  value       = openstack_compute_keypair_v2.key.private_key
}

output "ssh_config" {
  description = "SSH Configuration file for use with ssh/config"
  value       = <<-EOT
# Automatically created by terraform

%{~for i, x in openstack_compute_instance_v2.controlplane.*}
Host ${x.name}
  HostName ${openstack_networking_floatingip_v2.controlplane_ip[i].address}
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  IdentityFile ${pathexpand("~/.ssh/${var.cluster_name}.pem")}
  User centos
%{~endfor}

%{~for x in [for m in local.machines : m if m.floating_ip]}
Host ${x.hostname}
  HostName ${openstack_networking_floatingip_v2.machine_ip[x.hostname].address}
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  IdentityFile ${pathexpand("~/.ssh/${var.cluster_name}.pem")}
  User ${x.username}
%{~endfor}

%{~for x in openstack_compute_instance_v2.worker.*}
Host ${x.name}
  HostName ${x.network[0].fixed_ip_v4}
  StrictHostKeyChecking no
  ProxyJump ${local.jumphost}
  UserKnownHostsFile=/dev/null
  IdentityFile ${pathexpand("~/.ssh/${var.cluster_name}.pem")}
  User centos
%{~endfor}

%{~for x in [for m in local.machines : m if !m.floating_ip]}
Host ${x.hostname}
  ProxyJump ${local.jumphost}
  HostName ${openstack_networking_port_v2.machine_ip[x.hostname].all_fixed_ips[0]}
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  IdentityFile ${pathexpand("~/.ssh/${var.cluster_name}.pem")}
  User ${x.username}
%{~endfor}
EOT
}

output "kubeconfig" {
  description = "KUBECONFIG file"
  sensitive   = true
  value       = rancher2_cluster.kube.kube_config
}

output "kube_id" {
  description = "OpenStack project name"
  value       = rancher2_cluster.kube.id
}

output "floating_ip" {
  description = "Map for floating ips and associated private ips"
  value = [
    for i, ip in openstack_networking_floatingip_v2.floating_ip.*.address : {
      private_ip = element(flatten(openstack_networking_port_v2.floating_ip.*.all_fixed_ips), i)
      public_ip  = ip
    }
  ]
}

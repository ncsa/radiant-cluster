locals {
  controlplane = [for l in range(var.controlplane_count): var.old_hostnames ? format("%s-controlplane-%d", var.cluster_name, l) : format("%s-controlplane-%d", var.cluster_name, l + 1)]
  worker       = [for l in range(var.worker_count): var.old_hostnames ? format("%s-worker-%d", var.cluster_name, l) : format("%s-worker-%02d", var.cluster_name, l + 1)]
}

# ----------------------------------------------------------------------
# control-plane nodes
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "controlplane" {
  count        = var.controlplane_count
  name         = local.controlplane[count.index]
  image_name   = var.os
  flavor_name  = var.controlplane_flavor
  key_pair     = openstack_compute_keypair_v2.key.name
  config_drive = false

  depends_on = [
    openstack_networking_secgroup_rule_v2.same_security_group_ingress_tcp,
  ]

  security_groups = [
    openstack_networking_secgroup_v2.cluster_security_group.name
  ]

  #echo "update hosts"
  #%{ for ip in openstack_networking_port_v2.worker_ip[count.index].all_fixed_ips }
  #echo "$${ip} $${node_name} $(hostname) $(hostname -f)"  >> /etc/hosts
  #%{ endfor }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.tmpl", {
    private_key  = openstack_compute_keypair_v2.key.private_key
    project_name = data.openstack_identity_auth_scope_v3.scope.project_name
    cluster_name = var.cluster_name
    node_name    = local.controlplane[count.index]
    node_command = rancher2_cluster.kube.cluster_registration_token.0.node_command
    node_options = "--address eth1 --internal-address eth0 --controlplane --etcd"
  }))

  block_device {
    uuid                  = data.openstack_images_image_v2.boot.id
    source_type           = "image"
    volume_size           = var.controlplane_disksize
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = element(openstack_networking_port_v2.controlplane_ip.*.id, count.index)
  }

  lifecycle {
    ignore_changes = [
      key_pair,
      block_device,
      user_data,
      network
    ]
  }
}

# ----------------------------------------------------------------------
# worker nodes
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "worker" {
  count        = var.worker_count
  name         = local.worker[count.index]
  flavor_name  = var.worker_flavor
  key_pair     = local.key
  config_drive = false

  depends_on = [
    openstack_networking_secgroup_rule_v2.same_security_group_ingress_tcp
  ]

  security_groups = [
    openstack_networking_secgroup_v2.cluster_security_group.name
  ]

  user_data = base64encode(templatefile("${path.module}/templates/user_data.tmpl", {
    private_key  = openstack_compute_keypair_v2.key.private_key
    project_name = data.openstack_identity_auth_scope_v3.scope.project_name
    cluster_name = var.cluster_name
    node_name    = local.worker[count.index]
    node_command = rancher2_cluster.kube.cluster_registration_token.0.node_command
    node_options = "--worker"
  }))

  block_device {
    uuid                  = data.openstack_images_image_v2.boot.id
    source_type           = "image"
    volume_size           = var.worker_disksize
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = element(openstack_networking_port_v2.worker_ip.*.id, count.index)
  }

  lifecycle {
    ignore_changes = [
      key_pair,
      block_device,
      user_data
    ]
  }
}

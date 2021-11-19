# ----------------------------------------------------------------------
# control-plane nodes
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "controlplane" {
  count           = var.controlplane_count
  depends_on      = [
    openstack_networking_secgroup_rule_v2.same_security_group_ingress_tcp,
  ]
  name            = format("%s-controlplane-%d", var.cluster_name, count.index + 1)
  image_name      = var.os
  flavor_name     = var.controlplane_flavor
  key_pair        = local.key
  security_groups = [
    openstack_networking_secgroup_v2.cluster_security_group.name
  ]
  config_drive    = false

  user_data  = base64encode(templatefile("${path.module}/templates/user_data.tmpl", {
    private_key  = openstack_compute_keypair_v2.key.private_key
    project_name = data.openstack_identity_auth_scope_v3.scope.project_name
    cluster_name = var.cluster_name
    node_name    = format("%s-controlplane-%d", var.cluster_name, count.index + 1)
    node_command = rancher2_cluster_v2.kube.cluster_registration_token[0].node_command
    node_options = "--controlplane --etcd --address awspublic --internal-address awslocal"
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

  # network {
  #   port = element(openstack_networking_port_v2.controlplane_ip_public.*.id, count.index)
  # }

  lifecycle {
    ignore_changes = [
      key_pair,
      block_device,
      user_data
    ]
  }
}

# ----------------------------------------------------------------------
# worker nodes
# ----------------------------------------------------------------------

resource "openstack_compute_instance_v2" "worker" {
  count           = var.worker_count
  depends_on      = [
    openstack_networking_secgroup_rule_v2.same_security_group_ingress_tcp,
    openstack_networking_port_v2.controlplane_ip
  ]
  name            = format("%s-worker-%02d", var.cluster_name, count.index + 1)
  flavor_name     = var.worker_flavor
  key_pair        = local.key
  config_drive    = false
  security_groups = [ openstack_networking_secgroup_v2.cluster_security_group.name ]

  user_data  = base64encode(templatefile("${path.module}/templates/user_data.tmpl", {
    private_key  = openstack_compute_keypair_v2.key.private_key
    project_name = data.openstack_identity_auth_scope_v3.scope.project_name
    cluster_name = var.cluster_name
    node_name    = format("%s-worker-%02d", var.cluster_name, count.index + 1)
    node_command = rancher2_cluster_v2.kube.cluster_registration_token[0].node_command
    node_options = "--worker --internal-address awslocal"
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

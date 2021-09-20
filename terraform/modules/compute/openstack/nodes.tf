resource "random_string" "rke2_secret" {
  length  = 32
  special = false
}

locals {
  rke2_secret = var.rke2_secret == "" ? random_string.rke2_secret.result : var.rke2_secret
  public_key = var.public_key != "create_a_new_key" && fileexists(var.public_key) ? file(var.public_key) : ""
}

# ----------------------------------------------------------------------
# control-plane nodes
# ----------------------------------------------------------------------
resource "openstack_compute_keypair_v2" "key" {
  name       = var.cluster_name
  public_key = local.public_key
}

# TODO READ KEY HERE

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
  key_pair        = openstack_compute_keypair_v2.key.name
  security_groups = [openstack_networking_secgroup_v2.cluster_security_group.name]
  config_drive    = false

  user_data  = base64encode(templatefile("${path.module}/templates/server_userdata.tmpl", {
    count_index              = count.index,
    name                     = format("%s-controlplane-%d", var.cluster_name, count.index + 1),
    rke2_private_ip          = element(openstack_networking_port_v2.controlplane_ip.*.all_fixed_ips[0], count.index),
    rke2_public_ip           = element(openstack_networking_floatingip_v2.controlplane_ip.*.address, count.index),
    rke2_server_0_private_ip = openstack_networking_port_v2.controlplane_ip[0].all_fixed_ips[0],
    rke2_secret              = local.rke2_secret,
    rke2_version             = var.rke2_version,
    rancher_import           = var.rancher_import,
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

//  network {
//    port = element(openstack_networking_port_v2.controlplane_ip_public.*.id, count.index)
//  }

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
  key_pair        = openstack_compute_keypair_v2.key.name
  config_drive    = false
  security_groups = [ openstack_networking_secgroup_v2.cluster_security_group.name ]

  user_data  = base64encode(templatefile("${path.module}/templates/agent_userdata.tmpl", {
    count_index              = count.index,
    name                     = format("%s-worker-%02d", var.cluster_name, count.index + 1),
    rke2_private_ip          = element(openstack_networking_port_v2.worker_ip.*.all_fixed_ips, count.index),
    rke2_server_0_private_ip = openstack_networking_port_v2.controlplane_ip[0].all_fixed_ips[0],
    rke2_secret              = local.rke2_secret,
    rke2_version             = var.rke2_version,
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

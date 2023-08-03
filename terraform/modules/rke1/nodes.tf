locals {
  usernames = {
    "centos" = "centos",
    "ubuntu" = "ubuntu"
  }

  node_options = {
    "controlplane" = "--address awspublic --internal-address awslocal --controlplane --etcd",
    "worker"       = "--address awspublic --internal-address awslocal --worker"
  }

  machines = flatten([
    for x in var.cluster_machines : [
      for i in range(x.count == null ? 1 : x.count) : {
        hostname    = format("%s-%s-%02d", var.cluster_name, x.name, (i + 1))
        username    = lookup(local.usernames, x.os, "UNDEFINED")
        image_name  = lookup(var.openstack_os_image, x.os, "UNDEFINED")
        flavor      = try(x.flavor, "gp.medium")
        image_id    = data.openstack_images_image_v2.os_image[try(x.os, "UNDEFINED")].id
        disk_size   = try(x.disk, 40)
        zone        = try(x.zone, "nova")
        role        = try(x.role, "worker")
        floating_ip = try(x.floating_ip, can(x.role == "controlplane"))
        labels      = flatten([x.name, try(x.labels, [])])
      }
    ]
  ])

  jumphost = concat([for vm in local.machines : vm.hostname if vm.floating_ip], local.controlplane)[0]

  # DEPRECATED
  controlplane = [for l in range(var.controlplane_count) : var.old_hostnames ? format("%s-controlplane-%d", var.cluster_name, l) : format("%s-controlplane-%d", var.cluster_name, l + 1)]
  worker       = [for l in range(var.worker_count) : var.old_hostnames ? format("%s-worker-%d", var.cluster_name, l) : format("%s-worker-%02d", var.cluster_name, l + 1)]
}

# ----------------------------------------------------------------------
# cluster nodes
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "machine" {
  for_each          = { for vm in local.machines : vm.hostname => vm }
  name              = each.value.hostname
  image_name        = each.value.image_name
  availability_zone = each.value.zone
  flavor_name       = each.value.flavor
  key_pair          = openstack_compute_keypair_v2.key.name
  config_drive      = false

  depends_on = [
    openstack_networking_secgroup_rule_v2.same_security_group_ingress_tcp,
  ]

  security_groups = [
    openstack_networking_secgroup_v2.cluster_security_group.name
  ]

  network {
    port = openstack_networking_port_v2.machine_ip[each.key].id
  }

  block_device {
    uuid                  = each.value.image_id
    source_type           = "image"
    volume_size           = each.value.disk_size
    destination_type      = "volume"
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.tmpl", {
    private_key  = openstack_compute_keypair_v2.key.private_key
    project_name = data.openstack_identity_auth_scope_v3.scope.project_name
    cluster_name = var.cluster_name
    username     = each.value.username
    node_name    = each.value.hostname
    node_command = rancher2_cluster.kube.cluster_registration_token.0.node_command
    node_options = lookup(local.node_options, each.value.role, "--worker")
    node_labels  = join(" ", [for l in each.value.labels : format("-l %s", replace(l, " ", "_"))])
  }))
}

# ----------------------------------------------------------------------
# control-plane nodes
# DEPRECATED
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "controlplane" {
  count             = var.controlplane_count
  name              = local.controlplane[count.index]
  image_name        = var.os
  availability_zone = var.openstack_zone
  flavor_name       = var.controlplane_flavor
  key_pair          = openstack_compute_keypair_v2.key.name
  config_drive      = false

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
    username     = "centos"
    node_name    = local.controlplane[count.index]
    node_command = rancher2_cluster.kube.cluster_registration_token.0.node_command
    node_options = "--address awspublic --internal-address awslocal --controlplane --etcd"
    node_labels  = ""
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
      availability_zone
    ]
  }
}

# ----------------------------------------------------------------------
# worker nodes
# DEPRECATED
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "worker" {
  count             = var.worker_count
  name              = local.worker[count.index]
  image_name        = var.os
  availability_zone = var.openstack_zone
  flavor_name       = var.worker_flavor
  key_pair          = local.key
  config_drive      = false

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
    username     = "centos"
    node_command = rancher2_cluster.kube.cluster_registration_token.0.node_command
    node_options = "--worker"
    node_labels  = ""
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
      user_data,
      availability_zone
    ]
  }
}


locals {
  images = {
    "centos" = "CentOS-7-GenericCloud-Latest",
    "ubuntu" = "Ubuntu Jammy (22.04) latest"
  }

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
        username    = lookup(local.usernames, x.os, "centos")
        image_name  = lookup(local.images, x.os, "CentOS-7-GenericCloud-Latest")
        flavor      = try(x.flavor, "gp.medium")
        image_id    = data.openstack_images_image_v2.boot[try(x.os, "centos")].id
        disk_size   = try(x.disk, 40)
        zone        = try(x.zone, "nova")
        role        = try(x.role, "worker")
        floating_ip = try(x.floating_ip, can(x.role == "controlplane"))
        labels      = flatten([x.name, try(x.labels, [])])
      }
    ]
  ])

  jumphost = [for vm in local.machines : vm.hostname if vm.floating_ip][0]
}

data "openstack_images_image_v2" "boot" {
  for_each    = local.images
  name        = each.value
  most_recent = true
}

data "openstack_identity_auth_scope_v3" "scope" {
  name = var.cluster_name
}

resource "openstack_compute_keypair_v2" "key" {
  name = var.cluster_name
}

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

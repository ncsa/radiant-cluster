locals {
  node_options = {
    "controlplane" = "--address awspublic --internal-address awslocal --controlplane --etcd",
    "worker"       = "--address awspublic --internal-address awslocal --worker"
  }

  machines = flatten([
    for x in var.cluster_machines : [
      for i in range(contains(keys(x), "count") ? x.count : 1) : {
        hostname    = format("%s-%s-%02d", var.cluster_name, x.name, (i + (contains(keys(x), "start_index") ? x.start_index : 1)))
        username    = var.openstack_os_image[x.os].username
        image_name  = var.openstack_os_image[x.os].imagename
        flavor      = x.flavor
        image_id    = data.openstack_images_image_v2.os_image[x.os].id
        disk_size   = x.disk
        zone        = x.zone
        role        = x.role
        floating_ip = x.floating_ip != null ? x.floating_ip : (x.role == "controlplane")
        labels      = flatten([format("ncsa.role=%s", x.name), format("ncsa.flavor=%s", try(x.flavor, "gp.medium")), try(x.labels, [])])
      }
    ]
  ])

  jumphost = [for vm in local.machines : vm.hostname if vm.floating_ip][0]
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
  key_pair          = local.key_name
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
    project_name         = data.openstack_identity_auth_scope_v3.scope.project_name
    cluster_name         = var.cluster_name
    username             = each.value.username
    k8s_cis_hardening    = var.k8s_cis_hardening
    node_name            = each.value.hostname
    node_command         = local.kube.cluster_registration_token.0.node_command
    node_options         = lookup(local.node_options, each.value.role, "--worker")
    node_labels          = join(" ", [for l in each.value.labels : format("-l %s", replace(l, " ", "_"))])
    ncsa_security        = var.ncsa_security
    qualys_url           = var.qualys_url
    qualys_activation_id = var.qualys_activation_id
    qualys_customer_id   = var.qualys_customer_id
    qualys_server        = var.qualys_server
    taiga_enabled        = var.taiga_enabled
    network_cidr         = var.network_cidr
    install_docker       = local.kube_dist == "rke1" && var.install_docker
  }))

  lifecycle {
    ignore_changes = [
      key_pair,
      block_device,
      user_data,
      availability_zone,
      flavor_name,
      image_name
    ]
  }
}

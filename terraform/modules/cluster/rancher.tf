locals {
  kube_version = var.kubernetes_version
  kube_dist    = strcontains(local.kube_version, "k3s") ? "k3s" : "rke2"

  kube    = rancher2_cluster_v2.kube
  kube_id = rancher2_cluster_v2.kube.cluster_v1_id

  has_psa_template         = var.default_psa_template != null && var.default_psa_template != ""
  rancher_psact_mount_path = local.has_psa_template ? "/etc/rancher/${local.kube_dist}/config/rancher-psact.yaml" : ""
  kube_apiserver_arg       = local.has_psa_template ? ["admission-control-config-file=${local.rancher_psact_mount_path}"] : []
}

# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster_v2" "kube" {
  name                                                       = var.cluster_name
  annotations                                                = var.cluster_description != "" ? { "field.cattle.io/description" = var.cluster_description } : {}
  kubernetes_version                                         = local.kube_version
  default_pod_security_admission_configuration_template_name = var.default_psa_template
  rke_config {
    dynamic "machine_selector_config" {
      # Set profile only if it's a RKE2 hardened cluster
      for_each = (var.rke2_cis_hardening && local.kube_dist == "rke2") ? [1] : []
      content {
        config = yamlencode({ profile = var.cis_benchmark })
      }
    }
    machine_global_config = yamlencode(
      merge(
        {
          disable = [
            # K3S
            #- coredns
            "servicelb",
            "traefik",
            "local-storage",
            #- metrics-server
            # RKE2
            #- rke2-coredns
            "rke2-ingress-nginx"
            #- rke2-metrics-server
          ]
        },
        var.network_plugin != "" ? { cni = var.network_plugin } : {},
        length(local.kube_apiserver_arg) > 0 ? { kube-apiserver-arg = local.kube_apiserver_arg } : {}
      )
    )
    upgrade_strategy {
      control_plane_concurrency = "1"
      worker_concurrency        = "1"
      control_plane_drain_options {
        delete_empty_dir_data                = true
        disable_eviction                     = false
        enabled                              = var.drain_controlplane
        force                                = false
        grace_period                         = 120
        ignore_daemon_sets                   = true
        ignore_errors                        = false
        skip_wait_for_delete_timeout_seconds = 0
        timeout                              = 0
      }
      worker_drain_options {
        delete_empty_dir_data                = true
        disable_eviction                     = false
        enabled                              = var.drain_worker
        force                                = false
        grace_period                         = 120
        ignore_daemon_sets                   = true
        ignore_errors                        = false
        skip_wait_for_delete_timeout_seconds = 0
        timeout                              = 0
      }
    }
  }
}

# ----------------------------------------------------------------------
# cluster access
# ----------------------------------------------------------------------
# users are looked up by name (the uid claim from CILogon), the user must
# have logged into rancher at least once before they can be added.
data "rancher2_user" "users" {
  for_each    = setunion(var.admin_users, var.member_users)
  name        = each.value
  is_external = true
}

resource "rancher2_cluster_role_template_binding" "admin_users" {
  for_each         = var.admin_users
  name             = "${local.kube_id}-user-${replace(each.value, "_", "-")}"
  cluster_id       = local.kube_id
  role_template_id = "cluster-owner"
  user_id          = data.rancher2_user.users[each.value].id
  depends_on       = [openstack_compute_instance_v2.machine]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_principal_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "admin_groups" {
  for_each           = var.admin_groups
  name               = "${local.kube_id}-group-${replace(each.value, "_", "-")}"
  cluster_id         = local.kube_id
  role_template_id   = "cluster-owner"
  group_principal_id = format(var.rancher_group_principal, each.value)
  depends_on         = [openstack_compute_instance_v2.machine]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      group_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "member_users" {
  for_each         = var.member_users
  name             = "${local.kube_id}-user-${replace(each.value, "_", "-")}"
  cluster_id       = local.kube_id
  role_template_id = "cluster-member"
  user_id          = data.rancher2_user.users[each.value].id
  depends_on       = [openstack_compute_instance_v2.machine]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_principal_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "member_groups" {
  for_each           = var.member_groups
  name               = "${local.kube_id}-group-${replace(each.value, "_", "-")}"
  cluster_id         = local.kube_id
  role_template_id   = "cluster-member"
  group_principal_id = format(var.rancher_group_principal, each.value)
  depends_on         = [openstack_compute_instance_v2.machine]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      group_id
    ]
  }
}

locals {
  rke1    = var.kubernetes_version == ""
  kube    = local.rke1 ? rancher2_cluster.kube[0] : rancher2_cluster_v2.kube[0]
  kube_id = local.rke1 ? rancher2_cluster.kube[0].id : rancher2_cluster_v2.kube[0].cluster_v1_id
}

# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster_v2" "kube" {
  count              = local.rke1 ? 0 : 1
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  rke_config {
    machine_global_config = yamlencode({
      cni : var.network_plugin
      disable : [
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
    })
    upgrade_strategy {
      control_plane_concurrency = "1"
      worker_concurrency        = "1"
      control_plane_drain_options {
        delete_empty_dir_data                = true
        disable_eviction                     = false
        enabled                              = true
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
        enabled                              = true
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

resource "rancher2_cluster" "kube" {
  count       = local.rke1 ? 1 : 0
  name        = var.cluster_name
  description = var.cluster_description
  driver      = "rancherKubernetesEngine"

  cluster_auth_endpoint {
    enabled = false
  }

  rke_config {
    kubernetes_version = var.rke1_version
    enable_cri_dockerd = true
    network {
      plugin = var.network_plugin
    }
    ingress {
      provider = "none"
    }
    upgrade_strategy {
      drain = true
      drain_input {
        delete_local_data  = true
        ignore_daemon_sets = true
        timeout            = 120
      }
      max_unavailable_controlplane = 1
      max_unavailable_worker       = 1
    }
  }
}

# ----------------------------------------------------------------------
# cluster access
# ----------------------------------------------------------------------
resource "rancher2_cluster_role_template_binding" "admin_users" {
  for_each          = var.admin_users
  name              = "${local.kube_id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube_id
  role_template_id  = "cluster-owner"
  user_principal_id = "openldap_user://uid=${each.value},ou=People,dc=ncsa,dc=illinois,dc=edu"
  depends_on        = [ openstack_compute_instance_v2.machine ]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "admin_groups" {
  for_each          = var.admin_groups
  name              = "${local.kube_id}-group-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube_id
  role_template_id  = "cluster-owner"
  user_principal_id = "openldap_group://cn=${each.value},ou=Groups,dc=ncsa,dc=illinois,dc=edu"
  depends_on        = [ openstack_compute_instance_v2.machine ]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "member_users" {
  for_each          = var.member_users
  name              = "${local.kube_id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube_id
  role_template_id  = "cluster-member"
  user_principal_id = "openldap_user://uid=${each.value},ou=People,dc=ncsa,dc=illinois,dc=edu"
  depends_on        = [ openstack_compute_instance_v2.machine ]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "member_groups" {
  for_each          = var.member_groups
  name              = "${local.kube_id}-group-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube_id
  role_template_id  = "cluster-member"
  user_principal_id = "openldap_group://cn=${each.value},ou=Groups,dc=ncsa,dc=illinois,dc=edu"
  depends_on        = [ openstack_compute_instance_v2.machine ]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

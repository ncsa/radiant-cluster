locals {
  kube = var.cluster_type == "rke" ? element(rancher2_cluster.rke_kube.*, 0) : (
          var.cluster_type == "rke2" ? element(rancher2_cluster.rke2_kube.*, 0) : null
         )
}

# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster" "rke_kube" {
  count       = var.cluster_type == "rke" ? 1 : 0
  name        = var.cluster_name
  description = var.cluster_description

  cluster_auth_endpoint {
    enabled = false
  }

  rke_config {
    network {
      plugin = "weave"
    }
    ingress {
      provider = "none"
    }
    upgrade_strategy {
      drain                        = true
      drain_input {
        delete_local_data          = true
        ignore_daemon_sets         = true
        timeout                    = 120
      }
      max_unavailable_controlplane = 1
      max_unavailable_worker       = 1
    }
  }
}

resource "rancher2_cluster" "rke2_kube" {
  count       = var.cluster_type == "rke2" ? 1 : 0
  name        = var.cluster_name
  description = var.cluster_description
  #driver      = "imported"
  #driver      = "rke2"

  cluster_auth_endpoint {
    enabled = false
  }
}

# ----------------------------------------------------------------------
# cluster access
# ----------------------------------------------------------------------

resource "rancher2_cluster_role_template_binding" "admin_users" {
  for_each          = var.admin_users
  name              = "${local.kube.id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube.id
  role_template_id  = "cluster-owner"
  user_principal_id = "openldap_user://uid=${each.value},ou=People,dc=ncsa,dc=illinois,dc=edu"
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
  name              = "${local.kube.id}-group-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube.id
  role_template_id  = "cluster-owner"
  user_principal_id = "openldap_group://cn=${each.value},ou=Groups,dc=ncsa,dc=illinois,dc=edu"
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
  name              = "${local.kube.id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube.id
  role_template_id  = "cluster-member"
  user_principal_id = "openldap_user://uid=${each.value},ou=People,dc=ncsa,dc=illinois,dc=edu"
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
  name              = "${local.kube.id}-group-${replace(each.value, "_", "-")}"
  cluster_id        = local.kube.id
  role_template_id  = "cluster-member"
  user_principal_id = "openldap_group://cn=${each.value},ou=Groups,dc=ncsa,dc=illinois,dc=edu"
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

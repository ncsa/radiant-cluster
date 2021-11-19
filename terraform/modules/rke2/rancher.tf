# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster_v2" "kube" {
  name                                     = var.cluster_name
  kubernetes_version                       = var.rke2_version
  default_cluster_role_for_project_members = "user"

  rke_config {
    local_auth_endpoint {
      enabled  = var.cluster_direct_access
    }
    machine_global_config = <<EOF
disable:
- rke2-ingress-nginx
EOF
    upgrade_strategy {
      control_plane_concurrency = 1
      control_plane_drain_options {
        ignore_daemon_sets = true
        delete_empty_dir_data  = true
        grace_period = 120
      }
      worker_concurrency = 1
      worker_drain_options {
        ignore_daemon_sets = true
        delete_empty_dir_data  = true
        grace_period = 120
      }
    }
  }
}

# ----------------------------------------------------------------------
# cluster access
# ----------------------------------------------------------------------

resource "rancher2_cluster_role_template_binding" "admin_users" {
  for_each          = var.admin_users
  name              = "admin-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_v2.kube.cluster_v1_id
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
  name              = "admin-group-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_v2.kube.cluster_v1_id
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
  name              = "member-user-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_v2.kube.cluster_v1_id
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
  name              = "member-group-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_v2.kube.cluster_v1_id
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

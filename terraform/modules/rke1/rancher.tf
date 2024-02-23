# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster" "kube" {
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

# Create a new rancher2 Cluster Sync for foo-custom cluster
resource "rancher2_cluster_sync" "kube" {
  depends_on    = [openstack_compute_instance_v2.machine]
  cluster_id    = rancher2_cluster.kube.id
  wait_catalogs = false
}

# ----------------------------------------------------------------------
# cluster access
# ----------------------------------------------------------------------
resource "rancher2_cluster_role_template_binding" "admin_users" {
  for_each          = var.admin_users
  name              = "${rancher2_cluster_sync.kube.id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_sync.kube.id
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
  name              = "${rancher2_cluster_sync.kube.id}-group-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_sync.kube.id
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
  name              = "${rancher2_cluster_sync.kube.id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_sync.kube.id
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
  name              = "${rancher2_cluster_sync.kube.id}-group-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster_sync.kube.id
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

# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster_v2" "kube" {
  name                                     = var.cluster_name
  default_cluster_role_for_project_members = "user"
  kubernetes_version                       = var.rke2_version

  agent_env_vars {
    name  = "CATTLE_AGENT_LOGLEVEL"
    value = "info"
  }

  rke_config {
    local_auth_endpoint {
      enabled = var.cluster_direct_access
    }
    machine_global_config = <<EOF
disable:
- rke2-ingress-nginx
EOF
    upgrade_strategy {
      control_plane_concurrency = 1
      control_plane_drain_options {
        ignore_daemon_sets    = true
        delete_empty_dir_data = true
        grace_period          = 120
      }
      worker_concurrency = 1
      worker_drain_options {
        ignore_daemon_sets    = true
        delete_empty_dir_data = true
        grace_period          = 120
      }
    }
  }
}

# Create a new rancher2 Cluster Sync for cluster
resource "rancher2_cluster_sync" "kube" {
  depends_on      = [ openstack_compute_instance_v2.controlplane[0] ]
  cluster_id      = rancher2_cluster_v2.kube.cluster_v1_id
  wait_catalogs   = false
}


# ----------------------------------------------------------------------
# applications
# ----------------------------------------------------------------------
resource "rancher2_app_v2" "monitoring" {
  count      = var.monitoring_enabled ? 1 : 0
  cluster_id = rancher2_cluster_sync.kube.id
  name       = "rancher-monitoring"
  namespace  = "cattle-monitoring-system"
  repo_name  = "rancher-charts"
  chart_name = "rancher-monitoring"
  //  values        = <<EOF
  //prometheus:
  //  resources:
  //    core:
  //      limits:
  //        cpu: "4000m"
  //        memory: "6144Mi"
  //EOF
  lifecycle {
    ignore_changes = [
      values
    ]
  }
}

resource "rancher2_app_v2" "longhorn" {
  count      = var.longhorn_enabled ? 1 : 0
  cluster_id = rancher2_cluster_v2.kube.cluster_v1_id
  name       = "longhorn"
  namespace  = "longhorn-system"
  repo_name  = "rancher-charts"
  chart_name = "longhorn"
  values     = <<EOF
defaultSettings:
  backupTarget: nfs://radiant-nfs.ncsa.illinois.edu:/radiant/projects/${data.openstack_identity_auth_scope_v3.scope.project_name}/${var.cluster_name}/backup
  defaultReplicaCount: ${var.longhorn_replicas}
persistence:
  defaultClass: false
  defaultClassReplicaCount: ${var.longhorn_replicas}
EOF
  lifecycle {
    ignore_changes = [
      values
    ]
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

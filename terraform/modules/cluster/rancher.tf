locals {
  kube_version = var.kubernetes_version
  kube_dist = (
    local.kube_version == ""                ? "rke1" :
    strcontains(local.kube_version, "rke2") ? "rke2" :
    strcontains(local.kube_version, "k3s")  ? "k3s"  :
    "rke1"
  )

  kube = local.kube_dist == "rke1" ? rancher2_cluster.kube[0] : rancher2_cluster_v2.kube[0]
  kube_id = local.kube_dist == "rke1" ? rancher2_cluster.kube[0].id : rancher2_cluster_v2.kube[0].cluster_v1_id

  rancher_psact_mount_path = "/etc/rancher/${local.kube_dist}/config/rancher-psact.yaml"
  kube_apiserver_arg = (
    var.default_psa_template != null && var.default_psa_template != ""
  ) ? ["admission-control-config-file=${local.rancher_psact_mount_path}"] : []
}

# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster_v2" "kube" {
  count              = local.kube_dist == "rke1" ? 0 : 1
  name               = var.cluster_name
  kubernetes_version = local.kube_version
  default_pod_security_admission_configuration_template_name = var.default_psa_template
  rke_config {
    machine_selector_config {
      # Set profile only if it's a RKE2 hardened cluster
      config = (
        var.k8s_cis_hardening && local.kube_dist == "rke2" ?
          yamlencode({ profile = var.cis_benchmark }) : ""
      )
    }
    machine_global_config = yamlencode({
      cni = var.network_plugin
      kube-apiserver-arg = local.kube_apiserver_arg
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
  count       = local.kube_dist == "rke1" ? 0 : 1
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
  depends_on        = [openstack_compute_instance_v2.machine]
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
  depends_on        = [openstack_compute_instance_v2.machine]
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
  depends_on        = [openstack_compute_instance_v2.machine]
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
  depends_on        = [openstack_compute_instance_v2.machine]
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

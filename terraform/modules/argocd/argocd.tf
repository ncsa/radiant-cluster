locals {
  cluster_argocd_url = "${var.rancher_url}/k8s/clusters/${var.cluster_kube_id}"

  argocd_cluster = templatefile("${path.module}/templates/cluster.yaml.tmpl", {
    cluster_name  = var.cluster_name
    cluster_url   = local.cluster_argocd_url
    rancher_token = var.rancher_token
  })

  argocd_cluster_project = templatefile("${path.module}/templates/project.yaml.tmpl", {
    cluster_name  = var.cluster_name
    cluster_url   = local.cluster_argocd_url
    admin_groups  = var.admin_groups
    admin_users   = var.admin_users
    member_groups = var.member_groups
    member_users  = var.member_users
  })

  argocd_cluster_app = templatefile("${path.module}/templates/argocd.yaml.tmpl", {
    cluster_name                = var.cluster_name
    cluster_url                 = local.cluster_argocd_url
    cluster_kube_id             = var.cluster_kube_id
    rancher_token               = var.rancher_token
    argocd_url                  = local.cluster_argocd_url
    argocd_annotations          = var.argocd_annotations
    argocd_sync                 = var.argocd_sync
    argocd_repo_url             = var.argocd_repo_url
    argocd_repo_version         = var.argocd_repo_version
    openstack_url               = var.openstack_url
    openstack_region_name       = var.openstack_region_name
    openstack_credential_id     = var.openstack_credential_id
    openstack_credential_secret = var.openstack_credential_secret
    openstack_project           = var.openstack_project
    longhorn_enabled            = var.longhorn_enabled
    longhorn_replicas           = var.longhorn_replicas
    nfs_enabled                 = var.nfs_enabled
    cinder_enabled              = var.cinder_enabled
    manila_enabled              = var.manila_enabled
    metallb_enabled             = var.metallb_enabled
    floating_ip                 = var.floating_ip
    ingress_controller_enabled  = var.ingress_controller_enabled
    ingress_controller          = var.ingress_controller
    traefik_storageclass        = var.traefik_storageclass
    traefik_ports               = indent(14, yamlencode(var.traefik_ports))
    acme_staging                = var.acme_staging
    acme_email                  = var.acme_email
    sealedsecrets_enabled       = var.sealedsecrets_enabled
    monitoring_enabled          = var.monitoring_enabled
    healthmonitor_enabled       = var.healthmonitor_enabled
    healthmonitor_nfs           = var.healthmonitor_nfs
    healthmonitor_secrets       = var.healthmonitor_secrets
  })
}

# ----------------------------------------------------------------------
# upload to central argocd server
# ----------------------------------------------------------------------
resource "kubectl_manifest" "argocd_cluster" {
  count     = var.argocd_kube_id != "" ? 1 : 0
  yaml_body = local.argocd_cluster
}

resource "kubectl_manifest" "argocd_cluster_project" {
  count     = var.argocd_kube_id != "" ? 1 : 0
  yaml_body = local.argocd_cluster_project
}

resource "kubectl_manifest" "argocd_cluster_app" {
  count     = var.argocd_kube_id != "" ? 1 : 0
  yaml_body = local.argocd_cluster_app
}

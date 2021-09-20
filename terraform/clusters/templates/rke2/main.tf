locals {
  admin_groups = var.admin_radiant ? setunion(var.admin_groups, [ "radiant_${module.openstack_cluster.project_name}" ]) : var.admin_groups
}

module "rancher_cluster" {
  source = "../../modules/rancher"

  cluster_name        = var.cluster_name
  cluster_description = var.cluster_description
  rancher_url         = var.rancher_url
  rancher_token       = var.rancher_token
  cluster_type        = var.cluster_type

  admin_users         = var.admin_users
  admin_groups        = local.admin_groups
  member_users        = var.member_users
  member_groups       = var.member_groups
}

module "openstack_cluster" {
  source = "../../modules/compute/openstack"

  cluster_name                 = var.cluster_name
  cluster_type                 = var.cluster_type

  rke2_version                 = var.rke2_version
  rancher_import               = module.rancher_cluster.import_command

  openstack_url                = var.openstack_url
  openstack_credential_id      = var.openstack_credential_id
  openstack_credential_secret  = var.openstack_credential_secret
  openstack_external_net       = var.openstack_external_net
  #openstack_credential_id      = does not work
  #openstack_credential_secret  = does not work
  #public_key                   = use default in module
  
  controlplane_count           = var.controlplane_count
  #controlplane_flavor          = use default in module
  #controlplane_disksize        = use default in module

  worker_count                 = var.worker_count
  worker_flavor                = var.worker_flavor
  worker_disksize              = var.worker_disksize

  #network_cidr                 = use default in module
  #dns_servers                  = use default in module
  #floating_ip                  = use default in module
}

module "argocd" {
  source = "../../modules/argocd"

  cluster_name                = var.cluster_name
  cluster_kube_id             = module.rancher_cluster.kube.id
  floating_ip                 = module.openstack_cluster.floating_ip

  openstack_url               = var.openstack_url
  openstack_credential_id     = var.openstack_credential_id
  openstack_credential_secret = var.openstack_credential_secret
  openstack_project           = module.openstack_cluster.project_name

  rancher_url                 = var.rancher_url
  rancher_token               = var.rancher_token

  acme_email                  = var.acme_email

  argocd_master               = var.argocd_master
  argocd_kube_id              = var.argocd_kube_id
  argocd_annotations          = var.argocd_annotations
  argocd_sync                 = var.argocd_sync

  admin_users                 = var.admin_users
  admin_groups                = local.admin_groups
  member_users                = var.member_users
  member_groups               = var.member_groups
}

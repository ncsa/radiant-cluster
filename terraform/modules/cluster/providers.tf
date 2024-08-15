provider "openstack" {
  auth_url                      = var.openstack_url
  region                        = var.openstack_region_name
  application_credential_id     = var.openstack_credential_id
  application_credential_secret = var.openstack_credential_secret
}

provider "rancher2" {
  api_url   = var.rancher_url
  token_key = var.rancher_token
}

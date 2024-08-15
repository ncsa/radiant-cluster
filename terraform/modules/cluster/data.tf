# external network
data "openstack_networking_network_v2" "ext_net" {
  name = var.openstack_external_net
}

# openstack project name (bbXX)
data "openstack_identity_auth_scope_v3" "scope" {
  name = "my_scope"
}

data "openstack_images_image_v2" "os_image" {
  for_each    = var.openstack_os_image
  name        = each.value.imagename
  most_recent = true
}

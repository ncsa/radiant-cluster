# Each cluster will either have a shared key, or their own
# unique key.
resource "openstack_compute_keypair_v2" "key" {
  count = var.openstack_ssh_key == "" ? 1 : 0
  name  = var.cluster_name
}

data "openstack_compute_keypair_v2" "key" {
  count = var.openstack_ssh_key == "" ? 0 : 1
  name  = var.openstack_ssh_key
}

# set local variable to hold final key, either created or
# loaded.
locals {
  key_name    = var.openstack_ssh_key == "" ? openstack_compute_keypair_v2.key[0].name : data.openstack_compute_keypair_v2.key[0].name
  private_key = var.openstack_ssh_key == "" ? openstack_compute_keypair_v2.key[0].private_key : ""
}

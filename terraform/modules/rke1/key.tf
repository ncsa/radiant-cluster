# Each cluster will either have a shared key, or their own
# unique key.
resource "openstack_compute_keypair_v2" "key" {
  #count      = 1 #var.openstack_ssh_key == "" ? 0 : 1
  name = var.cluster_name
}

# set local variable to hold final key, either created or
# loaded.
locals {
  key = var.cluster_name # var.openstack_ssh_key == "" ? var.cluster_name : var.openstack_ssh_key
}

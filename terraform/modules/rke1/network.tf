# Each cluster has their own network. The network will have a
# private ip spaces of 192.168.0.0/21. Each of the machines will
# have a fixed ip address in this private IP space.
#
# For the worker machines, there will be a set of floating IP addresses
# that can be given to a load balancer (using for example metallb).
#

data "openstack_networking_network_v2" "ext_net" {
  name = var.openstack_external_net
}

# ----------------------------------------------------------------------
# setup network, subnet and router
# ----------------------------------------------------------------------

resource "openstack_networking_network_v2" "cluster_net" {
  name           = "${var.cluster_name}-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "cluster_subnet" {
  name            = "${var.cluster_name}-subnet"
  network_id      = openstack_networking_network_v2.cluster_net.id
  cidr            = var.network_cidr
  ip_version      = 4
  dns_nameservers = var.dns_servers
}

resource "openstack_networking_router_v2" "kube_router" {
  name                = "${var.cluster_name}-router"
  external_network_id = data.openstack_networking_network_v2.ext_net.id
  admin_state_up      = "true"
}

resource "openstack_networking_router_interface_v2" "kube_gateway" {
  router_id = openstack_networking_router_v2.kube_router.id
  subnet_id = openstack_networking_subnet_v2.cluster_subnet.id
}

# ----------------------------------------------------------------------
# floating IP
# ----------------------------------------------------------------------

# create a port that will be used with the floating ip, this will be associated
# with all of the VMs.
resource "openstack_networking_port_v2" "floating_ip" {
  count      = var.floating_ip
  depends_on = [openstack_networking_subnet_v2.cluster_subnet]
  name       = format("%s-floating-ip-%02d", var.cluster_name, count.index + 1)
  network_id = openstack_networking_network_v2.cluster_net.id
}

# create floating ip that is associated with a fixed ip
resource "openstack_networking_floatingip_v2" "floating_ip" {
  count       = var.floating_ip
  description = format("%s-floating-ip-%02d", var.cluster_name, count.index + 1)
  pool        = data.openstack_networking_network_v2.ext_net.name
  port_id     = element(openstack_networking_port_v2.floating_ip.*.id, count.index)
}

# ----------------------------------------------------------------------
# machines
# ----------------------------------------------------------------------

resource "openstack_networking_port_v2" "machine_ip" {
  for_each           = { for vm in local.machines : vm.hostname => vm }
  name               = each.value.hostname
  network_id         = openstack_networking_network_v2.cluster_net.id
  security_group_ids = [openstack_networking_secgroup_v2.cluster_security_group.id]
  depends_on         = [openstack_networking_router_interface_v2.kube_gateway]

  dynamic "allowed_address_pairs" {
    for_each = openstack_networking_port_v2.floating_ip.*.all_fixed_ips.0
    content {
      ip_address = allowed_address_pairs.value
    }
  }
}

resource "openstack_networking_floatingip_v2" "machine_ip" {
  for_each    = { for vm in local.machines : vm.hostname => vm if vm.floating_ip }
  description = each.value.hostname
  pool        = data.openstack_networking_network_v2.ext_net.name
  port_id     = openstack_networking_port_v2.machine_ip[each.key].id
}



resource "openstack_networking_secgroup_v2" "cluster_security_group" {
  name        = var.cluster_name
  description = "${var.cluster_name} kubernetes cluster security group"
}

# ----------------------------------------------------------------------
# Ingress
# ----------------------------------------------------------------------

# Ingress IPv4  ICMP  Any 0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 22 (SSH)  0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_ssh" {
  description       = "ssh"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 80 (HTTP) 0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_http" {
  description       = "http"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 443 (HTTPS) 0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_https" {
  description       = "https"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 6443  141.142.0.0/16  - kube api  
resource "openstack_networking_secgroup_rule_v2" "ingress_kubeapi" {
  description       = "kubeapi"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.openstack_security_kubernetes
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 30000 - 32767 0.0.0.0/0 - nodeport  
# resource "openstack_networking_secgroup_rule_v2" "ingress_nodeport" {
#   description       = "nodeport"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 30000
#   port_range_max    = 32767
#   security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
#   depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
# }

resource "openstack_networking_secgroup_rule_v2" "same_security_group_ingress_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_security_group.id
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

resource "openstack_networking_secgroup_rule_v2" "same_security_group_ingress_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_security_group.id
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}


# Ingress IPv4  TCP 1 - 65535 192.168.100.0/24  - - 
# Ingress IPv4  TCP 1 - 65535 141.142.216.0/21  - - 
# Ingress IPv4  TCP 2376  141.142.0.0/16  - - 
# Ingress IPv4  TCP 2379 - 2380 141.142.0.0/16  - etcd  
# Ingress IPv4  TCP 5201  0.0.0.0/0 - - 
# Ingress IPv4  TCP 6783  141.142.0.0/16  - weave 
# Ingress IPv4  TCP 10250 - 10255 141.142.0.0/16  - kubelet 
# Ingress IPv4  UDP 1 - 65535 192.168.100.0/24  - - 
# Ingress IPv4  UDP 1 - 65535 141.142.216.0/21  - - 
# Ingress IPv4  UDP 6783 - 6784 141.142.0.0/16  - weave 

# ----------------------------------------------------------------------
# CLUSTER INFO
# ----------------------------------------------------------------------
variable "cluster_name" {
  type        = string
  description = "Desired name of new cluster"
}

variable "cluster_description" {
  type        = string
  description = "Description of new cluster"
  default     = ""
}

variable "cluster_direct_access" {
  type        = bool
  description = "Allow for direct access"
  default     = true
}

variable "cluster_machines" {
  type        = set(map(any))
  description = "machine definition"
  default     = []
}

# ----------------------------------------------------------------------
# RANCHER
# ----------------------------------------------------------------------

variable "rancher_url" {
  type        = string
  description = "URL where rancher runs"
  default     = "https://gonzo-rancher.ncsa.illinois.edu"
}

variable "rancher_token" {
  type        = string
  sensitive   = true
  description = "Access token for rancher, clusters are created as this user"
}

# RKE2
# curl -s https://releases.rancher.com/kontainer-driver-metadata/release-v2.9/data.json | jq -r '.rke2.releases[].version'
# K3S
# curl -s https://releases.rancher.com/kontainer-driver-metadata/release-v2.9/data.json | jq -r '.k3s.releases[].version'
variable kubernetes_version {
  type        = string
  description = "Version of rke2/k3s to install (leave blank to install rke1)"
  default     = ""
}

# curl -s https://releases.rancher.com/kontainer-driver-metadata/release-v2.6/data.json | jq -r '.K8sVersionRKESystemImages | keys'
variable "rke1_version" {
  type        = string
  description = "Version of rke1 to install."
  default     = "v1.21.14-rancher1-1"
}

variable "network_plugin" {
  type        = string
  description = "Network plugin to be used (canal, cilium, calico, flannel, ...)"
  default     = "weave"
}

# ----------------------------------------------------------------------
# USERS
# ----------------------------------------------------------------------

variable "admin_users" {
  type        = set(string)
  description = "List of LDAP users with admin access to cluster."
  default     = []
}

variable "admin_groups" {
  type        = set(string)
  description = "List of LDAP groups with admin access to cluster."
  default     = []
}

variable "member_users" {
  type        = set(string)
  description = "List of LDAP users with access to cluster."
  default     = []
}

variable "member_groups" {
  type        = set(string)
  description = "List of LDAP groups with access to cluster."
  default     = []
}

# ----------------------------------------------------------------------
# OPENSTACK
# ----------------------------------------------------------------------

variable "openstack_url" {
  type        = string
  description = "OpenStack URL"
  default     = "https://radiant.ncsa.illinois.edu"
}

variable "openstack_region_name" {
  type        = string
  description = "OpenStack region name"
  default     = "RegionOne"
}

variable "openstack_credential_id" {
  type        = string
  sensitive   = true
  description = "Openstack credentials"
}

variable "openstack_credential_secret" {
  type        = string
  sensitive   = true
  description = "Openstack credentials"
}

variable "openstack_external_net" {
  type        = string
  description = "OpenStack external network"
  default     = "ext-net"
}

variable "openstack_security_kubernetes" {
  type        = map(any)
  description = "IP address to allow connections to kube api port, default is rancher nodes"
  default = {
    "rancher-1" : "141.142.218.167/32"
    "rancher-2" : "141.142.217.171/32"
    "rancher-3" : "141.142.217.184/32"
  }
}

variable "openstack_security_ssh" {
  type        = map(any)
  description = "IP address to allow connections to ssh, default is open to NCSA"
  default = {
    "world" : "141.142.0.0/16"
  }
}

variable "openstack_security_custom" {
  type        = map(any)
  description = "ports to open for custom services to the world, assumed these are blocked in other ways"
  default = {
  }
}

variable "openstack_os_image" {
  type        = map(any)
  description = "Map from short OS name to image"
  default = {
    "ubuntu" = {
      "imagename" : "Ubuntu Jammy (22.04) latest"
      "username" : "ubuntu"
    }
    "ubuntu22" = {
      "imagename" : "Ubuntu Jammy (22.04) latest"
      "username" : "ubuntu"
    }
  }
}

# ----------------------------------------------------------------------
# NETWORKING
# ----------------------------------------------------------------------

variable "network_cidr" {
  type        = string
  description = "CIDR to be used for internal network"
  default     = "192.168.0.0/21"
}

variable "dns_servers" {
  type        = set(string)
  description = "DNS Servers"
  default     = ["141.142.2.2", "141.142.230.144"]
}

variable "floating_ip" {
  type        = string
  description = "Number of floating IP addresses available for loadbalancers"
  default     = 2
}

# ----------------------------------------------------------------------
# NODE CREATION OPTIONS
# ----------------------------------------------------------------------

variable "ncsa_security" {
  type        = bool
  description = "Install NCSA security options, for example rsyslog"
  default     = false
}

variable "taiga_enabled" {
  type        = bool
  description = "Enable Taiga mount"
  default     = true
}

variable "install_docker" {
  type        = bool
  description = "Install Docker when provisioning node (only for rke1)"
  default     = true
}

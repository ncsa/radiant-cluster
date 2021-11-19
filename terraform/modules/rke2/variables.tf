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

# ----------------------------------------------------------------------
# USERS
# ----------------------------------------------------------------------

variable "admin_users" {
  type        = set(string)
  description = "List of LDAP users with admin access to cluster."
  default     = [ ]
}

variable "admin_groups" {
  type        = set(string)
  description = "List of LDAP groups with admin access to cluster."
  default     = [ ]
}

variable "member_users" {
  type        = set(string)
  description = "List of LDAP users with access to cluster."
  default     = [ ]
}

variable "member_groups" {
  type        = set(string)
  description = "List of LDAP groups with access to cluster."
  default     = [ ]
}

# ----------------------------------------------------------------------
# RKE2
# ----------------------------------------------------------------------

variable "rke2_secret" {
  type        = string
  sensitive   = true
  description = "default token to be used, if empty random one is used"
  default     = ""
}

# get latest version from rancher using:
# curl https://releases.rancher.com/kontainer-driver-metadata/release-v2.6/data.json | jq '.rke2.releases | .[].version' | sort
variable "rke2_version" {
  type        = string
  description = "Version of rke2 to install."
  default     = "v1.21.6+rke2r1"
}

# ----------------------------------------------------------------------
# OPENSTACK
# ----------------------------------------------------------------------

variable "openstack_url" {
  type        = string
  description = "OpenStack URL"
  default     = "https://radiant.ncsa.illinois.edu"
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

variable "openstack_ssh_key" {
  type        = string
  description = "existing SSH key to use, leave blank for a new one"
  default     = ""
}

# ----------------------------------------------------------------------
# OPENSTACK KUBERNETES
# ----------------------------------------------------------------------

variable "os" {
  type        = string
  description = "Base image to use for the OS"
  default     = "CentOS-7-GenericCloud-Latest"
}

variable "controlplane_count" {
  type        = string
  description = "Desired quantity of control-plane nodes"
  default     = 1
}

variable "controlplane_flavor" {
  type        = string
  description = "Desired flavor of control-plane nodes"
  default     = "m1.medium"
}

variable "controlplane_disksize" {
  type        = string
  description = "Desired disksize of control-plane nodes"
  default     = 40
}

variable "worker_count" {
  type        = string
  description = "Desired quantity of worker nodes"
  default     = 1
}

variable "worker_flavor" {
  type        = string
  description = "Desired flavor of worker nodes"
  default     = "m1.large"
}

variable "worker_disksize" {
  type        = string
  description = "Desired disksize of worker nodes"
  default     = 40
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

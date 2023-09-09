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
# APPLICATIONS
# ----------------------------------------------------------------------

# DEPRECATED - will move to argocd
variable "monitoring_enabled" {
  type        = bool
  description = "Enable monitoring in rancher"
  default     = true
}

# DEPRECATED - will move to argocd
variable "longhorn_enabled" {
  type        = bool
  description = "Enable longhorn storage"
  default     = true
}

# DEPRECATED - will move to argocd
variable "longhorn_replicas" {
  type        = string
  description = "Number of replicas"
  default     = 3
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

# curl -s https://releases.rancher.com/kontainer-driver-metadata/release-v2.6/data.json | jq -r '.K8sVersionRKESystemImages | keys'
variable "rke1_version" {
  type        = string
  description = "Version of rke1 to install."
  default     = "v1.21.14-rancher1-1"
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

# DEPRECATED - new key will always be created
variable "openstack_ssh_key" {
  type        = string
  description = "existing SSH key to use, leave blank for a new one"
  default     = ""
}

# DEPRECATED - use cluster.json
variable "openstack_zone" {
  type        = string
  description = "default zone to use for openstack nodes"
  default     = "nova"
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

// TODO change this to be ncsa only
variable "openstack_security_ssh" {
  type        = map(any)
  description = "IP address to allow connections to ssh, default is open to the world"
  default = {
    "world" : "0.0.0.0/0"
  }
}

variable "openstack_os_image" {
  type        = map(any)
  description = "Map from short OS name to image"
  default = {
    "centos" = "CentOS-7-GenericCloud-Latest"
    "ubuntu" = "Ubuntu Jammy (22.04) latest"
  }
}

# ----------------------------------------------------------------------
# OPENSTACK NODES
# ----------------------------------------------------------------------

# DEPRECATED - will always start at 1 with cluster.json
variable "old_hostnames" {
  type        = bool
  description = "should old hostname be used (base 0)"
  default     = false
}

# DEPRECATED - use cluster.json
variable "os" {
  type        = string
  description = "Base image to use for the OS"
  default     = "CentOS-7-GenericCloud-Latest"
}

# DEPRECATED - use cluster.json
variable "controlplane_count" {
  type        = string
  description = "Desired quantity of control-plane nodes"
  default     = 1
}

# DEPRECATED - use cluster.json
variable "controlplane_flavor" {
  type        = string
  description = "Desired flavor of control-plane nodes"
  default     = "m1.medium"
}

# DEPRECATED - use cluster.json
variable "controlplane_disksize" {
  type        = string
  description = "Desired disksize of control-plane nodes"
  default     = 40
}

# DEPRECATED - use cluster.json
variable "worker_count" {
  type        = string
  description = "Desired quantity of worker nodes"
  default     = 1
}

# DEPRECATED - use cluster.json
variable "worker_flavor" {
  type        = string
  description = "Desired flavor of worker nodes"
  default     = "m1.large"
}

# DEPRECATED - use cluster.json
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

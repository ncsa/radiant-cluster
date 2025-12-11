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
  type = set(object({
    name        = string
    os          = string
    role        = optional(string, "worker")
    count       = optional(number, 1)
    start_index = optional(number, 1)
    flavor      = optional(string, "gp.medium")
    disk        = optional(number, 40)
    zone        = optional(string, "nova")
    floating_ip = optional(bool)
    labels      = optional(map(string), {})
    taints      = optional(map(string), {})
  }))
  description = "machine definition"
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

variable "cis_benchmark" {
  type        = string
  description = "CIS Benchmark RKE2 profile used to validate configuration"
  default     = "cis"
}

# RKE2
# curl -s https://releases.rancher.com/kontainer-driver-metadata/release-v2.9/data.json | jq -r '.rke2.releases[].version'
# K3S
# curl -s https://releases.rancher.com/kontainer-driver-metadata/release-v2.9/data.json | jq -r '.k3s.releases[].version'
variable "kubernetes_version" {
  type        = string
  description = "Version of rke2/k3s to install (leave blank to install rke1)"
  default     = ""
}

# There are two builtin Pod Security Admission Configuration Template (PSACT): rancher-privileged and rancher-restricted.
# Leaving this blank will result in no PSA for K3s/RKE1/RKE2 and "rancher-restricted" for RKE2 if rke2_cis_hardening = true
variable "default_psa_template" {
  type        = string
  description = "RKE2/K3s cluster-wide default Pod Security Admission Configuration Template"
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

variable "drain_controlplane" {
  type        = bool
  description = "When upgrading, drain controlplane nodes"
  default     = true
}

variable "drain_worker" {
  type        = bool
  description = "When upgrading, drain worker nodes"
  default     = false
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

variable "openstack_ssh_key" {
  type        = string
  description = "OpenStack SSH key name, leave blank to generate new key"
  default     = ""
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

variable "rke2_cis_hardening" {
  type        = bool
  description = "Install host-level and kubernetes-level RKE2 security options for CIS Benchmark compliance"
  default     = false
}

variable "ncsa_security" {
  type        = bool
  description = "Install NCSA security options, for example rsyslog"
  default     = false
}

variable "qualys_url" {
  type        = string
  description = "When installing qualys-cloud-agent, the URL to download the agent from"
  default     = ""
}

variable "qualys_activation_id" {
  type        = string
  description = "When installing qualys-cloud-agent, this is the activation id"
  default     = ""
}

variable "qualys_customer_id" {
  type        = string
  description = "When installing qualys-cloud-agent, this is the customer id"
  default     = ""
}

variable "qualys_server" {
  type        = string
  description = "When installing qualys-cloud-agent, this is the server to connect to"
  default     = ""
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

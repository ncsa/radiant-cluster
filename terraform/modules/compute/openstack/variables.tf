variable "cluster_name" {
  type        = string
  description = "Desired name of new cluster"
}

variable "cluster_type" {
  type        = string
  description = "Cluster type, can be either rke or rke2"
  default     = "rke2"
  validation {
    #condition     = var.cluster_type == "rke" || var.cluster_type == "rke2"
    #error_message = "Image needs to be one of [rke, rke2]."
    condition     = var.cluster_type == "rke2"
    error_message = "Currently only support rke2."
  }
}

variable "public_key" {
  type        = string
  description = "path to public key to be injected into vm"
  # leave as create_a_new_key to force a new key
  default     = "create_a_new_key"
}

# ----------------------------------------------------------------------
# RKE
# ----------------------------------------------------------------------

variable "rke2_secret" {
  type        = string
  sensitive   = true
  description = "default token to be used, if empty random one is used"
  default     = ""
}

variable "rke2_version" {
  type        = string
  description = "Version of rke2 to install, blank is the latest"
  default     = ""
}

variable "rancher_import" {
  type        = string
  description = "Command to import cluster into rancher"
}

# ----------------------------------------------------------------------
# OPENSTACK
# ----------------------------------------------------------------------

variable "openstack_url" {
  type        = string
  description = "OpenStack URL"
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

# ----------------------------------------------------------------------
# GENERAL
# ----------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  description = "Desired name of new cluster"
}

variable "cluster_description" {
  type        = string
  description = "Description of what cluster is for"
  default     = ""
}

variable "cluster_type" {
  type        = string
  description = "Cluster type, can be either rke or rke2"
  default     = "rke2"
  validation {
    condition     = var.cluster_type == "rke" || var.cluster_type == "rke2"
    error_message = "Image needs to be one of [rke, rke2]."
  }
}

variable "write_ssh_files" {
  type        = bool
  description = "Write out the files to ssh into cluster"
  default     = true
}

variable "write_kubeconfig_files" {
  type        = bool
  description = "Write out the kubeconfig for devops user"
  default     = false
}

# ----------------------------------------------------------------------
# RKE2
# ----------------------------------------------------------------------

variable "rke2_version" {
  type        = string
  description = "Version of rke2 to install, blank is the latest"
  default     = ""
}

# ----------------------------------------------------------------------
# OPENSTACK
# ----------------------------------------------------------------------

variable "openstack_url" {
  type        = string
  description = "OpenStack URL"
  default     = "https://radiant.ncsa.illinois.edu:5000/v3/"
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
# KUBERNETES NODES
# ----------------------------------------------------------------------

variable "controlplane_count" {
  type        = string
  description = "Desired quantity of control-plane nodes"
  default     = 3
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
  default     = 3
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

variable "admin_radiant" {
  type        = bool
  description = "Should users that have access to radiant be an admin"
  default     = true
}

variable "admin_users" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ ]
}

variable "admin_groups" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ ]
}

variable "member_users" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ ]
}

variable "member_groups" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ ]
}

# ----------------------------------------------------------------------
# ARGOCD
# ----------------------------------------------------------------------
variable "argocd_master" {
  type        = bool
  description = "Is this the master argocd cluster, you most likely don't need to modify this value"
  default     = false
}

variable "argocd_sync" {
  type        = bool
  description = "Should apps automatically sync"
  default     = false
}

variable "argocd_annotations" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ ]
}

variable "argocd_kube_id" {
  type        = string
  description = "Rancher kube id for argocd cluster"
  default     = "c-dnt7n"
}

# ----------------------------------------------------------------------
# ARGOCD APPLICATIONS
# ----------------------------------------------------------------------

variable "monitoring_enabled" {
  type        = bool
  description = "Enable monitoring in rancher"
  default     = true
}

variable "longhorn_enabled" {
  type        = bool
  description = "Enable longhorn storage"
  default     = true
}

variable "longhorn_replica" {
  type        = string
  description = "Number of replicas"
  default     = 3
}

variable "nfs_enabled" {
  type        = bool
  description = "Enable NFS storage"
  default     = true
}

variable "healthmonitor_enabled" {
  type        = bool
  description = "Enable healthmonitor"
  default     = true
}

variable "healthmonitor_nfs" {
  type        = bool
  description = "Enable healthmonitor nfs"
  default     = true
}

variable "healthmonitor_notifications" {
  type        = string
  description = "Notifications for healthmonitor"
  default     = ""
}

# ----------------------------------------------------------------------
# INGRESS
# working:
# - traefik1
# - traefik2
# - none
# work in progress
# - nginx
# - nginxinc
# ----------------------------------------------------------------------

variable "ingress_controller" {
  type        = string
  description = "Desired ingress controller (traefik1, traefik2, nginxinc, nginx, none)"
  default     = "traefik2"
}

# ----------------------------------------------------------------------
# TRAEFIK
# ----------------------------------------------------------------------

variable "traefik_dashboard" {
  type        = bool
  description = "Should dashboard ingress rule be added as /traefik"
  default     = true
}

variable "traefik_server" {
  type        = string
  description = "Desired hostname to be used for cluster, nip.io will use ip address"
  default     = ""
}

variable "traefik_access_log" {
  type        = bool
  description = "Should traefik enable access logs"
  default     = false
}

variable "traefik_use_certmanager" {
  type        = bool
  description = "Should traefik v2 use cert manager"
  default     = false
}

# ----------------------------------------------------------------------
# LETS ENCRYPT
# ----------------------------------------------------------------------

variable "acme_staging" {
  type        = bool
  description = "Use the staging server"
  default     = false
}

variable "acme_email" {
  type        = string
  description = "Use the following email for cert messages"
  default     = "devops.isda@lists.illinois.edu"
}

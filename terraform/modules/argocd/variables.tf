variable "cluster_name" {
  type        = string
  description = "Desired name of new cluster"
}

variable "cluster_kube_id" {
  type        = string
  description = "Rancher created cluster"
}

variable "cluster_description" {
  type        = string
  description = "Description of new cluster"
  default     = ""
}

variable "floating_ip" {
  type = list(object({
    private_ip = string,
    public_ip  = string
  }))
  description = "List of public/private ip addresses, Private ip addres can be blank"
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
  description = "Rancher access token"
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

variable "openstack_project" {
  type        = string
  description = "Openstack project name"
}

# ----------------------------------------------------------------------
# ARGOCD
# ----------------------------------------------------------------------
variable "argocd_kube_id" {
  type        = string
  description = "Rancher argocd cluster, set to blank to not install argocd"
}

variable "argocd_sync" {
  type        = bool
  description = "Should apps automatically sync"
  default     = false
}

variable "argocd_repo_url" {
  type        = string
  description = "URL to pull argocd applications from"
  default     = "https://github.com/ncsa/radiant-cluster.git"
}

variable "argocd_repo_version" {
  type        = string
  description = "What version of the application to deploy"
  default     = "HEAD"
}

variable "argocd_annotations" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = []
}

# ----------------------------------------------------------------------
# ARGOCD APPLICATIONS
# ----------------------------------------------------------------------

variable "monitoring_enabled" {
  type        = bool
  description = "Enable monitoring in rancher"
  default     = true
}

variable "cinder_enabled" {
  type        = bool
  description = "Enable cinder storage"
  default     = true
}

variable "longhorn_enabled" {
  type        = bool
  description = "Enable longhorn storage"
  default     = true
}

variable "longhorn_replicas" {
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

variable "healthmonitor_secrets" {
  type        = string
  description = "Secrets (config/checks/notifications) for healthmonitor"
  default     = "config"
}

variable "sealedsecrets_enabled" {
  type        = bool
  description = "Enable sealed secrets"
  default     = false
}

variable "metallb_enabled" {
  type        = bool
  description = "Enable MetalLB"
  default     = true
}

# ----------------------------------------------------------------------
# USERS
# ----------------------------------------------------------------------

variable "admin_users" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = []
}

variable "admin_groups" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = []
}

variable "member_users" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = []
}

variable "member_groups" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = []
}

# ----------------------------------------------------------------------
# INGRESS
# ----------------------------------------------------------------------

variable "ingress_controller_enabled" {
  type        = bool
  description = "Enable IngressController"
  default     = true
}

variable "ingress_controller" {
  type        = string
  description = "Desired ingress controller (traefik, traefik2 (same as traefik), nginx, none)"
  default     = "traefik"
  validation {
    condition     = var.ingress_controller == "nginx" || var.ingress_controller == "traefik" || var.ingress_controller == "traefik2" || var.ingress_controller == "none"
    error_message = "Invalid ingress controller."
  }
}

# ----------------------------------------------------------------------
# TRAEFIK
# ----------------------------------------------------------------------

variable "traefik_access_log" {
  type        = bool
  description = "Should traefik enable access logs"
  default     = false
}

variable "traefik_storageclass" {
  type        = string
  description = "storageclass used by ingress controller"
  default     = ""
}

variable "traefik_ports" {
  type        = map(any)
  description = "Additional ports to add to traefik"
  default     = {}
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
  default     = "example@lists.example.com"
}

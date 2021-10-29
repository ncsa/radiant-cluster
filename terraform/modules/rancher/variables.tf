variable "cluster_name" {
  type        = string
  description = "Desired name of new cluster"
}

variable "cluster_description" {
  type        = string
  description = "Description of new cluster"
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

variable "rancher_import" {
  type        = bool
  description = "Import cluster?"
  default     = false
}

# ----------------------------------------------------------------------
# USERS
# ----------------------------------------------------------------------

variable "admin_users" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ ]
}

variable "admin_groups" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = [ "isda_admin" ]
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

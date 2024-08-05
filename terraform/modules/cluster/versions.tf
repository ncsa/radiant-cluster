terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.43.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 1.21.0"
    }
  }
}

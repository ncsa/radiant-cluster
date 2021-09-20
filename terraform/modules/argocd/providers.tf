provider "kubectl" {
  host             = "${var.rancher_url}/k8s/clusters/${var.argocd_kube_id}"
  token            = var.rancher_token
  load_config_file = false
}

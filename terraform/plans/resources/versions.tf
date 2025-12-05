terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  alias = "root"

  config_context = local.cluster_name
  config_path    = "~/.kube/config"
}

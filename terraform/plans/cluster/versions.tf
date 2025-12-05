terraform {
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

# Warning: Redundant empty provider block
provider "minikube" {
  alias = "root"
}

provider "helm" {
  alias = "root"

  kubernetes = {
    config_context = local.cluster.name
    config_path    = "~/.kube/config"
  }
}

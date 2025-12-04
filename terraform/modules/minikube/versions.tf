terraform {
  required_providers {
    minikube = {
      source = "scott-the-programmer/minikube"
      version = "0.6.0"
    }
  }
}

# Warning: Redundant empty provider block
# provider "minikube" {
# }
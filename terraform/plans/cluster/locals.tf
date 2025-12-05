locals {
  cluster = {
    name      = "uni"
    static_ip = "192.168.0.198"
    cpus      = "max"
    addons    = ["ingress"]
  }

  argocd_helm_release = {
    name        = "argocd"
    namespace   = "argocd"
    repository  = "https://argoproj.github.io/argo-helm"
    chart       = "argo-cd"
    version     = "9.1.6"
    values_file = file("./configs/argocd-bootstrap-values.yml")
  }
}

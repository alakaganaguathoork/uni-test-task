module "argocd_project" {
  source = "../../modules/kubernetes"

  manifest = local.kube_resources.project

  providers = {
    kubernetes = kubernetes.root
  }
}

module "argocd_resources" {
  for_each = local.kube_resources.apps
  source = "../../modules/kubernetes"

  manifest = each.value

  providers = {
    kubernetes = kubernetes.root
  }

  depends_on = [module.argocd_project]
}

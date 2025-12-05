module "mini_cluster" {
  source = "../../modules/minikube"

  cluster_name = local.cluster.name
  static_ip    = local.cluster.static_ip
  cpus         = local.cluster.cpus
  addons       = local.cluster.addons

  providers = {
    minikube = minikube.root
  }
}

module "argocd" {
  source = "../../modules/helm"

  release = local.argocd_helm_release

  providers = {
    helm = helm.root
  }

  depends_on = [module.mini_cluster]
}

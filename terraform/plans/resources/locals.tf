locals {
  cluster_name = "uni"

  argocd_apps = {
    argocd = {
      name      = "argocd"
      namespace = "argocd"
      project   = "uni"
    },
    spam200 = {
      name      = "spam2000"
      namespace = "app"
      project   = "uni"
    },
    vmstack = {
      name      = "vmstack"
      namespace = "monitoring"
      project   = "uni"
    }
  }

  kube_resources = {
    project = file("./configs/argocd-project.yaml")
    # ApplicationSet didn't work via terraform's kubernetes provider due to the error: "The plugin.(*GRPCProvider).PlanResourceChange request was cancelled." 
    # apps_set = "./configs/argocd-apps-set.yaml"
    apps = {
      for key, app in local.argocd_apps :
      key => templatefile("./configs/argocd-app.yaml.tpl", app)
    }
  }
}

resource "minikube_cluster" "docker" {
  driver             = "docker"
  dns_domain         = "uni.local"
  cluster_name       = var.cluster_name
  cpus               = var.cpus
  disk_size          = var.disk_size
  kubernetes_version = "v${var.kube_version}"
  static_ip          = try(var.static_ip, null)
  addons             = try(var.addons, [])
  delete_on_failure  = true
  ha                 = false
  install_addons     = true
}

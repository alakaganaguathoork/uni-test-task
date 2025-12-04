resource "minikube_cluster" "docker" {
  driver             = "docker"
  cluster_name       = var.cluster_name
  kubernetes_version = "v${var.kube_version}"
  static_ip          = try(var.static_ip, null)
  cpus               = var.cpus
  delete_on_failure  = true
  disk_size          = var.disk_size
  dns_domain         = "uni.local"
  ha                 = false

  install_addons = true
  addons         = try(var.addons, [])
}

output "host" {
  value = minikube_cluster.docker.host
}
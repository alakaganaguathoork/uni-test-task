module "local_cluster" {
  source = "./modules/minikube"

  cluster_name = "uni"
  static_ip    = "192.168.0.198"
  cpus         = "max"
  addons       = ["ingress"]
}

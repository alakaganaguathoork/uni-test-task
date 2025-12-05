resource "kubernetes_manifest" "this" {
  manifest = yamldecode(var.manifest)
}

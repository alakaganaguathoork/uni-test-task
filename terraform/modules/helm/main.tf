resource "helm_release" "this" {
  name             = var.release.name
  namespace        = var.release.namespace
  repository       = var.release.repository
  chart            = var.release.chart
  create_namespace = try(var.release.create_namespace, true)
  cleanup_on_fail  = try(var.release.cleanup_on_fail, true)
  atomic           = try(var.release.atomic, true)
  force_update     = try(var.release.force_update, true)
  lint             = try(var.release.lint, true)
  replace          = true
  reuse_values     = true
  wait             = true
  skip_crds        = false
  version          = try(var.release.version, null)
  values           = [var.release.values_file]
}

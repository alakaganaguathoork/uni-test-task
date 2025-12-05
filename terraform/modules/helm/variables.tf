variable "release" {
  type = object({
    values_file     = any
    name            = string
    namespace       = string
    repository      = string
    chart           = string
    cleanup_on_fail = optional(bool)
    atomic          = optional(bool)
    force_update    = optional(bool)
    lint            = optional(bool)
    version         = optional(string)
  })
}

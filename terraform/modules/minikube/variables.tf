variable "cluster_name" {
  type        = string
  description = "A name of a minikube profile to create. Defaults to 'default'."
  default     = "default"
}

variable "kube_version" {
  type        = string
  description = "Kubernetes version, e.g. '1.35.0'. Defaults to '1.34.0'."
  default     = "1.34.0"
}

variable "static_ip" {
  type        = string
  description = "A static IP for a cluster to set (easies /etc/hosts file updating)."
  default     = null
}

variable "cpus" {
  type        = string
  description = "Number of CPUs to allocate. Valid options: 'max', 'no-limit'."

  validation {
    condition = contains(["max", "no-limit"], var.cpus)

    error_message = "Option is not valid. Please provided any of the following: 'max' or 'no-limit'."
  }
}

variable "disk_size" {
  type        = string
  description = "Amount of memory allocated (format: [(case-insensitive)], where unit = b, k, kb, m, mb, g or gb). Defaults to '20gb'."
  default     = "20gb"
}

variable "addons" {
  type        = list(string)
  description = "List of addons to be installed. Defaults to none."
  default     = []
}

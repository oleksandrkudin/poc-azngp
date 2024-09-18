variable "delimiter" {
  description = "Character that split parts of resource name."
  type        = string
  default     = "-"
}

variable "resource_type_added" {
  description = "Whether to add resource type abbreviation. Allowed values are prefix, suffix."
  type        = string
  default     = "prefix"

  validation {
    condition     = contains(["prefix", "suffix"], var.resource_type_added)
    error_message = "The resource_type_added value is not correct. Allowed values are \"prefix\", \"suffix\"."
  }
}

variable "base" {
  description = "List of string that should uniquely identify project deployment instance."
  type        = list(string)
}

variable "components" {
  description = "List of components that resource belong to. It is used when resource name should reflect product software design."
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name of the resource."
  type        = string
}

variable "location" {
  description = "Azure location."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "Azure resource tags."
  type        = map(string)
  default     = null
}

variable "federated_identity_credentials" {
  description = "Map of federated identity credential objects."
  type = map(object({
    audience = optional(list(string), ["api://AzureADTokenExchange"])
    issuer   = string
    subject  = string
  }))
  default = {}
}

variable "role_mappings" {
  type = map(object({
    scope                 = string
    role_definition_names = list(string)
  }))
  default = {}
}

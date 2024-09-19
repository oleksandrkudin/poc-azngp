variable "principal_id" {
  type = string
}

variable "role_mappings" {
  type = map(object({
    scope                 = string
    role_definition_names = list(string)
  }))
}

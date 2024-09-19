variable "location" {
  description = "Azure location where resource are placed."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "component_path" {
  description = "Absolute file system path for component where backend_override.tf should be created."
  type        = string
}

variable "global" {
  type = object({
    product                 = string
    location_short_name_map = map(string)

    terraform_azurerm_backend = object({
      component_name                = string
      resource_group_instance_name  = string
      storage_account_instance_name = string
      container_name                = string
    })
  })
}

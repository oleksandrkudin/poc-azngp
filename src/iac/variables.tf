variable "global" {
  type = object({
    product                 = string
    business_owner          = string
    location_short_name_map = map(string)

    terraform_azurerm_backend = object({
      component_name                = string
      resource_group_instance_name  = string
      storage_account_instance_name = string
      container_name                = string

      account_tier             = optional(string, "Standard")
      account_replication_type = optional(string, "LRS")
    })
  })
}

variable "location" {
  description = "Azure location where resource are placed."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

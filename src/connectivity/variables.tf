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

variable "virtual_network" {
  description = "Virtual network."
  type = object({
    instance_name = optional(string, "main")
    address_space = list(string)
    subnets = object({
      aks = object({
        instance_name    = optional(string, "aks")
        address_prefixes = list(string)
        network_security_group = optional(object({
          instance_name = optional(string, "aks")
        }), {})
      })
    })
  })
}
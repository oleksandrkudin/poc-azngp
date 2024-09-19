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

variable "terraform_backend" {
  description = "Terraform backend type. Allowed values are local, azurerm."
  type        = string
  default     = "azurerm"
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

variable "defaults" {
  description = "Default values for `terraform_remote_state` outputs, in case the state file is empty or lacks a required output."
  type        = any
  default     = {}
}

variable "deepmerge" {
  description = "Whether to perform deep merge for outputs and default maps."
  type        = bool
  default     = true
}
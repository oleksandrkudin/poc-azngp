# Global naming and tagging
module "naming" {
  source = "../../modules/naming"

  base       = [var.global.product, var.environment, var.global.location_short_name_map[var.location]]
  components = [var.global.terraform_azurerm_backend.component_name]
}

module "tags" {
  source = "../../modules/tags"

  product        = var.global.product
  environment    = var.environment
  location       = var.location
  business_owner = var.global.business_owner
}

# Resource group
resource "azurerm_resource_group" "resource_group" {
  name     = format(module.naming.formats["azurerm_resource_group"], var.global.terraform_azurerm_backend.resource_group_instance_name)
  location = var.location
  tags     = module.tags.tags
}

# Terraform azurerm backend storage account
module "terraform_azurerm_backend" {
  source = "../../modules/azurerm-storage-account"

  name                     = format(module.naming.formats["azurerm_storage_account"], var.global.terraform_azurerm_backend.storage_account_instance_name)
  location                 = var.location
  resource_group_name      = azurerm_resource_group.resource_group.name
  account_tier             = var.global.terraform_azurerm_backend.account_tier
  account_replication_type = var.global.terraform_azurerm_backend.account_replication_type

  containers = {
    tfstate = {
      name = var.global.terraform_azurerm_backend.container_name
    }
  }

  tags = module.tags.tags
}
module "naming" {
  source = "../naming"

  base       = [var.global.product, var.environment, var.global.location_short_name_map[var.location]]
  components = [var.global.terraform_azurerm_backend.component_name]
}

locals {
  config = {
    resource_group_name  = format(module.naming.formats["azurerm_resource_group"], var.global.terraform_azurerm_backend.resource_group_instance_name)
    storage_account_name = format(module.naming.formats["azurerm_storage_account"], var.global.terraform_azurerm_backend.storage_account_instance_name)
    container_name       = var.global.terraform_azurerm_backend.container_name
    key                  = "${var.global.product}/${basename(var.component_path)}.terraform.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}

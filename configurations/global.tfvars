global = {
  product        = "azngp"
  business_owner = "Oleksandr"

  location_short_name_map = {
    westeurope = "weu"
    eastus     = "eus"
  }

  terraform_azurerm_backend = {
    component_name                = "iac"
    resource_group_instance_name  = "main"
    storage_account_instance_name = "tfstate"
    container_name                = "tfstate"
  }
}

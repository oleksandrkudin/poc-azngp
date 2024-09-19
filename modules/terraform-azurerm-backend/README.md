# terraform-azurerm-backend

The module provides terraform azurerm backend configuration object as module output. Allow to have single source of truth to manage terraform azurerm backend configuration in product. 
It is used to create `backend_override.tf.json` files, provide configuration for terraform_remote_state data source.

## Usage

### Example: generate azurerm backend configuration for `core` component.

```bash
module "azurerm_backend_config" {
  source = "../terraform-azurerm-backend"

  location                  = "westeurope"
  environment               = "dev"
  component_path            = abspath("../connectivity")

  global = {
    product = "azngp"

    location_short_name_map = {
      westeurope = "weu"
    }

    terraform_azurerm_backend = {
      component_name                = "iac"
      resource_group_instance_name  = "main" # relative name (function, role name) of resource group where storage account is located.
      storage_account_instance_name = "tfstate" # relative name (function, role name) of storage account.
      container_name                = "tfstate"
    }
  }
}
```

Module outputs in JSON format.
```json
{
  "terraform": {
    "backend": {
      "azurerm": {
        "container_name": "tfstate",
        "key": "azngp/iac.terraform.tfstate",
        "resource_group_name": "rg-azngp-dev-weu-iac-main",
        "storage_account_name": "azngpdevweuiactfstate",
        "use_azuread_auth": true
      }
    }
  }
}
```

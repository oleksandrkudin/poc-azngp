# data-terraform-remote-state

The module is a simple wrapper for `terraform_remote_state` data source which is extended with module that manage azurerm backend configuration. Support azurerm and local backends.
It is used for integration between components.

## Usage

### Example: get output from `connectivity` component.

```bash
module "connectivity_outputs" {
  source                    = "../../modules/data-terraform-remote-state"
  location                  = "westeurope"
  environment               = "dev"
  
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

  component_path            = abspath("../connectivity")  
}
```

# azurerm-storage-account

Regular reusable, flexible `resource` module that follows `Data as Code` principle.

## Usage

### Example

```bash
module "storate_account" {
  source = "../../modules/azurerm-storage-account"

  name                     = "sa-az-weu-dev-plz-data"
  location                 = "westeurope"
  resource_group_name      = "rg-az-weu-dev-plz-core"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  containers = {
    tfstate = {
      name = "downloads"
    }
  }
}
```

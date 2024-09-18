# naming

The module implements naming convention for Azure resources by providing product or product component scoped naming pattern as module output. This naming pattern is a specification string that should be used in format function to construct specific resource name. Having naming convention in a module allows to have consistent resource names throughout a product.

Name pattern consist of the following parts:
* base - identifies deployment product instance.
* components - optional, component hierarchy to which resource belong to.
* resource type - optional, can be added as prefix or suffix to resource name.
* resource - identifies resource within component or product. It is not specific value but format function specification string. May have several items to substitute.

Can be used to implement different naming schemas:
* Flat resource naming (no components). Resource names are global across whole product. So there are no issues with duplication in parts of resource name. But name uniqueness for resources is developer responsibility.
* Hierarchical resource naming (include component). Add to resource name component(s) it belongs and so uniqueness must be managed within component. Drawback is that duplication in parts of resource name are possible.

## Usage

### Example: resource group name - `rg-azngp-dev-weu-net` 

```bash
# Module instance should be defined only once in codebase as it provides pattern, but not specific resource name.
module "naming" {
  source = "../.."
  base   = ["azngp", "dev", "weu"]
}

resource "azurerm_resource_group" "this" {
  # Name value is split across multi lines for description. In codebase, it will be single line value.
  name = format(
           module.name_prefix.formats["azurerm_resource_group"],  # Return naming pattern for resource group.
           "net"                                                  # Specific resource group instance name. Instance name could be function or role resource plays.
         )

  location = "westeurope"
}
```
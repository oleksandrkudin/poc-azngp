module "naming" {
  source = "../.."
  base   = ["azngp", "poc", "weu"]
}

resource "azurerm_resource_group" "this" {
  name     = format(module.naming.formats["azurerm_resource_group"], "net")
  location = "westeurope"
}

output "naming" {
  value = module.naming
}

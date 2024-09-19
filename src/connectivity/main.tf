# Global naming and tagging
module "naming" {
  source = "../../modules/naming"

  base       = [var.global.product, var.environment, var.global.location_short_name_map[var.location]]
  components = [local.component_name]
}

# Resource group
resource "azurerm_resource_group" "resource_group" {
  name     = format(module.naming.formats["azurerm_resource_group"], "main")
  location = var.location
  tags     = module.tags_outputs.outputs.tags
}

# Virtual Network
module "virtual_network" {
  source = "../../modules/azurerm-virtual-network"

  name                = format(module.naming.formats["azurerm_virtual_network"], var.virtual_network.instance_name)
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = var.virtual_network.address_space

  subnets = { for subnet_key, subnet_value in var.virtual_network.subnets : subnet_key => merge(subnet_value, {
    name = format(module.naming.formats["azurerm_subnet"], subnet_value.instance_name)
    network_security_group = {
      name = format(module.naming.formats["azurerm_network_security_group"], subnet_value.network_security_group.instance_name)
    }
  }) }

  tags = module.tags_outputs.outputs.tags
}
# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = coalesce(each.value.name, each.key)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegations

    content {
      name = coalesce(delegation.value.name, delegation.key)
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Network Security Groups
locals {
  network_security_groups = { for key, value in var.subnets : key => value.network_security_group if contains(keys(value), "network_security_group") }
}

resource "azurerm_network_security_group" "this" {
  for_each = local.network_security_groups

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.network_security_groups

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# Private DNS zones
resource "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zones

  name                = coalesce(each.value.name, each.key)
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.private_dns_zones

  name                  = each.value.virtual_network_link.name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = each.value.virtual_network_link.registration_enabled
  tags                  = var.tags
}

# Virtual Network peering
resource "azurerm_virtual_network_peering" "local" {
  for_each = var.virtual_network_peerings

  name                      = each.value.name
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = each.value.remote_virtual_network_id
  allow_forwarded_traffic   = each.value.allow_forwarded_traffic
  use_remote_gateways       = each.value.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "remote" {
  for_each = var.virtual_network_peerings

  name                      = each.value.remote.name
  resource_group_name       = split("/", each.value.remote_virtual_network_id)[4]
  virtual_network_name      = split("/", each.value.remote_virtual_network_id)[8]
  remote_virtual_network_id = azurerm_virtual_network.this.id
  allow_forwarded_traffic   = each.value.remote.allow_forwarded_traffic
  use_remote_gateways       = each.value.remote.use_remote_gateways
}

# Private DNS Zones' Virtual Network links
resource "azurerm_private_dns_zone_virtual_network_link" "link_only" {
  for_each = var.private_dns_zone_vnet_links

  name                  = each.value.name
  private_dns_zone_name = each.value.private_dns_zone_name
  resource_group_name   = each.value.resource_group_name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags
}

# Route tables
resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                          = each.value.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation

  tags = var.tags
}

locals {
  # Create map of objects with route_table_key, route_key.
  route_table_route_object_map = merge(
    flatten(
      [
        for route_table_key, route_table_value in var.route_tables : [
          for route_key, route_value in route_table_value.routes : {
            format("%s_%s", route_table_key, route_key) = {
              route_table_key = route_table_key
              route           = route_value
            }
          }
        ]
      ]
    )...
  )
}

resource "azurerm_route" "this" {
  for_each = local.route_table_route_object_map

  name                   = each.value.route.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this[each.value.route_table_key].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = each.value.route.next_hop_in_ip_address
}

locals {
  # Create map of objects with route_table_key, subnet_key.
  route_table_subnet_object_map = merge(
    flatten(
      [
        for route_table_key, route_table_value in var.route_tables : [
          for subnet_key in coalescelist(route_table_value.subnet_keys, keys(var.subnets)) : {
            format("%s_%s", route_table_key, subnet_key) = {
              route_table_key = route_table_key
              subnet_key      = subnet_key
            }
          }
        ]
      ]
    )...
  )
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = local.route_table_subnet_object_map
  subnet_id      = azurerm_subnet.this[each.value.subnet_key].id
  route_table_id = azurerm_route_table.this[each.value.route_table_key].id
}

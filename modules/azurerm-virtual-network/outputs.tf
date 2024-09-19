output "name" {
  value = azurerm_virtual_network.this.name
}

output "id" {
  value = azurerm_virtual_network.this.id
}

output "subnets" {
  value = { for key, subnet in azurerm_subnet.this : key => {
    name = subnet.name
    id   = subnet.id
  } }
}

output "private_dns_zones" {
  value = { for key, private_dns_zone in azurerm_private_dns_zone.this : key => {
    name = private_dns_zone.name
    id   = private_dns_zone.id
  } }
}

output "network_security_groups" {
  value = { for key in keys(local.network_security_groups) : key => {
    name = azurerm_network_security_group.this[key].name
    id   = azurerm_network_security_group.this[key].id
  } }
}
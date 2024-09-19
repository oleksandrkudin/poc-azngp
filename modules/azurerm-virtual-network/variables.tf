variable "name" {
  description = "Name of the resource."
  type        = string
}

variable "location" {
  description = "Azure location."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "Azure resource tags."
  type        = map(string)
  default     = null
}

variable "address_space" {
  description = "List of address spaces that is used the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet objects."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    network_security_group = optional(object({
      name = string
    }))
    delegations = optional(map(object({
      name = optional(string)
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    })), {})
  }))
}

variable "private_dns_zones" {
  description = "Map of private DNS zones objects."
  type = map(object({
    name = optional(string)
    virtual_network_link = optional(object({
      name                 = optional(string)
      registration_enabled = optional(bool)
    }), {})
  }))
  default = {}
}

variable "virtual_network_peerings" {
  description = "Map of virtual network peerings configuration objects."
  type = map(object({
    name                      = string
    remote_virtual_network_id = string
    allow_forwarded_traffic   = optional(bool)
    use_remote_gateways       = optional(bool)
    remote = object({
      name                    = string
      allow_forwarded_traffic = optional(bool)
      use_remote_gateways     = optional(bool)
    })
  }))
  default = {}
}

variable "private_dns_zone_vnet_links" {
  description = "Map of private dns zone virtual network links."
  type = map(object({
    name                  = string
    private_dns_zone_name = string
    resource_group_name   = string
    registration_enabled  = optional(bool)
  }))
  default = {}
}

variable "route_tables" {
  description = "Map of route tables with routes. By default route table is associated with all subnets."
  type = map(object({
    name                          = string
    disable_bgp_route_propagation = optional(bool)
    subnet_keys                   = optional(list(string), [])
    routes = map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
  default = {}
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers"
  type        = list(string)
  default     = null
}
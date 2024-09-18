locals {
  # Map of Azure location name to its abbreviation.

  # location_short_name_map = {
  #   westeurope          = "weu"
  #   northcentralusstage = "ncus"
  #   eastus              = "eus"
  # }
  # location_short_name = local.location_short_name_map[var.location]

  # Map of resource type to its abbreviation.
  # Microsoft recommended resource type abbreviations - https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations.
  resource_type_abbreviation_map = {
    azurerm_resource_group                         = "rg"
    azurerm_virtual_network                        = "vnet"
    azurerm_network_security_group                 = "nsg"
    azurerm_mysql_flexible_server                  = "mysql"
    azurerm_user_assigned_identity                 = "id"
    azurerm_application_gateway                    = "agw"
    azurerm_kubernetes_cluster                     = "aks"
    azurerm_bastion_host                           = "bas"
    azurerm_orchestrated_virtual_machine_scale_set = "vmss"
    azurerm_linux_virtual_machine_scale_set        = "vmss"
    azurerm_network_interface                      = "nic"
    azurerm_monitor_autoscale_setting              = "autoscale"
    azurerm_nat_gateway                            = "ng"
    azurerm_public_ip                              = "pip"
    azurerm_key_vault                              = "kv"
    azurerm_private_endpoint                       = "pe"
    azurerm_subnet                                 = "snet"
    azurerm_virtual_network_peering                = "peer"
    azurerm_private_dns_zone_virtual_network_link  = "link"
    azurerm_managed_disk_data                      = "disk"
    azurerm_managed_disk_os                        = "osdisk"
    azurerm_linux_virtual_machine                  = "vm"
    azurerm_windows_virtual_machine                = "vm"
    azurerm_lb_internal                            = "lbi"
    azurerm_lb_external                            = "lbe"
    azurerm_key_vault_secret_password              = "password"
    azurerm_key_vault_secret_sshkey                = "sshkey"
    azurerm_lb_frontend_ip_configuration           = "ipconfig"
    azurerm_lb_probe                               = "probe"
    azurerm_lb_rule                                = "rule"
    azurerm_lb_backend_address_pool                = "pool"
    azurerm_network_interface_ip_configuration     = "ipconfig"
    azurerm_route_table                            = "rt"
    azurerm_route                                  = "udr"

    azurerm_recovery_services_vault                    = "rsv"
    azurerm_backup_policy_vm                           = "bkpol"
    azurerm_monitor_action_group                       = "ag"
    azurerm_monitor_activity_log_alert                 = "apr"
    azurerm_monitor_alert_processing_rule_action_group = "apr"
    azurerm_log_analytics_workspace                    = "log"

    # Resource types that does not contain resource type abbreviation in their names.
    azurerm_key_vault             = ""
    azurerm_storage_account       = ""
    azurerm_key_vault_secret      = ""
    azurerm_network_security_rule = ""
  }

  # Resource types that require parent resource reference to construct unique name.
  resource_type_parent_reference = [
    "azurerm_network_interface",
    "azurerm_managed_disk_data",
    "azurerm_public_ip",
    "azurerm_key_vault_secret_password",
    "azurerm_route_table",
    "azurerm_key_vault_secret_sshkey",
  ]

  # Resource types that do not require "base/common" part in their name.
  #  Usually it is sub-resources within parent resource that do no exist outside of its parent resource. Their visibility is only parent resource scope.
  resource_type_no_base_name = [
    "azurerm_lb_frontend_ip_configuration",
    "azurerm_network_interface_ip_configuration",
    "azurerm_lb_backend_address_pool",
    "azurerm_lb_rule",
    "azurerm_lb_probe",
    "azurerm_network_security_rule",
    "azurerm_backup_policy_vm",
    "azurerm_route",
  ]

  # Resource types that do not have delimiter
  # Must be all resource type with length limit
  resource_type_no_delimiter = [
    "azurerm_key_vault",
    "azurerm_storage_account"
  ]

  # Resource types that have very specific naming convention and cannot be built with common pattern.
  resource_type_naming_map = {
    # azurerm_storage_account = join("", [local.location_short_name, var.environment, var.solution, "%s"])
  }

  # Map of resource type to format function specification string.
  formats = { for resource_type in keys(local.resource_type_abbreviation_map) : resource_type => (
    contains(keys(local.resource_type_naming_map), resource_type) ? local.resource_type_naming_map[resource_type] : (
      # Common/general pattern. It is constructed from three parts.
      join(contains(local.resource_type_no_delimiter, resource_type) ? "" : var.delimiter,
        compact(
          concat(
            # Resource type part as prefix of the name.
            var.resource_type_added == "prefix" ?
            [
              local.resource_type_abbreviation_map[resource_type]
            ] : [],

            # Base/common part of the name. For sub-resource types can be optional.
            contains(local.resource_type_no_base_name, resource_type) ? [] : var.base,

            # Components part
            var.components,

            # Funtion(s), role(s) resource plays in product.
            [
              contains(local.resource_type_parent_reference, resource_type) ? "%s" : "", # Some resource types require reference to parent resource to be unique and informative.
              "%s",
            ],

            # Resource type part as suffix of the name.
            var.resource_type_added == "suffix" ?
            [
              local.resource_type_abbreviation_map[resource_type]
            ] : [],
          )
        )
      )
    )
    )
  }
}

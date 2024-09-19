resource "azurerm_storage_account" "this" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  access_tier                       = var.access_tier
  edge_zone                         = var.edge_zone
  enable_https_traffic_only         = var.enable_https_traffic_only
  min_tls_version                   = var.min_tls_version
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  shared_access_key_enabled         = var.shared_access_key_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  is_hns_enabled                    = var.is_hns_enabled
  nfsv3_enabled                     = var.nfsv3_enabled
  large_file_share_enabled          = var.large_file_share_enabled
  local_user_enabled                = var.local_user_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  sftp_enabled                      = var.sftp_enabled
  dns_endpoint_type                 = var.dns_endpoint_type

  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [1]

    content {
      default_action             = var.network_rules.default_action
      bypass                     = var.network_rules.bypass
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = coalesce(each.value.name, each.key)
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.container_access_type
}
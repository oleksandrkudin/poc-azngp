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

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  type        = string
  default     = null
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid."
  type        = string
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
}

variable "cross_tenant_replication_enabled" {
  description = "Whether cross Tenant replication is enabled."
  type        = bool
  default     = null
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot, Cool."
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist."
  type        = string
  default     = null
}

variable "enable_https_traffic_only" {
  description = "Boolean flag which forces HTTPS if enabled."
  type        = bool
  default     = null
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2."
  type        = string
  default     = null
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = null
}

variable "shared_access_key_enabled" {
  description = "Whether the storage account permits requests to be authorized with the account access key via Shared Key."
  type        = bool
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled."
  type        = bool
  default     = null
}

variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. "
  type        = bool
  default     = null
}

variable "is_hns_enabled" {
  description = "Whether Hierarchical Namespace enabled."
  type        = bool
  default     = null
}

variable "nfsv3_enabled" {
  description = "Whether NFSv3 protocol enabled."
  type        = bool
  default     = null
}

variable "large_file_share_enabled" {
  description = "Whether Large File Share enabled."
  type        = bool
  default     = null
}

variable "local_user_enabled" {
  description = "Whether Local User enabled."
  type        = bool
  default     = null
}

variable "infrastructure_encryption_enabled" {
  description = "Whether infrastructure encryption enabled."
  type        = bool
  default     = null
}

variable "sftp_enabled" {
  description = "Whether SFTP is enabled."
  type        = bool
  default     = null
}

variable "dns_endpoint_type" {
  description = "Specifies which DNS endpoint type to use. Possible values are Standard and AzureDnsZone."
  type        = string
  default     = null
}

variable "network_rules" {
  description = "Network rules configuration."
  type = object({
    default_action             = string
    bypass                     = optional(list(string))
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
  })
  default = null
}

variable "containers" {
  description = "Map of container configuration objects."
  type = map(object({
    name                  = optional(string)
    container_access_type = optional(string)
  }))
  default = {}
}
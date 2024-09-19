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

# Github repository environments
resource "github_repository_environment" "this" {
  for_each = local.github_environments

  repository  = data.external.github_repository.result.name
  environment = each.value.name

  dynamic "reviewers" {
    for_each = local.github_environments[each.key].reviewers == {} ? [] : [1]

    content {
      teams = local.github_environments[each.key].reviewers.teams
      users = local.github_environments[each.key].reviewers.users
    }
  }
}

# Azure Identity for GitHub Actions
module "github_identity" {
  source = "../../modules/azurerm-user-assigned-identity"

  name                = format(module.naming.formats["azurerm_user_assigned_identity"], "main")
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  federated_identity_credentials = {
    github_repository_environment = {
      audience = ["api://AzureADTokenExchange"]
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:${data.external.github_repository.result.full_name}:environment:${var.environment}_${var.global.location_short_name_map[var.location]}"
    }
    github_repository_environment_no_approve = {
      audience = ["api://AzureADTokenExchange"]
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:${data.external.github_repository.result.full_name}:environment:${var.environment}_${var.global.location_short_name_map[var.location]}-no-approve"
    }
  }

  role_mappings = {
    subscription = {
      scope                 = data.azurerm_subscription.this.id
      role_definition_names = ["Contributor", "Storage Blob Data Contributor", "Key Vault Secrets Officer"]
    }
  }

  tags = module.tags_outputs.outputs.tags
}

# Environment secrets
locals {
  github_environment_secrets = {
    AZURE_CLIENT_ID       = module.github_identity.client_id
    AZURE_TENANT_ID       = data.azurerm_client_config.this.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.this.subscription_id
  }

  github_secrets = merge(flatten([for github_environment in keys(local.github_environments) : {
    for name, value in local.github_environment_secrets : format("%s_%s", github_environment, name) => {
      "github_environment" = github_environment,
      "name"               = name,
      "value"              = value
    }
    }
  ])...)
}

resource "github_actions_environment_secret" "this" {
  for_each = local.github_secrets

  repository      = data.external.github_repository.result.name
  environment     = github_repository_environment.this[each.value.github_environment].environment
  secret_name     = each.value.name
  plaintext_value = each.value.value
}
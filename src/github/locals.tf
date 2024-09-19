locals {
  component_name = "github"

  github_environments = {
    this = {
      name = format("%s_%s", var.environment, var.global.location_short_name_map[var.location])
      reviewers = {
        teams = var.reviewers.teams
        users = coalesce(var.reviewers.users, [data.github_user.this.id])
      }
    }
    this_no_approve = {
      name      = format("%s_%s-no-approve", var.environment, var.global.location_short_name_map[var.location])
      reviewers = {}
    }
  }

  # github_environment_secrets = {
  #   AZURE_CLIENT_ID = var.azure_client_id
  #   AZURE_TENANT_ID = data.azurerm_client_config.this.tenant_id
  #   AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.this.subscription_id
  # }

}
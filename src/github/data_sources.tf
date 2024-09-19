data "azurerm_client_config" "this" {}

data "azurerm_subscription" "this" {}

data "github_user" "this" {
  username = ""
}

data "external" "github_repository" {
  program = ["bash", "-c",
    <<-EOSCRIPT
      jq -n '{"full_name": $FULL_NAME, "name": $NAME}' \
      --arg NAME "$(git remote get-url origin | sed -rn 's/\w+:\/\S+?\/\S+\/(\S+)$/\1/p')" \
      --arg FULL_NAME "$(git remote get-url origin | sed -rn 's/\w+:\/\S+?\/(\S+\/\S+)$/\1/p')"
    EOSCRIPT
  ]
}
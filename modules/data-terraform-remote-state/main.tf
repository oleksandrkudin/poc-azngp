module "azurerm_backend_config" {
  source = "../terraform-azurerm-backend"

  location       = var.location
  environment    = var.environment
  component_path = var.component_path
  global         = var.global
}

locals {
  backend_config_map = {
    local = {
      path = "${var.component_path}/terraform.tfstate"
    }
    azurerm = module.azurerm_backend_config.terraform_backend_block.terraform.backend.azurerm
  }
}

data "terraform_remote_state" "this" {
  backend  = var.terraform_backend
  config   = local.backend_config_map[var.terraform_backend]
  defaults = var.defaults
}

module "deepmerge" {
  count   = var.deepmerge ? 1 : 0
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"
  maps = [
    var.defaults,
    data.terraform_remote_state.this.outputs
  ]
}

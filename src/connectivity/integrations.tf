module "tags_outputs" {
  source = "../../modules/data-terraform-remote-state"

  location       = var.location
  environment    = var.environment
  component_path = abspath("../tags")
  global         = var.global

  defaults = {
    tags = {
      Product = "azngp"
    }
  }
}
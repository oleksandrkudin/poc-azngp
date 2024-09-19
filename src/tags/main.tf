# Global tagging
module "tags" {
  source = "../../modules/tags"

  product        = var.global.product
  environment    = var.environment
  location       = var.location
  business_owner = var.global.business_owner
}
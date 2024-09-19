output "tags" {
  value = {
    Product       = var.product
    Environment   = var.environment
    Location      = var.location
    BusinessOwner = var.business_owner
    DeployedBy    = "terraform"
  }
}
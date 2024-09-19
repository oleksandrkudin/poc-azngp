output "terraform_backend_block" {
  value = {
    terraform = {
      backend = {
        azurerm = local.config
      }
    }
  }
}
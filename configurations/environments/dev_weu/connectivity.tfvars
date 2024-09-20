virtual_network = {
  address_space = ["10.10.0.0/16"]
  subnets = {
    aks = {
      address_prefixes = ["10.10.0.0/24"]
    }
  }
}
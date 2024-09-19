variable "product" {
  description = "Short name of the product."
  type        = string
}

variable "environment" {
  description = "Short name of the delivery environment. Example: dev, prod, ..."
  type        = string
}

variable "location" {
  description = "Azure location where resources are deployed."
  type        = string
}

variable "business_owner" {
  description = "Email address of product business owner."
  type        = string
}
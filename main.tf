resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.env}-${var.loc}-01"
  location = var.location
  tags     = var.tags
}

data "http" "public_ip" {
  url = "https://api.ipify.org"
}

locals {
  my_public_ip = data.http.public_ip.response_body
}
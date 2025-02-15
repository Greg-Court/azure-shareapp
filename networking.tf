resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.env}-${var.loc}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet_functions" {
  name                 = "snet-func-${var.env}-01"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  # Possibly not used by the consumption plan, but can define service endpoints
  service_endpoints = ["Microsoft.Storage", "Microsoft.AzureCosmosDB"]
}

resource "azurerm_subnet" "subnet_storage" {
  name                 = "snet-storage-${var.env}-01"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "subnet_cosmos" {
  name                 = "snet-cosmos-${var.env}-01"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB"]
}
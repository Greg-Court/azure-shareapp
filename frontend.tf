resource "azurerm_static_web_app" "frontend" {
  name                = "my-frontend-${var.env}-${var.loc}-01"
  resource_group_name = azurerm_resource_group.main.name
  location            = "westeurope"
  sku_tier            = "Free"

  tags = var.tags
}
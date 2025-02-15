resource "azurerm_static_web_app" "frontend" {
  name                = "webapp-${var.project_name}-${var.env}-${var.loc}-01"
  resource_group_name = azurerm_resource_group.main.name
  location            = "westeurope"
  sku_tier            = "Free"

  tags = var.tags
}
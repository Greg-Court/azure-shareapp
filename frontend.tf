resource "azurerm_static_web_app" "frontend" {
  name                = "my-frontend-${var.env}-${var.loc}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_tier            = "Free"

  tags = var.tags
}

resource "null_resource" "deploy_frontend" {
  provisioner "local-exec" {
    command = "az staticwebapp upload --name my-frontend-${var.env}-${var.loc} --resource-group ${azurerm_resource_group.main.name} --source frontend.zip"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [azurerm_static_web_app.frontend]
}
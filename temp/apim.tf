# resource "azurerm_api_management" "main" {
#   name                = "apim-${var.project_name}-${var.env}-${var.loc}-01"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.main.name

#   publisher_name  = "gregc"
#   publisher_email = "gregcourt10@gmail.com"
#   sku_name        = "Developer_1"

#   tags = var.tags

#   # APIM doesn't always support service endpoints for consumption.
#   # If you want IP restrictions, you can do so via APIM policies or custom configs.
# }

# resource "azurerm_api_management_api" "file_api" {
#   name                = "file-api"
#   resource_group_name = azurerm_resource_group.main.name
#   api_management_name = azurerm_api_management.main.name
#   revision            = "1"
#   display_name        = "Fileshare API"
#   path                = "files" # ensure "files" not used by another API
#   protocols           = ["https"]

#   service_url = "https://${local.function_app_hostname}"
# }
resource "azurerm_eventgrid_system_topic" "storage_topic" {
  name                   = "egt-storage-${var.project_name}-${var.env}-01"
  location               = var.location
  resource_group_name    = azurerm_resource_group.main.name
  source_arm_resource_id = azurerm_storage_account.main.id
  topic_type             = "microsoft.storage.storageaccounts"
  tags                   = var.tags
}

# resource "azurerm_eventgrid_system_topic_event_subscription" "storage_sub" {
#   name                = "egsub-${var.project_name}-${var.env}"
#   resource_group_name = azurerm_resource_group.main.name
#   system_topic        = azurerm_eventgrid_system_topic.storage_topic.id

#   azure_function_endpoint {
#     function_id = azapi_resource.function_app.id
#   }

#   included_event_types = [
#     "Microsoft.Storage.BlobCreated",
#     "Microsoft.Storage.BlobDeleted"
#   ]

#   # If you need advanced filtering:
#   # advanced_filter {
#   #   key           = "subject"
#   #   operator_type = "StringContains"
#   #   values        = ["blobs"]
#   # }
# }
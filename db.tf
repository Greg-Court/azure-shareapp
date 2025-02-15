resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${var.project_name}-${var.env}-${var.loc}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  free_tier_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
  is_virtual_network_filter_enabled = true
  public_network_access_enabled     = false
  virtual_network_rule {
    id = azurerm_subnet.cosmos.id
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "${var.project_name}-db-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "files" {
  name                = "filesMetadata"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_paths = ["/id"]

  depends_on = [azurerm_cosmosdb_sql_database.db]
}
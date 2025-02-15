resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${var.project_name}-${var.env}-${var.loc}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Enable serverless
  capabilities {
    name = "EnableServerless"
  }

  # Enable free tier (if allowed in subscription)
  # enable_free_tier = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # ✅ Enable Virtual Network Filtering (so only allowed networks can access it)
  is_virtual_network_filter_enabled = true

  # ✅ Public network access (must be disabled if using only subnets)
  public_network_access_enabled = false # Set to true if you want IP-based access

  # ✅ Define subnet access (REQUIRED since IP rules aren't allowed)
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

  # For serverless, do not specify throughput
  depends_on = [azurerm_cosmosdb_sql_database.db]
}
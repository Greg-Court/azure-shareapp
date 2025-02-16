resource "azurerm_storage_account" "main" {
  name                          = "st${var.project_name}${var.env}${var.loc}01"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  tags                          = var.tags
  public_network_access_enabled = true # temp

  network_rules {
    default_action = "Allow" # temp
    bypass         = ["AzureServices"]
    ip_rules       = [local.my_public_ip]
    virtual_network_subnet_ids = [
      azurerm_subnet.storage.id
    ]
  }
}

resource "azurerm_storage_container" "files" {
  name                  = "files"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Optional: Microsoft Defender for Storage
# resource "azurerm_security_center_subscription_pricing" "defender_storage" {
#   resource_type = "StorageAccounts"
#   tier          = "Standard"
#   subplan       = "DefenderForStorageV2"

#   depends_on = [azurerm_storage_account.main]
# }

# resource "azurerm_security_center_storage_defender" "main" {
#   storage_account_id = azurerm_storage_account.main.id

#   override_subscription_settings_enabled      = true
#   malware_scanning_on_upload_enabled          = true
#   malware_scanning_on_upload_cap_gb_per_month = 100
#   sensitive_data_discovery_enabled            = true
# }
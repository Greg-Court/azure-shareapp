resource "null_resource" "package_function_code" {
  provisioner "local-exec" {
    command = "zip -r functions.zip functions/"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "azurerm_storage_blob" "function_zip" {
  name                   = "function.zip"
  storage_account_name   = azurerm_storage_account.func.name
  storage_container_name = azurerm_storage_container.deploy_container.name
  type                   = "Block"
  source                 = "functions.zip"
}

resource "azurerm_service_plan" "functions_plan" {
  name                = "asp-${var.project_name}-${var.env}-${var.loc}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "FC1" # Flex Consumption (Y1 for Consumption)
  tags                = var.tags
}

resource "azurerm_storage_account" "func" {
  name                          = "stfunc${var.project_name}${var.env}${var.loc}01"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = true # temp

  network_rules {
    default_action = "Allow" # temp
    bypass         = ["AzureServices"]
    ip_rules       = [local.my_public_ip]
    virtual_network_subnet_ids = [
      azurerm_subnet.functions.id
    ]
  }

  tags = {
    environment = var.env
    project     = var.project_name
  }
}

resource "azurerm_storage_container" "deploy_container" {
  name                  = "deploymentpackage"
  storage_account_name  = azurerm_storage_account.func.name
  container_access_type = "private"
}

resource "azapi_resource" "function_app" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  name                      = "func-${var.project_name}-${var.env}-${var.loc}-01"
  location                  = var.location
  parent_id                 = azurerm_resource_group.main.id
  schema_validation_enabled = false
  depends_on                = [azurerm_service_plan.functions_plan]

  body = {
    kind = "functionapp,linux"
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      serverFarmId = azurerm_service_plan.functions_plan.id

      functionAppConfig = {
        runtime = {
          name    = "node"
          version = "20"
        }
        scaleAndConcurrency = {
          instanceMemoryMB     = 2048
          maximumInstanceCount = 40
        }
        deployment = {
          storage = {
            type  = "blobContainer"
            value = "${azurerm_storage_account.func.primary_blob_endpoint}${azurerm_storage_container.deploy_container.name}"
            authentication = {
              type = "SystemAssignedIdentity"
            }
          }
        }
      }

      # siteConfig is where we add environment variables (app settings)
      siteConfig = {
        appSettings = [
          {
            name  = "WEBSITE_RUN_FROM_PACKAGE"
            value = "1"
          },
          {
            name  = "AzureWebJobsStorage__accountName"
            value = azurerm_storage_account.func.name
          }
        ]
      }
    }
  }

  tags = {
    environment = var.env
    project     = var.project_name
  }
}

# assign manually, leaving here for reference
# resource "azurerm_role_assignment" "allow_blob_access" {
#   scope                = azurerm_storage_account.func.id
#   role_definition_name = "Storage Blob Data Owner"

#   principal_id = azapi_resource.function_app.output["identity"]["principalId"]
# }

locals {
  function_app_hostname = azapi_resource.function_app.output["properties"]["defaultHostName"]
}
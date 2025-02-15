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

# 3) Storage Account (for function code + azurewebjobsstorage)
resource "azurerm_storage_account" "func" {
  name                     = "stfunc${var.project_name}${var.env}${var.loc}01"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  public_network_access_enabled = true # temp

  network_rules {
    # If you want to lock down further, set default_action = "Deny"
    default_action = "Deny"
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

# 4) A container to hold the function code deployment package (optional)
resource "azurerm_storage_container" "deploy_container" {
  name                  = "deploymentpackage"
  storage_account_name  = azurerm_storage_account.func.name
  container_access_type = "private"
}

# 7) Create the FLEX CONSUMPTION FUNCTION APP via AZAPI
resource "azapi_resource" "function_app" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  name                      = "func-${var.project_name}-${var.env}-${var.loc}-01"
  location                  = var.location
  parent_id                 = azurerm_resource_group.main.id
  schema_validation_enabled = false
  depends_on                = [azurerm_service_plan.functions_plan]

  # Provide a Terraform map/list object instead of a JSON string
  body = {
    kind = "functionapp,linux"
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      serverFarmId = azurerm_service_plan.functions_plan.id

      # Required: functionAppConfig for Flex Consumption
      functionAppConfig = {
        runtime = {
          name    = "node"
          version = "18"
        }
        scaleAndConcurrency = {
          instanceMemoryMB     = 2048
          maximumInstanceCount = 3
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
            name  = "FUNCTIONS_WORKER_RUNTIME"
            value = "node"
          },
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

resource "azurerm_role_assignment" "allow_blob_access" {
  scope                = azurerm_storage_account.func.id
  role_definition_name = "Storage Blob Data Owner"

  principal_id = jsondecode(azapi_resource.function_app.output)["identity"]["principalId"]
}

locals {
  function_app_hostname = jsondecode(azapi_resource.function_app.output)["properties"]["defaultHostName"]
}
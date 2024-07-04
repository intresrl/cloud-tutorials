data "azurerm_client_config" "current" {}

resource "random_id" "rnd" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.rg_name}-${random_id.rnd.hex}"
}

resource "azurerm_storage_account" "landarea" {
  name                     = "landarea${random_id.rnd.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

}

resource "azurerm_storage_container" "landarea" {
  name                  = "landarea"
  storage_account_name  = azurerm_storage_account.landarea.name
  container_access_type = "private"
}


# KeyVault
resource "azurerm_key_vault" "keyvault" {
  name                        = "vault-${random_id.rnd.hex}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "default" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge"
  ]
  storage_permissions = [
    "Get",
  ]
}

# Azure function
resource "azurerm_storage_account" "fn" {
  name                     = "fnstorage${random_id.rnd.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_service_plan" "fn" {
  name                = "azure-functions-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

module "fn_storage_notifier" {
  source                        = "modules/storage-notifier"
  location                      = azurerm_storage_account.landarea.location
  rg_name                       = azurerm_resource_group.rg.name
  key_vault_id                  = azurerm_key_vault.keyvault.id
  fn_service_plan               = azurerm_service_plan.fn.id
  fn_storage_account_name       = azurerm_storage_account.fn.name
  fn_storage_account_access_key = azurerm_storage_account.fn.primary_access_key
  sendgrid_api_key              = var.sendgrid_api_key
  mail_sender                   = var.mail_sender
  mail_receiver                 = var.mail_receiver
  landarea_storage_connstring   = azurerm_storage_account.landarea.primary_connection_string

  depends_on = [azurerm_key_vault_access_policy.default]
}

data "azurerm_client_config" "current" {}

resource "random_id" "rnd" {
  byte_length = 4
}

data "archive_file" "function_app_package" {
  type        = "zip"
  output_path = "/tmp/notifier/function-source.zip"
  source_dir  = "modules/storage-notifier/function-source/"
}

resource "azurerm_user_assigned_identity" "fn-identity" {
  name                = "fn-notifier-identity-${random_id.rnd.hex}"
  resource_group_name = var.rg_name
  location            = var.location
}

resource "azurerm_key_vault_access_policy" "function" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.fn-identity.principal_id

  secret_permissions = [
    "Get"
  ]

}
resource "terraform_data" "function_app_package_md5" {

  # Only produce a md5 checksum if local_path_to_function is set. Else just create an empty string.
  input = data.archive_file.function_app_package.output_md5
}

resource "azurerm_key_vault_secret" "sendgrid_key" {
  name         = "sendgrid-api-key"
  value        = var.sendgrid_api_key
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_key_vault_access_policy.function]
}


resource "azurerm_windows_function_app" "fn" {
  name                = "notifier-${random_id.rnd.hex}"
  resource_group_name = var.rg_name
  location            = var.location
  storage_account_name       = var.fn_storage_account_name
  storage_account_access_key = var.fn_storage_account_access_key
  service_plan_id            = var.fn_service_plan

  zip_deploy_file = data.archive_file.function_app_package.output_path

  lifecycle {
    # Whenever a change is made in the Function code, the md5 checksum of the zip will change.
    # This will trigger a replacement of the Function app and redeploy it with the new code.
    replace_triggered_by = [terraform_data.function_app_package_md5]
  }

  site_config {
    application_stack {
      node_version = "~18"
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.fn-identity.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.fn-identity.id

  app_settings = {
    landarea_STORAGE = var.landarea_storage_connstring
    MAIL_RECEIVER    = var.mail_receiver
    MAIL_SENDER      = var.mail_sender
    SENDGRID_API_KEY = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sendgrid_key.id})"
  }

}
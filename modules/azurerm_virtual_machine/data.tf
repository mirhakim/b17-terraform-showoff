
data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "username" {
  name         = var.secret_username
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "password" {
  name         = var.secret_password
  key_vault_id = data.azurerm_key_vault.kv.id
}



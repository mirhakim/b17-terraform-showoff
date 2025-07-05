resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.tenant_id.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
   # Important: enable RBAC mode
  enable_rbac_authorization   = true

}

resource "azurerm_role_assignment" "assign_kv_admin" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "a0f6fea9-14aa-4614-b222-31efe1063b27"
}

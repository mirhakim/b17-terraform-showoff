output "secret_username" {
  value = data.azurerm_key_vault_secret.username.value
}

output "secret_password" {
  value = data.azurerm_key_vault_secret.password.value
}
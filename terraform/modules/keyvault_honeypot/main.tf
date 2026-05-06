resource "azurerm_key_vault" "honeypot" {
  name                = "${var.prefix}-kv-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = merge(var.tags, { honeypot = "true", decoy_type = "keyvault" })

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action = "Allow"
    bypass         = "None"
  }
}

resource "azurerm_key_vault_secret" "bait" {
  name         = "prod-db-password"
  value        = "SuperSecretPassword123!"
  key_vault_id = azurerm_key_vault.honeypot.id
  tags         = var.tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

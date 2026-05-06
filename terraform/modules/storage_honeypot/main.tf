resource "azurerm_storage_account" "honeypot" {
  name                     = "${var.prefix}sa${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = merge(var.tags, { honeypot = "true", decoy_type = "storage" })

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "bait" {
  name                  = "customer-data"
  storage_account_name  = azurerm_storage_account.honeypot.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "fake_pii" {
  name                   = "customers_2024.csv"
  storage_account_name   = azurerm_storage_account.honeypot.name
  storage_container_name = azurerm_storage_container.bait.name
  type                   = "Block"
  source_content         = "id,name,ssn,email\n1,John Doe,123-45-6789,john@example.com\n2,Jane Smith,987-65-4321,jane@example.com"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

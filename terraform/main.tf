terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" }
  }
}

provider "azurerm" { features {} }

locals {
  prefix = "honeynet"
  tags   = { project = "azure-honeynet-factory", managed_by = "terraform" }
}

resource "azurerm_resource_group" "honeynet" {
  name     = "${local.prefix}-rg"
  location = "uksouth"
  tags     = local.tags
}

resource "azurerm_virtual_network" "isolated" {
  name                = "${local.prefix}-vnet"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  address_space       = ["10.254.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "honeypot" {
  name                 = "honeypot-subnet"
  resource_group_name  = azurerm_resource_group.honeynet.name
  virtual_network_name = azurerm_virtual_network.isolated.name
  address_prefixes     = ["10.254.1.0/24"]
}

resource "azurerm_network_security_group" "honeypot" {
  name                = "${local.prefix}-nsg"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  tags                = local.tags

  security_rule {
    name                       = "Allow-Inbound-RDP-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["3389", "22"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "vm_honeypot" {
  source              = "./modules/vm_honeypot"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  subnet_id           = azurerm_subnet.honeypot.id
  nsg_id              = azurerm_network_security_group.honeypot.id
  prefix              = local.prefix
  tags                = local.tags
}

module "keyvault_honeypot" {
  source              = "./modules/keyvault_honeypot"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  prefix              = local.prefix
  tags                = local.tags
}

module "storage_honeypot" {
  source              = "./modules/storage_honeypot"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  prefix              = local.prefix
  tags                = local.tags
}

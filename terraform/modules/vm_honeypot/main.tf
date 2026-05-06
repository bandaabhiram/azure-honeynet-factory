resource "azurerm_network_interface" "honeypot" {
  name                = "${var.prefix}-vm-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.honeypot.id
  }
}

resource "azurerm_public_ip" "honeypot" {
  name                = "${var.prefix}-vm-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_network_interface_security_group_association" "honeypot" {
  network_interface_id      = azurerm_network_interface.honeypot.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_windows_virtual_machine" "honeypot" {
  name                = "PROD-DB-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = random_password.vm.result
  tags                = merge(var.tags, { honeypot = "true", decoy_type = "vm" })

  network_interface_ids = [azurerm_network_interface.honeypot.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "random_password" "vm" {
  length  = 16
  special = true
}

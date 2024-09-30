resource "azurerm_resource_group" "resource_group_test" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    resource_group = var.resource_group_name
  }
}

# It's equal upper sentence.
# resource "azurerm_resource_group" "resource_group_test" {
#   name     = "resource_group_test"
#   location = "Japan East"
# }

resource "azurerm_virtual_network" "virtual_network_test" {
  name                = "virtual_network_test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group_test.location
  resource_group_name = azurerm_resource_group.resource_group_test.name
}

resource "azurerm_subnet" "azure_subnet_test" {
  name                 = "azure_subnet_test"
  resource_group_name  = azurerm_resource_group.resource_group_test.name
  virtual_network_name = azurerm_virtual_network.virtual_network_test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "network_interface_test" {
  name                 = "network_interface_test"
  location             = azurerm_resource_group.resource_group_test.location
  resource_group_name  = azurerm_resource_group.resource_group_test.name

  ip_configuration {
    name                          = "test_configuration"
    subnet_id                     = azurerm_subnet.azure_subnet_test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.private_key.private_key_pem 
    sensitive = true
}


# # ==================================================================
# # Create virtual machine
# resource "azurerm_windows_virtual_machine" "virtual_machine_test" {
#   name                  = "WinServer001"
#   admin_username        = "azureuser"
#   admin_password        = "Root@123456789"
#   location              = azurerm_resource_group.resource_group_test.location
#   resource_group_name   = azurerm_resource_group.resource_group_test.name
#   network_interface_ids = [azurerm_network_interface.network_interface_test.id]
#   size                  = "Standard_DS1_v2"

#   os_disk {
#     name                 = "myOsDisk"
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2022-datacenter-azure-edition"
#     version   = "latest"
#   }


#   # boot_diagnostics {
#   #   storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
#   # }
# }

# ==================================================================
# Create virtual machine
resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  name                  = "gitserver001"
  location              = var.location
  resource_group_name   = azurerm_resource_group.resource_group_test.name
  network_interface_ids = [azurerm_network_interface.network_interface_test.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "86-gen2"
    version   = "latest"
  }

  computer_name  = "gitserver001"
  admin_username = "azureuser"
  admin_password = var.password
  disable_password_authentication = false

  # admin_ssh_key {
  #   username   = "azureuser"
  #   public_key = tls_private_key.private_key.public_key_openssh
  # }

  # boot_diagnostics {
  #   storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  # }
}s

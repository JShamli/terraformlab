terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.15.0"
    }
  }
}

provider "azurerm" {
  subscription_id  = "ac6a84bb-b4a5-4015-b96e-d481df885986"
  client_id		 = "10be3496-87be-4fa6-8431-1df32855212a"
  client_secret 	 = "4RB8Q~FPLVwxq6MFpL4QMR2Pe8rEvAl6pvHTja8Y"
  tenant_id		 = "e88d0f07-7605-4e3c-88dd-7634f6450588"
  features{}
}

resource "azurerm_resource_group" "rgtest" {
  name     = "RG-Test"
  location = "East US"
}

resource "azurerm_public_ip" "testpublicip" {
  name                = "test-publicip"
  resource_group_name = azurerm_resource_group.rgtest.name
  location            = azurerm_resource_group.rgtest.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "testnsg" {
  name                = "nsg-test"
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name
  depends_on = [azurerm_network_security_group.testnsg]
  security_rule {
    name                       = "allow_public_rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }
}
resource "azurerm_virtual_network" "testvnet" {
  name                = "vnet-test"
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name
  address_space       = ["10.10.10.0/24"]
  depends_on = [azurerm_network_security_group.testnsg]
 }

resource "azurerm_subnet" "testsubnet" {
  name                 = "sub-test"
  resource_group_name  = azurerm_resource_group.rgtest.name
  virtual_network_name = azurerm_virtual_network.testvnet.name
  address_prefixes     = ["10.10.10.0/28"]
  depends_on = [azurerm_virtual_network.testvnet]
}

resource "azurerm_subnet_network_security_group_association" "testsubnet" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.testnsg.id
  depends_on = [azurerm_subnet.testsubnet]
}

resource "azurerm_network_interface" "testnic" {
  name                = "nic-testsrv"
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name
  depends_on = [azurerm_subnet_network_security_group_association.testsubnet]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.testpublicip.id
   }
}

resource "azurerm_windows_virtual_machine" "rgtest" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rgtest.name
  location            = azurerm_resource_group.rgtest.location
  size                = "Standard_B2s"
  admin_username      = "nimda"
  admin_password      = "Password@123"
  network_interface_ids = [
    azurerm_network_interface.testnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



resource "azurerm_network_interface" "testnic1" {
  name                = "nic-testsrv1"
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name
  depends_on = [azurerm_subnet_network_security_group_association.testsubnet]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "rgtest1" {
  name                = "testvm"
  resource_group_name = azurerm_resource_group.rgtest.name
  location            = azurerm_resource_group.rgtest.location
  size                = "Standard_B2s"
  admin_username      = "nimda"
  admin_password      = "Password@123"
  network_interface_ids = [
    azurerm_network_interface.testnic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



#5yrGtdIEVxkHjhG5ePvRilSp9CpaOvwUVqKE53Zgi2flKuZkCxkpJQQJ99BAACAAAAAAAAAAAAASAZDOb878

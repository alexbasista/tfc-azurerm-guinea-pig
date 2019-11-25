### --- main --- ###
resource "azurerm_resource_group" "test" {
  name     = "alex-test-rg"
  location = "East US 2"
}

### --- network --- ###
resource "azurerm_network_security_group" "test" {
  name                = "alex-test-nsg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Owner       = "alex"
    Tool        = "Terraform"
    Environment = "Lab"
  }
}

resource "azurerm_network_security_rule" "test" {
  name                        = "alex-test-allow-traffic"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
  description                 = "test allow from my workstation"
  access                      = "Allow"
  protocol                    = "Tcp"
  priority                    = 100
  direction                   = "Inbound"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "69.225.33.150/32"
  destination_address_prefix  = "10.0.0.0/16"
}

resource "azurerm_virtual_network" "test" {
  name                = "alex-default-network"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  location            = "East US 2"

  tags = {
    Owner       = "alex"
    Tool        = "Terraform"
    Environment = "Lab"
  }
}

resource "azurerm_subnet" "test1" {
  name                 = "TestSubnet1"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "test2" {
  name                 = "TestSubnet2"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

# --- compute --- ###
resource "azurerm_public_ip" "test" {
  name                = "TestPublicIp1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"

  tags = {
    environment = "Lab"
  }
}

resource "azurerm_network_interface" "test" {
  name                = "TestNetworkInterface1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testIpConfiguration1"
    subnet_id                     = azurerm_subnet.test1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }

  tags = {
    Environment = "Lab"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "alex-first-azure-vm"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "HelpMe123$"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Lab"
  }
}





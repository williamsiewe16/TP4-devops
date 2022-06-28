#resource "azurerm_ssh_public_key" "example" {
#  name                = var.public_key
#  resource_group_name = data.azurerm_resource_group.example.name
# location            = data.azurerm_resource_group.example.location
# public_key          = file("~/.ssh/id_rsa.pub")
#}

resource "azurerm_network_interface" "example" {
  name                = var.nic
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_public_ip" "example" {
  name                = var.public_ip
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  allocation_method   = "Static"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = var.vm_name
  location              = data.azurerm_resource_group.example.location
  resource_group_name   = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                  = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name    = "mydisk-20200236"
    caching = "ReadWrite"
    #create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  computer_name                   = var.computer_name
  admin_username                  = var.username
  disable_password_authentication = true

  # This is where we pass our cloud-init.
  custom_data = data.template_cloudinit_config.config.rendered

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  tags = {
    environment = "production"
  }
}

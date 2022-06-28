data "azurerm_resource_group" "example" {
  name = var.resource_group
}

data "azurerm_virtual_network" "main" {
  name                = var.network
  resource_group_name = var.resource_group
}

data "azurerm_subnet" "internal" {
  name                 = var.subnet
  resource_group_name  = var.resource_group
  virtual_network_name = var.network
}


data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = "packages: ['docker.io']"
  }
}
resource "azurerm_ssh_public_key" "common_key" {
  name                = "common_key"
  resource_group_name = azurerm_resource_group.resource_group["application"].name
  location            = var.region
  public_key          = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss002" {
  name                = "vmss-${var.project_name}-${var.env}-${var.region}-admin"
  resource_group_name = azurerm_resource_group.resource_group["application"].name
  location            = var.region
  zone_balance        = true
  zones               = [1, 2]
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "azureuser"
  user_data           = filebase64("./userdata_admin.sh")

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = azurerm_ssh_public_key.common_key.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss_nic"
    primary = true

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = azurerm_subnet.private_subnet["10-10-10-0-24"].id
      # application_gateway_backend_address_pool_ids = [one(azurerm_application_gateway.application_gateway.backend_address_pool[*].id)]
    }
  }
}

## Role assignment ##
# resource "azurerm_role_assignment" "blob_role_to_vmss" {
#   scope                = azurerm_resource_group.resource_group["storage"].id
#   role_definition_name = "Owner"
#   principal_id         = azurerm_linux_virtual_machine_scale_set.vmss002.identity[0].principal_id
# }

resource "azurerm_role_assignment" "blob_role_to_vmss_002" {
  scope                = azurerm_resource_group.resource_group["storage"].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine_scale_set.vmss002.identity[0].principal_id
}

resource "azurerm_role_assignment" "table_role_to_vmss_002" {
  scope                = azurerm_resource_group.resource_group["storage"].id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_virtual_machine_scale_set.vmss002.identity[0].principal_id
}
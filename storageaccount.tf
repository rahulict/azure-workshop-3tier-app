resource "random_string" "unique" {
  length  = 5
  special = false
  upper   = false
  numeric = true
}

locals {
  storage_acc_name = lower("st${var.project_name}${var.region}${random_string.unique.result}")
}

resource "azurerm_storage_account" "name" {
  count                         = var.create_storage_account ? 1 : 0
  name                          = local.storage_acc_name
  resource_group_name           = azurerm_resource_group.resource_group["storage"].name
  location                      = var.region
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
}

resource "azurerm_storage_container" "name" {
  count                 = var.create_storage_account ? 1 : 0
  name                  = "container${var.project_name}"
  storage_account_name  = azurerm_storage_account.name[count.index].name
  container_access_type = "private"
}
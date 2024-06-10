resource "azurerm_ssh_public_key" "common_key" {
  name                = "common_key"
  resource_group_name = azurerm_resource_group.resource_group["application"].name
  location            = var.region
  public_key          = file("~/.ssh/id_rsa.pub")
}
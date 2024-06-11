## Creating Virtual Network ##
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}-${var.env}-${var.region}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group["networking"].name
  address_space       = [var.vnet_cidr]

  tags = {
    environment = var.env
  }
}

## Creating Subnets ##
resource "azurerm_subnet" "public_subnet" {
  for_each             = { for cidr in var.public_subnet_cidrs : replace(replace(cidr, ".", "-"), "/", "-") => cidr }
  name                 = "public-subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.resource_group["networking"].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

resource "azurerm_subnet" "private_subnet" {
  for_each                        = { for cidr in var.private_subnet_cidrs : replace(replace(cidr, ".", "-"), "/", "-") => cidr }
  name                            = "private-subnet-${each.key}"
  resource_group_name             = azurerm_resource_group.resource_group["networking"].name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  address_prefixes                = [each.value]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "public-appgateway-subnet-${replace(replace(var.public_app_gateway_cidr, ".", "-"), "/", "-")}"
  resource_group_name  = azurerm_resource_group.resource_group["networking"].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_app_gateway_cidr]
}

resource "azurerm_subnet" "bashtion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.resource_group["networking"].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_bastion_cidr]
}

## Creating NAT Gateway ##
resource "azurerm_public_ip" "public_ip" {
  for_each            = var.public_ips
  name                = "${each.value}-ip-${var.project_name}-${var.env}-${var.region}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group["networking"].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "natgateway-${var.project_name}-${var.env}-${var.region}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group["networking"].name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.public_ip["natgateway"].id
}

resource "azurerm_subnet_nat_gateway_association" "private_subnet_nat_gateway_association" {
  for_each       = { for cidr in var.private_subnet_cidrs : replace(replace(cidr, ".", "-"), "/", "-") => cidr }
  subnet_id      = azurerm_subnet.private_subnet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

## Bastion host ##
resource "azurerm_bastion_host" "bastion_host" {
  name                = "bastion-${var.project_name}-${var.env}-${var.region}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group["networking"].name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bashtion_subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip["bastion"].id
  }
}

## App Gateway NSG & Its rules ##
resource "azurerm_network_security_group" "appgtw_nsg" {
  name                = "nsg-appgtw-${var.project_name}-${var.env}-${var.region}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group["networking"].name
}

resource "azurerm_network_security_rule" "appgtw_nsg_rule" {
  name                        = "appgtw_nsg_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = ["80", "443", "65200-65535"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group["networking"].name
  network_security_group_name = azurerm_network_security_group.appgtw_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_1" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgtw_nsg.id
}

## VMSS NSG & Its rules ##
resource "azurerm_network_security_group" "appgtw_nsg" {
  name                = "nsg-appgtw-${var.project_name}-${var.env}-${var.region}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group["networking"].name
}

resource "azurerm_network_security_rule" "appgtw_nsg_rule" {
  name                        = "appgtw_nsg_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = ["80", "443", "65200-65535"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group["networking"].name
  network_security_group_name = azurerm_network_security_group.appgtw_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_1" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgtw_nsg.id
}
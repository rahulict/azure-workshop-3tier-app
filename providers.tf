terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.107.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "studentResourceGroup"
    storage_account_name = "stforterraformstatefile"
    container_name       = "tfstatefile"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.107.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-for-terraform-resources"
    storage_account_name = "stforterraformstatefiles"
    container_name       = "tfstatefile"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
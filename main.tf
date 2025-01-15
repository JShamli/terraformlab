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

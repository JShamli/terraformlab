terraform {
  backend "azurerm" {
    resource_group_name = "RG-backend"
    storage_account_name = "stgdevopsbackend"
    container_name = "devopsblob"
    key = "devopsblob.tfstate"
  }
}

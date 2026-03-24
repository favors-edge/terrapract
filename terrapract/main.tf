provider "azurerm" {
    features {}
}

# Create resource group
resource "azurerm_resource_group" "resource_group" {
    name = "rg-terraform-pract"
    location = "eastus"
}

# Create a Storage Account
resource "random_string" "storage_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "st4trrpact${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}
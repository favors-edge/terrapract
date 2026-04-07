# Create Platform Management Group (sits under Tenant Root)

resource "azurerm_management_group" "platform" {
    display_name = "Platform"
}

# Create Platform children

resource "azurerm_management_group" "networking" {
    display_name = "Networking"
    parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
    display_name = "Identity"
    parent_management_group_id = azurerm_management_group.platform.id
}

# Create Landing Zones Group (sits under Tenant Root)

resource "azurerm_management_group" "landing_zones" {
    display_name = "Landing Zones"
}

# Create Landing Zone children

resource "azurerm_management_group" "dev {
    display_name = "Dev"
    parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "prod" {
    display_name = "Prod"
    parent_management_group_id = azurerm_management_group.landing_zones.id
}

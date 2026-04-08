# Useful Values After Deployment
output "platform_management_group_id" {
  value = azurerm_management_group.platform.id
}

output "landing_zones_management_group_id" {
  value = azurerm_management_group.landing_zones.id
}

output "dev_management_group_id" {
  value = azurerm_management_group.dev.id
}

output "prod_management_group_id" {
  value = azurerm_management_group.prod.id
}

output "resource_group_name" {
  value = azurerm_resource_group.landing_dev.name
}
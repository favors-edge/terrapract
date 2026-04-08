# Create Resource Group
resource "azurerm_resource_group" "landing_dev" {
    name = var.resource_group_name
    location = var.location
    tags = var.default_tags
}

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

resource "azurerm_management_group" "dev" {
    display_name = "Dev"
    parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "prod" {
    display_name = "Prod"
    parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Policy: Allowed Locations

resource "azurerm_policy_definition" "allowed_locations" {
    name = "allowed_locations"
    policy_type = "Custom"
    mode = "All"
    display_name = "Allowed locations"
    description = "Restricts resource deployment to approved Azure regions only."
    management_group_id = azurerm_management_group.landing_zones.id

    policy_rule = jsonencode({
        "if" = {
            "not" = {
                "field" = "location"
                "in" = ["eastus", "eastus2"]
            }
        },
        "then" = {
            "effect" = "deny"
        }
    })
}

resource "azurerm_management_group_policy_assignment" "location_assignment" {
    name = "restrict-locations"
    management_group_id = azurerm_management_group.landing_zones.id
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    display_name = "Restrict to approved regions"
    description = "Applied to all Landing Zone subscriptions via inheritance."
}

# Policy: Require Environment tag

resource "azurerm_policy_definition" "require_env_tag" {
  name         = "require-environment-tag"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Environment tag"
  description  = "Denies creation of resources missing the Environment tag."
  management_group_id = azurerm_management_group.landing_zones.id

  policy_rule = jsonencode({
    "if" = {
      "field"  = "tags['Environment']"
      "exists" = "false"
    },
    "then" = {
      "effect" = "deny"
    }
  })
}

resource "azurerm_management_group_policy_assignment" "tag_assignment" {
  name                 = "require-env-tag"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.require_env_tag.id
  display_name         = "Require Environment tag on all resources"
}

# Create RBAC

# Reader on Dev: can view resources, cannot change anything
resource "azurerm_role_assignment" "dev_reader" {
  scope                = azurerm_management_group.dev.id
  role_definition_name = "Reader"
  principal_id         = var.dev_reader_object_id
}

# Contributor on Dev: can create/manage, cannot change access policies
resource "azurerm_role_assignment" "dev_contributor" {
  scope                = azurerm_management_group.dev.id
  role_definition_name = "Contributor"
  principal_id         = var.dev_contributor_object_id
}

# No Contributor on Prod is intentional.
# Dev team members get read-only access to production.

# Assocating subscription to managemnet Group

data "azurerm_subscription" "current" {}

resource "azurerm_management_group_subscription_association" "dev_sub" {
  management_group_id = azurerm_management_group.landing_zones.id
  subscription_id     = data.azurerm_subscription.current.subscription_id
}
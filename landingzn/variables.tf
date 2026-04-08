variable "location" {
    description = "Azure region for all resources"
    type = string
    default = "East US"
}

variable "resource_group_name" {
    description = "Name of the base resource group"
    type = string
    default = "rg-landing-dev"
}

variable "default_tags" {
    description = "Standard tags applied to all resources"
    type = map(string)
    default = {
        Environment = "dev"
        Owner = "favors-edge"
        CostCenter = "terrapract-project"
        ManagedBy = "Terraform"
    }
}

# Object IDs for RBAC asignments
variable "dev_reader_object_id" {
  description = "Object ID of user/group to assign Dev Reader role"
  type        = string
}

variable "dev_contributor_object_id" {
  description = "Object ID of user/group to assign Dev Contributor role"
  type        = string
}
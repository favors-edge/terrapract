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
        Owner = "

    }
}
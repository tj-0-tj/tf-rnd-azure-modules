variable "assetname" {
  type        = string
  description = "String to set asset name"
}

variable "environment" {
  type        = string
  description = "String to create environment specific values in resources. Acceptable values DEV, TEST ,PROD"
}

variable "location" {
  type        = string
  description = "String to specify target region for deployment. ie values uksouth"
}

variable "purge_protection_enabled" {
  type = bool
  default = false
  description = "Purge Protection true/false for this Key Vault.Once Purge Protection has been Enabled it's not possible to Disable it."
}

variable "resource_group_name" {
  type = string
  description = " Resource group"
}
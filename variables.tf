variable "ado_vg_name" {
  type = string
}

variable "ado_project_name" {
  type = string
}

variable "ado_sp_endpoint_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "department" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "secret_maps" {
  type    = map(string)
  default = {}
}
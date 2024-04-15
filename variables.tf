variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group name"
}

variable "app_service_plan_name" {
  type        = string
  description = "Service plan name"
}

variable "app_service_name" {
  type        = string
  description = "App name"
}

variable "sql_server_name" {
  type        = string
  description = "SQL server name"
}

variable "sql_database_name" {
  type        = string
  description = "SQL database name"
}

variable "sql_admin_login" {
  type        = string
  description = "SQL admin username"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL admin password"
}

variable "firewall_rule_name" {
  type        = string
  description = "Firewall rull name"
}

variable "repo_url" {
  type        = string
  description = "GitHub repo URL"
}
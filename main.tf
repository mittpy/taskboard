terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  # name     = "ContactBookRG${random_integer.ri.result}"
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
  # location = "North Europe"
}

resource "azurerm_app_service_plan" "asp" {
  # name                = "contact-book${random_integer.ri.result}"
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "F1"
  }
}

resource "azurerm_linux_web_app" "alwa" {
  # name                = "web-app${random_integer.ri.result}"
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_app_service_plan.asp.location
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.mssqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssqldatabase.name};User ID=${azurerm_mssql_server.mssqlserver.administrator_login};Password=${azurerm_mssql_server.mssqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_server" "mssqlserver" {
  # name                         = "mssqlserver${random_integer.ri.result}"
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  # administrator_login          = "adminUser"
  # administrator_login_password = "thisIsKat11"
  # minimum_tls_version          = "1.2"

  # azuread_administrator {
  #   login_username = "AzureAD Admin"
  #   object_id      = "00000000-0000-0000-0000-000000000000"
  # }

  # tags = {
  #   environment = "production"
  # }
}

resource "azurerm_mssql_database" "mssqldatabase" {
  # name         = "mssql-db${random_integer.ri.result}"
  name         = "${var.sql_database_name}${random_integer.ri.result}"
  server_id    = azurerm_mssql_server.mssqlserver.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  # max_size_gb  = 4
  # read_scale     = true
  sku_name = "S0"
  # zone_redundant = true
  # enclave_type   = "VBS"

  # tags = {
  #   foo = "bar"
  # }
}

resource "azurerm_mssql_firewall_rule" "firewall" {
  # name             = "FirewallRule1"
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.mssqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "aassc" {
  app_id   = azurerm_linux_web_app.alwa.id
  repo_url = var.repo_url
  # repo_url               = "https://github.com/mittpy/taskboard"
  branch                 = "master"
  use_manual_integration = true
}
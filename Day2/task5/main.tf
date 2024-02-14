terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.44.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RCreation" {
  name     = "RCreation"
  location = "West Europe"
}

resource "azurerm_network_security_group" "snet" {
  name                = "snet"
  location            = azurerm_resource_group.RCreation.location
  resource_group_name = azurerm_resource_group.RCreation.name
}

resource "azurerm_virtual_network" "example" {
  name                = "VNET"
  location            = azurerm_resource_group.RCreation.location
  resource_group_name = azurerm_resource_group.RCreation.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.snet.id
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "SGRoup" {
  name                = "SGRoup"
  location            = azurerm_resource_group.RCreation.location
  resource_group_name = azurerm_resource_group.RCreation.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example1" {
  name                     = "vishnumvdevelopsazure"  # Unique storage account name
  resource_group_name      = azurerm_resource_group.RCreation.name
  location                 = azurerm_resource_group.RCreation.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



resource "azurerm_data_factory" "example" {
  name                = "VishnuDevelop"  # Use the same data factory name as in code3
  location            = azurerm_resource_group.RCreation.location
  resource_group_name = azurerm_resource_group.RCreation.name

  tags = {
    "terraform"    = "terraform"
    "environment"  = "Production"
  }
}
resource "azurerm_log_analytics_workspace" "log" {
  name                = "acctest-01"
  location            = azurerm_resource_group.RCreation.location
  resource_group_name = azurerm_resource_group.RCreation.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "example" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.RCreation.name
  short_name          = "p0action"
  
  email_receiver {
    name                    = "sendtodevops"
    email_address           = "vishnuvijayan62@outlook.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  name                = "metricalert"
  resource_group_name = azurerm_resource_group.RCreation.name
  scopes              = [azurerm_storage_account.example1.id]
  description         = "Action will be triggered when Transactions count is greater than 50."

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.example.id  # Use the ID of the action group
  }


  depends_on=[
  azurerm_monitor_action_group.example,
  azurerm_storage_account.example1]  
}
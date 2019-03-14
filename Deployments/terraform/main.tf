provider "azurerm" {}

resource "azurerm_resource_group" "rg" {
	name		= "cloudskills-${var.customer_name}-rg"
	location	= "${var.location}"
}

resource "azurerm_app_service_plan" "asp" {
	name		= "cloudskills-${var.customer_name}-asp"
	location	= "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"

	sku {
		tier = "Standard"
		size = "S1"
	}
}

resource "azurerm_app_service" "web" {
	name		= "cloudskills-${var.customer_name}"
	location	= "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	app_service_plan_id = "${azurerm_app_service_plan.asp.id}"

	app_settings = {
		"AzureCosmosDbOptions:ConnectionString" = "AccountEndpoint=${azurerm_cosmosdb_account.cosmos.endpoint};AccountKey=${azurerm_cosmosdb_account.cosmos.primary_master_key};"
		"AzureCosmosDbOptions:DatabaseId" = "cloudskills"
		"AzureQueueStorageEventPublisherOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"AzureQueueStorageEventPublisherOptions:QueuePrefix" = ""
		"AzureTableStorageOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"ApplicationInsights:InstrumentationKey" = "${azurerm_application_insights.ai.instrumentation_key}"
		"AzureADB2COptions:Authority" = "https://cloudskillsuhaul.b2clogin.com/cloudskillsuhaul.onmicrosoft.com/B2C_1_SignUpSignIn/v2.0"
		"AzureADB2COptions:ClientId" = "fd83d2b6-f2e9-4a30-a661-ae3e59f90af5"
		"AzureADB2COptions:ClientSecret" = ""
		"AzureADB2COptions:MetadataAddress" = "https://cloudskillsuhaul.b2clogin.com/cloudskillsuhaul.onmicrosoft.com/v2.0/.well-known/openid-configuration?p=B2C_1_SignUpSignIn"
	}
}

resource "azurerm_function_app" "func" {
	name = "cloudskills-${var.customer_name}-func"
	location = "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	app_service_plan_id = "${azurerm_app_service_plan.asp.id}"
	storage_connection_string = "${azurerm_storage_account.storage.primary_connection_string}"

	app_settings = {
		"AzureCosmosDbOptions:ConnectionString" = "AccountEndpoint=${azurerm_cosmosdb_account.cosmos.endpoint};AccountKey=${azurerm_cosmosdb_account.cosmos.primary_master_key};"
		"AzureCosmosDbOptions:DatabaseId" = "cloudskills"
		"AzureQueueStorageEventPublisherOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"AzureQueueStorageEventPublisherOptions:QueuePrefix" = ""
		"AzureStorageOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"ApplicationInsights:InstrumentationKey" = "${azurerm_application_insights.ai.instrumentation_key}"
		"APPLICATION_INSIGHTS" = "${azurerm_application_insights.ai.instrumentation_key}"
	}
}

resource "azurerm_storage_account" "storage" {
	name		= "cloudskills${var.customer_name}"
	location	= "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	account_tier	= "Standard"
	account_replication_type = "LRS"
}

resource "azurerm_storage_table" "table" {
	name		= "profiles"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	storage_account_name = "${azurerm_storage_account.storage.name}"
}

resource "azurerm_cosmosdb_account" "cosmos" {
	name = "cloudskills-${var.customer_name}-cosmosdb"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	location = "${azurerm_resource_group.rg.location}"
	offer_type = "Standard"
	enable_automatic_failover = "false"
	consistency_policy {
		consistency_level = "Session"
	}

	geo_location {
		location = "${azurerm_resource_group.rg.location}"
		failover_priority = "0"
	}
}

resource "azurerm_application_insights" "ai" {
	name = "cloudskills-${var.customer_name}-ai"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	location = "${azurerm_resource_group.rg.location}"
	application_type = "other"
}
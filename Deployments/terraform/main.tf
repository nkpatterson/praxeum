provider "azurerm" {}

locals {
	name_prefix = "cloudskills-${var.instance_name}"
	b2c_root_uri = "https://${var.b2c_tenant}.b2clogin.com/${var.b2c_tenant}.onmicrosoft.com"
}

resource "azurerm_resource_group" "rg" {
	name		= "${local.name_prefix}-rg"
	location	= "${var.location}"
}

resource "azurerm_app_service_plan" "asp" {
	name		= "${local.name_prefix}-asp"
	location	= "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"

	sku {
		tier = "Standard"
		size = "S1"
	}
}

resource "azurerm_app_service" "web" {
	name		= "${local.name_prefix}"
	location	= "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	app_service_plan_id = "${azurerm_app_service_plan.asp.id}"
	https_only = "true"

	app_settings = {
		"AzureCosmosDbOptions:ConnectionString" = "AccountEndpoint=${azurerm_cosmosdb_account.cosmos.endpoint};AccountKey=${azurerm_cosmosdb_account.cosmos.primary_master_key};"
		"AzureCosmosDbOptions:DatabaseId" = "cloudskills"
		"AzureQueueStorageEventPublisherOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"AzureQueueStorageEventPublisherOptions:QueuePrefix" = ""
		"AzureTableStorageOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"ApplicationInsights:InstrumentationKey" = "${azurerm_application_insights.ai.instrumentation_key}"
		"AzureADB2COptions:Authority" = "${local.b2c_root_uri}/${var.b2c_policy}/v2.0"
		"AzureADB2COptions:ClientId" = "${var.b2c_client_id}"
		"AzureADB2COptions:ClientSecret" = "${var.b2c_client_secret}"
		"AzureADB2COptions:MetadataAddress" = "${local.b2c_root_uri}/v2.0/.well-known/openid-configuration?p=${var.b2c_policy}"
		"APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.ai.instrumentation_key}"
		"APPINSIGHTS_PROFILERFEATURE_VERSION" = "1.0.0"
		"APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "1.0.0"
		"ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
		"DiagnosticServices_EXTENSION_VERSION" = "~3"
		"InstrumentationEngine_EXTENSION_VERSION" = "~1"
		"SnapshotDebugger_EXTENSION_VERSION" = "~1"
		"XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
		"XDT_MicrosoftApplicationInsights_Mode" = "recommended"
		"WEBSITE_RUN_FROM_PACKAGE" = "1"
	}

	site_config {
		always_on = "true"
	}
}

resource "azurerm_app_service_slot" "beta" {
	name		= "beta"
	location	= "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	app_service_plan_id = "${azurerm_app_service_plan.asp.id}"
	app_service_name = "${azurerm_app_service.web.name}"
	https_only = "true"

	app_settings = {
		"AzureCosmosDbOptions:ConnectionString" = "AccountEndpoint=${azurerm_cosmosdb_account.cosmos.endpoint};AccountKey=${azurerm_cosmosdb_account.cosmos.primary_master_key};"
		"AzureCosmosDbOptions:DatabaseId" = "cloudskills"
		"AzureQueueStorageEventPublisherOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"AzureQueueStorageEventPublisherOptions:QueuePrefix" = ""
		"AzureTableStorageOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"ApplicationInsights:InstrumentationKey" = "${azurerm_application_insights.ai.instrumentation_key}"
		"AzureADB2COptions:Authority" = "${local.b2c_root_uri}/${var.b2c_policy}/v2.0"
		"AzureADB2COptions:ClientId" = "${var.b2c_client_id}"
		"AzureADB2COptions:ClientSecret" = "${var.b2c_client_secret}"
		"AzureADB2COptions:MetadataAddress" = "${local.b2c_root_uri}/v2.0/.well-known/openid-configuration?p=${var.b2c_policy}"
		"APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.ai.instrumentation_key}"
		"APPINSIGHTS_PROFILERFEATURE_VERSION" = "1.0.0"
		"APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "1.0.0"
		"ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
		"DiagnosticServices_EXTENSION_VERSION" = "~3"
		"InstrumentationEngine_EXTENSION_VERSION" = "~1"
		"SnapshotDebugger_EXTENSION_VERSION" = "~1"
		"XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
		"XDT_MicrosoftApplicationInsights_Mode" = "recommended"
		"WEBSITE_RUN_FROM_PACKAGE" = "1"
	}

	site_config {
		always_on = "true"
	}
}

resource "azurerm_function_app" "func" {
	name = "${local.name_prefix}-func"
	location = "${azurerm_resource_group.rg.location}"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	app_service_plan_id = "${azurerm_app_service_plan.asp.id}"
	storage_connection_string = "${azurerm_storage_account.storage.primary_connection_string}"
	version = "~2"

	app_settings = {
		"AzureCosmosDbOptions:ConnectionString" = "AccountEndpoint=${azurerm_cosmosdb_account.cosmos.endpoint};AccountKey=${azurerm_cosmosdb_account.cosmos.primary_master_key};"
		"AzureCosmosDbOptions:DatabaseId" = "cloudskills"
		"AzureQueueStorageEventPublisherOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"AzureQueueStorageEventPublisherOptions:QueuePrefix" = ""
		"AzureStorageOptions:ConnectionString" = "${azurerm_storage_account.storage.primary_connection_string}"
		"ApplicationInsights:InstrumentationKey" = "${azurerm_application_insights.ai.instrumentation_key}"
		"APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.ai.instrumentation_key}"
		"APPINSIGHTS_PROFILERFEATURE_VERSION" = "1.0.0"
		"APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "1.0.0"
		"ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
		"DiagnosticServices_EXTENSION_VERSION" = "~3"
		"InstrumentationEngine_EXTENSION_VERSION" = "~1"
		"SnapshotDebugger_EXTENSION_VERSION" = "~1"
		"XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
		"XDT_MicrosoftApplicationInsights_Mode" = "recommended"
		"FUNCTIONS_EXTENSION_VERSION" = "~2"
		"WEBSITE_RUN_FROM_PACKAGE" = "1"
	}

	site_config {
		always_on = "true"
	}
}

resource "azurerm_storage_account" "storage" {
	name		= "cloudskills${var.instance_name}"
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
	name = "${local.name_prefix}-cosmosdb"
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
	name = "${local.name_prefix}-ai"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	location = "${azurerm_resource_group.rg.location}"
	application_type = "other"
}
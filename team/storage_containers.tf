resource "azurerm_storage_account" "this" {
  name                     = substr("workshopagenda${join("", regexall("[0-9a-z]+", var.name))}", 0, 24)
  resource_group_name      = azurerm_resource_group.global.name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.tags
}

resource "azurerm_storage_container" "this" {
  for_each = var.environments

  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  for_each = var.environments

  scope                = azurerm_storage_container.this[each.value].resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.iac[each.value].principal_id
}

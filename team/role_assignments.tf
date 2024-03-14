data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "iac" {
  for_each = var.environments

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.iac[each.value].principal_id
}

################################################################################

resource "azurerm_role_assignment" "operator" {
  scope                = azurerm_resource_group.environments["dev"].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_user_assigned_identity.operator.principal_id
}

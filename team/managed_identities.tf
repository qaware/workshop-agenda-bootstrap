resource "azurerm_user_assigned_identity" "iac" {
  for_each = var.environments

  location            = var.azure_location
  name                = "id-github-iac-${var.name}-${each.value}"
  resource_group_name = azurerm_resource_group.global.name
}

resource "azurerm_federated_identity_credential" "iac" {
  for_each = var.environments

  name                = "github-iac-${var.name}-${each.value}"
  resource_group_name = azurerm_resource_group.global.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.iac[each.value].id
  subject             = "repo:${github_repository.iac.full_name}:environment:${each.value}"
}

################################################################################

resource "azurerm_user_assigned_identity" "operator" {
  location            = var.azure_location
  name                = "id-github-operator-${var.name}"
  resource_group_name = azurerm_resource_group.global.name
}

resource "azurerm_federated_identity_credential" "operator" {
  name                = "github-operator-${var.name}"
  resource_group_name = azurerm_resource_group.global.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.operator.id
  subject             = "repo:${github_repository.operator.full_name}:ref:refs/heads/main"
}

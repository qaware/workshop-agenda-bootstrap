resource "azurerm_resource_group" "global" {
  name     = "rg-${var.name}-global"
  location = var.azure_location

  tags = local.tags
}

################################################################################

resource "azurerm_resource_group" "environments" {
  for_each = var.environments

  name     = "rg-${var.name}-${each.value}"
  location = var.azure_location

  tags = local.tags
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    github = {
      source = "integrations/github"
    }
  }
}

################################################################################

locals {
  tags = merge(var.tags, {
    Team = var.name
  })
}

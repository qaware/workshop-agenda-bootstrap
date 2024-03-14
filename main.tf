terraform {
  required_providers {
    azurerm = {
      # https://github.com/hashicorp/terraform-provider-azurerm/releases
      source  = "hashicorp/azurerm"
      version = "3.97.1"
    }
    github = {
      # https://github.com/integrations/terraform-provider-github/releases
      source  = "integrations/github"
      version = "6.2.0"
    }
  }
}

################################################################################
# Provider configurations

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}

################################################################################
# Global variables

locals {
  tags = {
    Type     = "workshop"
    Customer = "agenda"
  }
}

################################################################################
# Team configurations

data "azurerm_client_config" "current" {}

module "team" {
  source   = "./team"
  for_each = toset(["demo"])

  azure_tenant_id       = data.azurerm_client_config.current.tenant_id
  azure_subscription_id = data.azurerm_client_config.current.subscription_id
  azure_location        = var.location
  github_org            = var.github_org
  github_token          = var.github_token
  name                  = each.value

  tags = local.tags
}

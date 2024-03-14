locals {
  github_topics = ["workshop", "agenda", var.name]
}

################################################################################

resource "github_repository" "iac" {
  name      = "workshop-agenda-iac-${var.name}"
  auto_init = false
  topics    = local.github_topics

  template {
    owner      = var.github_org
    repository = "workshop-agenda-iac-template"
  }
}

resource "github_repository_environment" "iac" {
  for_each = var.environments

  environment = each.value
  repository  = github_repository.iac.name

  dynamic "deployment_branch_policy" {
    for_each = each.value == "dynamic" ? [] : [1]
    content {
      protected_branches     = true
      custom_branch_policies = false
    }
  }

  dynamic "reviewers" {
    for_each = each.value == "prod" ? [1] : []
    content {
      teams = []
      users = [
        9094768, # akowasch
      ]
    }
  }
}

resource "github_actions_variable" "iac" {
  for_each = {
    AZURE_TENANT_ID                    = var.azure_tenant_id
    AZURE_SUBSCRIPTION_ID              = var.azure_subscription_id
    BACKEND_AZURE_RESOURCE_GROUP_NAME  = azurerm_resource_group.global.name
    BACKEND_AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.this.name
    TF_VAR_GITHUB_ORG                  = var.github_org
    TF_VAR_GITOPS_REPO                 = github_repository.gitops.name
  }

  repository    = github_repository.iac.name
  variable_name = each.key
  value         = each.value
}

locals {
  environment_variables = {
    for env in var.environments : env => {
      AZURE_CLIENT_ID                              = azurerm_user_assigned_identity.iac[env].client_id
      AZURE_RESOURCE_GROUP_NAME                    = azurerm_resource_group.environments[env].name
      BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME = azurerm_storage_container.this[env].name
    }
  }
  environment_variables_expanded = merge([
    for k1, v1 in local.environment_variables : {
      for k2, v2 in v1 : "${upper(k1)}_${k2}" => {
        environment     = k1
        secret_name     = k2
        plaintext_value = v2
      }
    }
  ]...)
}

resource "github_actions_secret" "iac" {
  for_each = {
    TF_VAR_GITHUB_TOKEN = var.github_token
  }

  repository      = github_repository.iac.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_actions_environment_variable" "iac" {
  for_each = local.environment_variables_expanded

  repository    = github_repository.iac.name
  environment   = github_repository_environment.iac[each.value.environment].environment
  variable_name = each.value.secret_name
  value         = each.value.plaintext_value
}

################################################################################

resource "github_repository" "gitops" {
  name      = "workshop-agenda-gitops-${var.name}"
  auto_init = false
  topics    = local.github_topics
}

################################################################################

resource "github_repository" "operator" {
  name      = "workshop-agenda-operator-${var.name}"
  auto_init = false
  topics    = local.github_topics
}

resource "github_actions_variable" "operator" {
  for_each = {
    AZURE_CLIENT_ID           = azurerm_user_assigned_identity.operator.client_id
    AZURE_RESOURCE_GROUP_NAME = azurerm_resource_group.environments["dev"].name
    AZURE_SUBSCRIPTION_ID     = var.azure_subscription_id
    AZURE_TENANT_ID           = var.azure_tenant_id
  }

  repository    = github_repository.operator.name
  variable_name = each.key
  value         = each.value
}

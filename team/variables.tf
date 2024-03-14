variable "azure_tenant_id" {
  type        = string
  description = "The Azure tenant ID."
  nullable    = false
}

variable "azure_subscription_id" {
  type        = string
  description = "The Azure subscription ID."
  nullable    = false
}

variable "azure_location" {
  type        = string
  description = "The Azure location/region."
  nullable    = false
}

variable "github_org" {
  type        = string
  description = "The name of the GitHub organisation."
  nullable    = false
}

variable "github_token" {
  type        = string
  description = "The token to authenticate against the GitHub API."
  sensitive   = true
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the team."
  nullable    = false

  validation {
    condition     = var.name != ""
    error_message = "The name of the team must not be empty."
  }
}

variable "environments" {
  type        = set(string)
  description = "The deployment environments."
  default     = ["dev", "test", "prod", "dynamic"]
  nullable    = false

  validation {
    condition     = length(var.environments) > 0
    error_message = "At least one environment must be specified."
  }
}

variable "tags" {
  description = "The tags to associate with all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

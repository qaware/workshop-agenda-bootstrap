variable "location" {
  description = "The location/region of the resources."
  type        = string
  default     = "Germany West Central"
  nullable    = false

  validation {
    condition     = var.location != ""
    error_message = "The location must not be empty."
  }
}

variable "github_org" {
  description = "The name of the GitHub organisation."
  type        = string
  nullable    = false

  validation {
    condition     = var.github_org != ""
    error_message = "The GitHub organisation must not be empty."
  }
}

variable "github_token" {
  description = "The token to authenticate against the GitHub API."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = var.github_token != ""
    error_message = "The GitHub token must not be empty."
  }
}

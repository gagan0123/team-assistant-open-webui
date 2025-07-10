variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "location" {
  description = "Google Cloud region for Cloud Build"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "connection_id" {
  description = "The ID of the Cloud Build connection"
  type        = string
}

variable "github_app_installation_id" {
  description = "The installation ID of the GitHub App"
  type        = number
  sensitive   = true
}

variable "github_owner" {
  description = "The owner of the GitHub repository"
  type        = string
}

variable "repository_name" {
  description = "Name of the repository in Cloud Build"
  type        = string
}

variable "branch_regex" {
  description = "Regex for the branch to trigger builds on"
  type        = string
  default     = "^main$"
}

variable "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  type        = string
}

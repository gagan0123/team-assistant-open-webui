variable "project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources to."
  type        = string
}

variable "gcp_services" {
  description = "The list of GCP services to enable for Phase 1."
  type        = list(string)
  default = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
  ]
}

variable "repository_id" {
  description = "The ID for the Artifact Registry repository."
  type        = string
  default     = "open-webui"
}

variable "webui_secret_name" {
  description = "The name for the WebUI secret key in Secret Manager."
  type        = string
  default     = "webui-secret-key"
}

variable "cloud_run_service_name" {
  description = "The name for the Cloud Run service."
  type        = string
  default     = "open-webui-app"
}

variable "service_account_id" {
  description = "The ID for the application's service account."
  type        = string
  default     = "open-webui-app-sa"
}

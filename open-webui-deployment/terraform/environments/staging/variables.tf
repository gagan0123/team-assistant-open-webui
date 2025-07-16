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
    "compute.googleapis.com",       # For VPC
    "vpcaccess.googleapis.com",     # For VPC Connector
    "file.googleapis.com",          # For Filestore
    "sqladmin.googleapis.com",      # For Cloud SQL
    "redis.googleapis.com",         # For Memorystore (Redis)
    "servicenetworking.googleapis.com" # For private service connection
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

variable "network_name" {
  type    = string
  default = "open-webui-vpc"
}
variable "subnet_name" {
  type    = string
  default = "open-webui-subnet"
}
variable "subnet_ip_range" {
  type    = string
  default = "10.0.0.0/28" # A standard private IP range
}
variable "vpc_connector_name" {
  type    = string
  default = "open-webui-connector"
}

variable "db_instance_name" {
  type    = string
  default = "open-webui-pg-instance"
}
variable "db_name" {
  type    = string
  default = "openwebui"
}
variable "db_user" {
  type    = string
  default = "openwebui"
}
variable "redis_instance_name" {
  type    = string
  default = "open-webui-redis-cache"
}
variable "filestore_instance_name" {
  type    = string
  default = "open-webui-data-share"
}
variable "filestore_share_name" {
  type    = string
  default = "data"
}

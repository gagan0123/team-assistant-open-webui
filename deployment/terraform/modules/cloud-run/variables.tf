variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "container_image" {
  description = "URL of the container image"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run instances"
  type        = string
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run instances"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
}

variable "vpc_connector_name" {
  description = "Name of the VPC connector"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Email of the service account for the Cloud Run service"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the service"
  type        = map(string)
  default     = {}
}

variable "timeout_seconds" {
  description = "Timeout for the Cloud Run service"
  type        = number
  default     = 300
}

variable "container_concurrency" {
  description = "Container concurrency"
  type        = number
  default     = 80
}

variable "allow_public_access" {
  description = "Allow public access to the Cloud Run service"
  type        = bool
  default     = false
}

variable "artifact_repository_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
}

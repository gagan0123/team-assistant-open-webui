variable "project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "region" {
  description = "The GCP region for primary resources."
  type        = string
}

variable "zone" {
  description = "The GCP zone for the GCE instance."
  type        = string
}

variable "gcp_services" {
  description = "The list of GCP services to enable for the IAP model."
  type        = list(string)
  default = [
    "compute.googleapis.com",             # For GCE, Firewall, Load Balancer
    "iap.googleapis.com",                 # For Identity-Aware Proxy
    "artifactregistry.googleapis.com",    # To store our Docker image
    "cloudbuild.googleapis.com",          # To build our Docker image
    "secretmanager.googleapis.com",       # To manage secrets
  ]
}

variable "instance_name" {
  description = "The name of the GCE instance for the staging environment."
  type        = string
  default     = "open-webui-staging-vm"
}


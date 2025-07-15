variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_services" {
  description = "The list of GCP services to enable."
  type        = list(string)
}

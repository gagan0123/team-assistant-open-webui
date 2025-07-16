variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "service_name" {
  type = string
}
variable "image_uri" {
  type = string
}
variable "webui_secret_name" {
  type = string
}
variable "service_account_email" {
  description = "The email of the service account for the Cloud Run service to use."
  type        = string
}
variable "vpc_connector_id" {
  type = string
}
variable "filestore_ip_address" {
  type = string
}
variable "filestore_share_name" {
  type = string
}

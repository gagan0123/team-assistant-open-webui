variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "network_id" {
  type = string
}
variable "private_service_connection" {
  description = "Placeholder to enforce dependency on the private service connection."
  type        = any
  default     = null
}

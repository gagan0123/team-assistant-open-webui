variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "zone" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "machine_type" {
  type    = string
  default = "e2-medium"
}
variable "boot_disk_image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}
variable "network_tag" {
  type    = string
  default = "webserver"
}
variable "startup_script" {
  type      = string
  sensitive = true # The script might contain sensitive info
}
variable "docker_compose_content" {
  type      = string
  sensitive = true
}
variable "image_uri" {
  type = string
}
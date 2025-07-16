variable "project_id" {
  type = string
}
variable "zone" { # <-- Renamed from "region" to "zone"
  type = string
}
variable "instance_name" {
  type = string
}
variable "network_id" {
  type = string
}
variable "file_share_name" {
  type = string
}

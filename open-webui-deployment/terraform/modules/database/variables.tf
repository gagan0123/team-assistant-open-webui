variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "database_version" {
  type    = string
  default = "POSTGRES_14"
}
variable "db_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "db_password" {
  type = string
}
variable "network_id" {
  type = string
}


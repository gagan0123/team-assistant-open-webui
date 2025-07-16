variable "project_id" {
  type = string
}
variable "lb_name" {
  description = "A name prefix for all load balancer components."
  type        = string
}
variable "instance_group_link" {
  description = "The self_link of the instance group containing the backend VMs."
  type        = string
}
variable "domain_name" {
  description = "The custom domain for the SSL certificate (e.g., openwebui.your-company.com)."
  type        = string
}
variable "iap_members" {
  description = "List of members to grant access via IAP (e.g., ['group:team@example.com']). See https://cloud.google.com/iap/docs/managing-access#managing_access_with_the_gcloud_command_line_tool for formats."
  type        = list(string)
}
variable "support_email" {
  description = "The support email for the OAuth consent screen."
  type        = string
}
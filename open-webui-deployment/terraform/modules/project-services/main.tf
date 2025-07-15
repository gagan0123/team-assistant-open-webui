resource "google_project_service" "default" {
  for_each = toset(var.gcp_services)
  project  = var.project_id
  service  = each.key

  disable_on_destroy = false
}

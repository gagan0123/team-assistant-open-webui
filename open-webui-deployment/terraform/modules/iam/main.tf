resource "google_service_account" "default" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.display_name
}

output "email" {
  value = google_service_account.default.email
}


output "trigger_id" {
  description = "ID of the Cloud Build trigger"
  value       = google_cloudbuild_trigger.main.trigger_id
}

output "trigger_name" {
  description = "Name of the Cloud Build trigger"
  value       = google_cloudbuild_trigger.main.name
}

 
output "trigger_id" {
  description = "The ID of the Cloud Build trigger"
  value       = google_cloudbuildv2_trigger.openwebui_trigger.id
}

output "repository_id" {
  description = "The ID of the Cloud Build repository"
  value       = google_cloudbuildv2_repository.openwebui_repo.id
}

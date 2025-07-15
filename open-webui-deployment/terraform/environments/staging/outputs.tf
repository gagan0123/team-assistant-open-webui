output "open_webui_url" {
  description = "URL for the Open WebUI service."
  value       = module.cloud_run.service_url
}


output "application_url" {
  description = "The URL to access the Open WebUI application."
  value       = "http://${module.open_webui_vm.instance_ip}:8080"
}

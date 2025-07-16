output "load_balancer_ip" {
  description = "Public IP of the IAP-secured Load Balancer. Point your domain's A-record here."
  value       = module.lb_iap.load_balancer_ip
}
output "application_url" {
  description = "The secure URL to access the Open WebUI application."
  value       = "https://{var.domain_name}"
}

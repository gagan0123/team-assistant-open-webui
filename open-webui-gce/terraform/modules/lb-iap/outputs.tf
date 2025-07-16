output "load_balancer_ip" {
  description = "The external IP address of the HTTPS Load Balancer."
  value       = google_compute_global_address.default.address
}


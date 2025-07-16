output "instance_group_link" {
  description = "The self_link of the instance group, to be used by the load balancer."
  value       = google_compute_instance_group.default.self_link
}

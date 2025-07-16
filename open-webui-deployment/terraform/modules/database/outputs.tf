output "instance_private_ip" {
  value = google_sql_database_instance.default.private_ip_address
}
output "db_name" {
  value = google_sql_database.default.name
}
output "db_user_name" {
  value = google_sql_user.default.name
}
output "private_service_connection" {
  value = google_service_networking_connection.private_vpc_connection
}
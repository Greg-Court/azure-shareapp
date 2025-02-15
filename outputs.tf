output "my_public_ip" {
  value = local.my_public_ip
}

output "function_app_hostname" {
  description = "The function app default hostname"
  value       = local.function_app_hostname
}
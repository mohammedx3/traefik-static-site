output "application_url" {
  description = "URL to access the application"
  value       = local.access_url
}

output "access_instructions" {
  description = "Instructions for accessing the application"
  value       = var.environment == "dev" ? "Access your application at ${local.access_url} (using NodePort)" : "Access your application at ${local.access_url} (using LoadBalancer with IP: ${data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip})"
}

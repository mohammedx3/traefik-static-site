variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "cluster_context" {
  description = "Kubernetes cluster context (e.g., minikube)"
  type        = string
}

variable "app_namespace" {
  description = "Namespace for the application"
  type        = string
}

variable "environment" {
  description = "Environment (dev or prod)"
  type        = string
}

variable "app_domain" {
  description = "Domain name for the application"
  type        = string
}

variable "app_chart_path" {
  description = "Path to the local Helm chart"
  type        = string
  default     = "./traefik-chart"
}

variable "app_release_name" {
  description = "Name for the Helm release"
  type        = string
  default     = "traefik-app"
}

variable "secret_text" {
  description = "Secret text for the application"
  type        = string
  default     = "This is a secret for dev environment"
  sensitive   = true
}

variable "acme_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
  default     = "user@example.com"
}

variable "acme_server" {
  description = "ACME server URL for Let's Encrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

locals {
  service_type  = var.environment == "dev" ? "NodePort" : "LoadBalancer"
  http_nodeport = var.environment == "dev" ? data.kubernetes_service.traefik.spec.0.port.1.node_port : null
  access_url    = var.environment == "dev" ? "https://${var.app_domain}:${local.http_nodeport}" : "https://${var.app_domain}"
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "false" # Set this to true if the CRDS are not already installed
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  values = [
    yamlencode({
      providers = {
        kubernetesCRD = {
          namespaces = [
            "default",
            "traefik"
          ]
        },
        kubernetesIngress = {
          namespaces = [
            "default",
            "traefik"
          ]
        }
      },
      service = {
        type = local.service_type
      }
    })
  ]
}

resource "helm_release" "app" {
  name      = var.app_release_name
  chart     = var.app_chart_path
  namespace = var.app_namespace

  depends_on = [
    helm_release.cert_manager,
    helm_release.traefik
  ]

  values = [
    yamlencode({
      environment = var.environment
      domain      = var.app_domain
      secretText  = var.secret_text
    })
  ]
}

# To get details about LoadBalancer ip or NodePort.
data "kubernetes_service" "traefik" {
  depends_on = [helm_release.traefik]
  metadata {
    name      = "traefik"
    namespace = "traefik"
  }
}

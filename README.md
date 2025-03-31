# Kubernetes Deployment with Traefik and Static Website

This repository contains a Kubernetes-based project to deploy a Traefik reverse proxy server and a static website served using NGINX. The deployment includes two environments, `dev` and `prod`, and uses Helm for configuration and deployment. The static website displays a custom message injected via environment variables and secrets, and is served over HTTPS using self-signed certificates (for `dev`) or Let's Encrypt (for `prod`).

---

## Features

1. **Traefik Reverse Proxy**:
   - Handles HTTPS traffic.
   - Is sat as the default ingress controller in this example.

2. **Static Website**:
   - Hosted on an NGINX pod.
   - Displays a dynamic message based on environment (`dev` or `prod`) and a secret.

3. **Environment-Specific Configuration**:
   - `dev`: Uses self-signed certificates.
   - `prod`: Uses Let's Encrypt certificates.

---

## Prerequisites

- **Kubernetes Cluster**:
  - Minikube (for local development).
  - GKE/EKS (for production).
- **Helm**: Version 3 or later.
- **Terraform**: Version 1.0.0 or later.
- **kubectl**

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/mohammedx3/traefik-static-site.git
cd traefik-static-site
```

### 2. Set Terraform variables in terraform.tfvars
Ideally set `env` and `app_domain`
```bash
kubeconfig_path = "/home/mo/.kube/config"
cluster_context = "minikube"
environment     = "prod"
app_namespace   = "default"
app_domain      = "app-prod.localhost.direct"
secret_text     = "This is a secret"
```

### 3. Run Terraform
```bash
terraform init
terraform plan -var environment=dev -var app_domain=yourdomain.com
terraform apply -var environment=dev -var app_domain=yourdomain.com
```

### 4. Acess the application
- For dev: Access the application via the domain + Traefik NodePort provided by Minikube. `https://<app_domain>:<nodeport>`
- For prod: Access the application via the domain configured in your values.yaml. (The app will only be accessible through Traefik Load balancer, you will need to configure a dns to point the domain to the LoadBalancer ip) `https://<app_domain>`

#### Important Note for Production:
The application requires the proper Host header in HTTP requests for routing to work correctly. When accessing the application:

Ensure your DNS configuration is properly set up to point your domain to the LoadBalancer IP
Access the application using the domain name, not the IP address directly
If testing with tools like curl or Postman, include the appropriate Host header:
```bash
curl -H "Host: your-domain.com" https://your-domain.com
```

## Health Checks
Health checks are automatically configured in the values.yaml for the NGINX deployment.

## Certificate Management
This deployment uses cert-manager to handle TLS certificate management, with different approaches for development and production environments.

### Certificate Configuration
#### Development Environment
For development, self-signed certificates are generated using cert-manager:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
spec:
  secretName: selfsigned-cert-tls
  duration: 8760h  # 1 year
  renewBefore: 720h  # 30 days
  dnsNames:
    - "example.dev.local"
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
```
#### Production Environment
For production, cert-manager is configured with Let's Encrypt for automatic certificate generation and validation:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
    - http01:
        ingress:
          class: traefik
```

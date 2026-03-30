output "namespace" {
  description = "Namespace used by OpenMetadata."
  value       = var.namespace
}

output "release_name" {
  description = "OpenMetadata Helm release name."
  value       = try(helm_release.openmetadata[0].name, null)
}

output "ingress_hostname" {
  description = "Load balancer hostname reported by the Kubernetes ingress."
  value       = try(kubernetes_ingress_v1.openmetadata[0].status[0].load_balancer[0].ingress[0].hostname, null)
}

output "openmetadata_irsa_role_arn" {
  description = "IAM role ARN used by the OpenMetadata service account."
  value       = try(module.openmetadata_irsa[0].arn, null)
}

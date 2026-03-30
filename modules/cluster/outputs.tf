output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = try(module.eks.cluster_name, null)
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server."
  value       = try(module.eks.cluster_endpoint, null)
}

output "cluster_ca_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = try(module.eks.cluster_certificate_authority_data, null)
}

output "cluster_security_group_id" {
  description = "Cluster security group ID."
  value       = try(module.eks.cluster_security_group_id, null)
}

output "node_security_group_id" {
  description = "Node security group ID."
  value       = try(module.eks.node_security_group_id, null)
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA."
  value       = try(module.eks.oidc_provider_arn, null)
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = local.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server."
  value       = local.cluster_endpoint
}

output "cluster_ca_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = local.cluster_ca_data
}

output "cluster_security_group_id" {
  description = "Cluster security group ID for the EKS cluster."
  value       = local.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Node security group ID for the EKS managed node group."
  value       = local.node_security_group_id
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN used for IRSA."
  value       = local.oidc_provider_arn
}

output "database_endpoint" {
  description = "Endpoint for the PostgreSQL database instance."
  value       = local.database_endpoint
}

output "opensearch_endpoint" {
  description = "Endpoint for the OpenSearch domain."
  value       = local.opensearch_endpoint
}

output "openmetadata_irsa_role_arn" {
  description = "IAM role ARN for the OpenMetadata service account."
  value       = try(module.app[0].openmetadata_irsa_role_arn, null)
}

output "openmetadata_alb_dns" {
  description = "DNS name of the ALB provisioned for OpenMetadata."
  value       = try(module.app[0].ingress_hostname, null)
}

output "openmetadata_fqdn" {
  description = "Route53 record FQDN pointing to the OpenMetadata ALB."
  value       = try(module.dns[0].fqdn, null)
}

output "access_entry_ids" {
  description = "IDs of EKS access resources created for the cluster."
  value       = try(module.access[0].access_entry_ids, [])
}

output "rds_endpoint" {
  description = "RDS endpoint value."
  value       = coalesce(try(aws_db_instance.this[0].endpoint, null), var.existing_rds_endpoint)
}

output "rds_host" {
  description = "Hostname used by the OpenMetadata application to connect to PostgreSQL."
  value = coalesce(
    try(aws_db_instance.this[0].address, null),
    try(split(":", var.existing_rds_endpoint)[0], null)
  )
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN for the RDS credentials."
  value       = coalesce(try(aws_secretsmanager_secret.rds[0].arn, null), var.existing_rds_secret_arn)
}

output "opensearch_endpoint" {
  description = "OpenSearch endpoint."
  value       = coalesce(try(aws_opensearch_domain.this[0].endpoint, null), var.existing_opensearch_endpoint)
}

output "opensearch_secret_arn" {
  description = "Secrets Manager ARN for the OpenSearch credentials."
  value       = coalesce(try(aws_secretsmanager_secret.opensearch[0].arn, null), var.existing_opensearch_secret_arn)
}

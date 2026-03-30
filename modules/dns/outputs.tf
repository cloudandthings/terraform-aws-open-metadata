output "fqdn" {
  description = "FQDN of the Route53 CNAME record created for OpenMetadata."
  value       = try(aws_route53_record.openmetadata_alb[0].fqdn, null)
}

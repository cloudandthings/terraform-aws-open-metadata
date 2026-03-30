output "aws_load_balancer_controller_enabled" {
  description = "Whether the AWS Load Balancer Controller release is enabled."
  value       = var.create && var.create_aws_load_balancer_controller
}

output "lb_controller_irsa_role_arn" {
  description = "IRSA role ARN used by the AWS Load Balancer Controller."
  value       = try(module.lb_controller_irsa[0].arn, null)
}

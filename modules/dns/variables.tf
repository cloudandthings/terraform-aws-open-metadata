variable "create" {
  description = "Whether to create DNS resources."
  type        = bool
  default     = true
}

variable "route53_zone_name" {
  description = "Private Route53 hosted zone name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used for the private hosted zone lookup."
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the Route53 CNAME record."
  type        = string
}

variable "ingress_hostname" {
  description = "ALB hostname from the Kubernetes ingress. The record is only created once this is known."
  type        = string
  default     = null
}

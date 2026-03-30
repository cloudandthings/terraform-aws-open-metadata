output "access_entry_ids" {
  description = "IDs of the created EKS access resources."
  value = concat(
    [for entry in aws_eks_access_entry.principal : entry.id],
    [for association in aws_eks_access_policy_association.cluster : association.id],
    [for association in aws_eks_access_policy_association.namespace : association.id]
  )
}

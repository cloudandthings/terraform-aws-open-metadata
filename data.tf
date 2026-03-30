data "aws_kms_key" "secrets" {
  count  = var.secrets_kms_key_id != null ? 1 : 0
  key_id = var.secrets_kms_key_id
}

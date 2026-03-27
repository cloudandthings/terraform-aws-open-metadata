# Unit tests using mock providers — no AWS credentials required.
# Run with: tofu test
#       or: terraform test

mock_provider "aws" {}
mock_provider "null" {}

variables {
  naming_prefix = "test"
}

run "plan_succeeds" {
  command = plan
}

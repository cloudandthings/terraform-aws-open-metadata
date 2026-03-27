terraform {
  # Note that tests are only supported in TF > 1.6 which is installed in CI
  # but for the module we can support an older TF version.
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5, < 7"
    }
    null = { # Delete me
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
}

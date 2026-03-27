# Testing

Tests use the native [`terraform test`](https://developer.hashicorp.com/terraform/cli/commands/test) /
[`tofu test`](https://opentofu.org/docs/cli/commands/test/) framework introduced in Terraform/OpenTofu 1.6.
No additional tooling or Python environment is required.

## Test structure

```text
tests/
  basic.tftest.hcl          # Unit tests — use mock providers, no AWS credentials needed
  integration/
    basic.tftest.hcl        # Integration tests — create real AWS resources
```

## Unit tests

Unit tests use mock providers so they run without any AWS credentials. They validate that the
module plan succeeds and that outputs are correct.

```sh
tofu test
# or: terraform test
```

## Integration tests

Integration tests apply real infrastructure against AWS and then destroy it automatically.
You will need valid AWS credentials with sufficient permissions.

```sh
aws sso login --profile <your_profile>
AWS_PROFILE=<your_profile> tofu test -test-directory=tests/integration
# or: terraform test -test-directory=tests/integration
```

## What to test

- At minimum, add a unit test for each significant input variable combination.
- Add integration tests for any behaviour that cannot be verified with mock providers alone
  (e.g. IAM policy evaluation, resource dependencies, data source lookups).
- Cover bug fixes with a test to prevent regression.

## Maintain tests

Periodically review the template framework in the
[terraform-aws-template](https://github.com/cloudandthings/terraform-aws-template) and ensure
this project is kept up to date.

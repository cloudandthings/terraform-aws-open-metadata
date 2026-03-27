# Integration tests — require real AWS credentials.
# Run with: tofu test -test-directory=tests/integration
#       or: terraform test -test-directory=tests/integration
#
# These tests create real AWS resources and will incur costs.
# Resources are destroyed automatically after each run block completes.

run "apply_basic_example" {
  command = apply

  module {
    source = "../../examples/basic"
  }

  # Assert on outputs here. Example:
  # assert {
  #   condition     = output.module_example != null
  #   error_message = "Expected module_example output to be set"
  # }
}

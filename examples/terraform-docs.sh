#!/usr/bin/env bash
set -euo pipefail

terraform-docs . -c .tfdocs-config.yml

for dir in examples/*/; do
  [[ -d "$dir" ]] || continue
  terraform-docs "$dir" -c examples/.tfdocs-examples-config.yml
done

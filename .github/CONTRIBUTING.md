# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Terraform and OpenTofu Compatibility

This template is designed to work with both **[Terraform](https://www.terraform.io/)** (≥ 1.5.7)
and **[OpenTofu](https://opentofu.org/)** (≥ 1.6.0, the open-source MPL-2.0 fork).

### Version constraints

The module's `required_version` is set to `>= 1.5.7, < 2.0.0`:

- **Minimum 1.5.7**: the last MPL-2.0-licensed Terraform release. All OpenTofu releases (which
  start at 1.6.0) satisfy this constraint, as do all Terraform 1.6+ releases.
- **Upper bound `< 2.0.0`**: guards against unknown future breaking changes.

> **Important**: never use `~>` with a patch version (e.g. `~> 1.5.7`) in a module's
> `required_version`. That resolves to `>= 1.5.7, < 1.6.0`, which excludes OpenTofu entirely
> since OpenTofu has no 1.5.x release.

### Development tooling

The primary development tool is **OpenTofu** (`tofu` binary), managed via `mise`. Terraform is
also installed for CI matrix validation. Both CLIs accept the same `*.tftest.hcl` test files and
HCL syntax.

### Feature compatibility

To maintain compatibility with both tools, **avoid language features that are exclusive to one
binary**. The safe shared baseline is roughly Terraform/OpenTofu 1.6–1.8, before significant
feature divergence. Specifically:

- Do not use: Terraform 1.10+ exclusive features (ephemeral resources, write-only attributes)
- Do not use: OpenTofu-exclusive features not yet in Terraform
- Use: features available in both Terraform 1.6+ and OpenTofu 1.6+

## Development environment

We suggest using [VSCode](https://code.visualstudio.com/)

### With GitHub Codespaces

Simply open this project in GitHub Codespaces to continue.

### Locally, with Dev Containers

You can use [Visual Studio Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) to build a local, isolated development environment.

You will need to have [Docker](https://www.docker.com/) installed.

Open this project in a VSCode Remote Container to get started.

### Locally, without Dev Containers

We recommend using [mise-en-place](https://mise.jdx.dev/).

Once installed and activated, `mise` will in turn install and configure the correct version of all required dev tools and set environment variables.

### Locally, without mise

As a last resort you can try to manually install/configure what is specified by the [mise.toml](/mise.toml) file, but this is not recommended.

### Reducing clutter

To improve focus while developing, you may want to configure VSCode to hide all files beginning with `.` from the Explorer view.
These files are typically related to low-level environment configuration.
To do so, you could add `"**/.*"` to the `files.exclude` setting.

## Pull Request Process

1. Update the code, examples and/or documentation where appropriate.
1. Ideally, follow [conventional commits](https://www.conventionalcommits.org/) for your commit messages.
1. Locally run pre-commit hooks `pre-commit run -a`
1. Locally run unit tests via `tofu test`
1. Create pull request
1. Once all checks pass, notify a reviewer.

Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release. The terraform-aws-vpc maintainers take care of updating the CHANGELOG as they merge.

## Testing

### Unit tests (no AWS credentials required)

```sh
tofu test
# or: terraform test
```

### Integration tests (real AWS resources)

```sh
aws sso login --profile <your_profile>
AWS_PROFILE=<your_profile> tofu test -test-directory=tests/integration
```

See [tests/README.md](/tests/README.md) for full details.

## Checklists for contributions

- [ ] Add [semantics prefix](#semantic-pull-requests) to your PR or Commits (at least one of your commit groups)
- [ ] CI tests are passing
- [ ] README.md has been updated after any changes to variables and outputs. See [doc-generation](https://github.com/cloudandthings/terraform-aws-clickops-notifer/#doc-generation)
- [ ] Run pre-commit hooks `pre-commit run -a`

## Semantic Pull Requests

To generate changelog, Pull Requests or Commits must have semantic and must follow conventional specs below:

- `feat:` for new features
- `fix:` for bug fixes
- `improvement:` for enhancements
- `docs:` for documentation and examples
- `refactor:` for code refactoring
- `test:` for tests
- `ci:` for CI purpose
- `chore:` for chores stuff

The `chore` prefix skipped during changelog generation. It can be used for `chore: update changelog` commit message by example.

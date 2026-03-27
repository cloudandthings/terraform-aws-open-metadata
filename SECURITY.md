# Security Policy

## Supported Versions

We support the latest version of this Terraform module. Security updates will be applied to the most recent release.

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest| :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Email security concerns to the maintainers or use GitHub's private security reporting feature
3. Include as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: You should receive an acknowledgment within 48 hours
- **Assessment**: We will assess the vulnerability and determine its impact
- **Updates**: We will keep you informed of the progress toward a fix
- **Disclosure**: We will coordinate with you on the disclosure timeline
- **Credit**: With your permission, we will credit you in the security advisory

### Security Best Practices for Users

When using this module, please:

- Keep your Terraform version up to date
- Regularly update to the latest module version
- Review the CHANGELOG for security-related updates
- Use AWS IAM best practices with least-privilege access
- Enable AWS CloudTrail for audit logging
- Regularly run security scanning tools like Trivy (included in CI)
- Never commit sensitive data or credentials to version control

## Security Tools

This repository includes:

- **Trivy**: Automated security scanning in CI/CD pipeline
- **Pre-commit hooks**: Detect secrets and private keys before commit
- **Dependabot**: Automated dependency updates (if configured)

## Responsible Disclosure

We follow responsible disclosure practices and ask that you:

- Give us reasonable time to fix the vulnerability before public disclosure
- Avoid exploiting the vulnerability beyond what is necessary for validation
- Respect user privacy and data during security research

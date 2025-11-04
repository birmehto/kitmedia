# Security Policy

## Supported Versions

We actively support the following versions of KitMedia with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in KitMedia, please report it responsibly.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities to us privately:

- **Email**: security@kitmedia.app
- **Subject**: [SECURITY] Brief description of the vulnerability

### What to Include

When reporting a vulnerability, please include:

1. **Description**: A clear description of the vulnerability
2. **Steps to Reproduce**: Detailed steps to reproduce the issue
3. **Impact**: Potential impact and severity of the vulnerability
4. **Affected Versions**: Which versions of the app are affected
5. **Suggested Fix**: If you have ideas for fixing the issue

### Response Timeline

- **Acknowledgment**: We will acknowledge receipt within 48 hours
- **Initial Assessment**: We will provide an initial assessment within 5 business days
- **Status Updates**: We will provide regular updates on our progress
- **Resolution**: We aim to resolve critical vulnerabilities within 30 days

### Disclosure Policy

- We will work with you to understand and resolve the issue
- We will not take legal action against researchers who:
  - Report vulnerabilities responsibly
  - Do not access or modify user data
  - Do not disrupt our services
- We will publicly acknowledge your contribution (if desired)

### Security Best Practices

KitMedia follows these security practices:

#### Data Protection
- Local storage encryption for sensitive data
- No unnecessary data collection
- Secure handling of user preferences
- Regular security audits of dependencies

#### App Security
- Code obfuscation in release builds
- Secure communication protocols
- Input validation and sanitization
- Protection against common mobile vulnerabilities

#### Privacy
- Minimal permission requests
- Transparent privacy policy
- No tracking without consent
- Local-first data processing

### Common Security Concerns

#### File Access
- KitMedia only accesses media files with user permission
- No unauthorized file system access
- Secure file handling and validation

#### Network Security
- HTTPS for all network communications
- Certificate pinning for critical connections
- No sensitive data transmission without encryption

#### Third-Party Dependencies
- Regular dependency updates
- Security scanning of dependencies
- Minimal third-party integrations

### Reporting Non-Security Issues

For non-security related bugs and issues, please use our [GitHub Issues](https://github.com/kitmedia/kitmedia/issues) page.

### Contact

For any questions about this security policy, please contact:
- Email: security@kitmedia.app
- GitHub: [@kitmedia-team](https://github.com/kitmedia-team)

Thank you for helping keep KitMedia and our users safe!
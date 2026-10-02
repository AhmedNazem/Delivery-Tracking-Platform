# Security Policy

## Supported versions

This project is under development and has no stable release yet. Security fixes
target the current `main` branch. Older commits and development branches do not
receive separate security maintenance. A release support policy will be added
when stable versions are published.

## Reporting a vulnerability

Please report security vulnerabilities privately through GitHub:

1. Open the repository's [Security Advisories page](https://github.com/AhmedNazem/Delivery-Tracking-Platform/security/advisories).
2. Select **Report a vulnerability** and submit a private report.

The button is available only when the maintainer enables private vulnerability
reporting. If it is unavailable, open a public issue asking only for a private
security reporting channel. Do not include vulnerability details in that issue.

Do not disclose exploit instructions, credentials, personal data, or vulnerability
details in public issues, pull requests, discussions, or logs.

Include the following in your private report:

- Affected commit or version and component or endpoint.
- A description of the issue and its potential impact.
- Minimal reproduction steps using local demo data and test accounts.
- Expected and observed behavior.
- Sanitized evidence and a suggested fix, if available.

Never send real passwords, API keys, session cookies, or customer data. Reproduce
the issue only in environments you own or have explicit permission to test.

## Handling reports

The maintainer will review the report, request clarification if needed, and
coordinate a fix and disclosure through the private report. Response and fix times
depend on availability and severity; this learning project has no guaranteed SLA
or paid bug bounty program.

Please coordinate public disclosure with the maintainer after a fix is available.
If a report reveals an exposed credential, revoke or rotate it at the issuing
service immediately; deleting it from the repository is not sufficient.

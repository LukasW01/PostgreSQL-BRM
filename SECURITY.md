# Security Policy

This policy is based on the [CISA vulnerability disclosure policy template](https://www.cisa.gov/vulnerability-disclosure-policy-template) and the Policy that [Keycloak](https://github.com/keycloak/keycloak) uses.

## Introduction

This policy supports our open approach and is intended to give security researchers clear guidelines for submitting and coordinating discovered vulnerabilities with us. In complying with this policy, you authorize us to work with you to understand and resolve the issue quickly. For more details about our processes, please read the security charter.

## Guidelines

- Access and visibility to research and all CVE related data will follow the principle of least privilege by all vendors involved.
- Establish and set a reasonable amount of time to resolve the issue before a vulnerability is disclosed publicly; agree and coordinate on public disclosure dates when possible.
- Public disclosure should be prioritized on the need to keep company, government, and individual data confidential and the general public safe.
- All vendors will honor disclosure/embargo requests in good faith as long as all guidelines are met.
- Vendors involved in coordinated disclosure will remain actively involved.

Violation of these guidelines may result in the individual, or vendor, being added to a denied coordination list.

## Reporting a suspected vulnerability

Suspected vulnerabilities should be disclosed responsibly and not made public until after analysis and a fix are available. We will acknowledge your report within 7 business days and work with you to confirm the vulnerability's existence and impact. Our goal is to maintain open dialogue during the assessment and remediation process.

## Supported Versions

Depending on the severity of a vulnerability the issue may be fixed in the current major.minor release of this Project, or for lower severity vulnerabilities or hardening in the following major.minor release.

## Coordinated Vulnerability Disclosure

To report a security vulnerability in the codebase, send an email to [lukas@wigger.one](mailto:lukas@wigger.one). Please test against the latest version, include the affected version in your report, provide detailed instructions on how to reproduce the issue with a minimal and reproducible example, and include your contact information for acknowledgements. If you are reporting known CVEs related to third-party libraries used in this Project, please create a new GitHub issue.

If you would like to collaborate on a fix for the security vulnerability, please include your GitHub/Gitlab username in the email, and we will provide you access to a temporary private fork where we can work together.

If you discover any publicly disclosed security vulnerabilities, please notify us immediately through the same email address.
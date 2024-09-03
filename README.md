# Tumble-Ops

## Overview

Welcome to the **Tumble-Ops**. This repo is designed to streamline and automate the deployment and management of a Kubernetes-based microservices architecture for Tumble. The project is set up for both development and production environments using GitHub Actions, Helm, and Kubernetes.

### Features

- **Automated Setup**: Scripts and workflows to set up your development environment quickly.
- **Continuous Deployment**: GitHub Actions workflows automatically deploy changes when relevant files are modified.
- **Environment Management**: Separate environments for development and production, with tailored configurations.
- **Secrets Management**: Secure handling of sensitive data using Kubernetes secrets and GitHub Secrets.

## Project Structure

```plaintext
.
├── .github/workflows/
│   └── deploy-prod.yml      # CI/CD pipeline for the production environment
├── settings/
│   ├── dev/                 # Development environment configurations
│   │   ├── scripts/
│   │   │   └── setup.sh     # Script to set up local dev environment with Minikube
│   │   ├── middleware/      # Helm charts for middleware services
│   │   └── backend/         # Helm chart for the backend service
│   └── prod/                # Production environment configurations
│       ├── middleware/      # Helm charts for middleware services
│       └── backend/         # Helm charts for the backend service
└── README.md
```

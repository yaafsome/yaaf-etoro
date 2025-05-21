# Yaaf-eToro

This repository contains a chart and Jenkinsfile to manage and deploy a web application on a cluster using Helm and a parameter-based Jenkins pipeline.

## Helm Chart (simple-web)

The Helm chart is designed to deploy a simple web application with KEDA autoscaling capabilities.

## Jenkins Pipeline (Jenkinsfile)

The Jenkins pipeline automates the deployment and management of the application.

### Features

- **Parameterized Pipeline**: Supports customization via parameters
  - ACTION: Choose between 'deploy' and 'destroy'
  - NAMESPACE: Target Kubernetes namespace (can be add on to)
  - RELEASE_NAME: Name of the Helm release (can change release name)

- **Authentication**: Connects to Azure Kubernetes Service (AKS)
  - Uses Azure CLI with managed identity authentication
  - Configures kubectl automatically for the pipeline

- **Deployment Validation**: Performs a dry-run before actual deployment
  - Validates Helm chart syntax and configuration
  - Prevents deployment of faulty configurations

- **Deployment Verification**: Ensures successful deployment
  - Checks that pods are in the ready state
  - Waits for readiness with configurable timeout

- **Cleanup**: Supports application removal
  - Uninstalls Helm releases
  - Handles error cases gracefully

## Notes

- The application expects Nginx Ingress Controller and KEDA to be deployed in the cluster
- The pipeline expects the Azure CLI to be installed and configured
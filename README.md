# Scanly API

A robust .NET 10 API built for analyzing documents using Azure Document Intelligence and storing results securely in Azure Blob Storage. This repository includes the application code, Infrastructure as Code (IaC) via Bicep, and CI/CD workflows using GitHub Actions.

## Key Features

This project was developed to fulfill the requirements of a complete cloud solution:
- **RESTful API**: A .NET 10 Web API featuring 4+ well-documented endpoints, including a dedicated `/health` endpoint. Documentation is accessible via Swagger and Scalar UI.
- **Azure Integration**: Communicates directly with Azure Document Intelligence to process documents and returns structured data. Results are durably saved to Azure Blob Storage.
- **Monitoring & Error Handling**: Application Insights is integrated for robust monitoring and custom alerts. The API features clear error handling and appropriate HTTP status codes.
- **Scalable Infrastructure**: Container Apps are configured for high availability (minimum of 2 replicas). Bicep templates are fully parameterized to support distinct environments (`dev`, `prod`, `test`).
- **Secure by Default**: Zero hardcoded secrets. Relies on System-Assigned Managed Identity, Azure Key Vault, and GitHub Actions OIDC for authentication and authorization.
- **Automated CI/CD**: Automated GitHub Actions pipelines for deploying infrastructure and the application container.

---

## Architecture

The solution uses a modern Azure serverless/PaaS architecture:
- **Azure Container Apps**: Hosts the .NET 10 Web API, allowing it to scale automatically (even to zero).
- **Azure Container Registry (ACR)**: Stores the multi-stage Docker images built by our CI/CD pipeline.
- **Azure Storage Account**: Used to save the extracted document results.
- **Azure Key Vault**: Securely manages secrets and endpoints for Azure services (like Document Intelligence).
- **Managed Identity**: Used for secure, secretless communication between Container Apps, ACR, Storage, and Key Vault.

---

## Running Locally with Docker

You can easily run this application locally using Docker. The API is containerized using a multi-stage Dockerfile.

### Prerequisites
- Docker installed.
- Valid credentials/keys for Azure Document Intelligence (if testing those specific endpoints).

### Steps

1. **Build the Docker Image**
   Run the following command from the repository root:
   ```bash
   docker build -t scanly-api ./api
   ```

2. **Run the Container**
   Start the container, mapping port 8080. Be sure to inject any necessary environment variables your application expects (e.g., Azure service keys):
   ```bash
   docker run -d -p 8080:8080 -e AZURE_DI_ENDPOINT="<your-endpoint>" -e AZURE_DI_KEY="<your-key>" --name scanly-api scanly-api
   ```

3. **Access the API**
   - The API will be available at: http://localhost:8080
   - **Health Check**: http://localhost:8080/health
   - **Swagger / Scalar UI**: Navigate to the provided API documentation endpoint to test the available routes.

---

## Infrastructure as Code (Bicep)

The Azure infrastructure is defined declaratively using Bicep.

### How it Works
- The main entry point is `bicep/main.bicep`.
- It dynamically generates resource names to avoid collisions and orchestrates the deployment of multiple modules (`storage.bicep`, `containerregistry.bicep`, `containerapps.bicep`, `keyvault.bicep`).
- **Role Assignments**: Bicep automatically configures Role-Based Access Control (RBAC). It assigns the Container App a System-Assigned Managed Identity and grants it:
  - AcrPull on the Container Registry.
  - Storage Blob Data Contributor on the Storage Account.
- **Environments**: Parameter files are located in `bicep/parameters/` (e.g., `dev.bicepparam`, `prod.bicepparam`). This allows seamless scaling and configuration management across different environments.

---

## CI/CD Workflows

We use **GitHub Actions** for continuous integration and continuous deployment. The workflows are defined in `.github/workflows/`.

### 1. Build and Deploy API (`deploy.yaml`)
Triggered automatically on pushes to the `main` branch when changes occur in the `api/` or `api.tests/` directories.
- **Build**: Compiles the .NET 10 solution.
- **Test**: Runs the unit tests (`api.tests`).
- **Push**: Authenticates via OIDC to Azure, builds the Docker image, and pushes it to Azure Container Registry (ACR) tagged with the commit SHA and `latest`.
- **Deploy**: Updates the Azure Container App to use the newly built image (deploying the required minimum replicas for high availability).

### 2. Infrastructure Deployment (`bicep.yaml`)
Triggered manually or via changes to Bicep files.
- Validates and deploys the Bicep templates to the specified Azure Resource Group.
- Automatically handles the setup of dependent resources before the application code is pushed.

---

## Security
- **No Hardcoded Secrets**: All access is handled via Managed Identities in Azure and GitHub Actions OIDC. Secrets (like the Document Intelligence key) are stored securely in GitHub Secrets during pipeline runs and deployed into Azure Key Vault.

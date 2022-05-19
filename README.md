# Deploying Azure Container Registry with GitHub Actions
This repository provides demonstrates several aspects of using GitHub Actions with Azure Container Registry (ACR). It also demonstrates:

- :arrow_left: Step output variables
- :mask: Masking outputs 
- :key: Dynamically creating secrets using GH CLI
- :handshake: Using GitHub with Federated Identity Credentials in Azure Active Directory (OIDC)
- :muscle: Deploying Bicep infrastructure and setting permissions
- :lock: Building and pushing an image to ACR using an OIDC credential

## Setup & Configuration
An application meeds to be created and registered in Azure Active Directory.

1. Open Azure Active Directory's **App Registrations** blade.
2. Press **New registration**.
   - Specify any name. This name will also be the "user" that you will assign roles.
   - Select **Accounts in this organizational directory only (Single tenant)**
   - Redirect URI can be left blank
3. In the Application blade, choose **Certificates & Secrets**
4. Select **Federated Credentials** and choose **Add Credential**
   - For **Federated credential scenario**, choose **GitHub Actions deploying Azure resources** 
   - Enter the **Organization** and **Repository** associated with the credential.
   - Specify an **Entity Type** based on the job deploying the resource. If it's a 
     tag-triggered Action, select Tag. If it's branch triggered, select Branch. 
     For pull requests, select Pull Request. If the credential is being used by a
     job deploying to an Environment, you should use Environment.
   - Provide a name for this scenario and optionally provide a description.
   - Click **Add**
5. In the Overview blade, capture the **Application (Client) ID** and the **Directory (Tenant) ID**
6. From the appropriate Azure Resource Group (or the subscription), capture the **Subscription ID**.
7. In Azure, configure resources with appropriate RBAC permissions using the name of the application as the identity. For this sample, assign `Contributor` rights at the subscription level.
8. In GitHub, open your personal Settings, then open **Developer Settings** and select [**Personal access tokens**(https://github.com/settings/tokens). Create a token with the `repo` and `read:org`
9. In the GitHub repository, configure the following secrets with the values collected in steps 5,6 and 8:

   | Secret                | Value                                                |
   | --------------------- |    ------------------------------------------------------ |
   | AZURE_CLIENT_ID       | Application (Client)    Id                                |
   | AZURE_TENANT_ID       | Azure AD directory (tenant)    identifier.                |
   | AZURE_SUBSCRIPTION_ID | The Azure subscription containing the resources.       |
   | REPO_TOKEN            | The PAT from Step 8.
   | ACR_LOGIN_SERVER      | If the server already exists, enter the name. Otherwise the [deploy-acr.yaml](.github/workflows/deploy-acr.yml) will create this automatically |

## Dev Containers
This repository supports [GitHub Codespaces](https://github.com/features/codespaces) and VS Code development containers. This creates a standalone environment for viewing and editing the files

## Application
The application used for this sample is a basic Python 3 Flask web application that displays a 'Hello world' message. The Dockerfile will create an image that serves the web pages on Port 80, making this image compatible with Azure Container Instance, Azure Container Apps, and Azure App Service containers for validation and testing.
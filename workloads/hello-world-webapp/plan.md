# Plan: Hello World Web App on Azure App Service

## Overview
Deploy a simple "Hello World" web application to Azure App Service in the Sweden Central region.

## Requirements
- **App:** Simple HTML/Node.js "Hello World".
- **Infrastructure:** Azure App Service (Web App) + App Service Plan.
- **Region:** Sweden Central (`swedencentral`).
- **IaC:** Bicep.

## Architecture
- **Resource Group:** `rg-hello-world-swc`
- **App Service Plan:** `plan-hello-world-swc`
  - SKU: F1 (Free) or B1 (Basic) for development.
  - OS: Linux.
- **App Service:** `app-hello-world-swc-[unique-suffix]`
  - Runtime: Node.js 18 LTS (or newer).

## Implementation Steps (for Developer)
1.  **Directory Structure:**
    - `src/`: Application source code (`index.js`, `package.json`).
    - `iac/`: Infrastructure code (`main.bicep`).
2.  **Application Code:**
    - Create a simple Express.js server returning "Hello World".
3.  **Infrastructure Code (Bicep):**
    - Define `Microsoft.Web/serverfarms` (App Service Plan).
    - Define `Microsoft.Web/sites` (App Service).
    - ensure location is parameterizable but defaults to `swedencentral`.

## Verification
- Deploy Bicep template.
- Deploy Code.
- Curl the endpoint and expect "Hello World".

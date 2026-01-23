# Azure Deployment Prompt Files

This folder contains reusable prompt files for common Azure infrastructure deployment scenarios. These prompts trigger the automated agent workflow to plan, implement, deploy, document, and review Azure workloads.

## What are Prompt Files?

Prompt files (`.prompt.md`) are VS Code-native files that define reusable prompts for development tasks. They follow the [VS Code prompt file specification](https://code.visualstudio.com/docs/copilot/customization/prompt-files) and automatically invoke the Planner agent to orchestrate the complete deployment workflow.

## How to Use

### Option 1: Quick Access (Recommended)
1. Open VS Code with GitHub Copilot
2. Open the Chat view
3. Type `/` followed by the prompt name:
   - `/deployAzureInfrastructure` - General-purpose Azure deployment
   - `/static-web-app-functions` - Static Web App with Functions backend
   - `/container-apps-postgresql` - Container Apps with PostgreSQL
   - `/aks-basic-cluster` - Basic AKS cluster deployment
   - `/azure-openai-deployment` - Azure OpenAI service setup

4. VS Code will prompt you for required inputs (region, resources, etc.)
5. The Planner agent will automatically execute the full workflow

### Option 2: Run from File
1. Open any `.prompt.md` file in this folder
2. Click the **▶ Play button** in the editor toolbar
3. Choose to run in current chat or open a new session

### Option 3: Command Palette
1. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
2. Run `Chat: Run Prompt`
3. Select a prompt from the list

## Available Prompts

### General Purpose

#### `deployAzureInfrastructure`
**Description**: General-purpose prompt for any Azure infrastructure deployment  
**Use When**: You have a custom requirement not covered by specific prompts  
**Inputs**: 
- Resources needed
- Azure region
- Environment (prod/staging/test/dev)
- Requirements and constraints
- Preferences (optional)

---

### Specific Scenarios

#### `static-web-app-functions`
**Description**: Deploy Azure Static Web App with Functions backend and blob storage  
**Use When**: Building serverless web applications with React/Vue/Angular frontend  
**Includes**:
- Static Web App with Azure AD authentication
- Azure Functions (TypeScript/Node.js) backend
- Blob Storage for file uploads
- Application Insights monitoring

#### `container-apps-postgresql`
**Description**: Deploy containerized API with PostgreSQL database  
**Use When**: Building REST APIs or microservices with container deployment  
**Includes**:
- Azure Container Apps Environment
- PostgreSQL Flexible Server
- Private networking
- Auto-scaling configuration
- Sample Node.js API code

#### `aks-basic-cluster`
**Description**: Deploy basic AKS cluster with NGINX ingress  
**Use When**: Need Kubernetes orchestration for containerized workloads  
**Includes**:
- AKS cluster with CNI networking
- NGINX ingress controller
- Sample application deployment
- kubectl configuration
- Container Insights

#### `azure-openai-deployment`
**Description**: Deploy Azure OpenAI with GPT models and private networking  
**Use When**: Building AI-powered applications requiring OpenAI models  
**Includes**:
- Azure OpenAI service
- Model deployments (GPT-4o, embeddings)
- Private endpoints and VNet
- Key Vault integration
- Sample API code

## What Happens When You Run a Prompt?

The prompts trigger this automated workflow:

1. **Planning** (Planner Agent)
   - Analyzes requirements
   - Checks Azure policies for conflicts using Resource Graph MCP Server
   - Researches best practices from Microsoft Learn
   - Creates comprehensive architectural plan

2. **Implementation** (Developer Agent)
   - Generates Bicep/IaC templates (subscription-level deployment)
   - Creates application code (if needed)
   - Follows Azure best practices

3. **Deployment** (Developer Agent)
   - Executes Azure CLI commands
   - Deploys infrastructure to Azure
   - Validates deployment

4. **Documentation** (Documenter Agent)
   - Creates/updates README.md
   - Documents architecture and usage
   - Includes cost estimates

5. **Review** (PRManager Agent)
   - Creates Pull Request
   - Includes all changes for review

## Creating Your Own Prompts

To create a custom prompt file:

1. Create a new file with `.prompt.md` extension in this folder
2. Add YAML frontmatter:
```yaml
---
name: myCustomPrompt
description: Brief description (max 15 words)
agent: Planner
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'azure-resource-graph/*', 'microsoftdocs/mcp/*', 'agent', 'todo']
---
```
3. Write your prompt content using:
   - `${input:variableName:placeholder}` for user inputs
   - Clear instructions and requirements
   - Expected outcomes

4. Test with the editor play button

## Tips

- **Be Specific**: The more details you provide, the better the result
- **Include Constraints**: Mention cost limits, compliance requirements, or security needs upfront
- **Review the Plan**: The Planner creates a detailed plan before implementation
- **Monitor Agent Chain**: The workflow automatically chains through all agents
- **Check Pull Requests**: All changes are captured in PRs for review

## Troubleshooting

**Prompt not appearing in `/` menu**:
- Ensure the file has `.prompt.md` extension
- Check YAML frontmatter is valid
- Restart VS Code

**Agent not triggered**:
- Verify `agent: Planner` is set in frontmatter
- Ensure tools are correctly specified

**Workflow stops mid-chain**:
- The Planner agent monitors the chain and will autonomously continue if an agent fails to invoke the next one

## More Information

- [VS Code Prompt Files Documentation](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [Agent Workflow Documentation](../.github/agents/README.md)
- [Main Project README](../../README.md)

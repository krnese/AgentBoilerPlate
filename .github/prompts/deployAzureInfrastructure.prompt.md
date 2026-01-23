---
name: deployAzureInfrastructure
description: Deploy Azure infrastructure with automated planning, implementation, and documentation workflow
argument-hint: Describe infrastructure requirements (resources, region, environment, constraints)
agent: Planner
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'azure-resource-graph/*', 'microsoftdocs/mcp/*', 'agent', 'todo']
---

# Azure Infrastructure Deployment Request

I need to deploy the following Azure infrastructure:

**Resources**: ${input:resources:Describe Azure resources (e.g., 2 VMs, Load Balancer, PostgreSQL database)}

**Region**: ${input:region:Azure region (e.g., eastus, westeurope, swedencentral)}

**Environment**: ${input:environment:Environment type (production, staging, test, development)}

**Requirements**:
${input:requirements:List functional and non-functional requirements (security, compliance, availability, cost constraints)}

**Preferences**:
${input:preferences:Specify SKU preferences, naming conventions, or architectural preferences (optional)}

**Expected Outcome**:
- Complete infrastructure deployed and validated
- Comprehensive documentation
- Sample code/scripts where applicable
- Cost estimate
- Best practices implemented

**Additional Context**:
${input:additionalContext:Any specific constraints or special requirements (optional)}

---

This prompt will trigger the complete Azure deployment workflow:
1. **Planning**: Architecture design, policy checks, best practices research
2. **Implementation**: Bicep/IaC code generation with subscription-level deployment
3. **Deployment**: Automated Azure deployment with validation
4. **Documentation**: README with deployment details and usage instructions
5. **Review**: Pull Request creation for version control

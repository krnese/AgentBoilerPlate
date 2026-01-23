# AgentBoilerPlate

**Accelerate your Azure journey with Multi-Agent AI.**

AgentBoilerPlate is a ready-to-use framework for building, reviewing, and deploying Azure workloads using AI agents. By leveraging the power of Natural Language Processing (NLP) and GitHub Copilot, it allows both citizen developers and professional engineers to go from "Idea" to "Deployed Architecture" in record time.

## 🚀 Time-to-Value

Stop writing boilerplate infrastructure code. Start delivering value.

*   **From Days to Minutes:** Automate the creation of Bicep templates, application scaffolding, and CI/CD configurations.
*   **Standardized Quality:** Every workload passes through automated planning and review agents, ensuring architectural best practices and security compliance.
*   **Seamless Deployment:** Integrated workflows handle everything from git branching to live Azure deployment validation.

## 👥 Who is this for?

### For Citizen Developers (Low-Code/No-Code)
*   **Describe, don't code:** Simply tell the agents what you need (e.g., *"I need a web app in Sweden Central"*), and watch the system generate the complex code for you.
*   **Learn comfortably:** Inspect the generated artifacts to learn how professional Azure solutions are structured.
*   **Safety net:** Automated reviewers catch mistakes before they impact production.

### For Professional Developers
*   **Eliminate toil:** Offload repetitive tasks like setting up Resource Groups, dependencies, and basic Bicep modules.
*   **Focus on Logic:** Spend your energy on complex business logic while agents handle the plumbing.
*   **Review Assistant:** Use the Reviewer agent to double-check your work or the work of your team for common pitfalls.

## 🤖 The Agent Team

This repository comes pre-configured with a team of specialized agents that work sequentially:

1.  **Planner:** Architects the solution, breaks it down into actionable steps, and creates the implementation plan.
    *   *Tools:* `azure-mcp/search` (Azure Resource Graph), Web Search.
2.  **Developer:** Implements the application code and Infrastructure as Code (Bicep), deploys to Azure, and validates the live deployment.
    *   *Tools:* `microsoftdocs/mcp/*` (Access to MS Learn), `bicep-experim/*` (Bicep Best Practices), `azure-mcp/*` (Deployment).
3.  **Documenter:** Generates comprehensive documentation (`README.md`) for the new workload, ensuring accurate terminology.
    *   *Tools:* `microsoftdocs/mcp/*` (Terminology Check).
4.  **PRManager:** Automates the git workflow, creating branches, pushing code, and opening Pull Requests.
    *   *Tools:* `microsoftdocs/mcp/*` (Git Best Practices).
5.  **Reviewer:** Audits the code for security and architecture against MS Learn benchmarks, posts comments directly to the PR, and approves changes.
    *   *Tools:* `microsoftdocs/mcp/*` (Security Benchmarks), `gh` (GitHub CLI).

## 🛠️ Getting Started

### Prerequisites
*   **Visual Studio Code**
*   **GitHub Copilot** (with Chat extension)
*   **Azure CLI** (`az login`)
*   **GitHub CLI** (`gh auth login`) - *Required for PR management*
*   **Git**

### Installation

1.  **Fork & Clone**
    ```bash
    git clone https://github.com/krnese/AgentBoilerPlate.git
    cd AgentBoilerPlate
    ```

2.  **Sign in to Azure**
    Open the integrated terminal in VS Code and log in:
    ```bash
    az login
    ```

3.  **Start Developing**
    Open the GitHub Copilot Chat in VS Code and invoke an agent or simply describe your intent.

    > **Example Prompt:**
    > *"@Planner Plan a new python function app in West Europe that processes blob storage events."*

## 📦 Project Structure

*   `.github/agents/`: Definitions for the AI agents (prompts, tools, and personas).
*   `workloads/`: The workspace where your new projects will be generated.
*   `.github/`: CI/CD workflows and configuration.

## ➕ Adding New Agents

The framework is designed to be extensible. To add a specialized agent (e.g., a "Security Auditor" or "Database Admin"), simply create a new file in the `.github/agents/` directory.

### Example: Creating a `Tester` Agent

1.  Create a file named `.github/agents/tester.agent.md`.
2.  Add the following definition:

    ```markdown
    ---
    name: Tester
    description: An agent that writes and runs automated tests
    tools: ['vscode', 'execute', 'read', 'edit', 'agent']
    ---
    You are a testing agent responsible for validating application logic.

    Step 1: Read the code in the 'workloads/' folder.
    Step 2: Generate unit tests using the appropriate framework (e.g., Jest, PyTest).
    Step 3: Run the tests and report any failures.
    ```

3.  Reload the VS Code window or restart the agent extension to pick up the new profile.

## 🤝 Contributing
Contributions are welcome! Please fork the repository and submit a Pull Request.
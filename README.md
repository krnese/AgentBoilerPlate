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
    *   *Tools:* `microsoftdocs/mcp/*` (Azure Resource Graph), Web Search.
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
*   **GitHub Copilot** (with Chat extension and active subscription)
*   **Azure CLI** (`az login`)
*   **GitHub CLI** (`gh auth login`) - *Required for PR management*
*   **Node.js 18+** - *Required for MCP servers and local web UI*
*   **Git**

### Installation

1.  **Fork & Clone**
    ```bash
    git clone https://github.com/krnese/AgentBoilerPlate.git
    cd AgentBoilerPlate
    ```

2.  **Install Dependencies**
    Install the required npm packages including GitHub Copilot SDK:
    ```bash
    npm install
    ```

3.  **Configure MCP Servers**
    This repository includes a `.vscode/mcp.json` configuration file for the Azure Resource Graph MCP server.
    
    *   Open `.vscode/mcp.json`.
    *   Replace the `AZURE_SUBSCRIPTION_ID` value with your actual subscription ID (run `az account show --query id -o tsv` to find it).
    *   Restart VS Code or reload the window to apply the changes.

4.  **Sign in to Azure & GitHub**
    Open the integrated terminal in VS Code and authenticate:
    ```bash
    az login
    gh auth login
    ```

5.  **Start the Local Web UI (Optional)**
    Launch the interactive chat interface to work with agents via web browser:
    ```bash
    npm start
    ```
    
    Then open your browser to: **http://localhost:3000**
    
    The web UI provides:
    - Real-time streaming responses from AI agents
    - File attachment support for context
    - Model selection (Claude Sonnet 4.5, GPT-5, etc.)
    - Agent-specific sessions with specialized instructions
    
    For development with auto-reload:
    ```bash
    npm run dev
    ```

6.  **Start Developing**
    **Option A - VS Code Copilot Chat:**
    Open the GitHub Copilot Chat panel in VS Code and invoke an agent:
    
    > **Example Prompt:**
    > *"@Planner Plan a new python function app in West Europe that processes blob storage events."*
    
    **Option B - Local Web UI:**
    Use the web interface at http://localhost:3000 to interact with agents via a chat interface.

## 📦 Project Structure

*   `.github/agents/`: Definitions for the AI agents (prompts, tools, and personas). [Learn more](.github/agents/README.md)
*   `.github/prompts/`: Reusable prompt files for common Azure deployment scenarios. [Learn more](.github/prompts/README.md)
*   `.vscode/mcp.json`: MCP server configuration for Azure Resource Graph integration
*   `workloads/`: The workspace where your new projects will be generated
*   `public/`: Web UI frontend (HTML, CSS, JavaScript)
*   `server.js`: Express server with WebSocket support for real-time agent interactions
*   `agentLoader.js`: Dynamic agent loader that reads agent definitions from `.github/agents/`
*   `package.json`: Node.js dependencies including GitHub Copilot SDK

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
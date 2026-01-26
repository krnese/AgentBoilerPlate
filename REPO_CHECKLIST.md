# Repository Files Checklist

## ✅ Essential Files to Include in Repository

### Core Application Files
- ✅ `package.json` - Defines dependencies (@github/copilot-sdk, express, ws, multer)
- ✅ `server.js` - Main Express server with WebSocket and Copilot SDK integration
- ✅ `agentLoader.js` - Dynamic agent loader from `.github/agents/`
- ✅ `LICENSE` - License file
- ✅ `README.md` - Main documentation with setup instructions
- ✅ `.gitignore` - Excludes node_modules, uploads, logs, etc.

### Web UI Files
- ✅ `public/index.html` - Web interface HTML
- ✅ `public/app.js` - Frontend JavaScript for WebSocket communication
- ✅ `public/style.css` - UI styling

### Agent Definitions
- ✅ `.github/agents/` - Directory containing all agent definitions
  - ✅ `planner.agent.md`
  - ✅ `developer.agent.md`
  - ✅ `documenter.agent.md`
  - ✅ `prmanager.agent.md`
  - ✅ `reviewer.agent.md`
  - ✅ `README.md` - Agent documentation

### Prompts & Configuration
- ✅ `.github/prompts/` - Reusable prompt templates
- ✅ `.vscode/mcp.json` - MCP server configuration (with placeholder subscription ID)

### Example Workloads
- ✅ `workloads/` - Example projects directory
  - ✅ `hello-world/` - Sample workload demonstrating the framework

### Directories Created at Runtime
- ⚠️ `uploads/` - **Auto-created** by multer when first file is uploaded (excluded via .gitignore)

## ❌ Files to EXCLUDE from Repository

These are automatically excluded by `.gitignore`:
- ❌ `node_modules/` - Installed via `npm install`
- ❌ `package-lock.json` - Generated during npm install (optional to include)
- ❌ `uploads/*` - User-uploaded files (runtime data)
- ❌ `.DS_Store` - macOS system files
- ❌ `*.log` - Log files

## 🚀 Quick Start for Users

After cloning/forking the repository, users need to run:

```bash
# 1. Install dependencies (installs @github/copilot-sdk and other packages)
npm install

# 2. Configure Azure subscription in .vscode/mcp.json
az account show --query id -o tsv  # Get subscription ID

# 3. Authenticate with Azure and GitHub
az login
gh auth login

# 4. Start the local web server (optional)
npm start
```

## 📋 Pre-Release Checklist

Before users clone/fork:
- [ ] `.vscode/mcp.json` has placeholder `AZURE_SUBSCRIPTION_ID` (not your real one!)
- [ ] `node_modules/` is NOT committed
- [ ] `uploads/` directory is empty or not committed
- [ ] No sensitive credentials in any files
- [ ] README.md has complete setup instructions
- [ ] `.gitignore` properly excludes runtime/dependency files

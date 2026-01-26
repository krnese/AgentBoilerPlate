class CopilotChat {
  constructor() {
    this.ws = null;
    this.isProcessing = false;
    this.currentAssistantMsg = null;
    this.attachments = [];
    this.agents = [];

    // DOM elements
    this.messagesEl = document.getElementById("messages");
    this.promptEl = document.getElementById("prompt");
    this.formEl = document.getElementById("chat-form");
    this.statusEl = document.getElementById("status");
    this.agentSelect = document.getElementById("agent-select");
    this.modelSelect = document.getElementById("model-select");
    this.newSessionBtn = document.getElementById("new-session");
    this.sendBtn = document.getElementById("send-btn");
    this.abortBtn = document.getElementById("abort-btn");
    this.fileInput = document.getElementById("file-input");
    this.attachmentsEl = document.getElementById("attachments");

    this.init();
  }

  init() {
    this.loadAgents();
    this.formEl.addEventListener("submit", (e) => this.handleSubmit(e));
    this.newSessionBtn.addEventListener("click", () => this.createSession());
    this.abortBtn.addEventListener("click", () => this.abort());
    this.fileInput.addEventListener("change", (e) => this.handleFileSelect(e));
    
    // Listen for agent selection changes
    this.agentSelect.addEventListener("change", () => {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.createSession();
      }
    });

    // Auto-resize textarea
    this.promptEl.addEventListener("input", () => {
      this.promptEl.style.height = "auto";
      this.promptEl.style.height = Math.min(this.promptEl.scrollHeight, 150) + "px";
    });

    // Shift+Enter for newline, Enter to send
    this.promptEl.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        this.formEl.dispatchEvent(new Event("submit"));
      }
    });

    this.connect();
  }

  async loadAgents() {
    this.agentsLoaded = (async () => {
      try {
        const response = await fetch("/api/agents");
        this.agents = await response.json();
        
        // Populate agent select
        this.agents.forEach(agent => {
          const option = document.createElement("option");
          option.value = agent.id;
          option.textContent = `@${agent.name}`;
          option.title = agent.description;
          this.agentSelect.appendChild(option);
        });
        console.log(`Loaded ${this.agents.length} agents:`, this.agents.map(a => a.name).join(', '));
      } catch (error) {
        console.error("Failed to load agents:", error);
      }
    })();
    return this.agentsLoaded;
  }

  connect() {
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    this.ws = new WebSocket(`${protocol}//${window.location.host}`);

    this.ws.onopen = async () => {
      this.setStatus("Connected", "connected");
      // Wait for agents to load before creating session
      await this.agentsLoaded;
      this.createSession();
    };

    this.ws.onclose = () => {
      this.setStatus("Disconnected - Reconnecting...", "error");
      setTimeout(() => this.connect(), 3000);
    };

    this.ws.onerror = () => {
      this.setStatus("Connection error", "error");
    };

    this.ws.onmessage = (event) => this.handleMessage(JSON.parse(event.data));
  }

  handleMessage(msg) {
    switch (msg.type) {
      case "session_created":
        const agentInfo = msg.agent ? ` with @${msg.agent}` : "";
        const agentBadge = msg.agent ? `\n\n<div style="display: inline-block; background: #0078d4; color: white; padding: 4px 12px; border-radius: 4px; font-weight: bold; margin: 8px 0;">🤖 Active Agent: ${msg.agent}</div>` : "";
        this.addSystemMessage(`Session started${agentInfo} using ${msg.model || "default model"}${agentBadge}`);
        this.setProcessing(false);
        break;

      case "delta":
        if (!this.currentAssistantMsg) {
          this.currentAssistantMsg = this.addMessage("", "assistant");
          this.currentAssistantMsg.dataset.rawContent = "";
        }
        // Accumulate raw content and re-render as markdown
        this.currentAssistantMsg.dataset.rawContent += msg.content;
        if (typeof marked !== "undefined") {
          this.currentAssistantMsg.innerHTML = marked.parse(this.currentAssistantMsg.dataset.rawContent);
        } else {
          this.currentAssistantMsg.textContent = this.currentAssistantMsg.dataset.rawContent;
        }
        this.scrollToBottom();
        break;

      case "message":
        if (this.currentAssistantMsg) {
          if (typeof marked !== "undefined") {
            this.currentAssistantMsg.innerHTML = marked.parse(msg.content);
          } else {
            this.currentAssistantMsg.textContent = msg.content;
          }
        } else {
          this.addMessage(msg.content, "assistant");
        }
        break;

      case "tool_start":
        this.showToolIndicator(msg.tool, true);
        break;

      case "tool_end":
        this.showToolIndicator(msg.tool, false);
        break;

      case "idle":
        this.setProcessing(false);
        this.currentAssistantMsg = null;
        break;

      case "aborted":
        this.setProcessing(false);
        this.currentAssistantMsg = null;
        this.addSystemMessage("Response aborted");
        break;

      case "error":
        this.addSystemMessage(`Error: ${msg.message}`);
        this.setProcessing(false);
        break;
    }
  }

  createSession() {
    const model = this.modelSelect.value;
    const agent = this.agentSelect.value;
    
    console.log(`Creating session with agent: "${agent}", model: ${model}`);
    
    // Reset client state
    this.currentAssistantMsg = null;
    this.isProcessing = false;
    this.setProcessing(false);
    
    this.ws.send(JSON.stringify({ type: "create_session", model, agent }));
    this.messagesEl.innerHTML = "";
    this.setStatus("Creating session...", "");
  }

  async handleSubmit(e) {
    e.preventDefault();
    const prompt = this.promptEl.value.trim();
    if (!prompt || this.isProcessing) return;

    this.addMessage(prompt, "user");
    this.promptEl.value = "";
    this.promptEl.style.height = "auto";

    const message = { type: "send_message", prompt };
    if (this.attachments.length > 0) {
      message.attachments = this.attachments;
      this.clearAttachments();
    }

    this.ws.send(JSON.stringify(message));
    this.setProcessing(true);
  }

  abort() {
    this.ws.send(JSON.stringify({ type: "abort" }));
  }

  async handleFileSelect(e) {
    const file = e.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);

    try {
      const res = await fetch("/upload", { method: "POST", body: formData });
      const data = await res.json();

      if (data.error) {
        this.addSystemMessage(`Upload failed: ${data.error}`);
        return;
      }

      this.attachments.push({ path: data.path, name: data.name });
      this.renderAttachments();
    } catch (err) {
      this.addSystemMessage(`Upload failed: ${err.message}`);
    }

    this.fileInput.value = "";
  }

  renderAttachments() {
    this.attachmentsEl.innerHTML = this.attachments
      .map(
        (a, i) => `
      <div class="attachment-chip">
        📄 ${a.name}
        <button onclick="chat.removeAttachment(${i})">×</button>
      </div>
    `
      )
      .join("");
  }

  removeAttachment(index) {
    this.attachments.splice(index, 1);
    this.renderAttachments();
  }

  clearAttachments() {
    this.attachments = [];
    this.attachmentsEl.innerHTML = "";
  }

  addMessage(content, role) {
    const div = document.createElement("div");
    div.className = `message ${role}`;
    // Render markdown for assistant messages, plain text for user messages
    if (role === "assistant" && typeof marked !== "undefined") {
      div.innerHTML = marked.parse(content);
    } else {
      div.textContent = content;
    }
    this.messagesEl.appendChild(div);
    this.scrollToBottom();
    return div;
  }

  addSystemMessage(content) {
    const div = document.createElement("div");
    div.className = "message system";
    // Use innerHTML if content contains HTML tags, otherwise use textContent
    if (content.includes('<')) {
      div.innerHTML = content;
    } else {
      div.textContent = content;
    }
    this.messagesEl.appendChild(div);
    this.scrollToBottom();
  }

  showToolIndicator(toolName, isStart) {
    if (isStart && this.currentAssistantMsg) {
      const indicator = document.createElement("div");
      indicator.className = "tool-indicator";
      indicator.textContent = `🔧 Using: ${toolName}`;
      indicator.id = `tool-${toolName}`;
      this.currentAssistantMsg.appendChild(indicator);
    }
  }

  setProcessing(processing) {
    this.isProcessing = processing;
    this.sendBtn.hidden = processing;
    this.abortBtn.hidden = !processing;
    this.promptEl.disabled = processing;
  }

  setStatus(text, className) {
    this.statusEl.textContent = text;
    this.statusEl.className = `status ${className}`;
  }

  scrollToBottom() {
    this.messagesEl.scrollTop = this.messagesEl.scrollHeight;
  }
}

const chat = new CopilotChat();

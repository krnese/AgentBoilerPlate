import express from "express";
import { WebSocketServer } from "ws";
import { createServer } from "http";
import multer from "multer";
import path from "path";
import fs from "fs";
import { CopilotClient } from "@github/copilot-sdk";
import { loadAgents } from "./agentLoader.js";

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server });

// File upload config
const upload = multer({ dest: "uploads/" });

app.use(express.static("public"));
app.use(express.json());

// Store active sessions and agents
const sessions = new Map();
const agents = loadAgents();
let client = null;

// Initialize Copilot client
async function initClient() {
  if (!client) {
    client = new CopilotClient();
    await client.start();
    console.log("Copilot client started");
  }
  return client;
}

// WebSocket connection handler
wss.on("connection", async (ws) => {
  console.log("Client connected");
  let session = null;

  ws.on("message", async (data) => {
    try {
      const msg = JSON.parse(data);

      switch (msg.type) {
        case "create_session":
          await initClient();
          
          // Destroy existing session if it exists
          if (session) {
            await session.destroy();
            session = null;
          }
          
          // Get agent configuration if specified
          const agentId = msg.agent && msg.agent.trim() !== "" ? msg.agent : null;
          const agent = agentId ? agents[agentId] : null;
          
          // Debug logging
          console.log(`Creating session - Agent ID: "${agentId}", Found: ${!!agent}`);
          if (agentId && !agent) {
            console.warn(`Agent "${agentId}" not found. Available agents:`, Object.keys(agents));
          }
          
          const sessionConfig = {
            model: msg.model || "claude-sonnet-4.5",
            streaming: true,
          };
          
          // Inject agent instructions as system message
          if (agent) {
            console.log(`Applying agent: ${agent.name}`);
            console.log(`System prompt preview: ${agent.instructions.substring(0, 200)}...`);
            // Use the full agent instructions as the system message with strong framing
            sessionConfig.systemMessage = {
              mode: "replace",
              content: `<role>
${agent.instructions}
</role>

You are ONLY acting as the agent described above. Follow the steps and instructions precisely. Do not mention that you are GitHub Copilot unless specifically asked about your underlying model.`
            };
          } else if (agentId) {
            console.log('No agent system message applied (General Chat mode)');
          }
          
          session = await client.createSession(sessionConfig);

          // Set up event handler for streaming
          session.on((event) => {
            if (event.type === "assistant.message_delta") {
              ws.send(JSON.stringify({ type: "delta", content: event.data.deltaContent }));
            } else if (event.type === "assistant.message") {
              ws.send(JSON.stringify({ type: "message", content: event.data.content }));
            } else if (event.type === "assistant.reasoning_delta") {
              ws.send(JSON.stringify({ type: "reasoning_delta", content: event.data.deltaContent, reasoningId: event.data.reasoningId }));
            } else if (event.type === "assistant.reasoning") {
              ws.send(JSON.stringify({ type: "reasoning", content: event.data.content, reasoningId: event.data.reasoningId }));
            } else if (event.type === "session.idle") {
              ws.send(JSON.stringify({ type: "idle" }));
            } else if (event.type === "tool.execution_start") {
              ws.send(JSON.stringify({ type: "tool_start", tool: event.data.toolName }));
            } else if (event.type === "tool.execution_end") {
              ws.send(JSON.stringify({ type: "tool_end", tool: event.data.toolName }));
            }
          });

          // Update session reference in the map
          sessions.set(ws, session);
          
          ws.send(JSON.stringify({ 
            type: "session_created", 
            model: msg.model,
            agent: agent ? agent.name : null
          }));
          break;

        case "send_message":
          if (!session) {
            ws.send(JSON.stringify({ type: "error", message: "No active session" }));
            return;
          }

          const options = { prompt: msg.prompt };
          if (msg.attachments?.length) {
            options.attachments = msg.attachments.map((a) => ({
              type: "file",
              path: a.path,
              displayName: a.name,
            }));
          }

          await session.send(options);
          break;

        case "abort":
          if (session) {
            await session.abort();
            ws.send(JSON.stringify({ type: "aborted" }));
          }
          break;
      }
    } catch (error) {
      console.error("Error:", error);
      ws.send(JSON.stringify({ type: "error", message: error.message }));
    }
  });

  ws.on("close", async () => {
    console.log("Client disconnected");
    const session = sessions.get(ws);
    if (session) {
      await session.destroy();
      sessions.delete(ws);
    }
  });
});

// File upload endpoint
app.post("/upload", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }
  res.json({
    path: path.resolve(req.file.path),
    name: req.file.originalname,
  });
});

// API endpoint to get available agents
app.get("/api/agents", (req, res) => {
  const agentList = Object.values(agents).map(a => ({
    id: a.id,
    name: a.name,
    description: a.description
  }));
  res.json(agentList);
});

// API endpoint to get available models
app.get("/api/models", async (req, res) => {
  try {
    await initClient();
    const models = await client.listModels();
    res.json(models);
  } catch (error) {
    console.error("Failed to fetch models:", error);
    res.status(500).json({ error: "Failed to fetch models" });
  }
});

// Cleanup uploads on exit
process.on("SIGINT", async () => {
  console.log("\nShutting down...");
  for (const session of sessions.values()) {
    await session.destroy();
  }
  if (client) {
    await client.stop();
  }
  if (fs.existsSync("uploads")) {
    fs.rmSync("uploads", { recursive: true });
  }
  process.exit();
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

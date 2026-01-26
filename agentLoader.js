import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function loadAgents() {
  const agentsDir = path.join(__dirname, '.github', 'agents');
  const agents = {};

  try {
    const files = fs.readdirSync(agentsDir);

    files.forEach(file => {
      if (file.endsWith('.agent.md') && file !== 'README.md') {
        const filePath = path.join(agentsDir, file);
        const content = fs.readFileSync(filePath, 'utf8');

        // Split by --- to separate frontmatter from instructions
        const parts = content.split('---').filter(s => s.trim());
        
        if (parts.length < 2) {
          console.warn(`Skipping ${file}: Invalid format`);
          return;
        }

        // Parse frontmatter (YAML-like)
        const frontmatter = parts[0];
        const instructions = parts.slice(1).join('---').trim();

        const metadata = {};
        frontmatter.split('\n').forEach(line => {
          const colonIndex = line.indexOf(':');
          if (colonIndex > 0) {
            const key = line.substring(0, colonIndex).trim();
            const value = line.substring(colonIndex + 1).trim();
            
            // Parse arrays
            if (value.startsWith('[')) {
              try {
                metadata[key] = JSON.parse(value.replace(/'/g, '"'));
              } catch (e) {
                metadata[key] = value;
              }
            } else {
              metadata[key] = value;
            }
          }
        });

        if (metadata.name) {
          const agentId = metadata.name.toLowerCase().replace(/\s+/g, '_');
          agents[agentId] = {
            id: agentId,
            name: metadata.name,
            description: metadata.description || '',
            tools: metadata.tools || [],
            instructions: instructions
          };
        }
      }
    });

    console.log(`Loaded ${Object.keys(agents).length} agents:`, Object.keys(agents).join(', '));
  } catch (error) {
    console.error('Error loading agents:', error);
  }

  return agents;
}

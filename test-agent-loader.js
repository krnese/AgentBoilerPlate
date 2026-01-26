import { loadAgents } from './agentLoader.js';

console.log('Testing agent loader...');
const agents = loadAgents();

console.log('\n=== Loaded Agents ===');
console.log('Total agents:', Object.keys(agents).length);
console.log('Agent IDs:', Object.keys(agents));

console.log('\n=== Agent Details ===');
Object.values(agents).forEach(agent => {
  console.log(`\n${agent.name} (${agent.id})`);
  console.log(`  Description: ${agent.description}`);
  console.log(`  Tools: ${agent.tools.length}`);
  console.log(`  Instructions length: ${agent.instructions.length} chars`);
});

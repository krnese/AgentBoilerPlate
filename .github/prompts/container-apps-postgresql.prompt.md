---
name: container-apps-postgresql
description: Deploy Azure Container Apps with PostgreSQL database
agent: Planner
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'azure-resource-graph/*', 'microsoftdocs/mcp/*', 'agent', 'todo']
---

# Azure Container Apps with PostgreSQL

## Request

Deploy a containerized Node.js REST API with PostgreSQL database in **North Europe**. This is for a **staging** environment.

## Requirements

1. **Container App**: Azure Container Apps running a Node.js Express API
2. **Database**: Azure Database for PostgreSQL (Flexible Server)
3. **Networking**: Container App Environment with internal ingress
4. **Scaling**: Auto-scale based on HTTP requests (min 1, max 5 replicas)
5. **Secrets**: Use Container Apps secrets for database connection strings
6. **Environment**: Staging/Test environment

## Technical Details

- PostgreSQL version: 15
- Smallest SKU possible (cost optimization)
- Private networking between Container App and PostgreSQL
- Health probes configured
- Container from Docker Hub (you can use `node:18-alpine` as base)

## Preferences

- Name resources like: `<type>-api-staging-northeurope`
- Use **managed identity** where possible
- Enable diagnostic logging
- Include sample Node.js API code that connects to PostgreSQL

## What I Expect

- Deployed infrastructure with working API
- Simple CRUD API endpoints (create/read users or similar)
- PostgreSQL database with initial schema
- Documentation on how to test the API
- Health endpoint that verifies database connectivity

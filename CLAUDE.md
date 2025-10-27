# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repository is a collection and creation hub for AI agent prompts. The goal is to aggregate, organize, and develop high-quality prompts for various AI agents and use cases.

## Repository Structure

The repository is currently in its initial stage. As it grows, prompts should be organized by:
- **Use case** (e.g., coding, research, writing, analysis)
- **Agent type** (e.g., Claude, GPT, specialized agents)
- **Complexity level** (basic, intermediate, advanced)
- **Domain** (software engineering, data science, content creation, etc.)

## MCP Server Configuration

This project uses two MCP servers configured in `.mcp.json`:

- **serena**: A semantic coding tool for codebase analysis and manipulation
- **context7**: Provides up-to-date library documentation and code examples

## Working with Agent Prompts

When creating or organizing agent prompts:

1. **Format**: Use markdown (.md) files for readability and easy editing
2. **Metadata**: Include at the top of each prompt file:
   - Purpose/objective
   - Target agent/model
   - Expected input/output
   - Usage examples
   - Tags for categorization

3. **Naming Convention**: Use descriptive, kebab-case names that clearly indicate the prompt's purpose (e.g., `code-review-assistant.md`, `data-analysis-helper.md`)

4. **Testing**: When creating prompts, consider including test cases or example interactions to validate effectiveness

## Vietnamese Language Support

This repository supports Vietnamese documentation and prompts alongside English. Use the language that best serves the intended audience.

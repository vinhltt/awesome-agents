# Awesome Agents

A comprehensive template repository for specification-driven AI agent development. Provides structured workflows for feature development and unit test generation with multi-platform support.

## Quick Start

```bash
# Clone the repository
git clone <repo-url> awesome-agents
cd awesome-agents

# Copy environment template
cp .specify/.speckit.env.example .specify/.speckit.env

# Configure your project prefix (edit .specify/.speckit.env)
# SPECKIT_PREFIX_LIST="aa"  # Your project prefix(es)
```

## Features

### SpecKit Workflow
Specification-driven feature development with 9 commands:

| Command | Description |
|---------|-------------|
| `/speckit.specify` | Create feature specification with user scenarios |
| `/speckit.clarify` | Clarify ambiguous requirements |
| `/speckit.plan` | Generate implementation plan |
| `/speckit.tasks` | Break down into ordered tasks |
| `/speckit.analyze` | Cross-artifact consistency check |
| `/speckit.implement` | Execute implementation |
| `/speckit.status` | View workflow progress |
| `/speckit.checklist` | Generate custom checklist |
| `/speckit.constitution` | Manage project governance |

### Unit Test Workflow
AI-powered test generation with 7 commands:

| Command | Description |
|---------|-------------|
| `/ut.specify` | Create test specification |
| `/ut.analyze` | Analyze codebase for test gaps |
| `/ut.clarify` | Clarify test requirements |
| `/ut.plan` | Generate test implementation plan |
| `/ut.generate` | Generate unit test code |
| `/ut.review` | Review generated tests |
| `/ut.run` | Execute tests and analyze results |

### Multi-Platform Support

| Platform | Integration |
|----------|-------------|
| Claude Code | `.claude/commands/`, `.claude/agents/` |
| GitHub Copilot | `.github/prompts/`, `.github/agents/` |
| Google Gemini | `.gemini/commands/` |
| OpenCode | `.opencode/command/` |

## Repository Structure

```
awesome-agents/
├── .claude/              # Claude Code integration
│   ├── agents/          # Specialized AI agents
│   └── commands/        # Slash commands (speckit.*, ut.*)
├── .github/             # GitHub Copilot integration
│   ├── agents/          # GitHub agents
│   └── prompts/         # GitHub prompts
├── .gemini/             # Google Gemini commands
├── .opencode/           # OpenCode commands
├── .serena/             # Serena MCP server config
├── .specify/            # Spec Kit core system
│   ├── features/        # Feature specifications
│   ├── memory/          # Constitution & state
│   ├── scripts/bash/    # Automation scripts
│   ├── templates/       # Workflow templates
│   └── ut-templates/    # Test framework templates
├── docs/                # Documentation
└── specify-prompt/      # Customization prompts
```

## Example Workflow

### 1. Create Feature Specification
```
/speckit.specify features/aa-1 "Build user authentication system"
```

### 2. Clarify Requirements
```
/speckit.clarify
```

### 3. Generate Plan
```
/speckit.plan
```

### 4. Create Tasks
```
/speckit.tasks
```

### 5. Check Progress
```
/speckit.status
```

### 6. Implement
```
/speckit.implement
```

## Test Framework Support

Pre-configured templates for:
- **Jest** - JavaScript/TypeScript testing
- **Pytest** - Python testing
- **Vitest** - Vite-native testing

Templates located in `.specify/ut-templates/`

## Configuration

### Environment Variables

Copy `.specify/.speckit.env.example` to `.specify/.speckit.env`:

```bash
# Project Configuration
SPECKIT_PREFIX_LIST="aa"              # Allowed prefixes
SPECKIT_DEFAULT_FOLDER="features"     # Default folder
SPECKIT_MAIN_BRANCH="master"          # Base branch
SPECKIT_SPECS_ROOT=".specify"         # Specs root directory

# Testing Configuration
SPECKIT_UT_FRAMEWORK="jest"           # Test framework
SPECKIT_UT_STYLE="describe-it"        # Test style
```

### Branch Naming

Format: `[folder]/[prefix]-[number]`

Examples:
- `features/aa-1` - Feature branch
- `hotfix/aa-99` - Hotfix branch
- `features/aa-2` - Another feature

## Documentation

| Document | Description |
|----------|-------------|
| [Project Overview](docs/project-overview-pdr.md) | Vision, features, roadmap |
| [Codebase Summary](docs/codebase-summary.md) | Structure, components, flows |
| [Code Standards](docs/code-standards.md) | Naming conventions, quality standards |
| [System Architecture](docs/system-architecture.md) | Architecture, data flows |

### Additional Guides

| Guide | Description |
|-------|-------------|
| [SpecKit Migration](docs/migration-guide-speckit-workflow.md) | Migrating to SpecKit |
| [SpecKit Troubleshooting](docs/troubleshooting-speckit.md) | Common issues |
| [Workflow Examples](docs/workflow-examples-speckit.md) | Usage examples |
| [Multi-Project Setup](docs/setup-multi-project.md) | Multiple project config |
| [UT Troubleshooting](docs/ut-troubleshooting.md) | Test workflow issues |
| [UT Migration](docs/ut-workflow-migration.md) | Test workflow migration |

## Constitution

This project follows a governance constitution (v1.0.0) with core principles:

1. **Quality First** - Complete metadata, examples, testing
2. **Multilingual Support** - English + Vietnamese
3. **Organization by Purpose** - Use case, agent type, complexity, domain
4. **Markdown-First** - All prompts and docs in Markdown
5. **Testing and Validation** - Test cases for prompts

See [Constitution](/.specify/memory/constitution.md) for details.

## MCP Servers

Configured in `.mcp.json`:

- **serena** - Semantic coding tool for codebase analysis
- **context7** - Up-to-date library documentation

## Supported Languages

- Documentation: English, Vietnamese
- File naming: English (kebab-case)
- Prompts: Language appropriate to audience

## Contributing

1. Follow the [Code Standards](docs/code-standards.md)
2. Use SpecKit workflow for new features
3. Include test cases for new prompts
4. Update documentation as needed
5. Follow conventional commit messages

## License

MIT License - See [LICENSE](LICENSE) for details.

---

**Version**: 1.0.0 | **Last Updated**: 2025-11-25

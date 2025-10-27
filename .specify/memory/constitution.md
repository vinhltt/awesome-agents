# Awesome Agents Constitution

<!--
SYNC IMPACT REPORT
==================
Version Change: none → 1.0.0 (Initial constitution)
Modified Principles: none (initial creation)
Added Sections:
  - Core Principles (5 principles)
  - Quality Standards
  - Development Workflow
  - Governance

Templates Status:
  ✅ plan-template.md - reviewed, compatible (Constitution Check section aligns)
  ✅ spec-template.md - reviewed, compatible (user stories align with Quality First principle)
  ✅ tasks-template.md - reviewed, compatible (task structure aligns with workflow)

Follow-up TODOs: none

Rationale: MINOR version (1.0.0) for initial constitution establishment.
This is a new project with initial governance structure being established.
-->

## Core Principles

### I. Quality First

Every prompt in this repository MUST include:
- Clear purpose/objective statement
- Target agent/model specification
- Expected input/output examples
- Usage examples demonstrating effectiveness
- Appropriate metadata tags for categorization

**Rationale**: High-quality prompts are the core value proposition. Without proper documentation and examples, prompts cannot be effectively discovered, understood, or reused by the community.

### II. Multilingual Support

The repository MUST support both English and Vietnamese content:
- Documentation may be provided in either language
- Prompts should use the language that best serves the intended audience
- Naming conventions use English for file/directory names (kebab-case)
- README and core documentation should provide bilingual summaries when possible

**Rationale**: Supporting multiple languages broadens accessibility and serves diverse user communities. English naming ensures cross-platform compatibility while content can be in the most appropriate language.

### III. Organization by Purpose

Prompts MUST be organized according to clear categorical dimensions:
- Use case (coding, research, writing, analysis, etc.)
- Agent type (Claude, GPT, specialized agents)
- Complexity level (basic, intermediate, advanced)
- Domain (software engineering, data science, content creation, etc.)

**Rationale**: Systematic organization enables discovery and helps users find relevant prompts quickly. Multiple categorization dimensions support different search patterns.

### IV. Markdown-First Documentation

All prompts and documentation MUST use Markdown format (.md files):
- Ensures readability in version control systems
- Provides consistent formatting across editors and platforms
- Enables easy editing and collaboration
- Supports rich formatting (code blocks, tables, links) without tooling dependencies

**Rationale**: Markdown balances human readability with machine processability and works universally across development environments.

### V. Testing and Validation

Prompts SHOULD include validation mechanisms:
- Test cases demonstrating expected behavior
- Example interactions showing successful outcomes
- Edge cases or failure modes to be aware of
- Version compatibility notes when relevant

**Rationale**: Validated prompts provide confidence to users and maintain quality standards. Test cases serve as both documentation and verification.

## Quality Standards

### Naming Conventions

- **Files**: Use descriptive kebab-case names (e.g., `code-review-assistant.md`, `data-analysis-helper.md`)
- **Directories**: Use kebab-case reflecting organizational structure (e.g., `coding/`, `research/advanced/`)
- **Clarity**: Names should clearly indicate the prompt's purpose without requiring file inspection

### Metadata Requirements

Each prompt file MUST include a metadata section containing:
- **Purpose/Objective**: What problem does this prompt solve?
- **Target Agent/Model**: Which AI systems is this designed for?
- **Expected Input/Output**: Format and structure of interactions
- **Usage Examples**: At least one complete example
- **Tags**: Categorization labels for discovery

### Version Control Practices

- Commit messages MUST be descriptive and follow conventional commit format
- Major prompt changes should be documented in commit messages
- Breaking changes to prompts should be called out explicitly
- Deprecated prompts should be moved to an archive directory, not deleted

## Development Workflow

### Adding New Prompts

1. **Research**: Check if similar prompts already exist
2. **Draft**: Create prompt with complete metadata
3. **Test**: Validate prompt with target agent
4. **Document**: Add usage examples and edge cases
5. **Categorize**: Place in appropriate directory structure
6. **Commit**: Use descriptive commit message

### Updating Existing Prompts

1. **Review**: Understand current prompt and its usage
2. **Modify**: Make targeted improvements
3. **Test**: Validate changes don't break existing use cases
4. **Document**: Update examples if behavior changed
5. **Version**: Note significant changes in commit message

### Quality Review

Before merging new or updated prompts:
- Verify all metadata fields are complete
- Confirm file is in correct organizational location
- Check that usage examples work as documented
- Validate naming convention compliance
- Ensure Markdown formatting is correct

## Governance

### Amendment Process

This constitution may be amended when:
- New organizational needs emerge
- Quality standards require adjustment
- Community feedback indicates improvements
- Tool integration requires structural changes

Amendments require:
1. Documentation of rationale for change
2. Review of impact on existing prompts
3. Migration plan if structural changes needed
4. Update of dependent templates and documentation

### Versioning Policy

Constitution version follows semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes to organizational structure or principles
- **MINOR**: Addition of new principles, sections, or requirements
- **PATCH**: Clarifications, wording improvements, non-semantic updates

### Compliance Review

All contributions MUST:
- Adhere to organizational structure defined in principles
- Meet quality standards for metadata and documentation
- Follow naming conventions
- Include appropriate test/validation examples

Projects using this repository's speckit templates should reference this constitution in their "Constitution Check" sections to verify alignment with repository governance.

**Version**: 1.0.0 | **Ratified**: 2025-10-27 | **Last Amended**: 2025-10-27

---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Execution Steps

### Step 0: Validate Task ID

**CRITICAL**: Check task ID argument FIRST before any operations.
**NOTE**: Users must create feature branch manually before running this command.

1. **Parse user input**:
   - Task ID is OPTIONAL for this command (can derive from branch)
   - If provided: validate format `[folder/]prefix-number`
   - If not provided: script will derive from current branch name

2. **Validate task ID (if provided)**:
   ```
   If task ID provided AND invalid format:
     ERROR: "Invalid task ID format. Expected: [folder/]prefix-number"
     STOP - Do NOT proceed
   ```

3. **Derive from branch (if not provided)**:
   - Script automatically detects current branch
   - Extracts task ID from branch name (e.g., `features/{prefix}-001` → `{prefix}-001`)
   - `{prefix}` = value from `.speckit.env` SPECKIT_PREFIX_LIST
   - If not on feature branch:
     WARNING: "Not on feature branch, using current branch"

4. **Determine feature directory**:
   - Pattern: `.specify/{folder}/{prefix-number}/`
   - Validate directory exists (should have spec.md from /speckit.specify)
   - If not found:
     ERROR: "Feature directory not found. Run /speckit.specify first"

**After Validation**:
- Proceed to execute setup-plan.sh
- Script handles task ID extraction and path resolution

### Step 1: Setup

1. **Setup**: Run `.specify/scripts/bash/setup-plan.sh --json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### Step 2: Load Context: Read FEATURE_SPEC and `.specify/memory/constitution.md`. Load IMPL_PLAN template (already copied).

### Step 3: Execute Plan Workflow: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

### Step 4: Report Results: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Agent context update**:
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

**Output**: data-model.md, /contracts/*, quickstart.md, agent-specific file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications

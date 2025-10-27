# Prompt: Customize GitHub Spec Kit Implementation

**Objective:** Update the existing Spec Kit configuration to follow a new, standardized branching and directory structure. This prompt will serve as a reusable guide for this customization process.

**Background:** The default Spec Kit behavior for creating new features (e.g., `specs/123-feature-name`) needs to be replaced with a custom format. This involves modifying shell scripts, templates, and command definitions for various AI agents (`Claude`, `Gemini`).

---

## 1. Customization Parameters

The following key-value pairs define the new structure. All scripts and templates must be updated to use these values.

| Key | Value | Description |
| :--- | :--- | :--- |
| `[prefix]` | `aa` | The prefix for ticket/issue numbers. |
| `[branch-folder]` | `features` | The git branch folder for new feature branches. |
| `[main-branch]` | `master` | The primary branch from which new branches are created. |
| `[folder-specs]` | `.specify/features`| The directory where spec folders will be created. |

---

## 2. Core Requirements

### 2.1. Branching Strategy

- **Branch Format:** New feature branches must follow the pattern: `[branch-folder]/[prefix]-XXX`.
  - *Example:* `features/aa-123`
- **Base Branch:** All new feature branches must be created from `[main-branch]` (`master`).

### 2.2. Specification Directory Structure

- **Spec Folder:** When a new spec is created, its directory must be generated at: `[folder-specs]/[prefix]-XXX`.
  - *Example:* `.specify/features/aa-123`

### 2.3. Command Usage & Validation

- **Primary Command:** The main command for creating a new spec must be: `/speckit.specify [prefix]-XXX [description]`.
  - *Example:* `/speckit.specify aa-123 "Implement new login flow"`
- **Input Validation:** The script for `/speckit.specify` must validate that the first argument matches the `[prefix]-XXX` format. If the argument is missing or invalid, the script should exit with an informative error message for the user.
- **Consistency:** All other `/speckit.*` commands must be updated to be consistent with this new naming and directory convention.

---

## 3. File Modification Checklist

The following files must be updated to implement the changes described above.

### 3.1. `.specify` Scripts & Templates

-   **Scripts:** `/mnt/rz1_main_pool/VinhLTT_stored/0_personal/awesome-agents/.specify/scripts/bash/`
    -   [ ] `check-prerequisites.sh`: Update any checks related to branch or directory naming.
    -   [ ] `common.sh`: Update helper functions, particularly those that resolve branch names or spec paths.
    -   [ ] `create-new-feature.sh`: This is the core file. Modify it to handle the new branch format (`[branch-folder]/[prefix]-XXX`), base branch (`[main-branch]`), and spec directory creation (`[folder-specs]/[prefix]-XXX`). Implement the argument validation here.
    -   [ ] `setup-plan.sh`: Ensure this script correctly locates the spec files in the new directory structure.
    -   [ ] `update-agent-context.sh`: Update to reflect the new file paths and command structures.

-   **Templates:** `/mnt/rz1_main_pool/VinhLTT_stored/0_personal/awesome-agents/.specify/templates/`
    -   [ ] `agent-file-template.md`: Update any placeholder text that refers to the old branch/directory format.
    -   [ ] `checklist-template.md`: Update to reflect the new process.
    -   [ ] `plan-template.md`: Ensure paths and commands mentioned in the template are correct.
    -   [ ] `spec-template.md`: Update any references to feature names or paths.
    -   [ ] `tasks-template.md`: Update any references to feature names or paths.

### 3.2. `.claude` Agent Commands

-   **Commands:** `/mnt/rz1_main_pool/VinhLTT_stored/0_personal/awesome-agents/.claude/commands/`
    -   [ ] `speckit.analyze.md`: Update command usage and examples.
    -   [ ] `speckit.checklist.md`: Update command usage and examples.
    -   [ ] `speckit.clarify.md`: Update command usage and examples.
    -   [ ] `speckit.constitution.md`: Review for any hardcoded paths or commands.
    -   [ ] `speckit.implement.md`: Update command usage and examples.
    -   [ ] `speckit.plan.md`: Update command usage and examples.
    -   [ ] `speckit.specify.md`: Update the main command definition, description, and examples to match the new format.
    -   [ ] `speckit.tasks.md`: Update command usage and examples.

### 3.3. `.gemini` Agent Commands

-   **Commands:** `/mnt/rz1_main_pool/VinhLTT_stored/0_personal/awesome-agents/.gemini/commands/`
    -   [ ] `speckit.analyze.toml`: Update command usage and examples.
    -   [ ] `speckit.checklist.toml`: Update command usage and examples.
    -   [ ] `speckit.clarify.toml`: Update command usage and examples.
    -   [ ] `speckit.constitution.toml`: Review for any hardcoded paths or commands.
    -   [ ] `speckit.implement.toml`: Update command usage and examples.
    -   [ ] `speckit.plan.toml`: Update command usage and examples.
    -   [ ] `speckit.specify.toml`: Update the main command definition, description, and examples to match the new format.
    -   [ ] `speckit.tasks.toml`: Update command usage and examples.

### 3.4. `.github` Agent Prompts

-   **Prompts:** `/mnt/rz1_main_pool/VinhLTT_stored/0_personal/awesome-agents/.github/prompts/`
    -   [ ] `speckit.analyze.prompt.md`: Update command usage and examples.
    -   [ ] `speckit.checklist.prompt.md`: Update command usage and examples.
    -   [ ] `speckit.clarify.prompt.md`: Update command usage and examples.
    -   [ ] `speckit.constitution.prompt.md`: Review for any hardcoded paths or commands.
    -   [ ] `speckit.implement.prompt.md`: Update command usage and examples.
    -   [ ] `speckit.plan.prompt.md`: Update command usage and examples.
    -   [ ] `speckit.specify.prompt.md`: Update the main command definition, description, and examples to match the new format.
    -   [ ] `speckit.tasks.prompt.md`: Update command usage and examples.

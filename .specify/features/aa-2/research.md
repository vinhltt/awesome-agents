# Research: Unit Test Generation Command Flow

**Feature**: aa-2
**Date**: 2025-11-14
**Purpose**: Research findings to inform implementation decisions for the unit test generation workflow

**Key Clarification**: Following SpecKit's philosophy, this feature uses a **prompt-based AI workflow** approach. The AI agent (Claude) handles all intelligent operations through detailed prompts. No custom implementation code is required.

---

## 1. Implementation Approach

### Decision: Prompt-Based AI Workflow (Pure SpecKit Pattern)

**Rationale**: Following GitHub SpecKit's philosophy of AI-powered workflows, this feature leverages the AI agent's native capabilities for code analysis and generation rather than building custom parsers and generators.

**Approach**:
- **Slash command prompts** in `.claude/commands/ut/` provide detailed instructions to the AI agent
- **Bash wrapper scripts** in `.specify/scripts/bash/` handle command dispatch and basic file I/O
- **AI agent (Claude)** performs all intelligent operations:
  - Code analysis (identifying test gaps)
  - Framework detection (inspecting project files)
  - Test generation (creating syntactically correct tests)
  - Quality review (analyzing test completeness)
  - Test execution analysis (interpreting results)

**Alternatives Considered**:
- **Option A: Custom Implementation** - Build AST parsers, code generators, framework plugins in JavaScript/Python
  - **Rejected**: High complexity (130 tasks), long timeline (10-12 weeks), maintenance burden
- **Option B: Prompt-Based (CHOSEN)** - Use AI agent capabilities through prompts
  - **Selected**: Simpler (45 tasks), faster (2-3 weeks), more flexible, easier to maintain
- **Option C: Hybrid** - Minimal scripts + AI agent
  - **Rejected**: Added complexity without significant benefit over pure prompt approach

**Benefits of Chosen Approach**:
1. **Simplicity**: No code to write/debug/maintain - only prompts and bash scripts
2. **Flexibility**: AI agent adapts to any language/framework automatically
3. **Speed**: 2-3 weeks vs 10-12 weeks implementation time (75% faster)
4. **Maintainability**: Prompts easier to update than code
5. **Alignment**: Follows SpecKit's "AI-powered workflow" philosophy
6. **Zero Dependencies**: No npm packages, no Python libraries to install

---

## 2. Test Framework Support

### Decision: AI Agent Adaptive Detection (No Framework-Specific Code)

**Rationale**: The AI agent can analyze project files and adapt to any test framework without custom code for each framework.

**Frameworks to Support** (via AI prompts):
- **JavaScript/TypeScript**: Jest, Vitest, Mocha, Jasmine
- **Python**: Pytest, unittest, nose2
- **Future**: Java (JUnit), C# (NUnit), Go (testing), Rust (cargo test)

**Detection Strategy** (implemented via prompt instructions):
1. AI agent inspects `package.json` (for JS) or `pyproject.toml` (for Python)
2. Identifies test dependencies
3. Adapts test generation to detected framework syntax
4. Falls back to user question if framework unknown

**Template Examples** (optional reference):
- Located in `.specify/ut-templates/`
- Provide example test patterns the AI can reference
- Not required - AI has built-in knowledge of test patterns
- Maintained as Markdown files for easy updates

---

## 3. Command Workflow Architecture

### Decision: Sequential Workflow with Status Tracking

**Rationale**: Tests need structured progression from specification to execution, with ability to resume mid-workflow.

**Command Sequence**:
```
/ut.specify    → Creates test specification (test-spec.md)
/ut.analyze    → Analyzes code for test gaps (coverage-report.json)
/ut.plan       → Creates implementation plan (test-plan.md)
/ut.generate   → Generates actual test code (test files in project)
/ut.review     → Reviews generated tests for quality (review-report.md)
/ut.run        → Executes tests and analyzes results (execution-results.json)
```

**Status Tracking** (cross-workflow):
```
/speckit.status → Shows progress for any workflow (SpecKit default or UT)
```

**Research Sources**:
- GitHub SpecKit default workflow pattern (`/speckit.specify` → `/speckit.plan` → `/speckit.tasks`)
- CLI best practices from clig.dev (WebFetch: https://clig.dev)
- AI agent workflow patterns from Anthropic documentation

**Workflow Design Principles**:
1. **Independence**: Each command can run standalone (though logical sequence exists)
2. **Idempotency**: Re-running commands updates artifacts rather than failing
3. **Checkpoints**: Clear artifact outputs at each stage
4. **Human-in-loop**: Developer can review/modify between steps
5. **Resumable**: `/speckit.status` enables workflow resumption after interruption

---

## 4. Artifact Storage and Format

### Decision: File-Based Markdown + JSON Outputs

**Rationale**: Follows SpecKit pattern of storing workflow artifacts in `.specify/features/{feature-id}/` directory.

**Artifact Structure**:
```
.specify/features/{feature-id}/
├── spec.md                    # Feature specification (from /speckit.specify)
├── test-spec.md               # Test specification (from /ut.specify)
├── coverage-report.json       # Analysis results (from /ut.analyze)
├── test-plan.md               # Implementation plan (from /ut.plan)
├── review-report.md           # Quality review (from /ut.review)
└── execution-results.json     # Test run results (from /ut.run)
```

**Generated Tests Location**:
```
tests/                         # or __tests__/ - project convention
├── unit/
│   ├── feature-a.test.js     # Generated by /ut.generate
│   └── feature-b.test.py
└── integration/
```

**Format Choices**:
- **Markdown (.md)**: Human-readable specifications, plans, reviews
- **JSON (.json)**: Structured data for programmatic processing (coverage, results)
- **Test files**: Native format for detected framework (.test.js, .test.ts, test_*.py, etc.)

---

## 5. Bash Script Responsibilities

### Decision: Minimal Bash Scripts for Dispatch Only

**Rationale**: Bash scripts should handle only command-line interface and file operations, leaving all intelligence to AI agent prompts.

**Bash Script Scope** (for each `/ut.*` command):
1. **Argument parsing**: Extract feature-id, options, flags
2. **Path resolution**: Locate feature directory, artifacts
3. **File reading**: Load input artifacts (spec.md, etc.) to pass to AI agent
4. **File writing**: Save AI agent output to appropriate files
5. **Command dispatch**: Invoke appropriate slash command prompt

**Bash Script Does NOT Do**:
- ❌ Code analysis or parsing
- ❌ Test generation logic
- ❌ Framework detection logic
- ❌ Quality analysis
- ❌ Any intelligent decision making

**Example Bash Script Structure**:
```bash
#!/bin/bash
# .specify/scripts/bash/ut-specify.sh

# 1. Parse arguments
FEATURE_ID="$1"
FEATURE_DIR=".specify/features/${FEATURE_ID}"
SPEC_FILE="${FEATURE_DIR}/spec.md"

# 2. Validate inputs
[[ -f "$SPEC_FILE" ]] || { echo "Error: spec.md not found"; exit 1; }

# 3. Invoke slash command (AI agent handles logic)
# The AI agent prompt reads spec.md and generates test-spec.md
claude-code /ut.specify "$FEATURE_ID"

# 4. Confirm output created
[[ -f "${FEATURE_DIR}/test-spec.md" ]] && echo "✅ Test specification created"
```

---

## 6. Cross-Workflow Status Command

### Decision: Unified `/speckit.status` for All Workflows

**Rationale**: Developers need a single command to check progress regardless of which workflow they're using (SpecKit default or UT generation).

**Status Command Capabilities**:
1. **Detect workflow type**: Check which artifacts exist to determine active workflow
2. **Show completed steps**: List commands that have been executed
3. **Display artifacts**: Show existing files with timestamps
4. **Suggest next action**: Recommend next command based on progress
5. **Identify issues**: Flag missing or corrupted artifacts

**Implementation via Prompt**:
- Single prompt file: `.claude/commands/speckit/status.md`
- AI agent analyzes `.specify/features/{feature-id}/` contents
- Generates human-readable status report
- Works for both SpecKit and UT workflows automatically

**Example Status Output**:
```
📊 Feature: aa-2 (Unit Test Generation Command Flow)
Branch: features/aa-2

✅ Completed Steps:
  1. /speckit.specify - spec.md (2025-11-14 10:00)
  2. /speckit.plan - plan.md (2025-11-14 10:30)
  3. /ut.specify - test-spec.md (2025-11-14 11:00)
  4. /ut.analyze - coverage-report.json (2025-11-14 11:30)

📄 Artifacts:
  - spec.md (6.2 KB)
  - plan.md (8.1 KB)
  - test-spec.md (4.5 KB)
  - coverage-report.json (2.1 KB)

➡️  Next Step:
  Run: /ut.plan aa-2
  This will create a test implementation plan based on your spec and analysis.
```

---

## 7. Quality Assurance Strategy

### Decision: AI-Powered Review with Prompt-Defined Criteria

**Rationale**: AI agent can perform sophisticated quality analysis when given clear criteria in prompts.

**Review Dimensions** (defined in `/ut.review` prompt):
1. **Completeness**: All functions/methods have corresponding tests
2. **Assertion Quality**: Tests verify actual behavior, not just execution
3. **Edge Cases**: Boundary conditions and error scenarios covered
4. **Best Practices**: Framework conventions followed (describe/it structure, etc.)
5. **Mocking Appropriateness**: External dependencies properly isolated
6. **Maintainability**: Tests are readable and well-organized

**Review Process**:
1. `/ut.review` command reads generated test files
2. AI agent evaluates against criteria from prompt
3. Generates `review-report.md` with:
   - Overall quality score
   - Specific issues identified
   - Improvement recommendations
   - Code examples for fixes

**No Custom Linting Code Required**: AI agent understands test quality patterns through prompt instructions.

---

## 8. Performance and Scalability Considerations

### Decision: AI Agent Performance is Sufficient for Typical Projects

**Rationale**: For typical feature sizes (10-15 functions), AI agent analysis and generation completes within acceptable timeframes.

**Performance Targets** (from SC-008):
- Test generation for 10-15 functions: < 10 minutes
- Code analysis: < 30 seconds for typical module
- Test review: < 1 minute per test file

**Scalability Strategy**:
- Process files in batches if needed (handled in prompts)
- Focus on changed files only (AI agent can identify delta)
- User can specify scope (--include, --exclude flags)

**Large Codebase Handling**:
- AI agent can analyze incrementally (one module at a time)
- Status tracking allows pause/resume for long operations
- Prompt instructions include strategies for large-scale analysis

---

## 9. Error Handling and User Guidance

### Decision: Prompt-Based Error Recovery and User Assistance

**Rationale**: AI agent can provide contextual help and recovery suggestions when issues occur.

**Error Scenarios Addressed**:
1. **Missing dependencies**: AI detects and suggests installation
2. **Invalid syntax**: AI identifies and suggests corrections
3. **Test failures**: AI analyzes errors and recommends fixes
4. **Incomplete specifications**: AI requests clarifications
5. **Framework detection failures**: AI falls back to user questions

**User Guidance Strategy**:
- Clear error messages in AI agent output
- Actionable next steps provided
- Context-aware suggestions based on workflow state
- Links to documentation when appropriate

---

## 10. Integration with Existing SpecKit Infrastructure

### Decision: Extend SpecKit Pattern, Don't Replace It

**Rationale**: UT generation is an additional workflow that complements SpecKit's default feature development workflow.

**Integration Points**:
1. **Shared infrastructure**: Uses same `.specify/` directory structure
2. **Consistent patterns**: Commands follow `/namespace.action` format
3. **Cross-workflow status**: `/speckit.status` works for both workflows
4. **Compatible artifacts**: All outputs use Markdown/JSON like SpecKit

**SpecKit Default Workflow** (unchanged):
```
/speckit.specify → spec.md
/speckit.clarify → updated spec.md
/speckit.plan → plan.md, research.md, data-model.md, contracts/, quickstart.md
/speckit.tasks → tasks.md
/speckit.implement → (executes tasks)
```

**UT Workflow** (new, complementary):
```
/ut.specify → test-spec.md
/ut.analyze → coverage-report.json
/ut.plan → test-plan.md
/ut.generate → test files in project
/ut.review → review-report.md
/ut.run → execution-results.json
```

**Workflow Relationship**:
- UT workflow can start after SpecKit `/speckit.specify` creates spec.md
- Or UT workflow can run independently on existing code
- Both workflows tracked by shared `/speckit.status` command

---

## Summary of Key Decisions

| Decision Area | Choice | Rationale |
|---------------|--------|-----------|
| **Implementation Approach** | Prompt-based AI workflow | Simpler, faster, more maintainable than custom code |
| **Framework Support** | AI adaptive detection | No framework-specific code needed |
| **Workflow Architecture** | Sequential with checkpoints | Clear progression, resumable |
| **Artifact Storage** | File-based (Markdown + JSON) | Follows SpecKit pattern |
| **Bash Script Scope** | Dispatch only, no logic | Keep complexity in prompts, not scripts |
| **Status Tracking** | Unified `/speckit.status` | Single command works for all workflows |
| **Quality Assurance** | AI-powered review | Sophisticated analysis without custom tools |
| **Performance** | AI agent native speed | Sufficient for typical projects |
| **Error Handling** | Contextual AI guidance | Better UX than rigid error codes |
| **SpecKit Integration** | Extend, don't replace | Complementary workflow |

**Implementation Complexity**:
- **Tasks**: 45 (down from 130 in original plan)
- **Timeline**: 2-3 weeks (down from 10-12 weeks)
- **Dependencies**: Zero (no npm/pip packages needed)
- **Code to maintain**: Prompts + bash scripts only

**Next Phase**: Use these decisions to create data-model.md, contracts/, and quickstart.md in Phase 1.

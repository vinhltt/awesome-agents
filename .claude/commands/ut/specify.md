# /ut.specify - Create Unit Test Specification

## Purpose

Generate a comprehensive test specification document that defines what needs to be tested for a feature. This specification will guide test implementation by identifying testable units, test scenarios, coverage goals, and mocking requirements.

## Input

- **Feature ID**: Required argument (e.g., `aa-2`)
- **Feature Spec**: Reads from `.specify/features/{feature-id}/spec.md`
- **Optional**: Existing test-spec.md for updates

## Output

Creates or updates `.specify/features/{feature-id}/test-spec.md` with:

1. **Metadata**: Feature reference, timestamps, version, status
2. **Test Scenarios**: Prioritized test scenarios with test cases
3. **Coverage Goals**: Target coverage percentage, critical paths, edge cases
4. **Mocking Needs**: External services, databases, file system dependencies
5. **Test Data Requirements**: Input/output examples, fixtures needed
6. **Constraints**: Timeouts, resource limits, environment requirements

## Execution Instructions

### Step 1: Validate Input

1. Check that feature spec exists at `.specify/features/{feature-id}/spec.md`
2. If missing, respond: "Feature specification not found. Please run `/speckit.specify {feature-id}` first."
3. If spec exists but incomplete, warn user and ask to proceed or complete spec first

### Step 2: Load Test Specification Template

1. Read the template from `.specify/templates/test-spec-template.md`
2. Use this template structure to ensure consistency across all features
3. Template provides:
   - Standardized section headings and format
   - Quality checklist built-in
   - Example structures for test scenarios
   - Guidance comments for each section

### Step 3: Analyze Feature Specification

Read and extract from spec.md:

- **Functional Requirements (FR-*)**: Each requirement becomes a test scenario
- **User Stories**: Each story's acceptance criteria become test cases
- **Edge Cases**: Listed edge cases become specific test scenarios
- **Key Entities**: Entities define data structures to test
- **Success Criteria**: Measurable outcomes become coverage goals

### Step 4: Generate Test Scenarios

For each functional requirement and user story:

1. **Create Test Scenario**:
   - Scenario ID: `TS-{number}` (e.g., TS-001)
   - Description: What aspect of the feature is being tested
   - Priority: Based on user story priority (P1-P6)

2. **Generate Test Cases**:
   - Test ID: `TC-{number}` (e.g., TC-001)
   - Description: Specific test case name
   - Given/When/Then: BDD-style test definition
   - Expected Input/Output: Data structures
   - Edge Cases: Boundary conditions

### Step 5: Identify Coverage Goals

1. **Calculate Target Coverage**:
   - Critical features (P1-P2 user stories): 90%+ coverage
   - Important features (P3-P4): 80%+ coverage
   - Nice-to-have (P5-P6): 70%+ coverage

2. **List Critical Paths**: Happy paths from user stories
3. **List Edge Cases**: From spec.md edge cases section + inferred boundary conditions

### Step 6: Determine Mocking Needs

Analyze functional requirements for:

- **External Services**: APIs, third-party services mentioned
- **Databases**: Data persistence requirements
- **File System**: File I/O operations
- **Time/Date**: Time-dependent logic
- **Network**: HTTP requests, WebSockets

For each dependency:
- Name: What is being mocked
- Type: service | database | filesystem | time | network
- Reason: Why mocking is needed
- Strategy: How to mock (stub, spy, full mock)

### Step 7: Format Output Document

Using the template from `.specify/templates/test-spec-template.md`, populate it with generated content:

1. **Replace placeholders**: Fill in feature name, date, feature-id, etc.
2. **Map requirements**: Link each TS-### to corresponding FR-### from spec.md
3. **Add independent test descriptions**: For each scenario, describe how it can be tested independently
4. **Populate test cases**: Generate TC-### with Given/When/Then format
5. **Include quality checklist**: Auto-generate checklist validation at end of document

The template structure is:

```markdown
# Test Specification: {Feature Name}

**Feature**: {feature-id}
**Created**: {date}
**Version**: 1.0.0
**Status**: Draft

## Source

- Feature Spec: `.specify/features/{feature-id}/spec.md`
- Code Modules: {list source files if known, or "TBD"}

## Test Scenarios

### TS-001: {Scenario Description} (Priority: P1)

**What**: Testing {functional requirement}

#### Test Cases

##### TC-001: {Test case description}

- **Given**: {Initial state}
- **When**: {Action performed}
- **Then**: {Expected outcome}
- **Input**: `{example input data}`
- **Output**: `{expected output data}`
- **Edge Cases**: {boundary conditions}

{Repeat for all test cases in scenario}

{Repeat for all scenarios}

## Coverage Goals

- **Target Coverage**: 80% (adjust based on priorities)
- **Critical Paths**:
  1. {Happy path 1}
  2. {Happy path 2}
- **Edge Cases to Cover**:
  1. {Edge case 1}
  2. {Edge case 2}

## Mocking Requirements

### External Services

- **{Service Name}**: {Mocking strategy and reason}

### Database

- **{Database operations}**: {Mocking strategy}

### File System

- **{File operations}**: {Mocking strategy}

## Test Data Requirements

### Fixtures

- **{Fixture name}**: {Description of test data needed}

### Sample Inputs/Outputs

```{language}
// Example test data structures
```

## Constraints

- **Timeouts**: {Any time-sensitive operations}
- **Environment**: {Special environment requirements}
- **Dependencies**: {Test framework, mocking libraries}

## Notes

{Any additional testing considerations}
```

### Step 8: Generate Quality Checklist Validation

After generating test-spec.md, automatically create a validation checklist at:
`.specify/features/{feature-id}/checklists/test-requirements.md`

This checklist should include:

```markdown
# Test Specification Quality Checklist

**Feature**: {feature-id}
**Created**: {date}
**Status**: Pending Validation

## Completeness

- [ ] All functional requirements (FR-###) have corresponding test scenarios (TS-###)
- [ ] All user stories have test cases covering acceptance criteria
- [ ] Edge cases from spec.md are included in test scenarios
- [ ] All test scenarios have priority assigned (P1/P2/P3)
- [ ] Critical paths are clearly documented

## Quality

- [ ] Mocking needs are identified for all external dependencies
- [ ] Coverage goals are realistic and measurable (70-90% range)
- [ ] Test IDs are unique and sequential (no gaps or duplicates)
- [ ] Given/When/Then format is used consistently across all test cases
- [ ] Sample inputs/outputs are provided for complex data structures

## Clarity

- [ ] Each test scenario has "Maps to" section linking to FR-###
- [ ] Each test scenario has "Independent Test" description
- [ ] No [NEEDS TEST CLARIFICATION] markers remain in the document
- [ ] Mocking strategies are clearly defined

## Validation Result

**Score**: __/13 items completed

**Status**: 
- ✅ Pass: 13/13 items checked
- ⚠️ Needs Review: 10-12/13 items checked
- ❌ Incomplete: <10/13 items checked

**Notes**: [Add validation notes here]
```

### Step 9: Handle Existing Test Spec

If `test-spec.md` already exists:

1. Read existing content
2. Ask user: "Test specification already exists. Options:
   - **Update**: Merge new scenarios with existing (recommended)
   - **Replace**: Create fresh specification
   - **Cancel**: Keep existing unchanged"
3. Wait for user response
4. If Update: Preserve existing test IDs, add new scenarios with next available IDs
5. If Replace: Generate completely new specification

### Step 10: Write Output

1. Create or update `.specify/features/{feature-id}/test-spec.md`
2. Create validation checklist at `.specify/features/{feature-id}/checklists/test-requirements.md`
3. Confirm success with summary:
   ```
   ✅ Test specification created at .specify/features/{feature-id}/test-spec.md
   ✅ Quality checklist created at .specify/features/{feature-id}/checklists/test-requirements.md
   
   Summary:
   - {X} test scenarios generated (TS-001 to TS-{X})
   - {Y} test cases defined (TC-001 to TC-{Y})
   - Target coverage: {Z}%
   - Mocking requirements: {count} dependencies identified
   
   Next step: Run /ut.analyze {feature-id} to identify test coverage gaps
   ```

## Quality Checklist

Before finalizing test-spec.md, verify:

- [ ] All functional requirements have corresponding test scenarios
- [ ] All user stories have test cases covering acceptance criteria
- [ ] Edge cases from spec.md are included
- [ ] Mocking needs are identified for all external dependencies
- [ ] Coverage goals are realistic and measurable
- [ ] Test IDs are unique and sequential
- [ ] Given/When/Then format is used consistently
- [ ] Sample inputs/outputs are provided for complex data structures

## Example Usage

```bash
# Create test specification for feature aa-2
/ut.specify aa-2

# Output:
# Analyzing feature specification...
# Generating test scenarios for 6 user stories...
# Identified 24 test cases across 12 scenarios
# ✅ Test specification created at .specify/features/aa-2/test-spec.md
#
# Next step: Run /ut.analyze aa-2 to identify test coverage gaps
```

## Error Handling

- **Missing spec.md**: Prompt user to run `/speckit.specify` first
- **Malformed spec.md**: Report specific issues found, ask user to fix
- **Empty spec.md**: Cannot generate test spec, requires functional requirements
- **Write permission issues**: Report error, suggest checking file permissions

## Notes

- This is a **prompt-based workflow** - no custom code execution
- AI agent performs all analysis and generation
- Generated test-spec.md is a **planning document**, not executable tests
- Subsequent commands (`/ut.analyze`, `/ut.plan`, `/ut.generate`) will use this spec

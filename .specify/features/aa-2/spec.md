# Feature Specification: Unit Test Generation Command Flow

**Feature Branch**: `features/aa-2`  
**Created**: 2025-11-14  
**Status**: Draft  
**Input**: User description: "tôi muốn tào ra 1 flow tập hợp các command để build 1 flow cho ai agent để create UT tương tự cách github speckit làm nhưng các command này sẽ chuyên biệt cho việc tạo unit test cho project.nó sẽ kế thừa lại /speckit.specify. sau khi run speckit.specify thì ta có thể run tiếp các comamnd tiếp theo để cho ra kết quả UT."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initiate Unit Test Specification (Priority: P1)

A developer wants to generate comprehensive unit tests for a feature. They start by creating a test specification that inherits the structure from the existing SpecKit workflow, defining what needs to be tested and the expected test coverage.

**Why this priority**: This is the foundation of the entire workflow. Without a clear test specification, subsequent commands cannot generate accurate or comprehensive tests. This establishes the "what to test" baseline.

**Independent Test**: Can be fully tested by running the command with a feature specification and verifying that a complete test specification document is created with test scenarios, coverage requirements, and test case definitions.

**Acceptance Scenarios**:

1. **Given** a completed feature specification exists, **When** developer runs the test specification command, **Then** a test specification document is created with identified testable units, test scenarios, and coverage goals
2. **Given** an incomplete or missing feature specification, **When** developer runs the test specification command, **Then** system prompts developer to complete feature specification first or provides guidance on creating test spec independently
3. **Given** a test specification already exists, **When** developer runs the command again, **Then** system offers to update existing specification or create a new version

---

### User Story 2 - Analyze Codebase for Test Gaps (Priority: P2)

A developer wants to identify which parts of their codebase lack unit tests or have insufficient coverage. The system analyzes the codebase and generates a report showing functions, methods, and modules that need testing.

**Why this priority**: This provides visibility into current test coverage and helps prioritize test creation efforts. It's essential for ensuring comprehensive testing but can be done after establishing the test specification framework.

**Independent Test**: Can be fully tested by running the analysis command on a sample codebase and verifying that it correctly identifies untested code, existing test patterns, and coverage gaps with accurate reporting.

**Acceptance Scenarios**:

1. **Given** a codebase with mixed test coverage, **When** developer runs the analysis command, **Then** system generates a report showing functions without tests, coverage percentages, and priority recommendations
2. **Given** a codebase with existing tests, **When** analysis runs, **Then** system identifies test patterns, frameworks in use, and suggests consistent testing approaches
3. **Given** analysis results, **When** developer reviews the report, **Then** system highlights critical paths and high-risk areas requiring immediate test coverage

---

### User Story 3 - Generate Test Implementation Plan (Priority: P3)

A developer needs a structured plan for implementing the unit tests. The system creates a detailed implementation plan including test file structure, test suite organization, mocking strategies, and execution order.

**Why this priority**: This provides the roadmap for test implementation. While important for organized test development, it can be created after understanding what to test and where gaps exist.

**Independent Test**: Can be fully tested by providing test specifications and receiving a detailed implementation plan that includes file structure, test organization, mocking approach, and step-by-step implementation tasks.

**Acceptance Scenarios**:

1. **Given** a test specification document, **When** developer runs the planning command, **Then** system generates an implementation plan with test file locations, suite structure, and task breakdown
2. **Given** existing project test conventions, **When** planning runs, **Then** system follows project patterns for test organization and naming
3. **Given** complex dependencies in code, **When** planning runs, **Then** system identifies mocking requirements and suggests isolation strategies

---

### User Story 4 - Generate Unit Test Code (Priority: P4)

A developer wants to generate actual unit test code based on the test specification and implementation plan. The system creates test files with test cases, assertions, mocks, and fixtures following project conventions.

**Why this priority**: This is the execution phase that produces the actual test code. It depends on all previous steps to generate accurate and well-structured tests.

**Independent Test**: Can be fully tested by running the generation command and verifying that syntactically correct, executable test code is created with proper test cases, assertions, and mocking based on the specification.

**Acceptance Scenarios**:

1. **Given** a test implementation plan, **When** developer runs the generation command, **Then** system creates test files with test cases, setup/teardown code, and assertions
2. **Given** project uses specific test framework, **When** generation runs, **Then** system generates tests using the correct framework syntax and conventions
3. **Given** complex test scenarios with mocking needs, **When** generation runs, **Then** system creates appropriate mocks, stubs, and test fixtures
4. **Given** multiple test files to generate, **When** generation runs, **Then** system organizes tests logically and maintains consistency across files

---

### User Story 5 - Review and Validate Generated Tests (Priority: P5)

A developer wants to review generated tests for quality, completeness, and best practices before committing them. The system analyzes the generated tests and provides feedback on coverage, assertions, edge cases, and code quality.

**Why this priority**: This ensures quality of generated tests but happens after test generation. It's a validation step that improves test quality but isn't blocking for the basic workflow.

**Independent Test**: Can be fully tested by running the review command on generated test code and verifying that it correctly identifies issues, suggests improvements, and validates test completeness.

**Acceptance Scenarios**:

1. **Given** newly generated test code, **When** developer runs the review command, **Then** system analyzes tests for completeness, assertion quality, and best practices
2. **Given** test code with missing edge cases, **When** review runs, **Then** system identifies gaps and suggests additional test cases
3. **Given** test code with quality issues, **When** review runs, **Then** system provides specific recommendations for improvement with code examples
4. **Given** review feedback, **When** developer makes changes, **Then** system can re-validate and confirm improvements

---

### User Story 6 - Execute Tests and Analyze Results (Priority: P6)

A developer wants to run the generated tests and understand the results. The system executes the tests, reports pass/fail status, and provides insights on failures or performance issues.

**Why this priority**: This is the final validation step that confirms tests work correctly. While essential, it's the last step in the workflow after all tests are generated and reviewed.

**Independent Test**: Can be fully tested by running the execution command and verifying that tests run correctly, results are accurately reported, and actionable feedback is provided for any failures.

**Acceptance Scenarios**:

1. **Given** generated unit tests, **When** developer runs the execution command, **Then** system runs all tests and reports pass/fail status with detailed output
2. **Given** test failures occur, **When** execution completes, **Then** system provides clear error messages, stack traces, and suggestions for fixes
3. **Given** test execution results, **When** developer reviews them, **Then** system highlights coverage achieved, execution time, and performance bottlenecks
4. **Given** test failures, **When** developer fixes issues, **Then** system can re-run tests and track improvement over iterations

---

### User Story 7 - Track Workflow Progress (Priority: P2)

A developer working on any SpecKit workflow (default or UT generation) needs to stop mid-workflow and resume later. They want to quickly see what steps have been completed, what artifacts exist, and what the next action should be.

**Why this priority**: Essential for workflow resumption and developer productivity. Without progress tracking, developers must manually check files to understand where they left off. This is critical for real-world usage where work is interrupted. This is a **cross-workflow feature** that benefits both SpecKit default and UT workflows.

**Independent Test**: Can be fully tested by running commands in sequence, then running `/speckit.status` to verify it correctly identifies completed steps for both workflows and suggests next actions.

**Acceptance Scenarios**:

1. **Given** a partially completed UT workflow, **When** developer runs `/speckit.status`, **Then** system shows which UT commands have been executed, which artifacts exist (test-spec.md, coverage-report.json, etc.), and suggests the next logical command to run
2. **Given** a partially completed SpecKit default workflow, **When** developer runs `/speckit.status`, **Then** system shows which SpecKit commands have been executed (specify, plan, tasks) and suggests next command
3. **Given** no workflow has started, **When** developer runs `/speckit.status`, **Then** system indicates this is a fresh start and suggests beginning with appropriate command
4. **Given** workflow is complete through test generation, **When** developer runs `/speckit.status` in UT context, **Then** system shows completed steps and suggests running `/ut.review` or `/ut.run`
5. **Given** some artifacts are missing or corrupted, **When** developer runs `/speckit.status`, **Then** system identifies the issues and suggests regenerating specific artifacts

---

### Edge Cases

- What happens when the feature specification is incomplete or ambiguous?
- How does the system handle codebases with multiple programming languages or test frameworks?
- What if existing tests conflict with generated tests?
- How does the system handle large codebases where analysis would be time-consuming?
- What happens when the codebase uses uncommon or custom test patterns?
- How does the system handle private or protected methods that need testing?
- What if dependencies or external services need mocking but aren't easily mockable?
- How does the system handle asynchronous code or time-dependent tests?
- What happens when test generation fails or produces invalid code?
- How does the system handle updates to existing tests when code changes?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a command to create unit test specifications that inherit structure from feature specifications
- **FR-002**: System MUST analyze codebase to identify functions, methods, and modules lacking unit test coverage
- **FR-003**: System MUST detect existing test frameworks and patterns in the project
- **FR-004**: System MUST generate test implementation plans including file structure, test organization, and mocking strategies
- **FR-005**: System MUST generate executable unit test code following project conventions and test framework syntax
- **FR-006**: System MUST detect and support test frameworks currently in use by the client project, automatically adapting to the project's testing infrastructure (e.g., Jest, PyTest, JUnit, NUnit, Mocha, Vitest, etc.); when unsupported frameworks are detected, system MUST research available options and suggest appropriate test generation approaches to the user
- **FR-007**: System MUST create appropriate mocks, stubs, and fixtures based on code dependencies
- **FR-008**: System MUST include setup and teardown code in generated tests
- **FR-009**: System MUST generate assertions based on expected behavior defined in specifications
- **FR-010**: System MUST review generated tests for completeness, quality, and best practices
- **FR-011**: System MUST identify missing edge cases and boundary conditions in test coverage
- **FR-012**: System MUST execute generated tests and report results with pass/fail status
- **FR-013**: System MUST provide actionable feedback for test failures including error messages and suggestions
- **FR-014**: System MUST track test coverage metrics and report on coverage gaps
- **FR-015**: System MUST maintain consistency with existing project test patterns and naming conventions
- **FR-016**: System MUST detect and adapt to programming languages used in the client project, automatically supporting the project's technology stack; when encountering unsupported languages or testing patterns, system MUST research available testing libraries and suggest appropriate solutions to the user
- **FR-017**: System MUST allow developers to customize test generation templates and patterns
- **FR-018**: System MUST integrate with the existing SpecKit command workflow
- **FR-019**: System MUST provide a unified `/speckit.status` command that works across all workflows (SpecKit default and UT), showing workflow progress, completed steps, existing artifacts, and suggesting next actions for workflow resumption

### Key Entities

- **Test Specification**: Defines what needs to be tested, including test scenarios, coverage requirements, test cases, expected inputs/outputs, and mocking needs for a specific feature or module
- **Test Analysis Report**: Contains information about untested code, coverage gaps, existing test patterns, test framework detection results, and priority recommendations for test creation
- **Test Implementation Plan**: Describes the test suite structure, file organization, test execution order, mocking strategy, test data requirements, and step-by-step implementation tasks
- **Generated Test Code**: The actual unit test files containing test cases, assertions, mocks, fixtures, setup/teardown code, and test documentation
- **Test Review Results**: Quality assessment of generated tests including completeness scores, identified gaps, best practice violations, suggested improvements, and validation status
- **Test Execution Results**: Output from running tests including pass/fail counts, coverage metrics, error messages, stack traces, execution time, and performance data

## Command Naming Convention

All commands in this workflow use the `/ut` prefix (short for "unit test") for brevity and ease of use:

- **`/ut.specify`** - Create unit test specification
- **`/ut.analyze`** - Analyze codebase for test gaps
- **`/ut.plan`** - Generate test implementation plan
- **`/ut.generate`** - Generate unit test code
- **`/ut.review`** - Review and validate generated tests
- **`/ut.run`** - Execute tests and analyze results

**Cross-Workflow Command**:
- **`/speckit.status`** - Show workflow progress for any workflow (SpecKit default or UT), display completed steps, existing artifacts, and suggest next actions

This naming follows the SpecKit pattern (`/speckit.*`) while maintaining concise, memorable command names. The `/speckit.status` command is a shared utility that works across all workflow types.

## Assumptions

- **Assumption-001**: The system will analyze the client's codebase to detect programming languages, test frameworks, and testing patterns before generating tests
- **Assumption-002**: When the system encounters unfamiliar or unsupported frameworks/languages, it will leverage research capabilities to find appropriate testing approaches and present recommendations to the user
- **Assumption-003**: The system will maintain a knowledge base of common test frameworks and patterns that expands as it encounters new technologies
- **Assumption-004**: Users are willing to review and approve suggested approaches when their project uses uncommon or custom testing infrastructure
- **Assumption-005**: The system will prioritize adapting to existing project conventions over imposing standardized patterns

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can create a complete unit test specification from a feature specification in under 5 minutes
- **SC-002**: System accurately identifies at least 95% of functions and methods lacking unit test coverage
- **SC-003**: Generated unit tests achieve at least 80% code coverage for the target feature or module
- **SC-004**: Generated test code passes syntax validation and executes without manual modification in 90% of cases
- **SC-005**: Developers reduce time spent writing unit tests by 60% compared to manual test writing
- **SC-006**: Generated tests follow project conventions and match existing test patterns in 95% of cases
- **SC-007**: Test review identifies at least 3 improvement opportunities per generated test file on average
- **SC-008**: System generates tests for a typical feature (10-15 functions) in under 10 minutes
- **SC-009**: 85% of developers report that generated tests are production-ready with minimal modifications
- **SC-010**: Test execution correctly reports all pass/fail results with actionable feedback for 100% of failures

## Clarifications

### Session 2025-11-14

- Q: Where should the core implementation and templates be located in the repository structure? → A: No core implementation needed (prompt-based approach); templates in `.specify/ut-templates/`
- Q: What should the core implementation folder be named? → A: Not applicable - using prompt-based workflow instead of custom implementation
- Q: Do we need custom JavaScript/Python implementation files (AST parsers, code generators) or should we use AI agent prompt-based approach like SpecKit? → A: Prompt-based workflow only - no custom implementation files needed, AI agent handles code analysis and generation through detailed prompts
- Q: How can users track workflow progress when stopping mid-workflow and resuming later? → A: Use unified `/speckit.status` command that works for both SpecKit default workflow and UT workflow
- Q: Should template examples location be in docs/ or .specify/ folder? → A: `.specify/ut-templates/` (keeps templates closer to workflow artifacts)
- Q: Is the `docs/speckit-ut/` folder needed for documentation (README, CONTRIBUTING)? → A: No - documentation already exists in `.specify/features/aa-2/` (spec.md, quickstart.md, research.md, contracts/)

### Clarification 1: Implementation Approach (2025-11-14)

**Question**: Should this feature use custom implementation files (JS/Python parsers and generators in `docs/speckit-ut/`) or follow the pure prompt-based approach like GitHub SpecKit?

**Answer**: **Prompt-based workflow only**. Following SpecKit's philosophy, this feature will use:
- **Slash command prompts** in `.claude/commands/ut/` with detailed instructions
- **Bash wrapper scripts** in `.specify/scripts/bash/` for command dispatch and basic file operations
- **AI agent capabilities** for code analysis, test generation, and review
- **No custom implementation layer** - the AI agent directly analyzes source code and generates tests based on prompts

**Rationale**:
- Aligns with SpecKit's "AI-powered workflow" philosophy
- Simpler to maintain - prompts are easier to update than code
- Leverages Claude's native code analysis and generation capabilities
- Reduces complexity - no need for language-specific AST parsers
- More flexible - can adapt to new languages/frameworks without code changes

**Impact**:
- Remove all references to `docs/speckit-ut/src/` implementation files
- Remove tasks related to building parsers, generators, and analyzers
- Focus tasks on creating effective command prompts and bash wrappers
- Templates remain in `.specify/ut-templates/` as prompt examples for the AI agent
- Success criteria remain unchanged - AI agent can achieve same outcomes through prompts

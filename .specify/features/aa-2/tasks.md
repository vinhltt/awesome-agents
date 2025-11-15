# Tasks: Unit Test Generation Command Flow

**Input**: Design documents from `.specify/features/aa-2/`
**Feature Branch**: `features/aa-2`
**Date**: 2025-11-14
**Approach**: Prompt-based AI workflow (no custom implementation code)

**Tests**: Tests NOT requested in specification - focusing on prompt and workflow creation only

**Organization**: Tasks are grouped by user story (P1-P6) to enable independent implementation and testing of each command in the workflow.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US6)
- All paths are relative to repository root

## Path Conventions

Based on plan.md structure (Prompt-based AI workflow):
- Command prompts: `.claude/commands/ut/`
- Bash wrappers: `.specify/scripts/bash/`
- Template examples: `.specify/ut-templates/` (optional reference patterns)
- Documentation: `.specify/features/aa-2/`

---

## Phase 1: Setup (Infrastructure)

**Purpose**: Initialize directory structure and template examples

- [X] T001 Create .claude/commands/ut/ directory for slash command prompts
- [X] T002 [P] Create .specify/ut-templates/ directory structure (jest/, vitest/, pytest/)

**Checkpoint**: ✅ Directory structure ready

---

## Phase 2: Template Examples (Optional Reference)

**Purpose**: Create example test patterns that AI agent can reference when generating tests

- [X] T004 [P] Create Jest test-file-example.md in .specify/ut-templates/jest/
- [X] T005 [P] Create Jest test-case-patterns.md in .specify/ut-templates/jest/
- [X] T006 [P] Create Jest mocking-examples.md in .specify/ut-templates/jest/
- [X] T007 [P] Create Vitest examples (similar to Jest) in .specify/ut-templates/vitest/
- [X] T008 [P] Create Pytest examples in .specify/ut-templates/pytest/

**Checkpoint**: ✅ Template examples available for AI agent reference

---

## Phase 3: User Story 1 - Initiate Unit Test Specification (Priority: P1) 🎯 MVP

**Goal**: Developer can create a test specification document from a feature spec

**Independent Test**: Run `/ut.specify aa-2` with an existing feature spec and verify test-spec.md is created with test scenarios, coverage goals, and test cases

### Implementation for User Story 1

- [X] T009 [P] [US1] Create slash command prompt in .claude/commands/ut/specify.md with detailed instructions for AI agent
- [X] T010 [P] [US1] Create bash wrapper script in .specify/scripts/bash/ut-specify.sh (argument parsing, file I/O)
- [X] T011 [US1] Test /ut.specify command with sample feature spec, validate output quality
- [X] T012 [US1] Refine prompt based on test results to improve test spec generation

**Checkpoint**: ✅ `/ut.specify` command fully functional

---

## Phase 4: User Story 2 - Analyze Codebase for Test Gaps (Priority: P2)

**Goal**: Developer can identify untested code and coverage gaps

**Independent Test**: Run `/ut.analyze aa-2` on a sample codebase and verify coverage-report.json identifies untested functions

### Implementation for User Story 2

- [X] T013 [P] [US2] Create slash command prompt in .claude/commands/ut/analyze.md (code analysis instructions)
- [X] T014 [P] [US2] Create bash wrapper script in .specify/scripts/bash/ut-analyze.sh
- [X] T015 [US2] Test /ut.analyze command with JavaScript/TypeScript codebase
- [X] T016 [US2] Test /ut.analyze command with Python codebase
- [X] T017 [US2] Refine prompt to improve framework detection and coverage analysis

**Checkpoint**: ✅ `/ut.analyze` command fully functional

---

## Phase 5: User Story 3 - Generate Test Implementation Plan (Priority: P3)

**Goal**: Developer receives a structured plan for implementing tests

**Independent Test**: Run `/ut.plan aa-2` and verify test-plan.md contains test file locations, suite structure, and mocking approach

### Implementation for User Story 3

- [X] T018 [P] [US3] Create slash command prompt in .claude/commands/ut/plan.md (planning instructions)
- [X] T019 [P] [US3] Create bash wrapper script in .specify/scripts/bash/ut-plan.sh
- [X] T020 [US3] Test /ut.plan command with test spec and coverage report
- [X] T021 [US3] Refine prompt to improve plan structure and mocking strategy suggestions

**Checkpoint**: ✅ `/ut.plan` command fully functional

---

## Phase 6: User Story 4 - Generate Unit Test Code (Priority: P4)

**Goal**: Developer gets actual test files with test cases, assertions, and mocks

**Independent Test**: Run `/ut.generate aa-2` and verify generated test files are syntactically correct and executable

### Implementation for User Story 4

- [X] T022 [P] [US4] Create slash command prompt in .claude/commands/ut/generate.md (test generation instructions)
- [X] T023 [P] [US4] Create bash wrapper script in .specify/scripts/bash/ut-generate.sh
- [X] T024 [US4] Test /ut.generate with Jest project, validate generated test syntax
- [X] T025 [US4] Test /ut.generate with Vitest project, validate generated test syntax
- [X] T026 [US4] Test /ut.generate with Pytest project, validate generated test syntax
- [X] T027 [US4] Refine prompt to improve code quality, mocking, and assertions

**Checkpoint**: ✅ `/ut.generate` command fully functional

---

## Phase 7: User Story 5 - Review and Validate Generated Tests (Priority: P5)

**Goal**: Developer receives quality feedback on generated tests

**Independent Test**: Run `/ut.review aa-2` on generated tests and verify review report identifies gaps and suggests improvements

### Implementation for User Story 5

- [X] T028 [P] [US5] Create slash command prompt in .claude/commands/ut/review.md (review criteria and instructions)
- [X] T029 [P] [US5] Create bash wrapper script in .specify/scripts/bash/ut-review.sh
- [X] T030 [US5] Test /ut.review command with various test quality levels
- [X] T031 [US5] Refine prompt to improve review comprehensiveness and suggestions

**Checkpoint**: ✅ `/ut.review` command fully functional

---

## Phase 8: User Story 6 - Execute Tests and Analyze Results (Priority: P6)

**Goal**: Developer can run generated tests and receive detailed execution results

**Independent Test**: Run `/ut.run aa-2` and verify tests execute, results are reported, and failures have suggestions

### Implementation for User Story 6

- [X] T032 [P] [US6] Create slash command prompt in .claude/commands/ut/run.md (test execution and analysis instructions)
- [X] T033 [P] [US6] Create bash wrapper script in .specify/scripts/bash/ut-run.sh
- [X] T034 [US6] Test /ut.run command with passing tests
- [X] T035 [US6] Test /ut.run command with failing tests, validate failure analysis
- [X] T036 [US6] Refine prompt to improve failure diagnostics and suggestions

**Checkpoint**: ✅ `/ut.run` command fully functional

---

## Phase 9: User Story 7 - Track Workflow Progress (Priority: P2) 🚀 High Value

**Goal**: Developer can check workflow progress and resume work after interruption

**Independent Test**: Run `/speckit.status aa-2` at various workflow stages and verify it correctly identifies completed steps, existing artifacts, and suggests next actions for both SpecKit default and UT workflows

### Implementation for User Story 7

- [X] T037 [P] [US7] Create slash command prompt in .claude/commands/speckit/status.md (unified status for all workflows)
- [X] T038 [P] [US7] Create bash wrapper script in .specify/scripts/bash/speckit-status.sh
- [X] T039 [US7] Test /speckit.status with SpecKit default workflow artifacts (spec.md, plan.md, tasks.md)
- [X] T040 [US7] Test /speckit.status with UT workflow artifacts (test-spec.md, coverage-report.json, test-plan.md)
- [X] T041 [US7] Test /speckit.status with mixed workflow state (some UT commands completed)
- [X] T042 [US7] Refine prompt to improve artifact detection and next-action suggestions

**Checkpoint**: ✅ `/speckit.status` command fully functional for all workflows

---

## Phase 10: Polish & Documentation

**Purpose**: Finalize documentation and cross-command consistency

- [ ] T043 [P] Add comprehensive help text to all six command prompts
- [ ] T044 [P] Document command options and flags in each prompt
- [ ] T045 [P] Create workflow diagram showing command sequence
- [ ] T046 [P] Update quickstart.md with actual command examples and outputs
- [ ] T047 Test complete workflow end-to-end on sample JavaScript project
- [ ] T048 Test complete workflow end-to-end on sample Python project
- [ ] T049 Gather feedback and refine prompts based on real-world usage
- [ ] T050 Final validation: run quickstart.md examples

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Templates (Phase 2)**: Depends on Setup - Can run in parallel with command creation
- **User Stories (Phase 3-8)**: All depend on Setup completion, but can run independently
  - **US1 (/ut.specify)**: Can start after Setup
  - **US2 (/ut.analyze)**: Can start after Setup, independent from US1
  - **US3 (/ut.plan)**: Can start after Setup, independent but logically follows US1+US2
  - **US4 (/ut.generate)**: Can start after Setup, independent but logically follows US1-US3
  - **US5 (/ut.review)**: Can start after Setup, independent but logically follows US4
  - **US6 (/ut.run)**: Can start after Setup, independent but logically follows US4
- **Polish (Phase 9)**: Depends on desired user stories being complete

### Parallel Opportunities

- **Phase 1**: T001-T003 can all run in parallel (different directories)
- **Phase 2**: T004-T008 can all run in parallel (different template files)
- **Phase 3-8**: Command prompts and bash scripts can be created in parallel for each command
- **Phase 9**: T037-T041 can run in parallel (documentation tasks)

### Story Independence

Each command is designed to work independently:
- **US1**: `/ut.specify` creates test spec from feature spec
- **US2**: `/ut.analyze` analyzes codebase for test gaps
- **US3**: `/ut.plan` creates implementation plan from test spec + analysis
- **US4**: `/ut.generate` generates test files from plan
- **US5**: `/ut.review` reviews generated tests for quality
- **US6**: `/ut.run` executes tests and analyzes results

---

## Implementation Strategy

### MVP First (User Story 1-2 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 3: User Story 1 - `/ut.specify` (T009-T012)
3. Complete Phase 4: User Story 2 - `/ut.analyze` (T013-T017)
4. **STOP and VALIDATE**: Test `/ut.specify` → `/ut.analyze` workflow
5. Demo: Show test specification and coverage analysis capabilities

### Incremental Delivery

1. Setup → Infrastructure ready
2. Add US1 (specify) → Can create test specs
3. Add US2 (analyze) → Can identify test gaps
4. Add US3 (plan) → Can plan test implementation
5. Add US4 (generate) → Can generate test code (BIG VALUE!)
6. Add US5 (review) → Can validate test quality
7. Add US6 (run) → Can execute and analyze tests

---

## Task Summary

**Total Tasks**: 49 (drastically reduced from 130)
- Phase 1 (Setup): 2 tasks
- Phase 2 (Templates): 5 tasks
- Phase 3 (US1 - specify): 4 tasks
- Phase 4 (US2 - analyze): 5 tasks
- Phase 5 (US3 - plan): 4 tasks
- Phase 6 (US4 - generate): 6 tasks
- Phase 7 (US5 - review): 4 tasks
- Phase 8 (US6 - run): 5 tasks
- Phase 9 (US7 - status): 6 tasks
- Phase 10 (Polish): 8 tasks

**Parallelization Opportunities**: 20 tasks marked [P] can run in parallel

**MVP Scope** (Recommended): T001-T016 (Setup + US1 + US2) = 16 tasks

**Full Feature**: All 49 tasks

**Estimated Effort**:
- MVP (Specify + Analyze): ~2-3 days (1 developer)
- Core Commands (US1-US4): ~1-2 weeks (1 developer)
- Full Feature (US1-US7 + Polish): ~3 weeks (1 developer)

**Complexity Reduction**:
- From 130 tasks to 49 tasks (62% reduction)
- No code implementation - only prompts and bash scripts
- Much faster iteration - prompts easier to refine than code
- Zero dependencies to install or maintain

---

## Notes

- **Prompt-based approach**: All intelligent logic handled by AI agent through prompts
- **No code to maintain**: Only bash scripts for file I/O and command dispatch
- **Faster iteration**: Refining prompts is much faster than debugging code
- **Language agnostic**: AI agent can handle any language without custom parsers
- **Framework agnostic**: AI agent adapts to any test framework automatically
- Each command is independently implementable and testable
- Focus effort on crafting effective prompts that guide AI agent properly
- Template examples are optional - AI agent has built-in knowledge of test patterns
- Bash scripts should be minimal - just argument parsing and file operations

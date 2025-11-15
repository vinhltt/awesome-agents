# Command Interface Contract

**Feature**: aa-2  
**Date**: 2025-11-14  
**Purpose**: Define the interface contract for all `/ut.*` commands

---

## Overview

This document specifies the interface contract that all unit test generation commands must implement. Commands follow a consistent pattern for invocation, input, output, and error handling.

---

## General Command Pattern

### Invocation Syntax

```bash
/ut.<action> [options] [arguments]
```

**Components**:
- `/ut` - Fixed prefix for all unit test commands
- `<action>` - Command-specific action (specify, analyze, plan, generate, review, run)
- `[options]` - Optional flags (e.g., --json, --verbose, --dry-run)
- `[arguments]` - Command-specific arguments

### Standard Options

All commands MUST support these standard options:

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--help` | `-h` | Display command help | N/A |
| `--version` | `-v` | Display command version | N/A |
| `--json` | `-j` | Output in JSON format | false |
| `--verbose` | `-V` | Verbose output | false |
| `--dry-run` | `-d` | Simulate without making changes | false |
| `--feature` | `-f` | Specify feature ID | current |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Precondition failed |
| 4 | Validation failed |
| 5 | External dependency error |

---

## Command Specifications

### 1. `/ut.specify` - Create Test Specification

**Purpose**: Generate a test specification document from a feature specification.

**Signature**:
```bash
/ut.specify [options] <feature-id> [source-files...]
```

**Arguments**:
- `<feature-id>` - Feature identifier (e.g., "aa-2") [REQUIRED]
- `[source-files...]` - Specific source files to test [OPTIONAL]

**Options**:
- `--template <path>` - Custom test spec template
- `--coverage-target <percentage>` - Target coverage (default: 80%)
- `--include-integration` - Include integration test scenarios

**Input**:
- Feature specification (.specify/features/{feature-id}/spec.md)
- Source code files (optional)

**Output**:
```json
{
  "success": true,
  "testSpec": ".specify/features/{feature-id}/test-spec.md",
  "testCases": 12,
  "coverageTarget": 80,
  "warnings": []
}
```

**Error Conditions**:
- Feature spec not found (exit 3)
- Invalid coverage target (exit 2)
- Template parsing error (exit 4)

**Example**:
```bash
# Basic usage
/ut.specify aa-2

# With specific source files
/ut.specify aa-2 src/test-generator.js src/analyzer.js

# Custom coverage target
/ut.specify aa-2 --coverage-target 90 --json
```

---

### 2. `/ut.analyze` - Analyze Codebase for Test Gaps

**Purpose**: Scan codebase to identify untested code and coverage gaps.

**Signature**:
```bash
/ut.analyze [options] <feature-id> [scope]
```

**Arguments**:
- `<feature-id>` - Feature identifier [REQUIRED]
- `[scope]` - Analysis scope: `feature` | `module` | `project` (default: feature)

**Options**:
- `--exclude <patterns>` - Exclude file patterns (glob)
- `--include <patterns>` - Include only matching patterns
- `--frameworks <list>` - Detect specific frameworks (comma-separated)
- `--min-complexity <n>` - Minimum complexity threshold (default: 5)

**Input**:
- Test specification (.specify/features/{feature-id}/test-spec.md)
- Source code files
- Existing test files (if any)

**Output**:
```json
{
  "success": true,
  "report": ".specify/features/{feature-id}/coverage-report.json",
  "summary": {
    "untestedFunctions": 15,
    "untestedClasses": 3,
    "overallCoverage": 45,
    "detectedFramework": "jest"
  },
  "criticalGaps": 5
}
```

**Error Conditions**:
- Test spec not found (exit 3)
- Source files not accessible (exit 5)
- Framework detection failed (warning, not error)

**Example**:
```bash
# Analyze feature code
/ut.analyze aa-2

# Analyze entire project
/ut.analyze aa-2 project --exclude "**/*.spec.js"

# Target specific frameworks
/ut.analyze aa-2 --frameworks jest,vitest --min-complexity 10
```

---

### 3. `/ut.plan` - Generate Test Implementation Plan

**Purpose**: Create a detailed plan for implementing unit tests.

**Signature**:
```bash
/ut.plan [options] <feature-id>
```

**Arguments**:
- `<feature-id>` - Feature identifier [REQUIRED]

**Options**:
- `--organization <type>` - Test organization: `by_feature` | `by_type` | `by_module`
- `--mocking <strategy>` - Mocking strategy: `manual` | `automatic` | `hybrid`
- `--parallel` - Plan for parallel test execution
- `--template <path>` - Custom plan template

**Input**:
- Test specification
- Coverage analysis report

**Output**:
```json
{
  "success": true,
  "plan": ".specify/features/{feature-id}/test-plan.md",
  "testFiles": 8,
  "mockFiles": 4,
  "estimatedTests": 45,
  "estimatedEffort": "4-6 hours"
}
```

**Error Conditions**:
- Analysis report not found (exit 3)
- Invalid organization type (exit 2)
- Template errors (exit 4)

**Example**:
```bash
# Generate plan with defaults
/ut.plan aa-2

# Custom organization and mocking
/ut.plan aa-2 --organization by_type --mocking automatic

# Plan for parallel execution
/ut.plan aa-2 --parallel --json
```

---

### 4. `/ut.generate` - Generate Unit Test Code

**Purpose**: Generate actual test files based on the implementation plan.

**Signature**:
```bash
/ut.generate [options] <feature-id> [targets...]
```

**Arguments**:
- `<feature-id>` - Feature identifier [REQUIRED]
- `[targets...]` - Specific files/modules to generate tests for [OPTIONAL]

**Options**:
- `--framework <name>` - Force specific framework (overrides detection)
- `--overwrite` - Overwrite existing test files
- `--template-dir <path>` - Custom template directory
- `--ast` - Use AST-based generation (default)
- `--template` - Use template-based generation

**Input**:
- Test implementation plan
- Source code files
- Test templates (optional)

**Output**:
```json
{
  "success": true,
  "generated": [
    {
      "file": "tests/unit/test-generator.test.js",
      "testCases": 12,
      "assertions": 28,
      "mocks": 3
    },
    {
      "file": "tests/unit/analyzer.test.js",
      "testCases": 8,
      "assertions": 15,
      "mocks": 2
    }
  ],
  "summary": {
    "filesGenerated": 2,
    "totalTests": 20,
    "totalAssertions": 43,
    "estimatedCoverage": 82
  },
  "warnings": []
}
```

**Error Conditions**:
- Plan not found (exit 3)
- Framework not supported (exit 5)
- Syntax generation errors (exit 4)
- File write permission errors (exit 1)

**Example**:
```bash
# Generate all tests
/ut.generate aa-2

# Generate for specific modules
/ut.generate aa-2 src/test-generator.js

# Force framework and overwrite
/ut.generate aa-2 --framework jest --overwrite

# Dry run to preview
/ut.generate aa-2 --dry-run --verbose
```

---

### 5. `/ut.review` - Review and Validate Generated Tests

**Purpose**: Analyze generated tests for quality, completeness, and best practices.

**Signature**:
```bash
/ut.review [options] <feature-id> [test-files...]
```

**Arguments**:
- `<feature-id>` - Feature identifier [REQUIRED]
- `[test-files...]` - Specific test files to review [OPTIONAL]

**Options**:
- `--strict` - Apply stricter quality rules
- `--min-score <n>` - Minimum acceptable quality score (0-100)
- `--fix` - Auto-fix issues where possible
- `--rules <path>` - Custom review rules file

**Input**:
- Generated test files
- Test specification
- Project test conventions

**Output**:
```json
{
  "success": true,
  "report": ".specify/features/{feature-id}/test-review.md",
  "summary": {
    "filesReviewed": 8,
    "overallScore": 87,
    "criticalIssues": 0,
    "warnings": 5,
    "suggestions": 12
  },
  "passesThreshold": true,
  "fixableIssues": 3
}
```

**Error Conditions**:
- No test files found (exit 3)
- Quality score below threshold (exit 4)
- Syntax errors in tests (exit 4)

**Example**:
```bash
# Review all generated tests
/ut.review aa-2

# Review specific files with strict rules
/ut.review aa-2 tests/unit/generator.test.js --strict

# Auto-fix issues
/ut.review aa-2 --fix --min-score 90
```

---

### 6. `/ut.run` - Execute Tests and Analyze Results

**Purpose**: Run the generated tests and provide detailed results.

**Signature**:
```bash
/ut.run [options] <feature-id> [test-pattern]
```

**Arguments**:
- `<feature-id>` - Feature identifier [REQUIRED]
- `[test-pattern]` - Test file pattern (glob) [OPTIONAL]

**Options**:
- `--watch` - Run in watch mode
- `--coverage` - Generate coverage report
- `--parallel` - Run tests in parallel
- `--bail` - Stop on first failure
- `--reporter <type>` - Reporter: `default` | `verbose` | `json` | `junit`

**Input**:
- Generated test files
- Test configuration

**Output**:
```json
{
  "success": true,
  "results": ".specify/features/{feature-id}/test-execution.json",
  "summary": {
    "total": 45,
    "passed": 43,
    "failed": 2,
    "skipped": 0,
    "duration": 2847,
    "coverage": {
      "statements": 84,
      "branches": 79,
      "functions": 88,
      "lines": 83
    }
  },
  "failures": [
    {
      "test": "test-generator.test.js › should handle edge cases",
      "error": "Expected 'value' but got 'undefined'"
    }
  ]
}
```

**Error Conditions**:
- No tests found (exit 3)
- Test execution failed (exit 1)
- Coverage below target (warning, not error)

**Example**:
```bash
# Run all tests
/ut.run aa-2

# Run with coverage
/ut.run aa-2 --coverage

# Run specific tests in watch mode
/ut.run aa-2 "**/*.test.js" --watch

# Parallel execution with JSON output
/ut.run aa-2 --parallel --reporter json
```

---

## Common Patterns

### Progress Reporting

All long-running commands (>2 seconds) MUST display progress:

```
Running analysis...
├─ Scanning source files... 15/45 (33%)
├─ Detecting test framework... ✓
├─ Analyzing coverage gaps... ████████░░ 80%
└─ Generating report... ✓

Analysis complete! (3.2s)
```

### Error Messages

Error messages MUST be actionable and human-friendly:

```
❌ Error: Test specification not found

Expected file: .specify/features/aa-2/test-spec.md

Did you mean to run '/ut.specify aa-2' first?

For help: /ut.specify --help
```

### Validation

Commands MUST validate inputs before processing:

```bash
# Example validation sequence
1. Check feature ID format
2. Verify required files exist
3. Validate option values
4. Check dependencies available
5. Proceed with execution
```

---

## Workflow Integration

Commands are designed to chain together:

```bash
# Sequential workflow
/ut.specify aa-2
/ut.analyze aa-2
/ut.plan aa-2
/ut.generate aa-2
/ut.review aa-2
/ut.run aa-2

# Conditional chaining (future enhancement)
/ut.specify aa-2 && \
/ut.analyze aa-2 && \
/ut.plan aa-2 && \
/ut.generate aa-2 && \
/ut.review aa-2 --min-score 85 && \
/ut.run aa-2 --coverage
```

---

## Extensibility

### Plugin Interface

Commands support plugins for framework-specific behavior:

```javascript
// Plugin interface (conceptual)
interface TestFrameworkPlugin {
  name: string;
  detect(project): boolean;
  generateTest(spec, options): TestCode;
  runTests(files, options): TestResults;
}
```

### Custom Templates

Users can provide custom templates:

```bash
/ut.generate aa-2 --template-dir .specify/templates/custom-tests
```

Template structure:
```
templates/
├── test-file.template
├── test-case.template
├── mock.template
└── fixture.template
```

---

## Contract Status

**Version**: 1.0.0  
**Status**: ✅ Defined  
**Ready for**: Implementation  
**Next Step**: Generate quickstart.md

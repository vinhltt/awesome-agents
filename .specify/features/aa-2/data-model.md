# Data Model: Unit Test Generation Command Flow

**Feature**: aa-2  
**Date**: 2025-11-14  
**Purpose**: Define key entities and their relationships for the unit test generation workflow

---

## Overview

This document defines the data structures and entities used throughout the unit test generation workflow. Each entity corresponds to artifacts created by the `/ut.*` commands and aligns with the Key Entities defined in spec.md.

---

## Entity Definitions

### 1. Test Specification

**Description**: Defines what needs to be tested for a specific feature or module.

**Created By**: `/ut.specify` command  
**Consumed By**: `/ut.analyze`, `/ut.plan`  
**File Format**: Markdown (.md)

**Schema**:

```yaml
TestSpecification:
  metadata:
    featureId: string          # Reference to feature (e.g., "aa-2")
    featureName: string        # Name of feature being tested
    createdDate: datetime      # When spec was created
    lastModified: datetime     # Last update timestamp
    version: string            # Spec version (e.g., "1.0.0")
    status: enum               # draft | approved | implemented
    
  source:
    featureSpec: path          # Path to feature spec.md
    codeModules: array<path>   # Source files to be tested
    dependencies: array<string># External dependencies
    
  testScenarios:
    - scenarioId: string       # Unique identifier (e.g., "TS-001")
      description: string      # What is being tested
      priority: enum           # P1 | P2 | P3 | P4
      testCases: array<TestCase>
      
  coverageGoals:
    targetCoverage: percentage # e.g., 80%
    criticalPaths: array<string>
    edgeCases: array<string>
    
  mockingNeeds:
    externalServices: array<MockRequirement>
    databases: array<MockRequirement>
    fileSystem: array<MockRequirement>
    
  constraints:
    timeouts: array<TimeoutConstraint>
    resourceLimits: array<ResourceLimit>
```

**TestCase Sub-Entity**:
```yaml
TestCase:
  testId: string               # Unique identifier (e.g., "TC-001")
  description: string          # Test case description
  given: string                # Initial state/preconditions
  when: string                 # Action performed
  then: string                 # Expected outcome
  expectedInput: any           # Input data structure
  expectedOutput: any          # Output data structure
  edgeCases: array<string>     # Edge conditions to test
```

**MockRequirement Sub-Entity**:
```yaml
MockRequirement:
  name: string                 # What is being mocked
  type: enum                   # service | database | filesystem | module
  behavior: string             # Expected mock behavior
  returnValues: array<any>     # Possible return values
```

**Relationships**:
- References: Feature Specification (spec.md)
- Used By: Test Analysis Report, Test Implementation Plan

---

### 2. Test Analysis Report

**Description**: Contains information about untested code, coverage gaps, and testing priorities.

**Created By**: `/ut.analyze` command  
**Consumed By**: `/ut.plan`, `/ut.generate`  
**File Format**: JSON (.json)

**Schema**:

```json
{
  "metadata": {
    "featureId": "string",
    "analyzedDate": "datetime",
    "analyzer": "string",        // Tool/command version
    "projectPath": "path"
  },
  
  "detectedFrameworks": [
    {
      "language": "string",      // javascript | python | java | csharp
      "framework": "string",     // jest | pytest | junit | nunit
      "version": "string",
      "configFile": "path",
      "confidence": "percentage"
    }
  ],
  
  "untestedCode": [
    {
      "filePath": "path",
      "type": "enum",            // function | class | method | module
      "name": "string",
      "lineStart": "number",
      "lineEnd": "number",
      "complexity": "number",    // Cyclomatic complexity
      "priority": "enum",        // critical | high | medium | low
      "reason": "string"         // Why it's prioritized
    }
  ],
  
  "coverageGaps": {
    "overall": {
      "statementCoverage": "percentage",
      "branchCoverage": "percentage",
      "functionCoverage": "percentage",
      "lineCoverage": "percentage"
    },
    "byFile": [
      {
        "filePath": "path",
        "coverage": {
          "statements": "percentage",
          "branches": "percentage",
          "functions": "percentage",
          "lines": "percentage"
        },
        "uncoveredLines": ["array<number>"],
        "uncoveredBranches": ["array<number>"]
      }
    ]
  },
  
  "existingTestPatterns": [
    {
      "pattern": "string",       // describe/it, test functions, etc.
      "framework": "string",
      "frequency": "number",
      "examples": ["array<path>"]
    }
  ],
  
  "recommendations": [
    {
      "priority": "number",
      "category": "enum",        // coverage | edge_cases | mocking | performance
      "description": "string",
      "affectedFiles": ["array<path>"],
      "estimatedEffort": "enum"  // low | medium | high
    }
  ],
  
  "dependencies": {
    "external": [
      {
        "name": "string",
        "type": "enum",          // npm | pip | maven | nuget
        "version": "string",
        "mockable": "boolean",
        "mockStrategy": "string"
      }
    ],
    "internal": [
      {
        "modulePath": "path",
        "importedBy": ["array<path>"],
        "mockable": "boolean"
      }
    ]
  }
}
```

**Relationships**:
- References: Test Specification, Source Code
- Used By: Test Implementation Plan

---

### 3. Test Implementation Plan

**Description**: Describes the test suite structure, file organization, and implementation strategy.

**Created By**: `/ut.plan` command  
**Consumed By**: `/ut.generate`  
**File Format**: Markdown (.md)

**Schema**:

```yaml
TestImplementationPlan:
  metadata:
    featureId: string
    planDate: datetime
    basedOn: array<path>       # Spec and analysis files used
    approvalStatus: enum       # pending | approved | rejected
    
  testStructure:
    rootDirectory: path        # e.g., "tests/" or "src/__tests__"
    organization: enum         # by_feature | by_type | by_module
    namingConvention: string   # Pattern for test file names
    
  testSuites:
    - suiteId: string
      name: string
      type: enum               # unit | integration | e2e
      targetFiles: array<path>
      testFiles: array<TestFileSpec>
      
  mockingStrategy:
    approach: enum             # manual | automatic | hybrid
    mockLocations: path        # e.g., "tests/__mocks__"
    mockFiles: array<MockFileSpec>
    
  testDataStrategy:
    approach: enum             # fixtures | factories | inline
    dataDirectory: path
    dataFiles: array<DataFileSpec>
    
  executionOrder:
    - phase: string
      suites: array<string>
      parallelizable: boolean
      
  implementationTasks:
    - taskId: string
      description: string
      type: enum               # setup | generate | review | execute
      estimatedTime: duration
      dependencies: array<string>
      assignedTo: string       # optional
```

**TestFileSpec Sub-Entity**:
```yaml
TestFileSpec:
  filePath: path               # Relative path to test file
  targetSource: path           # Source file being tested
  framework: string            # jest | pytest | etc.
  testCases: array<string>     # IDs from TestSpecification
  setupRequired: boolean
  teardownRequired: boolean
  mocks: array<string>         # Required mock names
  fixtures: array<string>      # Required fixture names
```

**MockFileSpec Sub-Entity**:
```yaml
MockFileSpec:
  filePath: path
  mockTarget: string           # What is being mocked
  mockType: enum               # module | service | database | filesystem
  implementation: string       # Description of mock behavior
```

**Relationships**:
- References: Test Specification, Test Analysis Report
- Used By: Test Code Generator

---

### 4. Generated Test Code

**Description**: The actual unit test files with test cases, assertions, mocks, and fixtures.

**Created By**: `/ut.generate` command  
**Consumed By**: `/ut.review`, `/ut.run`  
**File Format**: Source code (.js, .ts, .py, etc.)

**Metadata** (embedded in comments):

```javascript
/**
 * Test File Metadata
 * @feature aa-2
 * @generated-by /ut.generate
 * @generated-date 2025-11-14
 * @framework jest
 * @target src/module.js
 * @test-spec .specify/features/aa-2/test-spec.md
 * @test-cases TC-001, TC-002, TC-003
 */
```

**Structural Elements**:

```yaml
TestFile:
  imports:
    - source: path
      items: array<string>
      
  mocks:
    - type: enum               # jest.mock() | @patch | etc.
      target: string
      implementation: code
      
  fixtures:
    - name: string
      type: enum               # factory | data | setup
      implementation: code
      
  setupHooks:
    - type: enum               # beforeEach | beforeAll | setup
      implementation: code
      
  teardownHooks:
    - type: enum               # afterEach | afterAll | teardown
      implementation: code
      
  testSuites:
    - description: string
      tests: array<Test>
      
  testCases:
    - testId: string           # Maps to TestCase.testId
      description: string
      implementation: code
      assertions: array<Assertion>
```

**Assertion Entity**:
```yaml
Assertion:
  type: enum                   # expect | assert | should
  subject: string              # What is being tested
  matcher: string              # toBe | toEqual | toHaveBeenCalled
  expected: any                # Expected value
  message: string              # Optional failure message
```

**Relationships**:
- References: Test Implementation Plan, Test Specification
- Used By: Test Review Results, Test Execution Results

---

### 5. Test Review Results

**Description**: Quality assessment of generated tests with improvement suggestions.

**Created By**: `/ut.review` command  
**Consumed By**: User, `/ut.generate` (for iterative improvement)  
**File Format**: Markdown (.md) + JSON (.json)

**Schema**:

```json
{
  "metadata": {
    "featureId": "string",
    "reviewDate": "datetime",
    "reviewer": "string",      // automated | manual | hybrid
    "testFilesReviewed": "number"
  },
  
  "overallScore": {
    "completeness": "percentage",
    "quality": "percentage",
    "bestPractices": "percentage",
    "coverage": "percentage",
    "overall": "percentage"
  },
  
  "fileReviews": [
    {
      "filePath": "path",
      "scores": {
        "completeness": "percentage",
        "assertionQuality": "percentage",
        "mockingQuality": "percentage",
        "edgeCaseCoverage": "percentage"
      },
      "issues": [
        {
          "issueId": "string",
          "severity": "enum",    // critical | warning | suggestion
          "category": "enum",    // assertion | mocking | coverage | style
          "line": "number",
          "description": "string",
          "suggestion": "string",
          "example": "code"
        }
      ],
      "strengths": ["array<string>"],
      "improvementOpportunities": ["array<ImprovementSuggestion>"]
    }
  ],
  
  "missingTests": [
    {
      "testCaseId": "string",
      "description": "string",
      "reason": "string",
      "priority": "enum"
    }
  ],
  
  "bestPracticeViolations": [
    {
      "rule": "string",
      "violations": "number",
      "examples": ["array<FileLocation>"]
    }
  ],
  
  "recommendations": [
    {
      "priority": "number",
      "category": "string",
      "action": "string",
      "rationale": "string",
      "estimatedEffort": "enum"
    }
  ],
  
  "validationStatus": {
    "syntaxValid": "boolean",
    "executable": "boolean",
    "frameworkCompliant": "boolean",
    "conventionsFollowed": "boolean"
  }
}
```

**ImprovementSuggestion Sub-Entity**:
```json
{
  "type": "enum",              // add_test | improve_assertion | add_mock | refactor
  "description": "string",
  "currentCode": "string",
  "suggestedCode": "string",
  "benefit": "string"
}
```

**Relationships**:
- References: Generated Test Code, Test Specification
- Used By: User (for manual review), Test Generator (for iteration)

---

### 6. Test Execution Results

**Description**: Output from running tests including pass/fail status and metrics.

**Created By**: `/ut.run` command  
**Consumed By**: User, `/ut.review` (for feedback loop)  
**File Format**: JSON (.json)

**Schema**:

```json
{
  "metadata": {
    "featureId": "string",
    "executionDate": "datetime",
    "framework": "string",
    "command": "string",       // Actual command executed
    "environment": {
      "os": "string",
      "runtime": "string",     // node v18.0.0 | python 3.11
      "ci": "boolean"
    }
  },
  
  "summary": {
    "totalTests": "number",
    "passed": "number",
    "failed": "number",
    "skipped": "number",
    "duration": "milliseconds",
    "successRate": "percentage"
  },
  
  "coverage": {
    "statements": {
      "total": "number",
      "covered": "number",
      "percentage": "percentage"
    },
    "branches": {
      "total": "number",
      "covered": "number",
      "percentage": "percentage"
    },
    "functions": {
      "total": "number",
      "covered": "number",
      "percentage": "percentage"
    },
    "lines": {
      "total": "number",
      "covered": "number",
      "percentage": "percentage"
    }
  },
  
  "testResults": [
    {
      "testFile": "path",
      "suite": "string",
      "testName": "string",
      "status": "enum",        // passed | failed | skipped | pending
      "duration": "milliseconds",
      "error": {              // If failed
        "message": "string",
        "type": "string",
        "stackTrace": "string",
        "expected": "any",
        "actual": "any"
      },
      "output": ["array<string>"]  // console.log output
    }
  ],
  
  "failures": [
    {
      "testFile": "path",
      "testName": "string",
      "errorMessage": "string",
      "stackTrace": "string",
      "suggestion": "string",  // Auto-generated fix suggestion
      "similarFailures": "number"
    }
  ],
  
  "performance": {
    "slowestTests": [
      {
        "testName": "string",
        "duration": "milliseconds",
        "file": "path"
      }
    ],
    "averageDuration": "milliseconds",
    "medianDuration": "milliseconds"
  },
  
  "coverageGaps": [
    {
      "file": "path",
      "uncoveredLines": ["array<number>"],
      "uncoveredBranches": ["array<number>"],
      "severity": "enum"
    }
  ],
  
  "recommendations": [
    {
      "type": "enum",          // fix_failure | improve_coverage | optimize_speed
      "description": "string",
      "action": "string",
      "priority": "enum"
    }
  ]
}
```

**Relationships**:
- References: Generated Test Code
- Used By: User (for debugging), Test Review (for quality feedback)

---

## Entity Relationships Diagram

```
┌─────────────────────────────────────────────────────────┐
│ Feature Specification (spec.md)                         │
│ [Created by /speckit.specify]                           │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ references
                   ▼
         ┌─────────────────────┐
         │ Test Specification  │◄──────────┐
         │ [/ut.specify]       │           │
         └──────────┬──────────┘           │
                    │                      │
                    │ consumed by          │ used for iteration
                    ▼                      │
         ┌─────────────────────┐           │
         │ Test Analysis       │           │
         │ Report              │           │
         │ [/ut.analyze]       │           │
         └──────────┬──────────┘           │
                    │                      │
                    │ consumed by          │
                    ▼                      │
         ┌─────────────────────┐           │
         │ Test Implementation │           │
         │ Plan                │           │
         │ [/ut.plan]          │           │
         └──────────┬──────────┘           │
                    │                      │
                    │ consumed by          │
                    ▼                      │
         ┌─────────────────────┐           │
         │ Generated Test Code │           │
         │ [/ut.generate]      │◄──────────┤
         └──────────┬──────────┘           │
                    │                      │
                    │ consumed by          │
                    ▼                      │
         ┌─────────────────────┐           │
         │ Test Review Results │───────────┘
         │ [/ut.review]        │
         └──────────┬──────────┘
                    │
                    │ consumed by
                    ▼
         ┌─────────────────────┐
         │ Test Execution      │
         │ Results             │
         │ [/ut.run]           │
         └─────────────────────┘
```

---

## Data Storage and Persistence

### File Organization

```
.specify/features/aa-###/
├── test-spec.md              # Test Specification (markdown)
├── coverage-report.json      # Test Analysis Report (JSON)
├── test-plan.md              # Test Implementation Plan (markdown)
├── test-review.md            # Test Review Results (markdown)
├── test-review.json          # Test Review Results (JSON)
├── test-execution.json       # Test Execution Results (JSON)
└── tests/                    # Generated Test Code
    ├── unit/
    │   ├── module1.test.js
    │   └── module2.test.py
    ├── integration/
    └── __mocks__/            # Mock implementations
```

### Data Validation Rules

1. **Referential Integrity**:
   - Test Specification MUST reference valid feature spec
   - Test files MUST reference valid test cases from spec
   - All file paths MUST be relative to project root

2. **Versioning**:
   - All entities include creation/modification timestamps
   - Version numbers follow semver (major.minor.patch)
   - Backward compatibility maintained across versions

3. **Constraints**:
   - Test IDs MUST be unique within specification
   - Coverage percentages MUST be 0-100
   - Priorities MUST follow defined enum values
   - File paths MUST exist and be accessible

---

## Schema Evolution

### Version 1.0.0 (Current)
- Initial data model
- Support for JavaScript/TypeScript (Jest, Vitest)
- Support for Python (Pytest)

### Planned Enhancements (v2.0.0)
- Multi-language test specifications
- Distributed test execution results
- Historical test metrics tracking
- AI-generated test improvement suggestions

---

**Data Model Status**: ✅ Complete  
**Ready for**: Contract Definition  
**Next Step**: Generate contracts/

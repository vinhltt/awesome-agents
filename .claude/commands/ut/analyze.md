# /ut.analyze - Analyze Codebase for Test Gaps

## ⛔ CRITICAL: Error Handling

**If ANY script returns an error, you MUST:**
1. **STOP immediately** - Do NOT attempt workarounds or auto-fixes
2. **Report the error** - Show the exact error message to the user
3. **Wait for user** - Ask user how to proceed before taking any action

**DO NOT:**
- Try alternative approaches when scripts fail
- Create branches manually when script validation fails
- Guess or assume what the user wants after an error
- Continue with partial results

---

## Purpose

Analyze a codebase to identify untested code, detect existing test patterns, and generate a coverage report showing which functions, methods, and modules lack unit tests.

## Input

- **Feature ID**: **REQUIRED** argument (e.g., `pref-2`, `AL-991`, `test/pref-123`)
  - Format: `[folder/]prefix-number`
  - Prefix configured in `.specify/.speckit.env`
  - If missing: ERROR "Task ID required. Usage: /ut:analyze {task-id}"
- **Codebase Path**: Optional, defaults to repository root or project src/
- **Test Spec**: Reads from `.specify/features/{feature-id}/test-spec.md` (optional)

## Output

Creates `.specify/features/{feature-id}/coverage-report.json` with:

1. **Framework Detection**: Identified test frameworks and configurations
2. **Code Analysis**: List of all testable units (functions, methods, classes)
3. **Test Coverage**: Which units have tests, which don't
4. **Priority Recommendations**: High-priority untested code
5. **Existing Test Patterns**: Conventions found in existing tests

## Execution Instructions

### Step 0: Validate Task ID

**CRITICAL**: Check task ID argument FIRST before any operations.

1. **Parse user input**:
   - Extract first argument from command
   - Expected format: `[folder/]prefix-number` (e.g., `pref-991`, `AL-991`, `test/pref-123`)

2. **Check if task ID provided**:
   ```
   If first argument is EMPTY or MISSING:
     ERROR: "Task ID required. Usage: /ut:analyze {task-id}"
     STOP - Do NOT proceed to Step 1
   ```

3. **Validate task ID format**:
   - Must match pattern: `[folder/]prefix-number`
   - Prefix must be in `.specify/.speckit.env` SPECKIT_PREFIX_LIST
   - If invalid: ERROR "Invalid task ID format: '{input}'"

**Examples** (assuming prefix=pref):
- ✅ CORRECT: `/ut:analyze pref-991`
- ✅ CORRECT: `/ut:analyze AL-991`
- ✅ CORRECT: `/ut:analyze test/pref-123`
- ❌ WRONG: `/ut:analyze` (no task ID)
- ❌ WRONG: `/ut:analyze create analysis` (not a task ID)

### Step 1: Detect Programming Language

Analyze repository to identify primary languages:

1. **JavaScript/TypeScript**:
   - Check for `package.json`, `tsconfig.json`
   - Look for `.js`, `.ts`, `.jsx`, `.tsx` files
   - Common paths: `src/`, `lib/`, `app/`

2. **Python**:
   - Check for `pyproject.toml`, `setup.py`, `requirements.txt`
   - Look for `.py` files
   - Common paths: `src/`, `app/`, package directories

3. **Other Languages**:
   - Java: `pom.xml`, `build.gradle`, `.java` files
   - C#: `.csproj`, `.cs` files
   - Go: `go.mod`, `.go` files
   - Ruby: `Gemfile`, `.rb` files

### Step 2: Detect Test Framework

Based on detected language, identify test framework:

**JavaScript/TypeScript**:
- Jest: Check `package.json` for `"jest"` dependency or `jest.config.js`
- Vitest: Check for `"vitest"` dependency or `vitest.config.js`
- Mocha: Check for `"mocha"` dependency
- Jasmine: Check for `"jasmine"` dependency

**Python**:
- Pytest: Check for `"pytest"` in requirements or `pytest.ini`
- unittest: Python built-in (check for `test_*.py` or `*_test.py`)
- nose2: Check for `"nose2"` dependency

**Report findings**:
```json
{
  "detectedLanguages": ["TypeScript", "JavaScript"],
  "detectedFramework": {
    "name": "Jest",
    "version": "29.7.0",
    "configFile": "jest.config.js"
  }
}
```

### Step 3: Locate Source Files

Identify source code files to analyze:

1. **Common source directories**:
   - `src/`, `lib/`, `app/`, `components/`, `services/`
   - For Python: package directories, `src/`
   - For project root: any `.js`/`.ts`/`.py` files not in `node_modules/`, `venv/`, etc.

2. **Exclude**:
   - Test files (`*.test.*`, `*.spec.*`, `test_*`, `*_test.py`)
   - Build artifacts (`dist/`, `build/`, `__pycache__/`)
   - Dependencies (`node_modules/`, `venv/`, `vendor/`)
   - Configuration files

3. **Create inventory**:
```json
{
  "sourceFiles": [
    {
      "path": "src/calculator.ts",
      "language": "TypeScript",
      "size": 1234,
      "lastModified": "2025-11-14"
    }
  ]
}
```

### Step 4: Analyze Source Code for Testable Units

For each source file, identify testable units:

**JavaScript/TypeScript**:
- **Functions**: `function name()`, `const name = () =>`
- **Classes**: `class Name`, methods within classes
- **Exports**: `export function`, `export class`

**Python**:
- **Functions**: `def function_name():`
- **Classes**: `class ClassName:`, methods within classes
- **Modules**: Top-level module functions

**Extract**:
```json
{
  "testableUnits": [
    {
      "id": "unit-001",
      "type": "function",
      "name": "calculateTotal",
      "file": "src/calculator.ts",
      "lineNumber": 15,
      "complexity": "medium",
      "hasTests": false
    },
    {
      "id": "unit-002",
      "type": "class",
      "name": "ShoppingCart",
      "file": "src/cart.ts",
      "lineNumber": 5,
      "methods": ["add", "remove", "getTotal"],
      "hasTests": true,
      "testFile": "src/__tests__/cart.test.ts"
    }
  ]
}
```

### Step 5: Locate Existing Tests

Search for test files:

1. **Common test locations**:
   - `__tests__/`, `tests/`, `test/`
   - Co-located: Same directory as source with `.test.` or `.spec.`
   - Python: `test_*.py`, `*_test.py`

2. **Parse test files** to identify what's tested:
   - Jest/Vitest: `describe('ClassName')`, `it('should...')`
   - Pytest: `class TestClassName:`, `def test_*():`

3. **Match tests to source units**:
   - If test file `calculator.test.ts` exists → `calculator.ts` has tests
   - If `describe('ShoppingCart')` exists → `ShoppingCart` class has tests
   - Check for specific method tests within test suites

### Step 6: Calculate Coverage Status

For each testable unit:

```javascript
{
  "hasTests": boolean,           // Does any test exist for this unit?
  "coverage": "full" | "partial" | "none",
  "testFile": string | null,     // Path to test file
  "testedMethods": string[],     // For classes: which methods are tested
  "untestedMethods": string[],   // For classes: which methods lack tests
  "priority": "high" | "medium" | "low"  // Based on complexity + visibility
}
```

**Priority Logic**:
- **High**: Public API functions, exported classes, critical business logic
- **Medium**: Internal utilities, helper functions
- **Low**: Private methods, configuration code

### Step 7: Identify Test Patterns

Analyze existing tests to find patterns:

```json
{
  "testPatterns": {
    "namingConvention": "*.test.ts",
    "testLocation": "co-located",
    "describePattern": "ClassName",
    "itPattern": "should [verb] [expected outcome]",
    "setupTeardown": ["beforeEach", "afterEach"],
    "mockingLibrary": "@jest/globals",
    "assertionStyle": "expect()"
  }
}
```

### Step 8: Generate Coverage Report

Create comprehensive JSON report:

```json
{
  "metadata": {
    "featureId": "pref-2",
    "analyzedDate": "2025-11-14T10:30:00Z",
    "analyzer": "ut-analyze v1.0"
  },

  "environment": {
    "languages": ["TypeScript", "JavaScript"],
    "framework": {
      "name": "Jest",
      "version": "29.7.0"
    },
    "testDirectory": "__tests__/"
  },

  "summary": {
    "totalFiles": 15,
    "totalUnits": 45,
    "testedUnits": 28,
    "untestedUnits": 17,
    "coveragePercentage": 62.2,
    "highPriorityGaps": 5
  },

  "untestedUnits": [
    {
      "id": "unit-003",
      "name": "validateEmail",
      "type": "function",
      "file": "src/validators.ts",
      "line": 25,
      "priority": "high",
      "reason": "Public API function with no tests",
      "suggestedTests": [
        "should accept valid email format",
        "should reject invalid email format",
        "should handle edge cases (empty, null, special chars)"
      ]
    }
  ],

  "partiallyTestedUnits": [
    {
      "id": "unit-002",
      "name": "ShoppingCart",
      "type": "class",
      "file": "src/cart.ts",
      "testedMethods": ["add", "remove"],
      "untestedMethods": ["clear", "checkout"],
      "priority": "medium"
    }
  ],

  "testPatterns": {
    "namingConvention": "*.test.ts",
    "testLocation": "__tests__/",
    "mockingLibrary": "jest"
  },

  "recommendations": [
    "Add tests for 5 high-priority functions",
    "Complete tests for ShoppingCart.clear() and checkout()",
    "Consider integration tests for payment flow"
  ]
}
```

### Step 9: Write Output

1. Write JSON report to `.specify/features/{feature-id}/coverage-report.json`
2. Pretty-print summary to console:

```
🔍 Code Analysis Complete
========================

Environment:
  Language: TypeScript, JavaScript
  Framework: Jest 29.7.0

Summary:
  Total Files: 15
  Total Units: 45
  Tested: 28 (62%)
  Untested: 17 (38%)

High Priority Gaps: 5
  - validateEmail (src/validators.ts:25)
  - processPayment (src/payment.ts:45)
  - calculateTax (src/cart.ts:120)
  - exportData (src/export.ts:15)
  - hashPassword (src/auth.ts:80)

✅ Coverage report saved: .specify/features/pref-2/coverage-report.json

Next step: Run /ut.plan pref-2 to create test implementation plan
```

### Step 10: Handle Edge Cases

**No test framework detected**:
- Report: "No test framework detected. Please install Jest, Vitest, or Pytest."
- Suggest: Framework recommendations based on language
- Still generate coverage report but flag framework as "unknown"

**No source files found**:
- Report: "No source files found in expected locations"
- Ask user: "Where is your source code located?"
- Suggest: Common patterns for the project type

**Permission errors**:
- Report specific file/directory with permission issues
- Suggest: Check file permissions or run with appropriate access

## Quality Checklist

- [ ] All source files in src/ analyzed
- [ ] Test files correctly identified and excluded from analysis
- [ ] Framework detection accurate (checked config files)
- [ ] Priority assignments logical (public APIs marked high)
- [ ] Suggested test cases meaningful and specific
- [ ] JSON output valid and well-structured
- [ ] Console output readable and actionable

## Example Usage

```bash
# Analyze codebase for feature pref-2
/ut.analyze pref-2

# Output:
# Detecting programming language... TypeScript
# Detecting test framework... Jest 29.7.0
# Analyzing source files... 15 files found
# Identifying testable units... 45 units found
# Locating existing tests... 28 units have tests
#
# ✅ Coverage report saved: .specify/features/pref-2/coverage-report.json
# High priority gaps: 5 functions need tests
```

## Notes

- This is a **prompt-based workflow** - AI agent performs analysis
- No AST parsing libraries needed - AI understands code structure
- Framework detection via file inspection (package.json, config files)
- Analysis focuses on **unit-testable code** (functions, classes, methods)
- Coverage report is **input for `/ut.plan`** command

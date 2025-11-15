# Quickstart Guide: Unit Test Generation Workflow

**Feature**: aa-2  
**Date**: 2025-11-14  
**Purpose**: Get started with unit test generation in under 10 minutes

---

## What Is This?

The Unit Test Generation Command Flow is a set of AI-powered commands that help you create comprehensive unit tests for your codebase. It follows a structured workflow from specification to execution, similar to how SpecKit helps with feature development.

**Key Benefits**:
- ⚡ Generate tests 60% faster than manual writing
- 🎯 Achieve 80%+ code coverage automatically
- 🔍 Identify test gaps and prioritize coverage
- ✅ Follow framework best practices automatically
- 🔄 Integrated with existing SpecKit workflow

---

## Prerequisites

- Existing feature specification (created with `/speckit.specify`)
- Source code to test
- Test framework already configured in your project
  - JavaScript/TypeScript: Jest or Vitest
  - Python: Pytest
  - (More frameworks coming soon)

---

## 5-Minute Quick Start

### Step 1: Create Test Specification (1 min)

Generate a test specification document that defines what needs to be tested:

```bash
/ut.specify aa-2
```

This creates `.specify/features/aa-2/test-spec.md` with:
- Test scenarios and cases
- Coverage goals
- Mocking requirements
- Expected inputs/outputs

**Review the generated spec** and make adjustments if needed.

---

### Step 2: Analyze Your Code (30 seconds)

Scan your codebase to identify untested functions and coverage gaps:

```bash
/ut.analyze aa-2
```

You'll get a report showing:
- Functions without tests
- Current coverage percentages
- Detected test framework
- Priority recommendations

**Check the coverage report** at `.specify/features/aa-2/coverage-report.json`

---

### Step 3: Generate Implementation Plan (1 min)

Create a structured plan for your tests:

```bash
/ut.plan aa-2
```

This generates `.specify/features/aa-2/test-plan.md` with:
- Test file structure
- Mocking strategy
- Test suite organization
- Step-by-step implementation tasks

**Review the plan** to ensure it matches your project conventions.

---

### Step 4: Generate Test Code (2 min)

Generate the actual test files:

```bash
/ut.generate aa-2
```

This creates test files in your project with:
- Test cases matching your spec
- Proper setup/teardown code
- Framework-appropriate mocks
- Meaningful assertions

**The tests are now ready to run!**

---

### Step 5: Review Generated Tests (30 seconds)

Check the quality of generated tests:

```bash
/ut.review aa-2
```

You'll get feedback on:
- Test completeness
- Assertion quality
- Missing edge cases
- Best practice violations

---

### Step 6: Run Your Tests (30 seconds)

Execute the tests and see results:

```bash
/ut.run aa-2 --coverage
```

You'll see:
- Pass/fail status for each test
- Code coverage metrics
- Detailed error messages for failures
- Performance statistics

---

## Common Workflows

### Workflow 1: Full Automated Generation

Generate everything in one go (for experienced users):

```bash
/ut.specify aa-2 && \
/ut.analyze aa-2 && \
/ut.plan aa-2 && \
/ut.generate aa-2 && \
/ut.review aa-2 && \
/ut.run aa-2 --coverage
```

---

### Workflow 2: Iterative Improvement

Generate tests, review, improve, repeat:

```bash
# Initial generation
/ut.specify aa-2
/ut.analyze aa-2
/ut.plan aa-2
/ut.generate aa-2

# Review and identify improvements
/ut.review aa-2

# Edit tests manually based on feedback

# Re-run review until satisfied
/ut.review aa-2 --min-score 90

# Final test execution
/ut.run aa-2 --coverage
```

---

### Workflow 3: Targeted Test Generation

Generate tests for specific files only:

```bash
# Analyze specific module
/ut.specify aa-2 src/core/generator.js

# Generate tests for that module
/ut.generate aa-2 src/core/generator.js

# Run those specific tests
/ut.run aa-2 "tests/unit/generator.test.js"
```

---

## Integration with SpecKit

The `/ut.*` commands work alongside `/speckit.*` commands:

```
1. /speckit.specify aa-2 "New feature description"
   ↓
2. /speckit.plan aa-2
   ↓
3. /speckit.tasks aa-2
   ↓
4. [Implement feature code]
   ↓
5. /ut.specify aa-2        ← Start test generation
   ↓
6. /ut.analyze aa-2
   ↓
7. /ut.plan aa-2
   ↓
8. /ut.generate aa-2
   ↓
9. /ut.review aa-2
   ↓
10. /ut.run aa-2
```

---

## Real-World Examples

### Example 1: JavaScript Project with Jest

```bash
# Project structure
myproject/
├── src/
│   ├── calculator.js
│   └── validator.js
├── package.json          # Jest configured
└── .specify/

# Generate tests
$ /ut.specify aa-calculator
✓ Created test specification with 8 test cases

$ /ut.analyze aa-calculator
✓ Found 2 untested functions
  Coverage: 0% → Target: 80%

$ /ut.generate aa-calculator
✓ Generated 2 test files
  - tests/unit/calculator.test.js (6 tests, 15 assertions)
  - tests/unit/validator.test.js (4 tests, 8 assertions)

$ /ut.run aa-calculator --coverage
✓ All 10 tests passed
  Coverage: 85% statements, 82% branches
```

---

### Example 2: Python Project with Pytest

```bash
# Project structure
myproject/
├── src/
│   ├── analyzer.py
│   └── reporter.py
├── pyproject.toml        # Pytest configured
└── .specify/

# Generate tests
$ /ut.specify aa-analytics
✓ Created test specification with 12 test cases

$ /ut.analyze aa-analytics
✓ Detected framework: pytest
  Found 3 untested classes, 8 untested methods

$ /ut.generate aa-analytics
✓ Generated 2 test files
  - tests/unit/test_analyzer.py (8 tests)
  - tests/unit/test_reporter.py (6 tests)

$ /ut.run aa-analytics --coverage
✓ 14/14 tests passed
  Coverage: 88% statements, 79% branches
```

---

## Tips for Success

### 1. Start with Good Feature Specs

The quality of generated tests depends on your feature specification. Include:
- Clear functional requirements
- Expected inputs and outputs
- Edge cases and error conditions
- Dependencies and integrations

### 2. Review Before Running

Always review generated tests before running them:
- Check that assertions make sense
- Verify mock implementations
- Ensure edge cases are covered
- Add any missing scenarios manually

### 3. Customize for Your Project

Override defaults to match your project:
```bash
# Custom coverage target
/ut.specify aa-2 --coverage-target 90

# Custom test organization
/ut.plan aa-2 --organization by_module

# Custom templates
/ut.generate aa-2 --template-dir .specify/templates/custom
```

### 4. Use Review Iteratively

The review command helps improve quality:
```bash
# First review
/ut.review aa-2
→ Score: 75/100, 8 suggestions

# Make improvements...

# Second review
/ut.review aa-2
→ Score: 88/100, 2 suggestions
```

### 5. Leverage Watch Mode

During development, use watch mode:
```bash
/ut.run aa-2 --watch
```
Tests re-run automatically when files change.

---

## Troubleshooting

### "Framework not detected"

**Problem**: System can't identify your test framework

**Solution**:
```bash
# Force framework explicitly
/ut.analyze aa-2 --frameworks jest
/ut.generate aa-2 --framework jest
```

---

### "Coverage below target"

**Problem**: Generated tests don't achieve target coverage

**Solution**:
```bash
# Review coverage gaps
/ut.analyze aa-2

# Generate additional tests for gaps
/ut.generate aa-2 src/uncovered-module.js

# Or lower target temporarily
/ut.specify aa-2 --coverage-target 70
```

---

### "Syntax errors in generated tests"

**Problem**: Generated code doesn't compile/run

**Solution**:
```bash
# Re-generate with template fallback
/ut.generate aa-2 --template

# Or check review for syntax issues
/ut.review aa-2 --strict

# Manual fix may be needed for complex cases
```

---

### "Tests fail after generation"

**Problem**: Generated tests don't pass

**Solution**:
```bash
# Get detailed error messages
/ut.run aa-2 --verbose

# Review expects the code to behave as spec'd
# Either fix the code or update the spec

# Re-generate after spec changes
/ut.generate aa-2 --overwrite
```

---

## Advanced Usage

### Custom Templates

Create project-specific test templates:

```
.specify/templates/custom-tests/
├── test-file.template
├── test-case.template
└── mock.template
```

Use them:
```bash
/ut.generate aa-2 --template-dir .specify/templates/custom-tests
```

---

### Parallel Execution

Speed up test runs:
```bash
/ut.run aa-2 --parallel --reporter json
```

---

### CI/CD Integration

Add to your CI pipeline:
```yaml
# .github/workflows/test.yml
- name: Generate and run tests
  run: |
    /ut.specify $FEATURE_ID
    /ut.analyze $FEATURE_ID
    /ut.plan $FEATURE_ID
    /ut.generate $FEATURE_ID
    /ut.review $FEATURE_ID --min-score 85
    /ut.run $FEATURE_ID --coverage --reporter junit
```

---

## Next Steps

- 📖 Read the [full specification](spec.md) for detailed requirements
- 🔧 Check [command interface contracts](contracts/command-interface.md) for all options
- 🏗️ Review [data model](data-model.md) for artifact structures
- 📊 See [research findings](research.md) for design decisions

---

## Getting Help

```bash
# Command-specific help
/ut.specify --help
/ut.analyze --help
/ut.plan --help
/ut.generate --help
/ut.review --help
/ut.run --help

# Check version
/ut.specify --version
```

---

## FAQ

**Q: Can I use this without SpecKit?**  
A: Yes! You can use `/ut.specify` directly with any codebase. SpecKit integration is optional.

**Q: What frameworks are supported?**  
A: Currently Jest, Vitest (JS/TS), and Pytest (Python). More coming based on user demand.

**Q: Will it overwrite my existing tests?**  
A: No, unless you use `--overwrite` flag. By default, it creates new files or skips existing ones.

**Q: Can I customize the generated tests?**  
A: Yes! You can edit generated tests manually, use custom templates, or modify the plan before generation.

**Q: How accurate is the coverage analysis?**  
A: The system achieves 95%+ accuracy in identifying testable units (SC-002). Always review the analysis report.

**Q: Does it work with monorepos?**  
A: Yes, specify the feature path and it will work within that context.

---

**Quickstart Status**: ✅ Complete  
**Estimated Read Time**: 8 minutes  
**Ready to Use**: Yes  

Happy testing! 🧪

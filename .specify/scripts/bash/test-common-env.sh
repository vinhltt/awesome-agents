#!/bin/bash
# Test script for common-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-env.sh"

echo "=== Environment Loading Tests ==="

# Test 1: Default values
echo "Test 1: Default values loaded"
[[ "$SPECKIT_PREFIX_LIST" == "aa" ]] && echo "✅ PREFIX_LIST" || echo "❌ PREFIX_LIST"
[[ "$SPECKIT_DEFAULT_FOLDER" == "features" ]] && echo "✅ DEFAULT_FOLDER" || echo "❌ DEFAULT_FOLDER"
[[ "$SPECKIT_MAIN_BRANCH" == "master" ]] && echo "✅ MAIN_BRANCH" || echo "❌ MAIN_BRANCH"

# Test 2: Parse simple ticket ID
echo -e "\nTest 2: Parse aa-123"
result=$(parse_ticket_id "aa-123")
expected="features|aa|123"
[[ "$result" == "$expected" ]] && echo "✅ Parse simple: $result" || echo "❌ Expected: $expected, Got: $result"

# Test 3: Parse with folder
echo -e "\nTest 3: Parse hotfix/aa-999"
result=$(parse_ticket_id "hotfix/aa-999")
expected="hotfix|aa|999"
[[ "$result" == "$expected" ]] && echo "✅ Parse with folder: $result" || echo "❌ Expected: $expected, Got: $result"

# Test 4: Validate prefix
echo -e "\nTest 4: Validate prefix 'aa'"
validate_prefix "aa" && echo "✅ Valid prefix" || echo "❌ Should be valid"

# Test 5: Invalid prefix
echo -e "\nTest 5: Invalid prefix 'xyz'"
validate_prefix "xyz" 2>/dev/null && echo "❌ Should fail" || echo "✅ Correctly rejected"

# Test 6: Invalid format
echo -e "\nTest 6: Invalid format 'invalid-format'"
parse_ticket_id "invalid-format" 2>/dev/null && echo "❌ Should fail" || echo "✅ Correctly rejected"

echo -e "\n=== Tests Complete ==="

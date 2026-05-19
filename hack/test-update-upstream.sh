#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPT="$SCRIPT_DIR/update-upstream.sh"

PASS=0
FAIL=0

pass() { ((PASS++)); echo "  PASS: $1"; }
fail() { ((FAIL++)); echo "  FAIL: $1 — $2"; }

assert_exit() {
    local desc="$1" expected_exit="$2" actual_exit="$3" output="$4"
    if [[ "$actual_exit" -eq "$expected_exit" ]]; then
        pass "$desc"
    else
        fail "$desc" "expected exit $expected_exit, got $actual_exit. Output: $output"
    fi
}

assert_output_contains() {
    local desc="$1" pattern="$2" output="$3"
    if echo "$output" | grep -qi "$pattern"; then
        pass "$desc"
    else
        fail "$desc" "output missing '$pattern'"
    fi
}

revert_submodule() {
    local sub="$1"
    git -C "$REPO_ROOT" reset HEAD "$sub" >/dev/null 2>&1 || true
    git -C "$REPO_ROOT" submodule update --init "$sub" >/dev/null 2>&1
}

cd "$REPO_ROOT"

# ============================================================
echo ""
echo "=== Group 1: Input Validation ==="
echo ""

# Test 1: No args
echo "Test 1: No args"
output=$("$SCRIPT" 2>&1 || true)
exit_code=0; "$SCRIPT" >/dev/null 2>&1 || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "prints usage" "Usage" "$output"

# Test 2: Too many args
echo "Test 2: Too many args"
output=$("$SCRIPT" build abc123f extra 2>&1 || true)
exit_code=0; "$SCRIPT" build abc123f extra >/dev/null 2>&1 || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "prints usage" "Usage" "$output"

# Test 3: Invalid submodule name
echo "Test 3: Invalid submodule name"
output=$("$SCRIPT" foo 2>&1 || true)
exit_code=0; "$SCRIPT" foo >/dev/null 2>&1 || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "error message" "must be 'build' or 'cli'" "$output"

# Test 4: Invalid SHA format (too short)
echo "Test 4: Invalid SHA (too short)"
output=$("$SCRIPT" build abc 2>&1 || true)
exit_code=0; "$SCRIPT" build abc >/dev/null 2>&1 || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "error message" "not a valid SHA" "$output"

# Test 5: Invalid SHA format (non-hex)
echo "Test 5: Invalid SHA (non-hex)"
output=$("$SCRIPT" build ZZZZZZZZ 2>&1 || true)
exit_code=0; "$SCRIPT" build ZZZZZZZZ >/dev/null 2>&1 || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "error message" "not a valid SHA" "$output"

# Test 6: SHA not found in remote (requires network)
echo "Test 6: SHA not found in remote"
FAKE_SHA="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
output=$("$SCRIPT" build "$FAKE_SHA" 2>&1 || true)
exit_code=0; "$SCRIPT" build "$FAKE_SHA" >/dev/null 2>&1 || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "error message" "not found in" "$output"

# ============================================================
echo ""
echo "=== Group 2: Core Functionality ==="
echo ""

# Test 7: Update build to latest (no SHA)
echo "Test 7: Update build to latest"
original_sha=$(git -C build rev-parse HEAD)
exit_code=0; output=$("$SCRIPT" build 2>&1) || exit_code=$?
assert_exit "exits zero" 0 "$exit_code" "$output"
new_sha=$(git -C build rev-parse HEAD)
assert_output_contains "shows update summary" "submodule updated" "$output"
revert_submodule build
reverted_sha=$(git -C build rev-parse HEAD)
if [[ "$reverted_sha" == "$original_sha" ]]; then
    pass "reverted successfully"
else
    fail "reverted successfully" "SHA after revert ($reverted_sha) != original ($original_sha)"
fi

# Test 8: Update cli to latest (no SHA)
echo "Test 8: Update cli to latest"
original_sha=$(git -C cli rev-parse HEAD)
exit_code=0; output=$("$SCRIPT" cli 2>&1) || exit_code=$?
assert_exit "exits zero" 0 "$exit_code" "$output"
assert_output_contains "shows update summary" "submodule updated" "$output"
revert_submodule cli
reverted_sha=$(git -C cli rev-parse HEAD)
if [[ "$reverted_sha" == "$original_sha" ]]; then
    pass "reverted successfully"
else
    fail "reverted successfully" "SHA after revert ($reverted_sha) != original ($original_sha)"
fi

# Test 9: Update build to explicit valid SHA
echo "Test 9: Update build to explicit SHA"
KNOWN_SHA="5025a95f"
original_sha=$(git -C build rev-parse HEAD)
exit_code=0; output=$("$SCRIPT" build "$KNOWN_SHA" 2>&1) || exit_code=$?
assert_exit "exits zero" 0 "$exit_code" "$output"
actual_sha=$(git -C build rev-parse HEAD)
if [[ "$actual_sha" == "$KNOWN_SHA"* ]]; then
    pass "submodule HEAD matches target SHA"
else
    fail "submodule HEAD matches target SHA" "expected $KNOWN_SHA*, got $actual_sha"
fi
assert_output_contains "shows update summary" "submodule updated" "$output"
revert_submodule build
reverted_sha=$(git -C build rev-parse HEAD)
if [[ "$reverted_sha" == "$original_sha" ]]; then
    pass "reverted successfully"
else
    fail "reverted successfully" "SHA after revert ($reverted_sha) != original ($original_sha)"
fi

# ============================================================
echo ""
echo "=== Group 3: Edge Cases ==="
echo ""

# Test 10: Run from wrong directory
echo "Test 10: Run from wrong directory"
exit_code=0; output=$(cd /tmp && "$SCRIPT" build 2>&1) || exit_code=$?
assert_exit "exits non-zero" 1 "$exit_code" "$output"
assert_output_contains "error message" "no .gitmodules found" "$output"

# ============================================================
echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
echo "================================"

# Verify submodules are clean after tests
echo ""
echo "Post-test submodule status:"
git submodule status

[[ $FAIL -eq 0 ]]

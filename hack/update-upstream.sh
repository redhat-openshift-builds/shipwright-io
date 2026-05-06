#!/bin/bash
set -euo pipefail

SUBMODULE="${1:-}"
TARGET_SHA="${2:-}"

usage() {
    echo "Usage: $0 <submodule> <sha>"
    echo "  <submodule>  must be 'build' or 'cli'"
    echo "  <sha>        target commit SHA (7-40 hex characters)"
    echo ""
    echo "Example:"
    echo "  $0 build abc1234def5678"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

if [[ "$SUBMODULE" != "build" && "$SUBMODULE" != "cli" ]]; then
    echo "Error: submodule must be 'build' or 'cli', got '$SUBMODULE'"
    exit 1
fi

if [[ ! -f ".gitmodules" ]]; then
    echo "Error: must be run from the repository root (no .gitmodules found)"
    exit 1
fi

if [[ ! "$TARGET_SHA" =~ ^[0-9a-f]{7,40}$ ]]; then
    echo "Error: '$TARGET_SHA' is not a valid SHA (expected 7-40 hex characters)"
    exit 1
fi

declare -A MIRROR_REPOS=(
    [build]="redhat-openshift-builds/shipwright-io-build"
    [cli]="redhat-openshift-builds/shipwright-io-cli"
)

REPO="${MIRROR_REPOS[$SUBMODULE]}"

echo "Validating SHA against remote ${REPO}..."
if ! gh api "repos/${REPO}/commits/${TARGET_SHA}" --silent 2>/dev/null; then
    echo "Error: SHA '${TARGET_SHA}' not found in ${REPO}"
    echo "Verify the SHA exists at: https://github.com/${REPO}/commit/${TARGET_SHA}"
    exit 1
fi
echo "SHA validated."

SUBMODULE_STATUS=$(git submodule status "$SUBMODULE" 2>/dev/null || true)
if [[ "$SUBMODULE_STATUS" == -* ]]; then
    echo "Submodule '$SUBMODULE' is not initialized. Initializing..."
    git submodule update --init "$SUBMODULE"
fi

OLD_SHA=$(git -C "$SUBMODULE" rev-parse HEAD)
echo "Current $SUBMODULE SHA: $OLD_SHA"

echo "Fetching origin in $SUBMODULE..."
git -C "$SUBMODULE" fetch origin

echo "Checking out $TARGET_SHA..."
git -C "$SUBMODULE" checkout "$TARGET_SHA"

NEW_SHA=$(git -C "$SUBMODULE" rev-parse HEAD)

git add "$SUBMODULE"

echo ""
echo "=== $SUBMODULE submodule updated ==="
echo "  Old SHA: $OLD_SHA"
echo "  New SHA: $NEW_SHA"
echo ""
echo "To see changelog:"
echo "  cd $SUBMODULE && git log --oneline ${OLD_SHA}..${NEW_SHA}"
echo ""
echo "Staged diff:"
git diff --cached --submodule "$SUBMODULE"

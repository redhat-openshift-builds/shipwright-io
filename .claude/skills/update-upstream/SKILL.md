---
name: update-upstream
description: Bump submodule SHAs on builds-X.Y branch to latest from mirror repos. For z-stream releases. Creates 2 separate PRs (one per submodule).
argument-hint: "[build] [cli] [build=<sha>] [cli=<sha>]"
allowed-tools: [Bash, Read]
user_invocable: true
---

# Update Mirror Submodule SHAs (Z-Stream)

Bumps `build` and/or `cli` submodule SHAs on the downstream `builds-X.Y` branch to the latest commit from the mirror repos' tracked branch. For z-stream (patch) releases.

Creates separate PRs per submodule for pipeline trigger reasons.

## Arguments

The user invoked this with: $ARGUMENTS

Parse optional arguments:
- `build` — update only the build submodule
- `cli` — update only the cli submodule
- `build=<sha>` — update build to a specific SHA
- `cli=<sha>` — update cli to a specific SHA
- No arguments — update both (default)

## Workflow

### 1. Ask for Release Version

Ask the user: "What is the release version? (format: X.Y, e.g., 1.8)"

Do NOT use AskUserQuestion tool — just ask directly and wait for the user to respond.

**Validation**: Ensure the version matches `^[0-9]+\.[0-9]+$`.

Store as `DOT_VERSION`. Derive `DASH_VERSION` by replacing `.` with `-`.

### 2. Checkout Release Branch

```bash
git checkout "builds-$DOT_VERSION"
git pull origin "builds-$DOT_VERSION"
```

### 3. Detect GitHub User and Verify Remotes

```bash
GH_USER=$(gh api user --jq '.login')
echo "Logged in as: $GH_USER"
```

```bash
FETCH_URL=$(git remote get-url origin)
PUSH_URL=$(git remote get-url --push origin)
```

Detect fork workflow: if FETCH_URL != PUSH_URL, extract fork owner from PUSH_URL.

### 4. Check for Dirty Working Tree

```bash
git status --porcelain -uno
```

If dirty, stop and offer to stash/commit/discard. Do not proceed until clean.

### 5. Show Current State and Commit Summary

For each submodule (build and cli):

```bash
CURRENT_SHA=$(git -C <submodule> rev-parse HEAD)
CURRENT_SHORT=$(git -C <submodule> rev-parse --short HEAD)

git -C <submodule> fetch origin

if [ -n "$EXPLICIT_SHA" ]; then
  TARGET_SHA="$EXPLICIT_SHA"
  TARGET_SHORT=$(echo "$TARGET_SHA" | cut -c1-8)
else
  TRACKED_BRANCH=$(git config -f .gitmodules --get "submodule.<submodule>.branch")
  TARGET_SHA=$(git -C <submodule> rev-parse "origin/$TRACKED_BRANCH")
  TARGET_SHORT=$(git -C <submodule> rev-parse --short "origin/$TRACKED_BRANCH")
fi

NEW_COMMITS=$(git -C <submodule> rev-list --count "$CURRENT_SHA..$TARGET_SHA" 2>/dev/null || echo "?")

echo ""
echo "=== <submodule> ==="
echo "Current: $CURRENT_SHORT"
echo "Latest:  $TARGET_SHORT"
echo "New commits: $NEW_COMMITS"
echo ""
git -C <submodule> log --oneline "$CURRENT_SHA..$TARGET_SHA" 2>/dev/null | head -20
```

If `NEW_COMMITS` is 0, display: "✓ <submodule> is already up to date." and skip it.

### 6. Ask User What to Update

If no explicit args were provided, ask the user:

"Update both submodules, just build, or just cli? (both/build/cli)"

Do NOT use AskUserQuestion tool. Default: both.

### 7. Per-Submodule Workflow

For each submodule to update, run steps 7a–7f **sequentially**. Complete build first, then cli.

#### 7a. Prepare Branch

```bash
git checkout "builds-$DOT_VERSION"
git checkout -b "bump-<submodule>-$DASH_VERSION"
```

#### 7b. Update Submodule

```bash
if [ -n "$EXPLICIT_SHA" ]; then
  ./hack/update-upstream.sh <submodule> "$EXPLICIT_SHA"
else
  ./hack/update-upstream.sh <submodule>
fi
```

#### 7c. Show Diff

```bash
git diff --cached
```

Print the diff to screen.

#### 7d. Commit

```bash
NEW_SHA=$(git -C <submodule> rev-parse --short HEAD)
OLD_SHA="$CURRENT_SHORT"

git commit -s -S -m "$(cat <<'EOF'
chore(deps): update <submodule> digest to <NEW_SHA>

Update <submodule> from <OLD_SHA> to <NEW_SHA>.

Co-Authored-By: Claude Opus 4.6
EOF
)"
```

#### 7e. Push and Create PR

```bash
git push -u origin "bump-<submodule>-$DASH_VERSION"
```

PR title must exactly match:
- Build: `chore(deps): update build digest to <NEW_SHA>`
- CLI: `chore(deps): update cli digest to <NEW_SHA>`

Use fork workflow detection to create PR correctly.

#### 7f. Print Warning

```
WARNING: Do NOT change the PR title. The Konflux/Tekton pipelines use
the title prefix to trigger the correct pipelines.
```

Return to release branch: `git checkout "builds-$DOT_VERSION"`

### 8. Print Summary

Show table with submodule, old SHA, new SHA, new commits count, and PR URL.

## Key Rules

1. **Detect GitHub username dynamically** via `gh api user`
2. **Always sign commits** with `-s -S` (DCO sign-off + GPG)
3. **One PR per submodule** — each gets its own branch, commit, and PR
4. **PR titles must match pipeline triggers exactly**
5. **Show commit summary before updating** — user sees what changed
6. **Sequential execution** — complete build fully before starting cli
7. **Co-author line**: `Co-Authored-By: Claude Opus 4.6`

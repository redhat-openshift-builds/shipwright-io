---
name: update-upstream
description: Bump build and/or cli submodule SHAs, commit, and create a PR. Usage: /update-upstream build=<sha> cli=<sha> (one or both).
---

# Update Upstream Submodules

Bumps `build` and/or `cli` submodule pointers to specific upstream commits, commits the change, and creates PRs.

Each submodule gets its own PR with a specific title that triggers the correct Konflux/Tekton pipelines.

## Arguments

The user invoked this with: $ARGUMENTS

Parse submodule=SHA pairs from arguments. Suggested input format:

```
/update-upstream build=abc123 cli=def456
```

At least one submodule must be provided. Both are optional.

## Workflow

### 1. Parse Arguments

Extract `build=<sha>` and/or `cli=<sha>` from `$ARGUMENTS`.
If neither is found, ask the user which submodule(s) to bump and to what SHA.

After parsing, print this info block:

```
INFO: Each submodule bump creates a separate PR because Konflux pipelines
use PR title prefixes to decide which pipelines to run:
- "chore(deps): update build digest" triggers build component pipelines
- "chore(deps): update cli digest" triggers client pipeline
```

### 2. Ask for Release Version

Ask the user for the release version (e.g., `v0.19`, `v0.20`).
This will be used in the branch name.

### 3. Detect GitHub User

```bash
GH_USER=$(gh api user --jq '.login')
echo "Logged in as: $GH_USER"
```

No hardcoded usernames. Works for any developer with `gh auth login` done.
If this fails, stop and ask the user to run `gh auth login`.

### 4. Verify Remotes

```bash
FETCH_URL=$(git remote get-url origin)
PUSH_URL=$(git remote get-url --push origin)
echo "Fetch: $FETCH_URL"
echo "Push:  $PUSH_URL"
```

- Fetch URL must contain `redhat-openshift-builds/shipwright-io`
- If FETCH_URL != PUSH_URL, this is a fork workflow -- extract fork owner from PUSH_URL
- If they are the same, the user has direct push access (no fork)

### 5. Check for Dirty Working Tree

```bash
git status --porcelain
```

If there are uncommitted changes, stop and offer to help:
- Stash changes (`git stash`)
- Commit changes
- Discard changes

Do not proceed until the working tree is clean.

### 6. Per-Submodule Workflow

For each submodule provided, run steps 6a-6g **sequentially**. If both submodules are provided, complete the full workflow for `build` first, then return to main and repeat for `cli`.

#### 6a. Prepare Branch

```bash
git checkout main
git pull origin main
git checkout -b bump-<submodule>-<release>
```

Example: `bump-build-v0.19`, `bump-cli-v0.19`.

#### 6b. Run update-upstream.sh

```bash
./hack/update-upstream.sh <submodule> <sha>
```

If the invocation fails, stop and report the error.

#### 6c. Show Diff

```bash
git diff --cached
```

Print the diff to screen. Tell the user: "Changes are staged. You can also review them in your IDE."

#### 6d. Commit

Always sign with `-s` (DCO) and `-S` (GPG).

```bash
git commit -s -S -m "$(cat <<'EOF'
chore(deps): update <submodule> digest to <short-new-sha>

Update <submodule> from <short-old-sha> to <short-new-sha>.

Co-Authored-By: Claude Opus 4.6
EOF
)"
```

#### 6e. Push

```bash
git push -u origin <branch-name>
```

#### 6f. Create PR

Extract upstream repo and fork owner from the remotes detected in step 4:

```bash
UPSTREAM_SLUG=$(echo "$FETCH_URL" | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
FORK_OWNER=$(echo "$PUSH_URL" | sed 's/.*github.com[:/]\([^/]*\).*/\1/')
```

PR title must exactly match the pipeline trigger prefix:
- Build: `chore(deps): update build digest to <short-new-sha>`
- CLI: `chore(deps): update cli digest to <short-new-sha>`

If fork workflow (FETCH_URL != PUSH_URL):
```bash
gh pr create --repo "$UPSTREAM_SLUG" --base main \
  --head "$FORK_OWNER:<branch-name>" \
  --title "chore(deps): update <submodule> digest to <short-new-sha>" \
  --body "$(cat <<'EOF'
## Summary

- Bump <submodule> submodule from <short-old-sha> to <short-new-sha>

Co-Authored-By: Claude Opus 4.6
EOF
)"
```

If direct push (FETCH_URL == PUSH_URL):
```bash
gh pr create --base main \
  --title "chore(deps): update <submodule> digest to <short-new-sha>" \
  --body "<same body as above>"
```

#### 6g. Print Warning

After each PR is created, print:

```
WARNING: Do NOT change the PR title. The Konflux/Tekton pipelines use
the title prefix to trigger the correct pipelines. Changing the title
will prevent pipelines from running.
```

### 7. Print Summary

Display:
- Branch name(s)
- Submodule(s) bumped with old -> new SHAs
- PR URL(s)

## Key Rules

1. **Detect GitHub username dynamically** via `gh api user` -- never hardcode usernames
2. **Always sign commits** with `-s -S` (DCO sign-off + GPG)
3. **Never `git add .`** -- the script handles staging specific submodule paths
4. **Never use `git submodule update --remote`** -- explicit SHAs only
5. **Show diff before committing** -- print to screen, suggest IDE review
6. **Co-author line**: `Co-Authored-By: Claude Opus 4.6`
7. **Fork workflow**: detect from remotes, push to fork, PR against upstream
8. **Clean working tree required** -- check and offer help before proceeding
9. **One PR per submodule** -- each submodule gets its own branch, commit, and PR
10. **PR titles must match pipeline triggers exactly** -- never modify the title format

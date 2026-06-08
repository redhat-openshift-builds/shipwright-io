# OpenShift Builds (shipwright-io)

Downstream packaging repo for Shipwright Build. Wraps upstream code (via git submodules) with Red Hat Konflux build pipelines and Dockerfiles.

## Architecture

This repo sits at the end of a three-tier supply chain:

- **Upstream:** `shipwright-io/build` and `shipwright-io/cli` (community repos in the `shipwright-io` GitHub org)
- **Midstream (mirror):** `redhat-openshift-builds/shipwright-io-build` and `redhat-openshift-builds/shipwright-io-cli` (Red Hat forks that sync from upstream and carry downstream patches)
- **Downstream (this repo):** tracks the midstream mirrors as git submodules and adds Konflux build pipelines

Key directories:

- `build/` and `cli/` are **git submodules** tracking the midstream mirror repos. These are read-only — never edit files inside them.
- `.konflux/` has 7 component directories, each with a Dockerfile that builds a container image: `client`, `controller`, `git-cloner`, `image-bundler`, `image-processing`, `waiter`, `webhook`
- `.tekton/` has pull-request and push pipeline definitions for each component (14 files total)
- `.github/workflows/` has the `bump-submodules` GitHub Action for automated submodule updates
- `hack/` contains scripts: `update-upstream.sh` (bump submodule SHAs), `build-binary.sh` (CLI binary build), `test-update-upstream.sh` (tests for update script)
- `rpms.in.yaml` / `rpms.lock.yaml` define RPM dependencies resolved via `rpm-lockfile-prototype` — see README.md for regeneration steps

## Build & Test Commands

No root-level Makefile — build and test commands live inside the submodules. At the root level:

- Bump submodule: `./hack/update-upstream.sh <build|cli> [sha]`
- Test update script: `./hack/test-update-upstream.sh`
- Regenerate RPM lockfile: see README.md (requires Podman)

## Key Conventions

- **Never edit submodule contents** — `build/` and `cli/` are read-only pointers. Go dependency changes happen upstream, then sync via submodule pointer updates.
- **Never combine submodule updates in one PR** — each submodule (build, cli) gets its own branch, commit, and PR. Konflux pipelines use PR title prefixes to decide which pipelines to run.
- **PR titles for submodule updates must match exactly:**
  - `chore(deps): update build digest to <SHA>` — triggers build component pipelines
  - `chore(deps): update cli digest to <SHA>` — triggers client pipeline
- **Dockerfile edits** — when updating base image SHAs (go-toolset, ubi9-minimal), update ALL Dockerfiles in `.konflux/*/Dockerfile` consistently.
- **Version labels** — each Dockerfile has `cpe=` and `version=` labels. These are updated together during release prep.
- **Never modify `.tekton/` files on main** — only on release branches (`builds-X.Y`).
- **Release branches** follow the `builds-X.Y` naming convention (e.g., `builds-1.8`).

## PR Conventions

- **Commit flags:** always use `-s` (sign-off) and `-S` (GPG sign)
- **Commit format:** `[BUILD-XXXX] scope: description` — Jira key prefix in brackets, conventional commit style
- **PR title:** `[BUILD-XXXX] builds-X.Y: scope: description` — include branch version prefix when targeting a release branch
- **PR body:** `## Summary` or `## CVE Fix` header with bullet points, `### Jira Issues` with `Resolves: BUILD-XXXX`, ends with `Co-Authored-By: Claude Code`
- **Fork-aware push:** detect fork vs upstream (`git remote get-url origin` vs `--push`) for `gh pr create --head` flag
- **One commit per PR:** amend and force push rather than adding commits. Rewrite commit message, PR title, and PR body to cover the full diff as if done in one shot — no references to "later added" or "fixed after review". User can override to keep multiple commits if needed.

<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-detect-secrets/v0.29.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-detect-secrets/v0.29.6** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### missing-permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no individual job defines its own `permissions:` block. Without explicit permissions, GitHub Actions grants the default token permissions (which may include write access to contents, pull-requests, etc.), violating the principle of least privilege.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/dockerimage.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** missing-permissions

**Notes:**

Added top-level `permissions:` blocks to all four workflow files with least-privilege permissions:
- depup.yml: `contents: write` + `pull-requests: write` (needs to push branches and create PRs via peter-evans/create-pull-request)
- dockerimage.yml: `contents: read` (only checks out code and builds a Docker image locally)
- release.yml: `contents: write` + `pull-requests: write` (creates GitHub releases, updates semver tags, and posts PR status comments via action-bumpr)
- reviewdog.yml: `contents: read` + `pull-requests: write` (checks out code and posts PR review comments via the detect-secrets action with reporter: github-pr-review)


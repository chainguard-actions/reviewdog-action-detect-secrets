<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-detect-secrets/v0.29.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-detect-secrets/v0.29.8** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The Dockerfile pipes a remote install script directly to `sh` without first downloading and verifying it: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- ...`. This allows a compromised or man-in-the-middle remote resource to execute arbitrary code in the build environment.

Locations:

- `Dockerfile:6`

### script-injection (severity: high)

entrypoint.sh expands multiple attacker-controlled INPUT_* environment variables (sourced from action inputs) without double-quoting, violating rule (b). Unquoted expansions allow shell word-splitting and metacharacter injection (`;`, `|`, `&`, `$(...)`, globs, etc.).

Offending lines:
- Line 13: `detect-secrets scan ${INPUT_DETECT_SECRETS_FLAGS} --baseline ${INPUT_BASELINE_PATH} ${INPUT_WORKDIR}` — three unquoted expansions
- Line 14: `mv ${INPUT_BASELINE_PATH} /tmp/.secrets.baseline` — unquoted
- Line 16: `detect-secrets scan ${INPUT_DETECT_SECRETS_FLAGS} ${INPUT_WORKDIR}` — two unquoted expansions
- Line 31: `${INPUT_REVIEWDOG_FLAGS}` — unquoted trailing flags

All of these variables are set from user-supplied action inputs and must be double-quoted (e.g. `"${INPUT_DETECT_SECRETS_FLAGS}"`) to prevent injection.

Locations:

- `entrypoint.sh:13`
- `entrypoint.sh:14`
- `entrypoint.sh:16`
- `entrypoint.sh:31`

### missing-permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no individual job within any workflow defines job-level permissions. Without explicit permissions, workflows run with the default (potentially broad) token permissions. All four workflow files are affected: depup.yml, dockerimage.yml, release.yml, and reviewdog.yml.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/dockerimage.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

1. Dockerfile (unsafe-shell): Replaced `wget ... | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}` with a two-step approach: download to `/tmp/install-reviewdog.sh`, then execute with `sh /tmp/install-reviewdog.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION}` (dropped `-s` and `--` which were shell stdin/option-terminator flags, not script arguments). Also added `bash` to the apk packages.

2. entrypoint.sh (script-injection): Changed shebang to `#!/bin/bash`. List-type inputs (`INPUT_DETECT_SECRETS_FLAGS`, `INPUT_REVIEWDOG_FLAGS`) are tokenized into bash arrays using the xargs+printf+NUL+while-read pattern with guards. Single-value inputs (`INPUT_BASELINE_PATH`, `INPUT_WORKDIR`) are double-quoted. `SKIP_AUDITED_FLAG` and `VERBOSE_FLAG` converted to arrays for safe expansion.

3. Workflow files (missing-permissions): Added top-level `permissions:` blocks to all four workflows: depup.yml (`contents: write, pull-requests: write`), dockerimage.yml (`contents: read`), release.yml (`contents: write`), reviewdog.yml (`contents: read, pull-requests: write`).


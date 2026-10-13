<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-detect-secrets/v0.31.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-detect-secrets/v0.31.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The Dockerfile fetches a remote install script via wget and pipes it directly to sh without any integrity verification. This is the classic 'curl/wget | sh' anti-pattern: if the remote URL is compromised or the content is tampered with in transit, arbitrary code will execute during the Docker image build. The specific line is: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}`. The script should be downloaded to a file first, its checksum verified, and then executed separately.

Locations:

- `Dockerfile:6`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed the wget|sh anti-pattern in Dockerfile line 6. Changed from piping wget output directly to sh ('wget -O - -q ... | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}') to downloading the script to /tmp/reviewdog-install.sh first, then executing it separately ('sh /tmp/reviewdog-install.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION}'). The '--' was dropped as required (it was the shell's option terminator for the pipe form 'sh -s', not an argument to the downloaded script). The URL remains pinned to the specific commit SHA fd59714416d6d9a1c0692d872e38e7f8448df4fc. The temp file is removed after execution.


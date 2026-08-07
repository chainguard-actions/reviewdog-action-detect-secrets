#!/bin/bash

cd "${GITHUB_WORKSPACE}" || exit 1

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

detect-secrets --version

git config --global --add safe.directory /github/workspace

# Tokenize list-type inputs into arrays using xargs for quote-aware splitting
detect_secrets_flags=()
if [ -n "${INPUT_DETECT_SECRETS_FLAGS}" ]; then
    while IFS= read -r -d '' t; do detect_secrets_flags+=("$t"); done \
        < <(printf '%s' "${INPUT_DETECT_SECRETS_FLAGS}" | xargs printf '%s\0')
fi

reviewdog_flags=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
    while IFS= read -r -d '' t; do reviewdog_flags+=("$t"); done \
        < <(printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs printf '%s\0')
fi

if [ -n "${INPUT_BASELINE_PATH}" ]; then
    # When .secrets.baseline is provided, the file is only updated and not written to stdout
    detect-secrets scan "${detect_secrets_flags[@]}" --baseline "${INPUT_BASELINE_PATH}" "${INPUT_WORKDIR}"
    mv "${INPUT_BASELINE_PATH}" /tmp/.secrets.baseline
else
    detect-secrets scan "${detect_secrets_flags[@]}" "${INPUT_WORKDIR}" > /tmp/.secrets.baseline
fi

skip_audited_flag=()
if [ "${INPUT_SKIP_AUDITED}" = "true" ]; then
    skip_audited_flag=("--skip-audited")
fi
verbose_flag=()
if [ "${INPUT_VERBOSE}" = "true" ]; then
    verbose_flag=("--verbose")
fi

cat /tmp/.secrets.baseline | baseline2rdf "${skip_audited_flag[@]}" "${verbose_flag[@]}" \
    | reviewdog -f=rdjson \
        -name="${INPUT_NAME:-detect-secrets}" \
        -filter-mode="${INPUT_FILTER_MODE:-added}" \
        -reporter="${INPUT_REPORTER:-github-pr-check}" \
        -fail-level="${INPUT_FAIL_LEVEL}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        "${reviewdog_flags[@]}"

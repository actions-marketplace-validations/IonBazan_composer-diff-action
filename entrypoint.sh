#!/bin/bash

git config --global --add safe.directory "$GITHUB_WORKSPACE"

ARGS=()
for arg in "$@"; do
    [ -n "$arg" ] && ARGS+=("$arg")
done

# INPUT_FILTER is set automatically by GitHub Actions for Docker actions.
# It may contain multiple newline-separated glob patterns.
if [ -n "$INPUT_FILTER" ]; then
    while IFS= read -r pattern; do
        [ -n "$pattern" ] && ARGS+=("--filter=$pattern")
    done <<< "$INPUT_FILTER"
fi

OUTPUT=$(composer diff --strict "${ARGS[@]}")
EXIT_CODE=$?

set -e

echo "$OUTPUT"

echo "composer_diff_exit_code=$EXIT_CODE" >> $GITHUB_OUTPUT

delimiter="$(openssl rand -hex 8)"
echo "composer_diff<<${delimiter}" >> "${GITHUB_OUTPUT}"
echo "${OUTPUT}" >> "${GITHUB_OUTPUT}"
echo "${delimiter}" >> "${GITHUB_OUTPUT}"

if [[ " ${ARGS[*]} " == *" --strict "* ]]; then
  exit $EXIT_CODE
fi

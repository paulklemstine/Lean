#!/usr/bin/env bash
# Install the Aether git hooks from the tracked templates into .git/hooks.
# Run this after cloning the repository or whenever the tracked hooks change.

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
TRACKED_DIR="${REPO_ROOT}/Aether/.aether_workspace/git-hooks"
GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"

if [ ! -d "$TRACKED_DIR" ]; then
    echo "Error: tracked hooks directory not found at ${TRACKED_DIR}" >&2
    exit 1
fi

mkdir -p "$GIT_HOOKS_DIR"

for hook in pre-commit post-commit; do
    src="${TRACKED_DIR}/${hook}"
    dst="${GIT_HOOKS_DIR}/${hook}"

    if [ ! -f "$src" ]; then
        echo "Warning: tracked hook missing: ${src}" >&2
        continue
    fi

    cp "$src" "$dst"
    chmod +x "$dst"
    echo "Installed ${hook} → ${dst}"
done

echo "Aether git hooks installed."

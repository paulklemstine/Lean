#!/usr/bin/env bash
# Update catalog-only branch: contains only Catalog/ lean files + root README.md.
# This script runs from the current checkout (master) and updates the
# catalog-lean branch without switching the user's working tree.

set -e

BRANCH_NAME="catalog-lean"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
CURRENT_COMMIT="$(git rev-parse HEAD)"

# Ensure Catalog/ exists at the current commit.
if ! git rev-parse --quiet --verify "${CURRENT_COMMIT}:Catalog" >/dev/null 2>&1; then
    echo "[catalog-branch] No Catalog/ directory on ${CURRENT_COMMIT}, aborting"
    exit 0
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

# Use an isolated index so we can stage only the lean files without touching
# the user's working tree.
export GIT_INDEX_FILE="${TMPDIR}/index"
git read-tree --empty

# Export the current Catalog tree to a temporary worktree, then discard every
# file that is not a .lean source file (e.g. .json, .md, .orig backups, etc.).
git archive "${CURRENT_COMMIT}" -- Catalog | tar -x -C "${TMPDIR}"
find "${TMPDIR}/Catalog" -type f ! -name '*.lean' -delete
find "${TMPDIR}/Catalog" -type d -empty -delete

# Stage the filtered Catalog tree into the isolated index.
git --work-tree="${TMPDIR}" add -A Catalog

# Include the root README.md if it exists.
if git rev-parse --quiet --verify "${CURRENT_COMMIT}:README.md" >/dev/null 2>&1; then
    git show "${CURRENT_COMMIT}:README.md" > "${TMPDIR}/README.md"
    git --work-tree="${TMPDIR}" add README.md
fi

NEW_TREE="$(git write-tree)"

COMMIT_MSG=$(printf "Sync catalog-lean branch from %s (%s)\n\nCo-Authored-By: Claude <noreply@anthropic.com>" "$CURRENT_BRANCH" "$CURRENT_COMMIT")
if git rev-parse --verify "refs/heads/${BRANCH_NAME}" >/dev/null 2>&1; then
    PARENT="$(git rev-parse "${BRANCH_NAME}")"
    NEW_COMMIT=$(printf "%s" "$COMMIT_MSG" | git commit-tree "${NEW_TREE}" -p "${PARENT}")
else
    NEW_COMMIT=$(printf "%s" "$COMMIT_MSG" | git commit-tree "${NEW_TREE}")
fi

git update-ref "refs/heads/${BRANCH_NAME}" "${NEW_COMMIT}"
echo "[catalog-branch] Updated ${BRANCH_NAME} to ${NEW_COMMIT} from ${CURRENT_COMMIT}"

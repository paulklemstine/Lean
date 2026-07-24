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

# Refresh the remote-tracking ref for the generated branch. This lets the
# post-commit force-with-lease push use a current expected value instead of
# the stale info that caused repeated hook failures. Fetch failure is not
# fatal; in that case we fall back to the local branch below.
git fetch origin "refs/heads/${BRANCH_NAME}:refs/remotes/origin/${BRANCH_NAME}" 2>/dev/null || true

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

# Prefer the current remote state as parent so the new local commit is a
# descendant of origin/catalog-lean. This eliminates the stale-info race in
# the common case where this repo is the only updater of the branch.
if git rev-parse --verify "refs/remotes/origin/${BRANCH_NAME}" >/dev/null 2>&1; then
    PARENT="$(git rev-parse "refs/remotes/origin/${BRANCH_NAME}")"
    echo "[catalog-branch] Building on top of origin/${BRANCH_NAME} (${PARENT})"
elif git rev-parse --verify "refs/heads/${BRANCH_NAME}" >/dev/null 2>&1; then
    PARENT="$(git rev-parse "refs/heads/${BRANCH_NAME}")"
    echo "[catalog-branch] Fetch unavailable; building on local ${BRANCH_NAME} (${PARENT})"
    echo "[catalog-branch] (Push may fail with stale info until the next successful fetch)"
else
    NEW_COMMIT=$(printf "%s" "$COMMIT_MSG" | git commit-tree "${NEW_TREE}")
    git update-ref "refs/heads/${BRANCH_NAME}" "${NEW_COMMIT}"
    echo "[catalog-branch] Created ${BRANCH_NAME} at ${NEW_COMMIT}"
    exit 0
fi

NEW_COMMIT=$(printf "%s" "$COMMIT_MSG" | git commit-tree "${NEW_TREE}" -p "${PARENT}")
git update-ref "refs/heads/${BRANCH_NAME}" "${NEW_COMMIT}"
echo "[catalog-branch] Updated ${BRANCH_NAME} to ${NEW_COMMIT} from ${CURRENT_COMMIT}"

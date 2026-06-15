#!/usr/bin/env bash
# Update catalog-only branch: contains only Catalog/ lean files + root README.
# This script runs from the current checkout (master) and updates the
# catalog-lean branch without switching the user's working tree.

set -e

BRANCH_NAME="catalog-lean"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
CURRENT_COMMIT="$(git rev-parse HEAD)"

# Get tree SHA of just Catalog/ and README.md from current commit.
CATALOG_TREE=$(git rev-parse "$CURRENT_COMMIT:Catalog" 2>/dev/null || true)
README_BLOB=$(git rev-parse "$CURRENT_COMMIT:README.md" 2>/dev/null || true)

if [ -z "$CATALOG_TREE" ]; then
    echo "[catalog-branch] No Catalog/ directory on $CURRENT_COMMIT, aborting"
    exit 0
fi

# Build a new tree containing Catalog/ at root and README.md at root.
if [ -n "$README_BLOB" ]; then
    NEW_TREE=$(printf "040000 tree %s\tCatalog\n100644 blob %s\tREADME.md\n" "$CATALOG_TREE" "$README_BLOB" | git mktree)
else
    NEW_TREE=$(printf "040000 tree %s\tCatalog\n" "$CATALOG_TREE" | git mktree)
fi

# Create or update the catalog-lean branch.
COMMIT_MSG=$(printf "Sync catalog-lean branch from %s (%s)\n\nCo-Authored-By: Claude Fable 5 <noreply@anthropic.com>" "$CURRENT_BRANCH" "$CURRENT_COMMIT")
if git rev-parse --verify "refs/heads/$BRANCH_NAME" > /dev/null 2>&1; then
    PARENT=$(git rev-parse "$BRANCH_NAME")
    NEW_COMMIT=$(printf "%s" "$COMMIT_MSG" | git commit-tree "$NEW_TREE" -p "$PARENT")
else
    NEW_COMMIT=$(printf "%s" "$COMMIT_MSG" | git commit-tree "$NEW_TREE")
fi

git update-ref "refs/heads/$BRANCH_NAME" "$NEW_COMMIT"
echo "[catalog-branch] Updated $BRANCH_NAME to $NEW_COMMIT from $CURRENT_COMMIT"

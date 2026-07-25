#!/usr/bin/env python3
"""Recover pruned/deleted Lean files from git history.

Scans git history for all .lean files under Catalog/
that do not currently exist on disk, normalizes their target domain path
(stripping temporary job folder prefixes like 5a7b49b0_retry1_aristotle or output-final_aristotle),
extracts their contents from the last commit before deletion, and restores them.
"""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

# Pattern for temporary job/run folders created by Aristotle/Aether
RUN_FOLDER_PATTERN = re.compile(r'^([0-9a-f]{8}_retry\d+.*|output-final.*|test_job.*)$', re.IGNORECASE)

KNOWN_DOMAINS = {
    "Algebra", "Applications", "Bridges", "Combinatorics", "Computation", "Cryptography",
    "EML", "Geometry", "Logic", "MachineLearning", "Novelty", "NumberTheory", "Physics",
    "Probability", "Pythagorean", "Shared", "Speculative", "Tropical",
}

def normalize_catalog_relpath(rel_path: str) -> str:
    """Normalize a relative path under Catalog/ by stripping temporary run folders."""
    parts = Path(rel_path).parts
    if not parts or parts[0] != 'Catalog':
        return rel_path

    clean_parts = ['Catalog']
    for p in parts[1:]:
        if RUN_FOLDER_PATTERN.match(p):
            continue
        clean_parts.append(p)

    # Ensure second element (domain) is present if possible
    if len(clean_parts) > 1 and clean_parts[1] not in KNOWN_DOMAINS:
        # If second element is a sub-sub folder, try finding the domain in clean_parts
        for i, p in enumerate(clean_parts):
            if p in KNOWN_DOMAINS:
                clean_parts = ['Catalog'] + clean_parts[i:]
                break

    return "/".join(clean_parts)

def find_deleted_lean_files(repo_root: str):
    """Find all unique deleted .lean files in git log along with their deletion commits."""
    print("[Recovery] Fast scanning git log for deleted .lean files under Catalog/...")
    cmd = ['git', 'log', '--diff-filter=D', '--raw', '--format=COMMIT:%H', '--', 'Catalog/']
    res = subprocess.run(cmd, capture_output=True, text=True, cwd=repo_root)

    if res.returncode != 0:
        print(f"[Error] Git log command failed: {res.stderr}")
        sys.exit(1)

    deleted_files = {} # normalized_rel_path -> (original_git_path, commit_hash)
    current_commit = None

    for line in res.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith('COMMIT:'):
            current_commit = line[7:]
        elif '\t' in line and line.endswith('.lean'):
            parts = line.split('\t')
            status = parts[0].split()[-1] if parts[0] else ''
            filepath = parts[-1]
            if (status == 'D' or 'D' in status) and filepath.startswith('Catalog/'):
                norm_path = normalize_catalog_relpath(filepath)
                if norm_path not in deleted_files:
                    deleted_files[norm_path] = (filepath, current_commit)

    return deleted_files

def recover_files(repo_root: str, deleted_files: dict, apply: bool = False):
    """Restore deleted files from git history."""
    repo_path = Path(repo_root)
    
    # Collect existing filenames (basename) across Catalog/ to avoid duplicate restorations of renamed files
    existing_basenames = set()
    for root, dirs, files in os.walk(repo_path / 'Catalog'):
        for f in files:
            if f.endswith('.lean'):
                existing_basenames.add(f)

    restorable = []
    skipped_existing = 0

    for norm_path, (orig_path, commit) in deleted_files.items():
        target_path = repo_path / norm_path
        fname = target_path.name

        # If file exists on disk at target path or exists under Catalog by basename
        if target_path.exists() or fname in existing_basenames:
            skipped_existing += 1
            continue

        restorable.append((norm_path, orig_path, commit))

    print(f"[Recovery] Found {len(deleted_files)} unique normalized deleted .lean file paths.")
    print(f"[Recovery] {skipped_existing} already exist on disk (or were renamed).")
    print(f"[Recovery] {len(restorable)} unique pruned files ready for recovery.")

    if not apply:
        print("\n--- DRY RUN: Files to be restored ---")
        for norm_path, orig_path, commit in restorable[:30]:
            print(f"  {norm_path}  (from {commit[:8]}~1:{orig_path})")
        if len(restorable) > 30:
            print(f"  ... and {len(restorable) - 30} more files.")
        print("\nRun with --apply to perform restoration.")
        return len(restorable)

    restored_count = 0
    failed_count = 0

    for norm_path, orig_path, commit in restorable:
        # Use commit~1 to get content before deletion
        git_show_spec = f"{commit}~1:{orig_path}"
        cmd = ['git', 'show', git_show_spec]
        res = subprocess.run(cmd, capture_output=True, text=True, cwd=repo_root, errors='replace')

        if res.returncode == 0 and res.stdout.strip():
            out_file = repo_path / norm_path
            out_file.parent.mkdir(parents=True, exist_ok=True)
            out_file.write_text(res.stdout, encoding='utf-8')
            restored_count += 1
            # Add to existing basenames to prevent duplicate file creation if multiple run paths deleted the same filename
            existing_basenames.add(out_file.name)
        else:
            failed_count += 1

    print(f"\n[Recovery Complete]")
    print(f"  Successfully restored: {restored_count} .lean files")
    if failed_count > 0:
        print(f"  Failed to retrieve:   {failed_count} files")

    return restored_count

def main():
    parser = argparse.ArgumentParser(description="Recover pruned/deleted Lean files from git history")
    parser.add_argument('--repo-root', default='.', help="Repository root directory")
    parser.add_argument('--apply', action='store_true', help="Execute file restoration")
    args = parser.parse_args()

    repo_root = os.path.abspath(args.repo_root)
    deleted_files = find_deleted_lean_files(repo_root)
    recover_files(repo_root, deleted_files, apply=args.apply)

if __name__ == '__main__':
    main()

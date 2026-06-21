#!/usr/bin/env python3
"""Deduplicate and merge package JSON files in the Aether Catalog.

Usage:
    python3 dedup_packages.py [--dry-run]
"""

import json
import sys
from pathlib import Path
from collections import defaultdict

# Find catalog path dynamically or fall back to /home/raver1975/lean/Catalog
REPO_ROOT = Path(__file__).resolve().parent.parent
CATALOG = (REPO_ROOT / "Catalog").resolve()
if not CATALOG.exists():
    CATALOG = Path("/home/raver1975/lean/Catalog")

PACKAGES_DIR = CATALOG / "Applications" / "Packages"

# Files to skip in the packages directory
SKIP_FILES = {
    "index.json", "package.json", "lineage.json",
    "future_directions.json", "statement.json",
    "future_directions_snapshot.json"
}


def normalize_title(title: str) -> str:
    """Normalize a package title for base concept grouping."""
    t = title.lower().strip()
    # Strip common prefixes
    for prefix in ["close proofs:", "deepening:", "repaired:", "fill proofs:"]:
        if t.startswith(prefix):
            t = t[len(prefix):].strip()
    # Take portion before first colon to isolate core concept
    t = t.split(":")[0].strip()
    # Strip punctuation
    t = "".join(c for c in t if c.isalnum() or c.isspace())
    return " ".join(t.split())


def get_jaccard_similarity(t1: str, t2: str) -> float:
    """Compute word-level Jaccard similarity between two strings."""
    w1 = set(normalize_title(t1).split())
    w2 = set(normalize_title(t2).split())
    if not w1 or not w2:
        return 0.0
    return len(w1 & w2) / len(w1 | w2)


def pick_canonical(pkg_list: list) -> dict:
    """Select the best canonical package in a group of duplicates.
    
    Priority:
    1. Has breakthrough = True
    2. Higher quality_score
    3. Has lean_proofs as a list (and longer list)
    4. Newest date
    """
    def score_pkg(item: tuple) -> tuple:
        path, data = item
        breakthrough = bool(data.get("breakthrough", False))
        q_score = float(data.get("quality_score", data.get("score", 0.0)))
        
        lp = data.get("lean_proofs", [])
        lp_len = len(lp) if isinstance(lp, list) else (1 if lp else 0)
        
        date = data.get("date", "")
        
        # We sort ascending, so return negated scores for higher priority
        return (
            not breakthrough,  # False < True (prefer breakthrough)
            -q_score,          # Lower is better (prefer higher score)
            -lp_len,           # Lower is better (prefer more proofs)
            date,              # Alphabetical date comparison
            str(path)          # Tiebreaker
        )

    pkg_list.sort(key=score_pkg)
    return pkg_list[0]


def merge_packages(canonical_data: dict, duplicate_data: dict) -> dict:
    """Merge duplicate package metadata into canonical package."""
    merged = canonical_data.copy()
    
    # Breakthrough status
    if duplicate_data.get("breakthrough"):
        merged["breakthrough"] = True
        merged["breakthrough_score"] = max(
            merged.get("breakthrough_score", 0.0),
            duplicate_data.get("breakthrough_score", 0.0),
            merged.get("quality_score", 0.0),
            duplicate_data.get("quality_score", 0.0)
        )
        
    # Source exp IDs
    ids1 = merged.get("source_exp_ids", []) or []
    ids2 = duplicate_data.get("source_exp_ids", []) or []
    if isinstance(ids1, list) and isinstance(ids2, list):
        merged["source_exp_ids"] = sorted(list(set(ids1 + ids2)))
        
    # Keywords
    kw1 = merged.get("keywords", []) or []
    kw2 = duplicate_data.get("keywords", []) or []
    if isinstance(kw1, list) and isinstance(kw2, list):
        merged["keywords"] = sorted(list(set(kw1 + kw2)))
        
    # Key Results
    kr1 = merged.get("key_results", []) or []
    kr2 = duplicate_data.get("key_results", []) or []
    if isinstance(kr1, list) and isinstance(kr2, list):
        merged["key_results"] = sorted(list(set(kr1 + kr2)))
        
    # Lean files
    lf1 = merged.get("lean_files", []) or []
    lf2 = duplicate_data.get("lean_files", []) or []
    if isinstance(lf1, list) and isinstance(lf2, list):
        merged["lean_files"] = sorted(list(set(lf1 + lf2)))

    # Lean proofs (merge lists, keeping unique files and longest code block)
    lp1 = merged.get("lean_proofs", [])
    lp2 = duplicate_data.get("lean_proofs", [])
    
    if isinstance(lp1, list) and isinstance(lp2, list):
        merged_lp = {}
        for item in lp1:
            if isinstance(item, dict):
                f_name = item.get("file", "").split("/")[-1]
                merged_lp[f_name] = item
        for item in lp2:
            if isinstance(item, dict):
                f_name = item.get("file", "").split("/")[-1]
                if f_name not in merged_lp:
                    merged_lp[f_name] = item
                else:
                    # Keep the longer code block
                    code1 = merged_lp[f_name].get("code", "")
                    code2 = item.get("code", "")
                    if len(code2) > len(code1):
                        merged_lp[f_name] = item
        merged["lean_proofs"] = list(merged_lp.values())
    elif not lp1 and isinstance(lp2, list):
        merged["lean_proofs"] = lp2

    # Modules
    mod1 = merged.get("modules", {}) or {}
    mod2 = duplicate_data.get("modules", {}) or {}
    if isinstance(mod1, dict) and isinstance(mod2, dict):
        merged_mod = mod1.copy()
        merged_mod.update(mod2)
        merged["modules"] = merged_mod
        
    return merged


def main():
    dry_run = "--dry-run" in sys.argv
    if dry_run:
        print("=== DRY RUN MODE (no files will be deleted or modified) ===\n")

    if not PACKAGES_DIR.exists():
        print(f"Packages directory not found: {PACKAGES_DIR}")
        sys.exit(1)

    print(f"Scanning packages in {PACKAGES_DIR}...")
    packages = []
    for f in PACKAGES_DIR.glob("*.json"):
        if f.name in SKIP_FILES:
            continue
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
            packages.append((f, data))
        except Exception as e:
            print(f"  Error reading {f.name}: {e}")

    print(f"  Found {len(packages)} package files")

    # Group by similarity
    groups = []
    visited = set()

    for i, (path1, data1) in enumerate(packages):
        if path1 in visited:
            continue
        group = [(path1, data1)]
        visited.add(path1)
        
        t1 = data1.get("title", "")
        n1 = normalize_title(t1)
        
        for j, (path2, data2) in enumerate(packages[i+1:]):
            if path2 in visited:
                continue
            t2 = data2.get("title", "")
            
            # Group if titles normalize to the same concept OR Jaccard similarity >= 0.70
            if n1 == normalize_title(t2) or get_jaccard_similarity(t1, t2) >= 0.70:
                group.append((path2, data2))
                visited.add(path2)
                
        if len(group) > 1:
            groups.append(group)

    print(f"  Identified {len(groups)} groups of duplicate packages")

    total_deleted = 0
    total_modified = 0

    for idx, group in enumerate(groups):
        print(f"\nGroup #{idx+1}:")
        for p, d in group:
            print(f"  - {p.name}: \"{d.get('title')}\" (Q={d.get('quality_score', 0.0):.2f})")
            
        canonical_path, canonical_data = pick_canonical(group)
        print(f"  => Canonical chosen: {canonical_path.name}")
        
        # Merge all duplicates into canonical
        merged_data = canonical_data
        to_delete = []
        for path, data in group:
            if path == canonical_path:
                continue
            merged_data = merge_packages(merged_data, data)
            to_delete.append(path)
            
        if not dry_run:
            # Save merged canonical
            canonical_path.write_text(json.dumps(merged_data, indent=2, sort_keys=True), encoding="utf-8")
            total_modified += 1
            # Delete duplicates - DISABLED per user request
            for p in to_delete:
                # p.unlink()
                # total_deleted += 1
                print(f"  [Disabled] Would have deleted: {p.name}")
        else:
            print(f"  [Dry-Run] Would write merged data to {canonical_path.name}")
            for p in to_delete:
                print(f"  [Dry-Run] Would delete: {p.name}")
                total_deleted += 1

    print(f"\nDone! Modified: {total_modified} files, Deleted: {total_deleted} files.")

    # Rebuild website package index if update_index.py exists
    update_script = REPO_ROOT / "docs" / "update_index.py"
    if update_script.exists() and not dry_run:
        import subprocess
        print(f"Running update_index.py to rebuild packages list...")
        try:
            res = subprocess.run([sys.executable, str(update_script)], capture_output=True, text=True)
            if res.returncode == 0:
                print("  Successfully updated catalog index.")
            else:
                print(f"  Index update failed: {res.stderr}")
        except Exception as e:
            print(f"  Index update failed: {e}")


if __name__ == "__main__":
    main()

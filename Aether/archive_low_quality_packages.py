#!/usr/bin/env python3
"""Archive Research Packages with Quality Score < threshold (Default: < 75% / 0.75, approx 140 packages).

Moves low-quality packages from active directories (Packages/, docs/, Catalog/Applications/Packages/)
to Packages_Archive/ and rebuilds package indices.

Usage:
    python3 archive_low_quality_packages.py [--dry-run] [--threshold 0.75]
"""

import os
import sys
import glob
import shutil
import json
import argparse
import subprocess
from pathlib import Path

EXCLUDED_FILES = {
    "index.json", "package.json", "lineage.json", "future_directions.json",
    "statement.json", "future_directions_snapshot.json", "catalog_tree.json"
}


def get_package_quality(fpath: Path) -> float:
    """Get the quality score of a package file."""
    try:
        data = json.loads(fpath.read_text(encoding="utf-8", errors="ignore"))
        qs = data.get("quality_score")
        if qs is None:
            qs = data.get("score")
        if qs is not None:
            return float(qs)
    except Exception as e:
        print(f"  [Warning] Error reading {fpath.name}: {e}")
    return 1.0  # Default to keeping if score is unknown


def main():
    parser = argparse.ArgumentParser(description="Archive low-quality research packages")
    parser.add_argument("--dry-run", action="store_true", help="Preview without moving files")
    parser.add_argument("--threshold", type=float, default=0.75, help="Quality threshold (default: 0.75 for lowest 140 packages)")
    args = parser.parse_args()

    threshold = args.threshold
    dry_run = args.dry_run

    aether_dir = Path(__file__).parent.resolve()
    repo_root = aether_dir.parent.resolve()
    if not (repo_root / "docs").exists():
        repo_root = Path("/home/raver1975/lean")

    packages_dir = repo_root / "Packages"
    docs_dir = repo_root / "docs"
    catalog_pkgs = repo_root / "Catalog" / "Applications" / "Packages"
    archive_dir = repo_root / "Packages_Archive"

    print(f"Repo Root: {repo_root}")
    print(f"Archive Directory: {archive_dir}")
    print(f"Quality Threshold: < {threshold * 100:.1f}% ({threshold})\n")

    # Prepare archive subdirectories
    archive_packages = archive_dir / "Packages"
    archive_docs = archive_dir / "docs"
    archive_viz = archive_dir / "visualizations"
    archive_docs_viz = archive_dir / "docs_visualizations"

    if not dry_run:
        archive_packages.mkdir(parents=True, exist_ok=True)
        archive_docs.mkdir(parents=True, exist_ok=True)
        archive_viz.mkdir(parents=True, exist_ok=True)
        archive_docs_viz.mkdir(parents=True, exist_ok=True)

    # 1. Collect low-quality package filenames from docs/ and Packages/
    low_quality_files = set()
    scanned_count = 0

    for source_dir in [docs_dir, packages_dir, catalog_pkgs]:
        if not source_dir.exists():
            continue
        for fpath in source_dir.glob("*.json"):
            if fpath.name in EXCLUDED_FILES:
                continue
            scanned_count += 1
            score = get_package_quality(fpath)
            if score < threshold:
                low_quality_files.add((fpath.name, score))

    print(f"Scanned package entries across active directories.")
    print(f"Identified {len(low_quality_files)} packages with quality score < {threshold * 100:.1f}%:\n")

    low_quality_filenames = {fn for fn, _ in low_quality_files}

    # Display list of packages to archive
    sorted_low_q = sorted(low_quality_files, key=lambda x: x[1])
    for fname, score in sorted_low_q:
        print(f"  - [Q={score*100:5.1f}%] {fname}")

    if dry_run:
        print(f"\n[DRY RUN] Would archive {len(low_quality_filenames)} package files and rebuild index.")
        return

    # 2. Archive package .json files
    moved_count = 0

    # Archive from Packages/
    if packages_dir.exists():
        for fpath in packages_dir.glob("*.json"):
            if fpath.name in low_quality_filenames:
                dest = archive_packages / fpath.name
                shutil.move(str(fpath), str(dest))
                moved_count += 1

    # Archive from docs/
    if docs_dir.exists():
        for fpath in docs_dir.glob("*.json"):
            if fpath.name in low_quality_filenames:
                dest = archive_docs / fpath.name
                shutil.move(str(fpath), str(dest))
                moved_count += 1

    # Archive from Catalog/Applications/Packages/ if present
    if catalog_pkgs.exists():
        for fpath in catalog_pkgs.glob("*.json"):
            if fpath.name in low_quality_filenames:
                dest = archive_packages / fpath.name
                shutil.move(str(fpath), str(dest))

    # 3. Archive associated visualization and code files matching slugs
    slugs = {fn.replace(".json", "") for fn in low_quality_filenames}

    for viz_src, viz_dest in [(packages_dir / "visualizations", archive_viz), (docs_dir / "visualizations", archive_docs_viz)]:
        if viz_src.exists():
            for item in viz_src.iterdir():
                if item.is_file():
                    for slug in slugs:
                        if item.name.startswith(slug):
                            shutil.move(str(item), str(viz_dest / item.name))
                            break

    print(f"\nArchived {len(low_quality_filenames)} distinct packages ({moved_count} total file moves).")

    # 4. Rebuild website package index
    update_script_docs = docs_dir / "update_index.py"
    if update_script_docs.exists():
        print("Rebuilding index for docs/...")
        try:
            res = subprocess.run([sys.executable, str(update_script_docs)], cwd=str(docs_dir), capture_output=True, text=True, check=True)
            print("  Successfully updated docs index.")
        except Exception as e:
            print(f"  Error updating docs index: {e}")

    update_script_pkgs = packages_dir / "update_index.py"
    if update_script_pkgs.exists():
        print("Rebuilding index for Packages/...")
        try:
            res = subprocess.run([sys.executable, str(update_script_pkgs)], cwd=str(packages_dir), capture_output=True, text=True, check=True)
            print("  Successfully updated Packages index.")
        except Exception as e:
            print(f"  Error updating Packages index: {e}")

    print("\nArchiving complete!")


if __name__ == "__main__":
    main()

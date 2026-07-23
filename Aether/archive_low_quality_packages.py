#!/usr/bin/env python3
"""Archive Research Packages with Quality Score < 60% (as displayed in the menu) while preserving permanent package numbers.

Moves packages with quality score < 60% from active directories (Packages/, docs/)
to Packages_Archive/ and rebuilds catalog indices.

Usage:
    python3 archive_low_quality_packages.py [--dry-run] [--threshold 0.60]
"""

import os
import sys
import json
import shutil
import argparse
import subprocess
from pathlib import Path

EXCLUDED_FILES = {
    "index.json", "package.json", "lineage.json", "future_directions.json",
    "statement.json", "future_directions_snapshot.json", "catalog_tree.json"
}


def main():
    parser = argparse.ArgumentParser(description="Archive low-quality research packages (< 60% as displayed in menu)")
    parser.add_argument("--dry-run", action="store_true", help="Preview without moving files")
    parser.add_argument("--threshold", type=float, default=0.60, help="Quality threshold (default: 0.60 / 60%)")
    args = parser.parse_args()

    threshold = args.threshold
    dry_run = args.dry_run

    aether_dir = Path(__file__).parent.resolve()
    repo_root = aether_dir.parent.resolve()
    if not (repo_root / "docs").exists():
        repo_root = Path("/home/raver1975/lean")

    packages_dir = repo_root / "Packages"
    docs_dir = repo_root / "docs"
    archive_dir = repo_root / "Packages_Archive"

    idx_file = docs_dir / 'package_index.js'
    if not idx_file.exists():
        print(f"Error: {idx_file} not found.")
        sys.exit(1)

    raw_js = idx_file.read_text(encoding='utf-8')
    master_index = json.loads(raw_js.split('window.PACKAGE_INDEX = ')[1].split(';\n')[0])

    print(f"Repo Root: {repo_root}")
    print(f"Archive Directory: {archive_dir}")
    print(f"Quality Threshold: < {threshold * 100:.1f}%\n")

    low_quality_files = set()
    for pkg in master_index:
        qs = pkg.get('quality_score')
        if qs is not None:
            try:
                val = float(qs)
                if val < threshold:
                    low_quality_files.add((pkg['filename'], val, pkg.get('pkg_num')))
            except ValueError:
                pass

    print(f"Identified {len(low_quality_files)} packages with displayed quality score < {threshold * 100:.1f}%:\n")

    low_quality_filenames = {fn for fn, _, _ in low_quality_files}

    sorted_low_q = sorted(low_quality_files, key=lambda x: x[1])
    for fname, score, num in sorted_low_q:
        print(f"  - #{num}: [Q={score*100:5.1f}%] {fname}")

    if dry_run:
        print(f"\n[DRY RUN] Would archive {len(low_quality_filenames)} package files and rebuild index.")
        return

    archive_packages = archive_dir / "Packages"
    archive_docs = archive_dir / "docs"
    archive_viz = archive_dir / "visualizations"
    archive_docs_viz = archive_dir / "docs_visualizations"

    archive_packages.mkdir(parents=True, exist_ok=True)
    archive_docs.mkdir(parents=True, exist_ok=True)
    archive_viz.mkdir(parents=True, exist_ok=True)
    archive_docs_viz.mkdir(parents=True, exist_ok=True)

    moved_count = 0

    if packages_dir.exists():
        for fpath in packages_dir.glob("*.json"):
            if fpath.name in low_quality_filenames:
                dest = archive_packages / fpath.name
                shutil.move(str(fpath), str(dest))
                moved_count += 1

    if docs_dir.exists():
        for fpath in docs_dir.glob("*.json"):
            if fpath.name in low_quality_filenames:
                dest = archive_docs / fpath.name
                shutil.move(str(fpath), str(dest))
                moved_count += 1

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

    # Rebuild website package index while preserving permanent package numbers
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

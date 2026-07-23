#!/usr/bin/env python3
import json
import glob
import os
import shutil
import sys
import subprocess
from pathlib import Path

def get_tick_cycle_analytics_ids(aether_ws: Path) -> set:
    """Get experiment IDs tracked specifically by cycle_analytics.json."""
    tracked = set()
    ca_file = aether_ws / "cycle_analytics.json"
    if ca_file.exists():
        try:
            ca = json.loads(ca_file.read_text(encoding="utf-8"))
            records = ca.get("records", []) if isinstance(ca, dict) else (ca if isinstance(ca, list) else [])
            for r in records:
                if isinstance(r, dict):
                    for key in ("exp_id", "experiment_id", "id", "job_id", "project_id"):
                        val = r.get(key)
                        if val:
                            tracked.add(str(val))
        except Exception as e:
            print(f"Error reading cycle_analytics.json: {e}")

    # Also check research_memory.jsonl for Phase B complete packages
    rm_file = aether_ws / "research_memory.jsonl"
    if rm_file.exists():
        try:
            with open(rm_file, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    if not line.strip():
                        continue
                    try:
                        d = json.loads(line)
                        # Phase B completed cycles or integrated packages
                        if d.get("status") == "packaged" or d.get("phase_b") or d.get("integrated"):
                            for key in ("exp_id", "experiment_id", "job_id", "project_id"):
                                val = d.get(key)
                                if val:
                                    tracked.add(str(val))
                    except Exception:
                        pass
        except Exception as e:
            print(f"Error reading research_memory.jsonl: {e}")

    # Also check research_journal.json
    rj_file = aether_ws / "research_journal.json"
    if rj_file.exists():
        try:
            rj = json.loads(rj_file.read_text(encoding="utf-8"))
            if isinstance(rj, dict):
                for k in rj:
                    tracked.add(str(k))
            elif isinstance(rj, list):
                for item in rj:
                    if isinstance(item, dict):
                        for key in ("exp_id", "experiment_id", "job_id", "id"):
                            val = item.get(key)
                            if val:
                                tracked.add(str(val))
        except Exception as e:
            print(f"Error reading research_journal.json: {e}")

    return tracked

def main():
    repo_root = Path(__file__).parent.parent.resolve()
    aether_ws = repo_root / "Aether" / ".aether_workspace"
    packages_dir = repo_root / "Packages"
    docs_dir = repo_root / "docs"
    archive_dir = repo_root / "Packages_Archive"

    do_archive = "--archive" in sys.argv

    tick_exp_ids = get_tick_cycle_analytics_ids(aether_ws)
    print(f"Total experiment IDs tracked by Aether tick process: {len(tick_exp_ids)}")

    excl = {"index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json", "catalog_tree.json"}
    all_pkg_files = sorted([f for f in packages_dir.glob("*.json") if f.name not in excl])

    tracked_pkgs = []
    untracked_pkgs = []

    for pf in all_pkg_files:
        try:
            data = json.loads(pf.read_text(encoding="utf-8", errors="ignore"))
            eid = str(data.get("exp_id") or data.get("experiment_id") or "")
            source_eids = [str(x) for x in data.get("source_exp_ids", []) if x]
            
            is_tracked = (
                (eid and eid in tick_exp_ids) or
                (pf.stem in tick_exp_ids) or
                any(se in tick_exp_ids for se in source_eids)
            )

            if is_tracked:
                tracked_pkgs.append((pf.name, eid, data.get("title", "")))
            else:
                untracked_pkgs.append((pf.name, eid, data.get("title", "")))
        except Exception as e:
            untracked_pkgs.append((pf.name, "", f"Error reading: {e}"))

    print(f"Total active package JSON files in Packages/: {len(all_pkg_files)}")
    print(f"Tracked by active Aether tick process: {len(tracked_pkgs)}")
    print(f"Untracked / Legacy packages: {len(untracked_pkgs)}")

    print(f"\n--- Sample Untracked Packages (First 20 out of {len(untracked_pkgs)}) ---")
    for fname, eid, title in untracked_pkgs[:20]:
        print(f"  - {fname:45} | exp_id={eid:10} | {title[:40]}")

    if not do_archive:
        print("\nRun with --archive to move untracked packages to Packages_Archive/ and rebuild indices.")
        return

    # Perform archiving of untracked packages
    archive_pkgs_dir = archive_dir / "Packages"
    archive_docs_dir = archive_dir / "docs"
    archive_viz_dir = archive_dir / "visualizations"
    archive_docs_viz_dir = archive_dir / "docs_visualizations"

    archive_pkgs_dir.mkdir(parents=True, exist_ok=True)
    archive_docs_dir.mkdir(parents=True, exist_ok=True)
    archive_viz_dir.mkdir(parents=True, exist_ok=True)
    archive_docs_viz_dir.mkdir(parents=True, exist_ok=True)

    untracked_filenames = {fname for fname, _, _ in untracked_pkgs}
    slugs = {fn.replace(".json", "") for fn in untracked_filenames}

    moved_count = 0

    # 1. Move from Packages/
    for fname in untracked_filenames:
        src = packages_dir / fname
        if src.exists():
            dest = archive_pkgs_dir / fname
            shutil.move(str(src), str(dest))
            moved_count += 1

    # 2. Move from docs/
    for fname in untracked_filenames:
        src = docs_dir / fname
        if src.exists():
            dest = archive_docs_dir / fname
            shutil.move(str(src), str(dest))
            moved_count += 1

    # 3. Move associated visualizations
    for viz_src, viz_dest in [(packages_dir / "visualizations", archive_viz_dir), (docs_dir / "visualizations", archive_docs_viz_dir)]:
        if viz_src.exists():
            for item in list(viz_src.iterdir()):
                if item.is_file():
                    for slug in slugs:
                        if item.name.startswith(slug):
                            shutil.move(str(item), str(viz_dest / item.name))
                            break

    print(f"\nSuccessfully archived {len(untracked_filenames)} untracked packages ({moved_count} total file moves).")

    # 4. Rebuild index for Packages/
    update_script = packages_dir / "update_index.py"
    if update_script.exists():
        print("Rebuilding package index for Packages/...")
        subprocess.run([sys.executable, str(update_script)], cwd=str(packages_dir), check=True)

    # 5. Sync to docs/
    print("Syncing Packages/ to docs/...")
    subprocess.run(["rsync", "-a", "--delete", str(packages_dir) + "/", str(docs_dir) + "/"], check=True)

    print("Archiving complete!")

if __name__ == "__main__":
    main()

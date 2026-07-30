#!/usr/bin/env python3
"""
Reseed & Recover Future Directions:
1. Extract all 1260 directions from git commit 99d887616f.
2. Reactivate any currently pruned directions in future_directions.json.
3. Merge all missing directions into future_directions.json without duplicates.
4. Update snapshots and frontend mirror files.
"""

import subprocess
import json
from pathlib import Path
from datetime import datetime, timezone

WORKSPACE_DIR = Path(__file__).parent / ".aether_workspace"
FD_FILE = WORKSPACE_DIR / "future_directions.json"

def norm_title(t: str) -> str:
    return t.lower().strip().rstrip(".")

def get_commit_file(sha: str, rel_path: str):
    res = subprocess.run(['git', 'show', f'{sha}:{rel_path}'], capture_output=True, text=True)
    if res.returncode == 0:
        try:
            return json.loads(res.stdout)
        except Exception as e:
            print(f"Error parsing JSON from git show {sha}:{rel_path}: {e}")
    return None

def main():
    print("[Reseed] Fetching directions from commit 99d887616f...")
    old_data = get_commit_file('99d887616f', 'Aether/.aether_workspace/future_directions.json')
    old_dirs = old_data.get('directions', []) if isinstance(old_data, dict) else []
    print(f"[Reseed] Loaded {len(old_dirs)} directions from commit 99d887616f.")

    # Load current file
    if FD_FILE.exists():
        current_data = json.loads(FD_FILE.read_text(encoding="utf-8"))
    else:
        current_data = {"directions": [], "pruned": []}

    current_dirs = current_data.get("directions", []) if isinstance(current_data, dict) else []
    current_pruned = current_data.get("pruned", []) if isinstance(current_data, dict) else []

    print(f"[Reseed] Current active: {len(current_dirs)}, current pruned: {len(current_pruned)}")

    # Step 1: Reactivate all pruned directions back into active directions
    reactivated = 0
    for pd in current_pruned:
        pd["status"] = "available"
        pd["prune_reason"] = ""
        pd["pruned_at"] = ""
        pd["consumed_by_exp_id"] = ""
        current_dirs.append(pd)
        reactivated += 1

    print(f"[Reseed] Reactivated {reactivated} pruned directions back to active.")

    # Step 2: Merge missing directions from 99d887616f
    seen_ids = {d.get("id") for d in current_dirs if d.get("id")}
    seen_titles = {norm_title(d.get("title", "")) for d in current_dirs if d.get("title")}

    merged_count = 0
    for od in old_dirs:
        oid = od.get("id")
        otitle = norm_title(od.get("title", ""))

        if oid in seen_ids or otitle in seen_titles:
            continue

        # Reset status if it was pruned/failed
        od["status"] = "available"
        od["consumed_by_exp_id"] = ""
        od["prune_reason"] = ""
        od["pruned_at"] = ""

        current_dirs.append(od)
        seen_ids.add(oid)
        seen_titles.add(otitle)
        merged_count += 1

    print(f"[Reseed] Merged {merged_count} new unique directions from commit 99d887616f.")

    # Sort by ID
    current_dirs.sort(key=lambda d: d.get("id", ""))

    new_data = {
        "directions": current_dirs,
        "pruned": [],  # Permanently keep pruned empty
        "cycle_syntheses": current_data.get("cycle_syntheses", {}),
        "recent_domain_counts": current_data.get("recent_domain_counts", {}),
        "recent_theme_keywords": current_data.get("recent_theme_keywords", {}),
        "selection_log": current_data.get("selection_log", []),
    }

    FD_FILE.write_text(json.dumps(new_data, indent=2, ensure_ascii=False, sort_keys=True), encoding="utf-8")
    print(f"[Reseed] Saved total {len(current_dirs)} directions into {FD_FILE}")

    # Update FutureDirectionsManager snapshot
    try:
        from research_memory import FutureDirectionsManager
        fd_mgr = FutureDirectionsManager(WORKSPACE_DIR)
        fd_mgr._update_snapshot()
        print("[Reseed] Updated future_directions_snapshot.json")
    except Exception as e:
        print(f"[Reseed] Note: snapshot update: {e}")

    # Sync mirror files across repo
    repo_root = Path(__file__).parent.parent
    snapshot_src = repo_root / "Packages" / "future_directions_snapshot.json"
    if snapshot_src.exists():
        for mirror_dir in [repo_root / "Packages", repo_root / "docs"]:
            mirror_fd = mirror_dir / "future_directions.json"
            mirror_snapshot = mirror_dir / "future_directions_snapshot.json"
            mirror_dir.mkdir(parents=True, exist_ok=True)
            mirror_fd.write_text(json.dumps(new_data, indent=2, ensure_ascii=False, sort_keys=True), encoding="utf-8")
            mirror_snapshot.write_text(snapshot_src.read_text(encoding="utf-8"), encoding="utf-8")
            print(f"[Reseed] Synced {mirror_dir}")

if __name__ == "__main__":
    main()

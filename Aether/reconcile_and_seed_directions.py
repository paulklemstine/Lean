#!/usr/bin/env python3
"""Reconcile and recover all future directions from git history, seed scripts, and workspace state."""

import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
AETHER_DIR = Path(__file__).parent
WORKSPACE = AETHER_DIR / ".aether_workspace"
PACKAGES_DIR = REPO_ROOT / "Packages"
DOCS_DIR = REPO_ROOT / "docs"

sys.path.insert(0, str(AETHER_DIR))

def normalize_title(title: str) -> str:
    """Normalize title for fuzzy dedup."""
    if not title:
        return ""
    t = title.lower().strip()
    t = re.sub(r'[^a-z0-9]+', ' ', t).strip()
    return t

def _merge_direction_objects(d1: dict, d2: dict) -> dict:
    """Smart field-level merge of two direction dictionaries."""
    merged = dict(d1)
    for k, v in d2.items():
        if k not in merged or merged[k] is None or merged[k] == "" or merged[k] == 0:
            merged[k] = v
        elif k == "attempt_count":
            merged[k] = max(int(d1.get(k, 0) or 0), int(d2.get(k, 0) or 0))
        elif k == "outcome_quality":
            merged[k] = max(float(d1.get(k, 0.0) or 0.0), float(d2.get(k, 0.0) or 0.0))
        elif k == "consumed_by_exp_id":
            merged[k] = d1.get(k) or d2.get(k) or ""
        elif k in ("last_attempt_time", "last_reviewed_at", "timestamp"):
            t1 = str(d1.get(k) or "")
            t2 = str(d2.get(k) or "")
            merged[k] = max(t1, t2)
        elif k in ("cleanup_review_count", "decomposition_depth"):
            merged[k] = max(int(d1.get(k, 0) or 0), int(d2.get(k, 0) or 0))
        elif k == "priority_score":
            merged[k] = max(float(d1.get(k, 0.5) or 0.5), float(d2.get(k, 0.5) or 0.5))
        elif isinstance(v, list) and isinstance(merged.get(k), list):
            combined = merged[k] + [x for x in v if x not in merged[k]]
            merged[k] = combined
        elif isinstance(v, str) and isinstance(merged.get(k), str):
            if len(v) > len(merged[k]):
                merged[k] = v
    return merged

def collect_directions_from_git():
    """Recover directions from past git commits over the last 4 days."""
    directions_map = {} # key -> direction dict
    print("[Reconcile] Scanning git commit history for future_directions.json...")
    
    files_to_check = [
        "Aether/.aether_workspace/future_directions.json",
        "Packages/future_directions.json",
        "docs/future_directions.json",
    ]
    
    # Get commit hashes
    cmd = ["git", "log", "--since=4 days ago", "--format=%H"]
    res = subprocess.run(cmd, cwd=str(REPO_ROOT), capture_output=True, text=True)
    commits = res.stdout.splitlines()
    print(f"[Reconcile] Found {len(commits)} commits to inspect.")

    for commit in commits:
        for rel_file in files_to_check:
            try:
                show_res = subprocess.run(
                    ["git", "show", f"{commit}:{rel_file}"],
                    cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=10
                )
                if show_res.returncode == 0 and show_res.stdout.strip():
                    data = json.loads(show_res.stdout)
                    dirs = data.get("directions", []) if isinstance(data, dict) else (data if isinstance(data, list) else [])
                    for d in dirs:
                        if not isinstance(d, dict):
                            continue
                        did = d.get("id")
                        title_norm = normalize_title(d.get("title", ""))
                        key = did if (did and not did.startswith("seed_")) else (title_norm or did)
                        if not key:
                            continue
                        if key in directions_map:
                            directions_map[key] = _merge_direction_objects(directions_map[key], d)
                        else:
                            directions_map[key] = d
            except Exception:
                pass

    print(f"[Reconcile] Recovered {len(directions_map)} unique directions from git history.")
    return directions_map

def collect_seed_directions():
    """Load directions from seed_directions.py and reseed_directions.py."""
    print("[Reconcile] Loading seed directions from seed_directions.py and reseed_directions.py...")
    seeds = []
    
    # 1. seed_directions.py
    try:
        from seed_directions import get_seed_directions
        seed_objs = get_seed_directions()
        for s in seed_objs:
            if hasattr(s, "to_dict"):
                seeds.append(s.to_dict())
            elif hasattr(s, "__dict__"):
                seeds.append(dict(s.__dict__))
            elif isinstance(s, dict):
                seeds.append(s)
        print(f"[Reconcile] Loaded {len(seed_objs)} directions from seed_directions.py")
    except Exception as e:
        print(f"[Reconcile] Warning loading seed_directions.py: {e}")

    # 2. reseed_directions.py
    try:
        from reseed_directions import SEEDS
        for s in SEEDS:
            if isinstance(s, dict):
                seeds.append(s)
        print(f"[Reconcile] Loaded {len(SEEDS)} directions from reseed_directions.py")
    except Exception as e:
        print(f"[Reconcile] Warning loading reseed_directions.py: {e}")

    return seeds

def main():
    merged_map = {}

    # 1. Load current local workspace directions
    ws_file = WORKSPACE / "future_directions.json"
    if ws_file.exists():
        try:
            ws_data = json.loads(ws_file.read_text(encoding="utf-8"))
            ws_dirs = ws_data.get("directions", []) if isinstance(ws_data, dict) else []
            for d in ws_dirs:
                did = d.get("id")
                norm_t = normalize_title(d.get("title", ""))
                key = did if (did and not did.startswith("seed_")) else (norm_t or did)
                if key:
                    merged_map[key] = d
            print(f"[Reconcile] Loaded {len(ws_dirs)} directions from current workspace future_directions.json")
        except Exception as e:
            print(f"[Reconcile] Warning loading current workspace file: {e}")

    # 2. Merge git history directions
    git_dirs = collect_directions_from_git()
    for key, d in git_dirs.items():
        if key in merged_map:
            merged_map[key] = _merge_direction_objects(merged_map[key], d)
        else:
            merged_map[key] = d

    # 3. Merge seed directions
    seed_dirs = collect_seed_directions()
    for d in seed_dirs:
        norm_t = normalize_title(d.get("title", ""))
        did = d.get("id")
        key = did if (did and not did.startswith("seed_")) else (norm_t or did)
        if key:
            if key in merged_map:
                merged_map[key] = _merge_direction_objects(merged_map[key], d)
            else:
                merged_map[key] = d

    # Sort final directions by timestamp (newest first or by priority)
    def get_timestamp(item):
        t = item.get("timestamp")
        if isinstance(t, (int, float)):
            return t
        if isinstance(t, str):
            try:
                return datetime.fromisoformat(t.replace("Z", "+00:00")).timestamp()
            except Exception:
                pass
        return 0

    all_directions = list(merged_map.values())
    all_directions.sort(key=get_timestamp)

    print(f"\n[Reconcile] Total reconciled unique directions: {len(all_directions)}")

    final_payload = {
        "cycle_syntheses": {},
        "directions": all_directions
    }

    # Write to workspace
    WORKSPACE.mkdir(parents=True, exist_ok=True)
    ws_file.write_text(json.dumps(final_payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[Reconcile] Saved reconciled directions to {ws_file}")

    # Write to Packages/
    PACKAGES_DIR.mkdir(parents=True, exist_ok=True)
    (PACKAGES_DIR / "future_directions.json").write_text(json.dumps(final_payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    # Run update_index.py in Packages/ and rsync to docs/
    print("[Reconcile] Rebuilding website index...")
    r = subprocess.run([sys.executable, "update_index.py"], cwd=str(PACKAGES_DIR), capture_output=True, text=True)
    if r.returncode == 0:
        print(f"[Reconcile] {r.stdout.strip()}")
    else:
        print(f"[Reconcile] update_index.py error: {r.stderr}")

    DOCS_DIR.mkdir(parents=True, exist_ok=True)
    subprocess.run(["rsync", "-a", str(PACKAGES_DIR) + "/", str(DOCS_DIR) + "/"], capture_output=True)
    print("[Reconcile] Synced to docs/.")

if __name__ == "__main__":
    main()

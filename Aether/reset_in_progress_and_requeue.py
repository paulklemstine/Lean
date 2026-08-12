#!/usr/bin/env python3
"""Reset in-progress future directions and clear inflight jobs queue for key migration.

Resets all directions in Packages/future_directions.json with status="in_progress"
back to status="available" (clearing consumed_by_exp_id), clears inflight_jobs.json,
and syncs snapshots.
"""

import json
import sys
from pathlib import Path

AETHER_DIR = Path(__file__).parent
sys.path.insert(0, str(AETHER_DIR))

from research_memory import FutureDirectionsManager


def main():
    print("=" * 70)
    print("AETHER: RESETTING IN-PROGRESS DIRECTIONS & INFLIGHT QUEUE")
    print("=" * 70)

    workspace = AETHER_DIR / ".aether_workspace"
    fd_manager = FutureDirectionsManager(workspace)

    # 1. Reset all in_progress directions to available
    result = fd_manager.reset_directions()
    print(f"[Reset] Directions updated: {result['released']} released to 'available' "
          f"(total directions: {result['total']})")

    # 2. Clear inflight jobs json
    inflight_file = workspace / "inflight_jobs.json"
    if inflight_file.exists():
        inflight_file.write_text("{}", encoding="utf-8")
        print(f"[Reset] Cleared {inflight_file}")
    else:
        print("[Reset] inflight_jobs.json did not exist; initialized clean")

    print("\n[Done] Reset complete! All uncompleted directions are requeued as available.")


if __name__ == "__main__":
    main()

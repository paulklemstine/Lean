#!/usr/bin/env python3
"""Analyze Aristotle reasoning logs.

After projects run, this script reads all .aether_workspace/reasoning_logs/
files and produces a summary table for analysis.

Usage:
    python3 analyze_reasoning_logs.py [--last N]
"""

import json
import sys
from pathlib import Path


def main():
    workspace = Path("/home/raver1975/lean/Aether/.aether_workspace")
    logs_dir = workspace / "reasoning_logs"
    if not logs_dir.exists():
        print(f"No logs at {logs_dir}")
        return

    logs = sorted(logs_dir.glob("*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    if "--last" in sys.argv:
        try:
            n = int(sys.argv[sys.argv.index("--last") + 1])
            logs = logs[:n]
        except (ValueError, IndexError):
            pass

    print(f"=== Aristotle Reasoning Log Analysis ({len(logs)} projects) ===\n")
    print(f"{'job_id':<10} {'status':<10} {'duration':<10} {'checkpts':<10} {'stages':<8} {'stalls':<8} {'pct/min':<10} {'domain'}")
    print("-" * 110)

    durations = []
    for path in logs:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue

        job_id = data.get("job_id", path.stem)[:8]
        status = data.get("final_status", "?")
        duration = data.get("total_duration_seconds", 0) or 0
        n_chk = len(data.get("checkpoints", []))
        n_stg = len(data.get("stages", []))
        domain = data.get("domain", "?")[:15]

        # Recompute summary stats
        checkpoints = data.get("checkpoints", [])
        n_stalls = 0
        for i in range(1, len(checkpoints)):
            prev, curr = checkpoints[i-1], checkpoints[i]
            if (curr.get("percent_complete", 0) == prev.get("percent_complete", 0)
                and curr.get("elapsed_seconds", 0) - prev.get("elapsed_seconds", 0) > 60):
                n_stalls += 1

        pct_per_min = 0
        if duration > 0:
            final_pct = data.get("final_percent", 0)
            pct_per_min = round(final_pct / (duration / 60), 2)

        if duration:
            durations.append(duration)

        print(f"{job_id:<10} {status:<10} {duration:<10.0f} {n_chk:<10} {n_stg:<8} {n_stalls:<8} {pct_per_min:<10} {domain}")

    if durations:
        print(f"\n=== Summary ===")
        print(f"Total projects: {len(durations)}")
        print(f"Avg duration: {sum(durations)/len(durations):.0f}s ({sum(durations)/len(durations)/60:.1f}min)")
        print(f"Max duration: {max(durations):.0f}s ({max(durations)/60:.1f}min)")
        print(f"Min duration: {min(durations):.0f}s ({min(durations)/60:.1f}min)")


if __name__ == "__main__":
    main()

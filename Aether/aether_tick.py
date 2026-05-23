#!/usr/bin/env python3
"""Aether Tick: One-shot pipeline step for CI.

Polls for completed Aristotle jobs, integrates them, dispatches new ones,
then exits. Designed for hourly cron — each run takes 2-5 minutes.

Usage:
    python3 aether_tick.py
    python3 aether_tick.py --max-inflight 9
"""

import argparse
import asyncio
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from knowledge_extractor import KnowledgeExtractor

TICK_COUNTER_PATH = Path(__file__).parent / ".aether_workspace" / "tick_counter.json"
MAX_TICKS_PER_HOUR = 2


def check_tick_rate_limit() -> bool:
    """Return True if we're within the 2-ticks-per-hour limit."""
    now = datetime.now(timezone.utc)
    one_hour_ago = now - timedelta(hours=1)

    ticks = []
    if TICK_COUNTER_PATH.exists():
        try:
            with open(TICK_COUNTER_PATH) as f:
                data = json.load(f)
                ticks = data.get("ticks", [])
        except (json.JSONDecodeError, OSError):
            ticks = []

    # Prune entries older than 1 hour
    recent = []
    for t in ticks:
        try:
            ts = datetime.fromisoformat(t["timestamp"])
            if ts > one_hour_ago:
                recent.append(t)
        except (KeyError, ValueError):
            continue

    if len(recent) >= MAX_TICKS_PER_HOUR:
        print(f"[Tick] Rate limit: {len(recent)}/{MAX_TICKS_PER_HOUR} ticks in the last hour, skipping")
        with open(TICK_COUNTER_PATH, "w") as f:
            json.dump({"ticks": recent}, f)
        return False

    # Record this tick
    recent.append({"timestamp": now.isoformat()})
    TICK_COUNTER_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(TICK_COUNTER_PATH, "w") as f:
        json.dump({"ticks": recent}, f)
    print(f"[Tick] Tick count: {len(recent)}/{MAX_TICKS_PER_HOUR} in the last hour")
    return True


async def tick(extractor: KnowledgeExtractor, max_inflight: int) -> None:
    """Run one tick inside a single event loop."""
    # Rate limit: max 2 ticks per hour
    if not check_tick_rate_limit():
        return

    # 1. Poll inflight jobs
    extractor._load_inflight()
    inflight_count = len(extractor.inflight)
    print(f"[Tick] {inflight_count} inflight jobs")

    completed_jobs = []
    if inflight_count > 0:
        completed_jobs = await extractor.poll_all()
        print(f"[Tick] {len(completed_jobs)} jobs completed since last tick")

    # 2. Integrate completed jobs
    for job in completed_jobs:
        if job.status != "completed":
            print(f"[Tick] Skipping {job.job_id[:8]} (status={job.status})")
            continue

        print(f"[Tick] Integrating {job.job_id[:8]}: {job.concept.title[:60]}")
        job = await extractor.extract_async(job)
        extractor._save_inflight()

        if job.error_message:
            print(f"[Tick] Extract failed: {job.error_message}")
            # Auth errors (403/401) mean we can never download this project's
            # results — it belongs to a different account. Mark as failed and
            # release the future direction so it can be retried.
            if "authentication error" in job.error_message or "403" in job.error_message or "401" in job.error_message:
                print(f"[Tick] Auth error on {job.job_id[:8]} — releasing direction")
                extractor._release_direction(job)
                # Remove from inflight so we don't keep retrying
                if job.project_id in extractor.inflight:
                    del extractor.inflight[job.project_id]
                extractor.failed_count += 1
            continue

        job = extractor.evaluate(job)
        extractor._save_inflight()

        job = await extractor.integrate_async(job)
        extractor._save_inflight()

        # Extract future directions
        extractor._extract_future_directions(job)

        # Cleanup and commit
        job = extractor.cleanup_catalog(job)
        extractor.commit(job)
        print(f"[Tick] Integrated {job.job_id[:8]}: score={job.quality_score:.3f}, "
              f"files={job.files_integrated}, theorems={job.theorem_count}")

    # 3. Dispatch new jobs up to max_inflight
    current_inflight = len([j for j in extractor.inflight.values()
                           if j.status not in ("completed", "failed", "integrated", "rejected")])
    slots_available = max_inflight - current_inflight

    if slots_available > 0:
        print(f"[Tick] {slots_available} dispatch slots available")
        for _ in range(slots_available):
            try:
                job = extractor.discover()
                job = await extractor.dispatch_async(job)
                if job.project_id:
                    extractor.inflight[job.project_id] = job
                    print(f"[Tick] Dispatched {job.project_id[:8]}: {job.concept.title[:60]}")
                else:
                    print(f"[Tick] Dispatch failed for {job.concept.title[:60]}")
                    break
            except Exception as e:
                print(f"[Tick] Dispatch error: {e}")
                break
        extractor._save_inflight()
    else:
        print(f"[Tick] No dispatch slots ({current_inflight}/{max_inflight} inflight)")

    # Summary
    remaining = len([j for j in extractor.inflight.values()
                    if j.status not in ("completed", "failed", "integrated", "rejected")])
    print(f"[Tick] Done — {len(completed_jobs)} integrated, {remaining} still inflight")


def main():
    parser = argparse.ArgumentParser(description="Aether Tick: one-shot CI pipeline step")
    parser.add_argument("--max-inflight", type=int, default=9)
    parser.add_argument("--config", type=str, default=None)
    parser.add_argument("--ollama-cloud", action="store_true")
    args = parser.parse_args()

    # Build config
    if args.ollama_cloud:
        import yaml
        config_path = Path(args.config) if args.config else Path(__file__).parent / "config.yaml"
        config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}
        config.setdefault("pi_agent", {}).setdefault("ollama_cloud", {})["enabled"] = True
        extractor = KnowledgeExtractor(config=config)
    else:
        extractor = KnowledgeExtractor(config_path=args.config)

    print(f"[Tick] Aether tick starting — max_inflight={args.max_inflight}")
    asyncio.run(tick(extractor, args.max_inflight))


if __name__ == "__main__":
    main()
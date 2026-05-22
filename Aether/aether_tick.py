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
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from knowledge_extractor import KnowledgeExtractor


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

    # 1. Load inflight jobs and poll for completions
    extractor._load_inflight()
    inflight_count = len(extractor.inflight)
    print(f"[Tick] {inflight_count} inflight jobs")

    completed_jobs = []
    if inflight_count > 0:
        completed_jobs = asyncio.run(extractor.poll_all())
        print(f"[Tick] {len(completed_jobs)} jobs completed since last tick")

    # 2. Integrate completed jobs
    for job in completed_jobs:
        if job.status != "completed":
            print(f"[Tick] Skipping {job.job_id[:8]} (status={job.status})")
            continue

        print(f"[Tick] Integrating {job.job_id[:8]}: {job.concept.title[:60]}")
        job = extractor.extract(job)
        extractor._save_inflight()

        if job.error_message:
            print(f"[Tick] Extract failed: {job.error_message}")
            continue

        job = extractor.evaluate(job)
        extractor._save_inflight()

        # integrate_async needs an event loop
        job = asyncio.run(extractor.integrate_async(job))
        extractor._save_inflight()

        # Extract future directions
        if job.status == "integrated" and job.job_id:
            extractor._extract_future_directions(job)

        # Cleanup and commit
        job = extractor.cleanup_catalog(job)
        extractor.commit(job)
        print(f"[Tick] Integrated {job.job_id[:8]}: score={job.quality_score:.3f}, "
              f"files={job.files_integrated}, theorems={job.theorem_count}")

    # 3. Dispatch new jobs up to max_inflight
    current_inflight = len([j for j in extractor.inflight.values()
                           if j.status not in ("completed", "failed", "integrated", "rejected")])
    slots_available = args.max_inflight - current_inflight

    if slots_available > 0:
        print(f"[Tick] {slots_available} dispatch slots available")
        for _ in range(slots_available):
            try:
                job = extractor.discover()
                job = extractor.dispatch(job)
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
        print(f"[Tick] No dispatch slots ({current_inflight}/{args.max_inflight} inflight)")

    # Summary
    remaining = len([j for j in extractor.inflight.values()
                    if j.status not in ("completed", "failed", "integrated", "rejected")])
    print(f"[Tick] Done — {len(completed_jobs)} integrated, {remaining} still inflight")


if __name__ == "__main__":
    main()
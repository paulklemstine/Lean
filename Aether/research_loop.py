#!/usr/bin/env python3
"""Aether Continuous Research Loop

The production loop that runs Aether. Architecture:

    Aether (orchestrator)
      → Pi (brains: decides WHAT to research, HOW to present it)
        → "Prove this theorem about X. Create python demos.
           Write a research paper with a Scientific American discussion.
           Show useful applications."
      → Aristotle (worker: proves theorems, creates all artifacts)
      → Pi (integrator: evaluates quality, places in Catalog)
      → Aether (commits, tracks metrics, loops)

Key principle: Aristotle has creative freedom. We tell it WHAT outcomes
we need (verified math, demos, papers, applications) but not HOW to
organize or name them. Pi evaluates and integrates the results.

Usage:
    python3 research_loop.py --single-cycle
    python3 research_loop.py --continuous --max-inflight 3
    python3 research_loop.py --dry-run --domain tropical
"""

import argparse
import asyncio
import sys
import datetime
from pathlib import Path

# Add Aether to path
sys.path.insert(0, str(Path(__file__).parent))

from knowledge_extractor import KnowledgeExtractor


class TeeWriter:
    """Duplicates stdout to both the terminal and a log file."""

    def __init__(self, terminal, log_file):
        self.terminal = terminal
        self.log_file = log_file
        self._is_duplicate = False
        try:
            import os
            if hasattr(terminal, "fileno") and hasattr(log_file, "fileno"):
                stat_term = os.fstat(terminal.fileno())
                stat_log = os.fstat(log_file.fileno())
                if stat_term.st_ino > 0 and stat_term.st_ino == stat_log.st_ino and stat_term.st_dev == stat_log.st_dev:
                    self._is_duplicate = True
        except Exception:
            pass

    def write(self, message):
        self.terminal.write(message)
        if not self._is_duplicate:
            self.log_file.write(message)
            self.log_file.flush()

    def flush(self):
        self.terminal.flush()
        if not self._is_duplicate:
            self.log_file.flush()

    def fileno(self):
        return self.terminal.fileno()

    def isatty(self):
        return self.terminal.isatty()


def main():
    parser = argparse.ArgumentParser(
        description="Aether: Autonomous Mathematical Research Engine\n\n"
        "Architecture: Pi (brains) → Aristotle (worker) → Pi (integrator) → Aether (orchestrator)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--single-cycle", action="store_true",
                        help="Run one complete research cycle")
    parser.add_argument("--continuous", action="store_true",
                        help="Run continuous loop until max_cycles")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what Pi would dispatch without sending to Aristotle")
    parser.add_argument("--domain", type=str, default=None,
                        help="Force a specific research domain")
    parser.add_argument("--max-inflight", type=int, default=3,
                        help="Max concurrent Aristotle jobs (continuous mode)")
    parser.add_argument("--max-cycles", type=int, default=50,
                        help="Max dispatch cycles (continuous mode)")
    parser.add_argument("--poll-interval", type=int, default=60,
                        help="Seconds between polls (continuous mode)")
    parser.add_argument("--config", type=str, default=None,
                        help="Path to config.yaml")
    args = parser.parse_args()

    # Mirror all console output to a timestamped log file
    log_dir = Path(__file__).parent / ".aether_workspace" / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    log_path = log_dir / f"aether_{timestamp}.log"
    log_file = open(log_path, "a", encoding="utf-8")
    sys.stdout = TeeWriter(sys.__stdout__, log_file)
    sys.stderr = TeeWriter(sys.__stderr__, log_file)
    print(f"[Aether] Logging to {log_path}")

    # Enable Ollama Cloud fallback in config BEFORE constructing KnowledgeExtractor
    # Ollama Cloud tier removed (2026-08-21): Aristotle is the only LLM.
    extractor = KnowledgeExtractor(config_path=args.config)

    print("=" * 60)
    print("AETHER: Autonomous Mathematical Knowledge Discovery Engine")
    print("=" * 60)
    print(f"  Catalog:  {extractor.catalog_root}")
    print(f"  Pi model: {extractor.config.get('pi_agent', {}).get('model', 'unknown')}")
    print(f"  Aristotle: configured = {bool(extractor.config.get('aristotle', {}).get('api_key'))}")
    print(f"  Verified files: {len(list(extractor.catalog_root.glob('**/*.lean')))}")
    print("=" * 60)

    if args.dry_run:
        job = extractor.discover(forced_domain=args.domain)
        extractor.dispatch(job, dry_run=True)
        print(f"\n[Dry Run] Would dispatch: {job.concept.title}")
        print(f"  Domain: {job.concept.domain}")
        print(f"  Mode: {job.concept.research_mode}")
        print(f"  Novelty: {job.concept.novelty_estimate:.2f}")
        print(f"  Breakthrough: {job.concept.breakthrough_potential:.2f}")
        print(f"  Description: {job.concept.concept_description[:200]}...")

    elif args.single_cycle:
        print(f"\n[Single Cycle] Starting...")
        job = extractor.run_single_cycle(forced_domain=args.domain)
        print(f"\n[Complete] Status: {job.status}")
        print(f"  Score: {job.quality_score:.3f}")
        print(f"  Theorems: {job.theorem_count}, Sorries: {job.sorry_count}")
        print(f"  Has demo: {bool(job.result_demo)}")
        print(f"  Has paper: {bool(job.result_paper)}")

    elif args.continuous:
        print(f"\n[Continuous] max_inflight={args.max_inflight}, "
              f"max_cycles={args.max_cycles}, poll={args.poll_interval}s")
        asyncio.run(extractor.run_continuous(
            max_inflight=args.max_inflight,
            max_cycles=args.max_cycles,
            poll_interval=args.poll_interval,
        ))

    else:
        print("\nUse --single-cycle, --continuous, or --dry-run")
        print("Examples:")
        print("  python3 research_loop.py --dry-run")
        print("  python3 research_loop.py --single-cycle --domain tropical")
        print("  python3 research_loop.py --continuous --max-inflight 3")


if __name__ == "__main__":
    main()
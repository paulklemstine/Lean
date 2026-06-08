#!/usr/bin/env python3
"""Prune Catalog: CLI interface for semantic catalog curation.

Groups Lean 4 files by semantic similarity, round-robins through similarity
groups, and queries Pi-Agent to select the canonical file and prune duplicate,
trivial, or redundant theorems.
"""

import argparse
import sys
from pathlib import Path

# Add Aether to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from pi_agent_client import PiAgentClient
from catalog_pruner import CatalogPruner


def main():
    parser = argparse.ArgumentParser(description="Prune Catalog .lean files")
    parser.add_argument("--all", action="store_true", help="Process all files/groups in one run")
    parser.add_argument("--batch-size", type=int, default=15, help="Number of files to review in this batch")
    parser.add_argument("--dry-run", action="store_true", help="Preview without making changes")
    args = parser.parse_args()

    catalog_root = Path(__file__).parent.parent / "Catalog"
    workspace = Path(__file__).parent / ".aether_workspace"

    print("[Prune] Initializing Pi-Agent...")
    pi_agent = PiAgentClient()
    pruner = CatalogPruner(catalog_root, pi_agent, workspace)

    target_count = 10000 if args.all else args.batch_size
    if args.dry_run:
        print("=== DRY RUN MODE ===")

    try:
        pruner.prune(target_remove_count=target_count, dry_run=args.dry_run)
    except Exception as e:
        print(f"[Prune] Curation failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
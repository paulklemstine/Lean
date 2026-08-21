#!/usr/bin/env python3
"""One-time migration: re-split legacy merged-blob future directions.

The pre-2026-08-16 ingestion stored whole FUTURE_DIRECTIONS documents as
single pseudo-directions (title = first non-header line, description = the
entire document, priority 0.75). 520 of these polluted the available pool.

For each legacy blob this script runs the improved section-aware splitter on
the blob's description; when the re-split yields at least one direction, the
blob is marked pruned (reason: re-split) and the new directions are added
(dedup + quality gate apply). Blobs that still cannot be split are left
untouched.

Usage:
    python3 migrate_legacy_fd_blobs.py --dry-run   # report only
    python3 migrate_legacy_fd_blobs.py --apply     # perform the migration
"""
import argparse
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from research_memory import FutureDirectionsManager  # noqa: E402
from fd_splitter import split_directions_from_text  # noqa: E402


def is_legacy_blob(d) -> bool:
    desc = d.description or ""
    return (
        d.status == "available"
        and desc.lstrip().startswith("#")
        and "future direction" in desc[:400].lower()
        and len(desc) >= 1000
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="perform the migration")
    args = ap.parse_args()

    mgr = FutureDirectionsManager(Path(__file__).parent / ".aether_workspace")
    blobs = [d for d in mgr._directions if is_legacy_blob(d)]
    print(f"[Migration] Legacy merged-blob directions found: {len(blobs)}")

    resplit_total = 0
    touched = 0
    for d in blobs:
        if not args.apply:
            # Dry-run: probe against a throwaway manager, add nothing
            probe = FutureDirectionsManager(Path(tempfile_dir()))
            probe._directions = []
            count, _ = split_directions_from_text(
                probe, d.description, source_exp_id=d.source_exp_id or d.id,
                source_path="resplit_migration",
            )
        else:
            # Apply: split against the SAME live manager instance so dedup sees
            # everything added so far, then retire the blob on that same
            # instance before saving. (The first cut mutated a stale object
            # from a different manager — the blobs were never retired and the
            # pool ended up with blobs and their children duplicated.)
            count, _ = split_directions_from_text(
                mgr, d.description, source_exp_id=d.source_exp_id or d.id,
                source_path="resplit_migration",
            )
            if count >= 1:
                d.status = "pruned"
                d.prune_reason = f"legacy merged blob re-split into {count} directions"
                d.pruned_at = time.strftime("%Y-%m-%dT%H:%M:%SZ")
                mgr._save()
        if count >= 1:
            resplit_total += count
            touched += 1
            print(f"  {d.id} -> {count} directions "
                  f"(title: {d.title[:50]!r})")

    print(f"[Migration] {'APPLIED' if args.apply else 'DRY-RUN'}: "
          f"{touched} blobs re-splittable into {resplit_total} directions; "
          f"{len(blobs) - touched} left untouched")
    return 0


def tempfile_dir() -> str:
    import tempfile
    return tempfile.mkdtemp()


if __name__ == "__main__":
    raise SystemExit(main())

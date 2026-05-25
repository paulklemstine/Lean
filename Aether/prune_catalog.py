#!/usr/bin/env python3
"""Prune Catalog: batch quality review of .lean files.

Processes files in batches, using quick heuristics for auto-decisions
and PI-agent for gray-area files. Moves removed files to Catalog/old/
instead of deleting them.

Usage:
    python3 prune_catalog.py                  # Process one batch
    python3 prune_catalog.py --all           # Process all files
    python3 prune_catalog.py --batch-size 20 # Custom batch size
    python3 prune_catalog.py --dry-run       # Preview without changes
"""

import argparse
import json
import os
import re
import shutil
from pathlib import Path
from typing import Dict, List, Optional

# Add Aether to path for pi_agent_client
import sys
sys.path.insert(0, str(Path(__file__).parent))

from pi_agent_client import PiAgentClient


CATALOG_ROOT = Path(__file__).parent.parent / "Catalog"
OLD_DIR = CATALOG_ROOT / "old"
BATCH_SIZE = 10

# Heuristic thresholds
SORRY_FREE_IMMORTALIZE_LINES = 80
SORRY_FREE_IMMORTALIZE_THEOREMS = 2
REMOVE_MAX_LINES_TRIVIAL = 20
REMOVE_MAX_LINES_NO_THEOREMS = 25


def scan_file(f: Path, catalog_root: Path) -> Optional[Dict]:
    """Quick heuristic scan of a .lean file."""
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None

    lines = content.split("\n")
    line_count = len([l for l in lines if l.strip() and not l.strip().startswith("--")])
    has_sorry = "sorry" in content
    theorem_count = len(re.findall(r"^\s*(theorem|lemma)\s", content, re.MULTILINE))
    has_deep_proof = bool(re.search(
        r"\b(induction|rcases|by_contra|omega|linarith|field_simp|ring_nf)\b", content
    ))
    is_trivial_only = not has_deep_proof and bool(re.search(
        r"\b(trivial|simp|rfl|decide|native_decide)\b", content
    ))

    rel_path = str(f.relative_to(catalog_root))
    parts = f.relative_to(catalog_root).parts
    domain = parts[0] if parts else "Unknown"

    return {
        "path": rel_path,
        "name": f.name,
        "domain": domain,
        "lines": line_count,
        "sorries": has_sorry,
        "theorems": theorem_count,
        "deep_proof": has_deep_proof,
        "trivial_only": is_trivial_only,
        "abs_path": f,
        "content_preview": content[:500],
    }


def auto_classify(candidate: Dict) -> str:
    """Classify a file as 'keep', 'remove', or 'review'.

    Returns:
        'keep' — clearly worth keeping
        'remove' — clearly junk
        'review' — gray area, needs PI agent
    """
    # Clear keep: sorry-free, substantial, has theorems
    if (not candidate["sorries"]
            and candidate["lines"] >= SORRY_FREE_IMMORTALIZE_LINES
            and candidate["theorems"] >= SORRY_FREE_IMMORTALIZE_THEOREMS):
        return "keep"

    # Clear remove: sorry-containing AND trivial AND short
    if candidate["sorries"] and candidate["trivial_only"] and candidate["lines"] < REMOVE_MAX_LINES_TRIVIAL:
        return "remove"

    # Clear remove: very short, no theorems, trivial-only
    if candidate["theorems"] == 0 and candidate["lines"] < REMOVE_MAX_LINES_NO_THEOREMS and candidate["trivial_only"]:
        return "remove"

    # Clear remove: sorry-containing, very short, no deep proofs
    if candidate["sorries"] and candidate["lines"] < REMOVE_MAX_LINES_TRIVIAL and not candidate["deep_proof"]:
        return "remove"

    # Everything else needs review
    return "review"


def build_review_prompt(batch: List[Dict]) -> str:
    """Build the PI agent prompt for a batch of gray-area files."""
    summaries = []
    for c in batch:
        tag = "deep" if c["deep_proof"] else ("trivial" if c["trivial_only"] else "mixed")
        summaries.append(
            f"  {c['path']} | {c['theorems']} theorems | {c['lines']} lines | "
            f"sorry={'yes' if c['sorries'] else 'no'} | proofs={tag}"
        )
    listing = "\n".join(summaries)

    return (
        "You are a Lean 4 theorem curator for the Aether research engine.\n"
        "Review these .lean file summaries. For each, decide:\n"
        "- KEEP: contains genuinely useful definitions, theorems, or non-trivial proofs\n"
        "- REMOVE: trivial stubs, sorry-heavy placeholders, or near-empty files with no substance\n\n"
        "Be generous with keeping (preserve good work). Only REMOVE clear junk.\n"
        "Respond in JSON:\n"
        '{\n'
        '  "keep": ["path/to/File1.lean", ...],\n'
        '  "remove": ["path/to/Junk1.lean", ...],\n'
        '  "notes": "brief summary"\n'
        '}'
    ), f"Lean files to review ({len(batch)} gray-area files):\n\n{listing}"


def main():
    parser = argparse.ArgumentParser(description="Prune Catalog .lean files")
    parser.add_argument("--all", action="store_true", help="Process all files, not just one batch")
    parser.add_argument("--batch-size", type=int, default=BATCH_SIZE, help="Files per PI-agent batch")
    parser.add_argument("--dry-run", action="store_true", help="Preview without changes")
    args = parser.parse_args()

    # Scan catalog
    skip_dirs = {"FINAL", "Speculative", ".lake", "ResearchOutput", "Applications", "old"}
    candidates = []
    for f in CATALOG_ROOT.rglob("*.lean"):
        parts = f.relative_to(CATALOG_ROOT).parts
        if any(p in skip_dirs for p in parts):
            continue
        if f.name == "Main.lean":
            continue
        c = scan_file(f, CATALOG_ROOT)
        if c:
            candidates.append(c)

    print(f"[Prune] Scanned {len(candidates)} .lean files")

    # Auto-classify
    to_keep = []
    to_remove = []
    to_review = []
    for c in candidates:
        decision = auto_classify(c)
        if decision == "keep":
            to_keep.append(c)
        elif decision == "remove":
            to_remove.append(c)
        else:
            to_review.append(c)

    print(f"[Prune] Auto-keep: {len(to_keep)}, Auto-remove: {len(to_remove)}, Review: {len(to_review)}")

    # Execute auto-removes
    if to_remove and not args.dry_run:
        OLD_DIR.mkdir(parents=True, exist_ok=True)
    removed = 0
    for c in to_remove:
        if args.dry_run:
            print(f"  [dry-run] REMOVE: {c['path']}")
        else:
            dest = OLD_DIR / c["path"]
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(c["abs_path"]), str(dest))
            removed += 1
    if removed:
        print(f"[Prune] Auto-removed {removed} junk files (moved to old/)")

    # Process review batches
    if to_review:
        pi_agent = PiAgentClient()
        total_kept = 0
        total_removed = 0

        files_to_process = to_review if args.all else to_review[:args.batch_size]
        batches = [files_to_process[i:i + args.batch_size]
                   for i in range(0, len(files_to_process), args.batch_size)]

        for batch_idx, batch in enumerate(batches):
            print(f"[Prune] Review batch {batch_idx + 1}/{len(batches)} ({len(batch)} files)")
            system, user = build_review_prompt(batch)

            try:
                raw = pi_agent._call_ollama(system, user, timeout=120)
            except Exception as e:
                print(f"[Prune] PI-Agent call failed: {e}")
                break

            result = pi_agent._parse_json_response(raw)
            if not result:
                print(f"[Prune] Could not parse PI-Agent response, skipping batch")
                continue

            keep_paths = set(result.get("keep", []))
            remove_paths = set(result.get("remove", []))

            for c in batch:
                if c["path"] in remove_paths:
                    if args.dry_run:
                        print(f"  [dry-run] REMOVE (PI): {c['path']}")
                    else:
                        dest = OLD_DIR / c["path"]
                        dest.parent.mkdir(parents=True, exist_ok=True)
                        shutil.move(str(c["abs_path"]), str(dest))
                        total_removed += 1
                elif c["path"] in keep_paths:
                    total_kept += 1
                else:
                    # PI agent didn't mention it — keep by default
                    total_kept += 1

            notes = result.get("notes", "")
            print(f"[Prune] Batch {batch_idx + 1}: kept {total_kept}, removed {total_removed}. {notes}")

        print(f"[Prune] Review complete: kept {total_kept}, removed {total_removed}")

    # Clean empty directories
    if not args.dry_run:
        cleaned = 0
        for d in sorted(CATALOG_ROOT.rglob("*"), reverse=True):
            if d.is_dir() and not any(d.iterdir()) and d.name != "old":
                d.rmdir()
                cleaned += 1
        if cleaned:
            print(f"[Prune] Cleaned {cleaned} empty directories")

    # Summary
    final_count = sum(1 for _ in CATALOG_ROOT.rglob("*.lean")
                      if not any(p in (".lake", "old", "Applications") for p in _.relative_to(CATALOG_ROOT).parts)
                      and _.name != "Main.lean")
    print(f"[Prune] Catalog now has {final_count} .lean files")


if __name__ == "__main__":
    main()
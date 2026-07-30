#!/usr/bin/env python3
"""
Direction Tournament Module: Option B Implementation.

Packages batches of candidate directions (e.g. 5-10 directions) into an Aristotle
evaluation job. Aristotle selects the top winner directions, writes formal Lean 4
theorem stubs for them, and provides formal mathematical reasons to retire rejected ones.
"""

import argparse
import asyncio
import json
import re
import sys
import time
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple

WORKSPACE_DIR = Path(__file__).parent / ".aether_workspace"

class DirectionTournament:
    """Manages direction tournament packaging, submission, and parsing."""

    def __init__(self, workspace: Optional[Path] = None):
        self.workspace = Path(workspace) if workspace else WORKSPACE_DIR
        self._ensure_imports()

    def _ensure_imports(self):
        sys.path.insert(0, str(Path(__file__).parent))
        from research_memory import FutureDirectionsManager, FutureDirection
        self.FutureDirectionsManager = FutureDirectionsManager
        self.FutureDirection = FutureDirection

    def get_candidate_batch(
        self,
        domain: Optional[str] = None,
        batch_size: int = 10,
        exclude_ids: Optional[List[str]] = None,
    ) -> List[Any]:
        """Select a batch of available candidate directions for tournament evaluation."""
        mgr = self.FutureDirectionsManager(self.workspace)
        available = [d for d in mgr._directions if d.status == "available"]
        
        if domain:
            available = [d for d in available if domain.lower() in [dom.lower() for dom in d.domains]]

        if exclude_ids:
            exclude_set = set(exclude_ids)
            available = [d for d in available if d.id not in exclude_set]

        # Prioritize candidates without existing lean stubs
        available.sort(key=lambda d: (bool(d.lean_theorem_stub), -d.priority_score))
        return available[:batch_size]

    def build_tournament_prompt(
        self,
        directions: List[Any],
        target_winners: int = 2,
    ) -> str:
        """Construct a structured prompt for Aristotle to evaluate candidate directions."""
        prompt_parts = [
            "# ARISTOTLE DIRECTION TOURNAMENT EVALUATION\n",
            "You are evaluating a batch of candidate mathematical conjectures to identify the most",
            "mathematically fruitful, non-trivial, and actionable research directions.\n",
            f"Please evaluate the following {len(directions)} candidate conjectures:\n"
        ]

        for idx, d in enumerate(directions, 1):
            prompt_parts.append(f"## Candidate {idx} (ID: {d.id})")
            prompt_parts.append(f"**Title**: {d.title}")
            prompt_parts.append(f"**Domains**: {', '.join(d.domains) if d.domains else 'General'}")
            prompt_parts.append(f"**Description**: {d.description}")
            if d.proof_strategy:
                prompt_parts.append(f"**Proposed Strategy**: {d.proof_strategy}")
            if d.catalog_references:
                prompt_parts.append(f"**Catalog References**: {', '.join(d.catalog_references)}")
            prompt_parts.append("")

        prompt_parts.append("---")
        prompt_parts.append("## INSTRUCTIONS FOR ARISTOTLE\n")
        prompt_parts.append(f"1. Select the top {target_winners} WINNER conjectures that are mathematically non-trivial and fruitful.")
        prompt_parts.append("2. For each WINNER conjecture:")
        prompt_parts.append("   - Provide a formal Lean 4 theorem statement stub using `by sorry` that typechecks against Mathlib/Catalog.")
        prompt_parts.append("3. For the remaining REJECTED conjectures:")
        prompt_parts.append("   - Provide a 1-sentence formal mathematical reason explaining why it is trivial, redundant, or ill-defined.\n")
        prompt_parts.append("Format your final markdown output in a section titled `## TOURNAMENT_RESULTS` with explicit subsections:")
        prompt_parts.append("- `### WINNERS` (Include ID, Title, and Lean 4 code block)")
        prompt_parts.append("- `### REJECTIONS` (Include ID, Title, and Reason)")

        return "\n".join(prompt_parts)

    def parse_tournament_report(self, report_text: str) -> Dict[str, Any]:
        """Parse Aristotle's generated TOURNAMENT_RESULTS report."""
        winners = []
        rejections = []

        # Extract Winners section
        winners_match = re.search(r'###\s+WINNERS(.*?)(?=###\s+REJECTIONS|\Z)', report_text, re.DOTALL | re.IGNORECASE)
        if winners_match:
            winners_block = winners_match.group(1)
            # Find candidate IDs and associated lean code blocks
            entries = re.split(r'[-\*]\s*(?:ID:\s*|Candidate\s+\d+\s*\()?([a-zA-Z0-9_\-]+)', winners_block)
            for idx in range(1, len(entries), 2):
                wid = entries[idx].strip()
                block = entries[idx + 1] if idx + 1 < len(entries) else ""
                code_match = re.search(r'```(?:lean4?|lean)?\s*(.*?)```', block, re.DOTALL)
                stub = code_match.group(1).strip() if code_match else ""
                if wid.startswith(("fd_", "dir_", "push_", "sorry_fill_", "scifi_")):
                    winners.append({"id": wid, "lean_stub": stub})

        # Extract Rejections section
        rejections_match = re.search(r'###\s+REJECTIONS(.*?)\Z', report_text, re.DOTALL | re.IGNORECASE)
        if rejections_match:
            rejections_block = rejections_match.group(1)
            # Find ID + Reason lines (e.g. "- ID: fd_0001: Reason text")
            for line in rejections_block.splitlines():
                line = line.strip()
                m = re.search(r'([a-zA-Z0-9_\-]+)\s*:\s*(.*)', line)
                if m:
                    rid, reason = m.group(1), m.group(2)
                    if rid.startswith("fd_") or rid.startswith("dir_") or rid.startswith("push_") or rid.startswith("sorry_fill_") or rid.startswith("scifi_"):
                        rejections.append({"id": rid, "reason": reason.strip()})

        return {
            "winners": winners,
            "rejections": rejections,
            "raw_report": report_text,
        }

    def apply_tournament_outcomes(
        self,
        winners: List[Dict[str, str]],
        rejections: List[Dict[str, str]],
    ) -> Dict[str, int]:
        """Apply tournament results to future_directions.json."""
        mgr = self.FutureDirectionsManager(self.workspace)
        
        promoted = 0
        retired = 0

        winner_map = {w["id"]: w.get("lean_stub", "") for w in winners}
        rejection_map = {r["id"]: r.get("reason", "rejected in aristotle tournament") for r in rejections}

        for d in mgr._directions:
            if d.id in winner_map:
                d.status = "available"
                d.priority_score = max(d.priority_score, 0.90)
                if winner_map[d.id]:
                    d.lean_theorem_stub = winner_map[d.id]
                d.ambition_level = "grand_challenge"
                promoted += 1
            elif d.id in rejection_map:
                d.status = "pruned"
                d.prune_reason = f"tournament_rejected: {rejection_map[d.id]}"
                d.pruned_at = time.strftime("%Y-%m-%dT%H:%M:%SZ")
                retired += 1

        mgr._save()
        return {"promoted": promoted, "retired": retired}

def main():
    parser = argparse.ArgumentParser(description="Aether Direction Tournament CLI")
    parser.add_argument("--domain", type=str, help="Domain filter for tournament batch")
    parser.add_argument("--batch-size", type=int, default=10, help="Number of candidate directions in batch")
    parser.add_argument("--target-winners", type=int, default=2, help="Number of winning directions to select")
    parser.add_argument("--dry-run", action="store_true", help="Build prompt without dispatching")

    args = parser.parse_args()

    tournament = DirectionTournament()
    candidates = tournament.get_candidate_batch(domain=args.domain, batch_size=args.batch_size)
    
    if not candidates:
        print("[Tournament] No candidate directions found for batch.")
        return

    print(f"[Tournament] Selected {len(candidates)} candidate directions:")
    for d in candidates:
        print(f"  - [{d.id}] {d.title[:70]}")

    prompt = tournament.build_tournament_prompt(candidates, target_winners=args.target_winners)
    print("\n--- GENERATED TOURNAMENT PROMPT ---")
    print(prompt[:600] + "\n...\n")

    if args.dry_run:
        print("[Tournament] Dry-run complete. Prompt generated successfully.")
        return

if __name__ == "__main__":
    main()

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


def _normalize_entry(entry: Any) -> Dict[str, str]:
    """Coerce a tournament result entry to {"id": ..., "reason": ...}.

    Accepts either a plain ID string ("fd_0421") or a dict with id/reason keys.
    """
    if isinstance(entry, str):
        return {"id": entry, "reason": ""}
    if isinstance(entry, dict):
        eid = entry.get("id", "")
        reason = entry.get("reason", "")
        return {"id": str(eid), "reason": str(reason) if reason else ""}
    return {"id": str(entry), "reason": ""}


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
        """Select a batch of available candidate directions for tournament evaluation.

        github_injection directions (owner-approved GitHub issues) are never
        candidates: they carry priority_score=1000, which would otherwise sort
        them to the FRONT of every batch and get them tournament-rejected
        before their dedicated dispatch path ever runs (issues #157/#159).
        """
        mgr = self.FutureDirectionsManager(self.workspace)
        available = [d for d in mgr._directions if d.status == "available"]

        # Owner-approved injected directions are exempt from tournament pruning
        available = [d for d in available
                     if getattr(d, "source", "") != "github_injection"]

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
        """Construct a prompt for Aristotle to evaluate candidate directions.

        Each direction is judged on its own mathematical merit — there is no
        fixed quota of winners. Aristotle returns a single JSON file
        ``tournament_results.json`` with the winner and rejection IDs.
        """
        import json as _json
        candidates = []
        for d in directions:
            candidates.append({
                "id": d.id,
                "title": d.title,
                "domains": d.domains if d.domains else ["General"],
                "description": d.description,
            })

        prompt_parts = [
            "# ARISTOTLE DIRECTION TOURNAMENT EVALUATION\n",
            "You are evaluating a batch of candidate mathematical conjectures.\n",
            "For EACH direction, judge it on its own mathematical merit:\n",
            "  - Is it non-trivial, well-defined, and mathematically fruitful?\n",
            "  - Is it actionable — can it lead to real theorems and proofs?\n",
            "  - Is it original, or redundant with known results?\n",
            "There is NO fixed number of winners. Accept every direction that is",
            "genuinely worth pursuing and reject every direction that is trivial,",
            "redundant, ill-defined, or unproductive. The winners list may be long",
            "or short depending on the actual quality of the batch.\n",
            f"Evaluate the following {len(directions)} candidate conjectures:\n",
            "```json",
            _json.dumps(candidates, indent=2),
            "```\n",
            "---",
            "## INSTRUCTIONS\n",
            "Write a single file named ``tournament_results.json`` containing ONLY this JSON:\n",
            "```json",
            '{"winners": ["<id1>", "<id2>"], "rejections": ["<id3>", "<id4>"]}',
            "```\n",
            "Rules:",
            "- Use the exact candidate IDs (e.g. fd_0421, seed_007).",
            "- List ALL candidates — every ID must appear in either winners or rejections.",
            "- Judge each direction on its own merit; do not force a fixed number of winners.",
            "- Output the JSON file and nothing else. No Markdown commentary, no Lean code.",
        ]

        return "\n".join(prompt_parts)

    def load_tournament_results(self, project_dir: Path) -> Optional[Dict[str, Any]]:
        """Load Aristotle's ``tournament_results.json`` from a project directory.

        Returns {"winners": [...], "rejections": [...]} or None if the file is
        missing/invalid. Each entry is a dict with at least an ``id`` key; the
        optional ``reason`` key carries Aristotle's rejection rationale.
        """
        if not project_dir or not project_dir.exists():
            return None
        for fp in project_dir.rglob("tournament_results.json"):
            try:
                data = json.loads(fp.read_text(encoding="utf-8", errors="replace"))
            except Exception as e:
                print(f"[Tournament] Failed to parse {fp}: {e}")
                continue
            if not isinstance(data, dict):
                continue
            winners = data.get("winners", [])
            rejections = data.get("rejections", [])
            if not isinstance(winners, list) or not isinstance(rejections, list):
                continue
            return {
                "winners": [_normalize_entry(w) for w in winners],
                "rejections": [_normalize_entry(r) for r in rejections],
            }
        return None

    # Keep the old text-based parser as a fallback for already-queued jobs.
    def parse_tournament_report(self, report_text: str) -> Dict[str, Any]:
        """Parse a legacy TOURNAMENT_RESULTS Markdown report (fallback)."""
        winners = []
        rejections = []

        dir_id_re = re.compile(r"\b((?:fd|seed|dir|push|scifi|sorry_fill|pyth|auto)_[a-zA-Z0-9_\-]+)")

        winners_match = re.search(r'###\s+WINNERS(.*?)(?=###\s+REJECTIONS|\Z)', report_text, re.DOTALL | re.IGNORECASE)
        if winners_match:
            winners_block = winners_match.group(1)
            split_pat = (
                r"(?=-[\s]*(?:ID:\s*)?(?:Candidate\s+\d+\s*\(ID:\s*)?"
                + dir_id_re.pattern.replace("((?:", "(?:(?:")
                + r")"
            )
            chunks = re.split(split_pat, winners_block)
            for chunk in chunks:
                m = dir_id_re.search(chunk)
                if not m:
                    continue
                wid = m.group(1)
                winners.append({"id": wid, "lean_stub": ""})

        rejections_match = re.search(r'###\s+REJECTIONS(.*?)\Z', report_text, re.DOTALL | re.IGNORECASE)
        if rejections_match:
            rejections_block = rejections_match.group(1)
            for line in rejections_block.splitlines():
                line = line.strip()
                if not line:
                    continue
                matches = dir_id_re.findall(line)
                if not matches:
                    continue
                rid = matches[-1]
                reason_m = re.search(re.escape(rid) + r"\s*:?\s*(.*)", line)
                reason = reason_m.group(1).strip() if reason_m else ""
                if not reason:
                    tail = line.split(rid, 1)[-1].lstrip(": -").strip()
                    reason = tail
                rejections.append({"id": rid, "reason": reason})

        return {
            "winners": winners,
            "rejections": rejections,
            "raw_report": report_text,
        }

    def apply_tournament_outcomes(
        self,
        winners: List[Dict[str, str]],
        rejections: List[Dict[str, str]],
        dispatched_ids: Optional[set] = None,
    ) -> Dict[str, int]:
        """Apply tournament results to future_directions.json.

        When dispatched_ids is provided (the set of direction IDs that were
        sent to the tournament), only those IDs are eligible for outcome
        write-back.  This prevents hallucinated or stale outcome IDs from
        clobbering unrelated pool directions.

        Entries may be plain ID strings ("fd_0421") from the JSON file or dicts
        ({"id": ..., "reason": ..., "lean_stub": ...}) from the legacy parser.
        """
        mgr = self.FutureDirectionsManager(self.workspace)

        promoted = 0
        retired = 0

        winner_map = {e["id"]: e.get("reason", "") for e in [_normalize_entry(w) for w in winners]}
        # An empty/whitespace reason (judge returned "" or the entry was a bare
        # ID string normalized to reason="") must fall back to the default text,
        # never be recorded as a bare "tournament_rejected: ".
        _default_rejection = "rejected in aristotle tournament"
        rejection_map = {
            e["id"]: ((e.get("reason") or "").strip() or _default_rejection)
            for e in [_normalize_entry(r) for r in rejections]
        }

        for d in mgr._directions:
            if d.id in winner_map:
                if dispatched_ids is not None and d.id not in dispatched_ids:
                    continue
                d.status = "available"
                d.priority_score = max(d.priority_score, 0.90)
                if winner_map[d.id]:
                    d.lean_theorem_stub = winner_map[d.id]
                d.ambition_level = "grand_challenge"
                promoted += 1
            elif d.id in rejection_map:
                if dispatched_ids is not None and d.id not in dispatched_ids:
                    continue
                # Owner-approved injected directions are never tournament-pruned:
                # their issues are open and awaiting the dedicated dispatch path.
                if getattr(d, "source", "") == "github_injection":
                    continue
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

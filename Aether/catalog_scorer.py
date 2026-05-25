#!/usr/bin/env python3
"""CatalogScorer: Continuous quality scoring and FINAL/ promotion pipeline.

Scores Catalog .lean files on a 0-10 scale across structural metrics and
LLM-evaluated dimensions (novelty, depth, impact, fun, solid). Files that
pass a two-pass quality gate (structural filter + LLM scoring + confirmation)
are promoted to Catalog/FINAL/{Domain}/.

The pipeline runs 50 files per research cycle, prioritizing least-recently-examined
files to ensure full coverage over time.
"""

import json
import os
import re
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Dict, List, Optional, Any

from catalog_analyzer import CatalogAnalyzer, CatalogFileSummary, DEEP_TACTICS

# Tactics considered "shallow" (minimal proof effort) — shared with quality_evaluator
SHALLOW_TACTICS = {"trivial", "simp", "rfl", "decide", "norm_num", "tauto", "aesop"}

# Structural scoring thresholds
SORRY_FREE_BONUS = 3.0
DEEP_PROOF_BONUS = 2.0
THEOREM_MANY_BONUS = 1.5
THEOREM_SOME_BONUS = 0.5
CROSS_DOMAIN_BONUS = 1.0
LINE_DEPTH_100_BONUS = 1.0
LINE_DEPTH_50_BONUS = 0.5
DECL_RICH_10_BONUS = 1.0
DECL_RICH_5_BONUS = 0.5

# LLM scoring confirmation threshold
STRUCTURAL_FILTER_THRESHOLD = 5.0
FINAL_SCORE_THRESHOLD = 7.0


@dataclass
class CatalogFileScore:
    """Score record for a single Catalog file."""
    relative_path: str        # e.g. "Algebra/Berggren.lean"
    domain: str               # e.g. "Algebra"
    structural_score: float = 0.0   # 0-10, from structural metrics
    llm_score: float = 0.0         # 0-10, from LLM evaluation (0 = not yet evaluated)
    final_score: float = 0.0       # weighted average of structural + llm
    novelty: float = 0.0           # 0-10, LLM-evaluated
    depth: float = 0.0             # 0-10, LLM-evaluated
    impact: float = 0.0            # 0-10, LLM-evaluated
    fun: float = 0.0               # 0-10, LLM-evaluated
    solid: float = 0.0             # 0-10, LLM-evaluated
    last_examined: float = 0.0     # timestamp of last scan
    in_final: bool = False         # currently in FINAL/
    promoted_at: float = 0.0       # timestamp when promoted (0 if not)
    confirmed: bool = False        # passed two-pass confirmation

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, d: dict) -> "CatalogFileScore":
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})


class CatalogScorer:
    """Continuous scoring and promotion pipeline for Catalog .lean files.

    Each cycle:
    1. Select batch_size least-recently-examined files
    2. Compute structural scores (free, local)
    3. Filter to structural_score >= 5.0
    4. Run LLM scoring on finalists (5 dimensions: novelty, depth, impact, fun, solid)
    5. For files with final_score >= 7.0, run two-pass confirmation
    6. Promote confirmed files to FINAL/
    """

    def __init__(self, catalog_root: Path, workspace: Path, pi_agent=None):
        """
        Args:
            catalog_root: Path to the Catalog directory (e.g., ../Catalog)
            workspace: Path to the Aether workspace (e.g., .aether_workspace)
            pi_agent: PiAgentClient for LLM evaluation calls
        """
        self.catalog_root = Path(catalog_root)
        self.workspace = Path(workspace)
        self.scores_dir = self.workspace / ".aether_workspace"
        self.scores_dir.mkdir(parents=True, exist_ok=True)
        self.scores_file = self.scores_dir / "catalog_scores.json"
        self.pi_agent = pi_agent
        self.analyzer = CatalogAnalyzer(self.catalog_root)
        self._scores: Dict[str, CatalogFileScore] = {}

    # ── Persistence ──

    def load_scores(self) -> None:
        """Load previously saved scores from JSON."""
        if not self.scores_file.exists():
            return
        try:
            data = json.loads(self.scores_file.read_text(encoding="utf-8"))
            for entry in data:
                score = CatalogFileScore.from_dict(entry)
                self._scores[score.relative_path] = score
        except (json.JSONDecodeError, Exception):
            pass

    def save_scores(self) -> None:
        """Persist scores to disk."""
        data = [s.to_dict() for s in self._scores.values()]
        self.scores_file.write_text(
            json.dumps(data, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    # ── Batch Selection ──

    def get_next_batch(self, batch_size: int = 50) -> List[CatalogFileSummary]:
        """Return the batch_size least-recently-examined files.

        Files that have never been examined come first (last_examined=0),
        then files examined longest ago. This ensures full coverage over time.
        """
        self.analyzer.invalidate_cache()
        all_files = self.analyzer.scan()
        if not all_files:
            return []

        # Sort by last_examined timestamp (unexamined = 0 comes first)
        def sort_key(s: CatalogFileSummary) -> float:
            score = self._scores.get(s.relative_path)
            return score.last_examined if score else 0.0

        sorted_files = sorted(all_files, key=sort_key)
        return sorted_files[:batch_size]

    # ── Structural Scoring ──

    def score_structural(self, summary: CatalogFileSummary) -> float:
        """Compute structural score (0-10) from file metrics.

        Scoring factors:
        - sorry_free: +3.0 if sorry_count == 0
        - deep_proofs: +2.0 if deep tactics dominate and >= 3 deep tactics
        - theorem_count: +1.5 if 5+ theorems, +0.5 if 3+
        - cross_domain: +1.0 if imports span 2+ different domain directories
        - line_depth: +1.0 if 100+ lines, +0.5 if 50+
        - declaration_richness: +1.0 if 10+ declarations, +0.5 if 5+
        """
        score = 0.0

        # Sorry-free bonus
        if summary.sorry_count == 0:
            score += SORRY_FREE_BONUS

        # Read file content for tactic analysis
        try:
            content = (self.catalog_root / summary.relative_path).read_text(
                encoding="utf-8", errors="replace"
            )
        except Exception:
            content = ""

        # Deep proof bonus
        if content:
            deep_count = sum(1 for t in DEEP_TACTICS if t in content)
            # Shallow tactics — count occurrences, not just presence
            shallow_count = 0
            for t in SHALLOW_TACTICS:
                shallow_count += content.count(t)
            # native_decide is a specific shallow tactic
            shallow_count += content.count("native_decide")

            if deep_count >= 3 and deep_count > shallow_count * 0.5:
                score += DEEP_PROOF_BONUS

        # Theorem count bonus
        theorem_count = sum(
            1 for d in summary.declarations
            if any(kw in d.lower() for kw in ("theorem", "lemma"))
        )
        # Also count from content if available
        if content:
            theorem_count = max(theorem_count, len(re.findall(
                r'\b(?:theorem|lemma)\s+\w+', content
            )))
        if theorem_count >= 5:
            score += THEOREM_MANY_BONUS
        elif theorem_count >= 3:
            score += THEOREM_SOME_BONUS

        # Cross-domain bonus (imports from 2+ different domain directories)
        if summary.imports:
            import_domains = set()
            for imp in summary.imports:
                # import Domain.SubModule.File
                parts = imp.replace("import ", "").strip().split(".")
                if parts and parts[0] in ("Algebra", "Bridges", "Computation",
                                          "Cryptography", "EML", "Geometry",
                                          "Logic", "MachineLearning", "Physics",
                                          "Pythagorean", "Shared", "Speculative",
                                          "Tropical"):
                    import_domains.add(parts[0])
            if len(import_domains) >= 2:
                score += CROSS_DOMAIN_BONUS

        # Line depth bonus
        if summary.size_lines >= 100:
            score += LINE_DEPTH_100_BONUS
        elif summary.size_lines >= 50:
            score += LINE_DEPTH_50_BONUS

        # Declaration richness bonus
        decl_count = len(summary.declarations)
        if decl_count >= 10:
            score += DECL_RICH_10_BONUS
        elif decl_count >= 5:
            score += DECL_RICH_5_BONUS

        return min(10.0, score)

    # ── LLM Scoring ──

    def score_llm(self, summary: CatalogFileSummary, structural_score: float) -> Optional[CatalogFileScore]:
        """Ask pi-agent to score this file across 5 dimensions.

        Returns a CatalogFileScore with all dimensions filled, or None if
        the LLM call fails.
        """
        if not self.pi_agent:
            return None

        # Read file content for the prompt
        try:
            content = (self.catalog_root / summary.relative_path).read_text(
                encoding="utf-8", errors="replace"
            )
        except Exception:
            return None

        # Truncate content for the prompt
        content_preview = content[:2000] if content else "(empty file)"

        # Extract theorem signatures (first 5)
        theorem_sigs = []
        for line in content.splitlines()[:200]:
            stripped = line.strip()
            if stripped.startswith(("theorem ", "lemma ")):
                theorem_sigs.append(stripped[:150])
                if len(theorem_sigs) >= 5:
                    break

        # Count deep/shallow tactics
        deep_count = sum(1 for t in DEEP_TACTICS if t in content)
        shallow_count = sum(
            content.count(t) for t in SHALLOW_TACTICS
        ) + content.count("native_decide")

        system_prompt = (
            "You are evaluating a Lean 4 mathematical proof file for world-class quality. "
            "Score this file 1-10 on each dimension:\n\n"
            "1. **Novelty**: Is this a new/unique result, or a re-proof of Mathlib?\n"
            "2. **Depth**: How mathematically deep are the proofs? "
            "(induction, rcases, by_contra = deep; native_decide = shallow)\n"
            "3. **Impact**: Would a mathematician care about this result? Does it advance the field?\n"
            "4. **Fun**: Is this exciting, surprising, or beautiful mathematics?\n"
            "5. **Solid**: Is the proof complete and rigorous? (no sorries, no gaps)\n\n"
            "Output ONLY valid JSON: "
            '{"novelty": N, "depth": N, "impact": N, "fun": N, "solid": N}\n'
            "where N is an integer 1-10."
        )

        user_prompt = (
            f"File: {summary.relative_path} ({summary.domain} domain, "
            f"{summary.size_lines} lines, {len(summary.declarations)} declarations)\n"
            f"Declarations: {', '.join(summary.declarations[:10])}\n"
            f"Deep tactics: {deep_count} deep, {shallow_count} shallow\n"
            f"Sorry-free: {'yes' if summary.sorry_count == 0 else f'no ({summary.sorry_count} sorries)'}\n"
            f"Structural score: {structural_score:.1f}/10\n"
        )

        if theorem_sigs:
            user_prompt += f"Key theorems:\n" + "\n".join(
                f"  {sig}" for sig in theorem_sigs
            ) + "\n"

        user_prompt += f"\nSource preview:\n```\n{content_preview}\n```"

        try:
            raw = self.pi_agent._call_ollama(system_prompt, user_prompt, timeout=120)
            json_match = re.search(r'\{[^{}]*\}', raw, re.DOTALL)
            if not json_match:
                return None
            data = json.loads(json_match.group())

            novelty = max(1, min(10, int(data.get("novelty", 5))))
            depth = max(1, min(10, int(data.get("depth", 5))))
            impact = max(1, min(10, int(data.get("impact", 5))))
            fun = max(1, min(10, int(data.get("fun", 5))))
            solid = max(1, min(10, int(data.get("solid", 5))))

            llm_avg = (novelty + depth + impact + fun + solid) / 5.0

            # Weighted final score: 40% structural + 60% LLM
            final_score = 0.4 * structural_score + 0.6 * llm_avg

            return CatalogFileScore(
                relative_path=summary.relative_path,
                domain=summary.domain,
                structural_score=structural_score,
                llm_score=round(llm_avg, 2),
                final_score=round(final_score, 2),
                novelty=novelty,
                depth=depth,
                impact=impact,
                fun=fun,
                solid=solid,
                last_examined=time.time(),
                in_final=False,
                promoted_at=0.0,
                confirmed=False,
            )
        except Exception:
            return None

    def _confirm_promotion(self, score: CatalogFileScore) -> bool:
        """Two-pass confirmation: ask LLM to confirm world-class quality.

        Only called for files with final_score >= 7.0.
        Returns True if the LLM confirms promotion.
        """
        if not self.pi_agent:
            # Without LLM, use structural score alone
            return score.structural_score >= 7.0

        system_prompt = (
            "You are a curator of a 'best of the best' mathematical proof collection. "
            "You previously scored a Lean 4 file and it scored highly. Confirm whether "
            "it truly belongs in a curated collection of world-class mathematics.\n\n"
            "Reply ONLY with YES or NO followed by one sentence of reasoning."
        )

        user_prompt = (
            f"File: {score.relative_path} ({score.domain} domain)\n"
            f"Structural score: {score.structural_score:.1f}/10\n"
            f"LLM scores: novelty={score.novelty}, depth={score.depth}, "
            f"impact={score.impact}, fun={score.fun}, solid={score.solid}\n"
            f"Average LLM score: {score.llm_score:.1f}/10\n"
            f"Final score: {score.final_score:.1f}/10\n\n"
            f"Is this truly a top-tier result that belongs in a curated "
            f"'best of the best' collection?"
        )

        try:
            raw = self.pi_agent._call_ollama(system_prompt, user_prompt, timeout=60)
            response = raw.strip().upper()
            return response.startswith("YES")
        except Exception:
            # If LLM call fails, confirm based on score threshold alone
            return score.final_score >= 7.5

    # ── Promotion / Demotion ──

    def promote_to_final(self, score: CatalogFileScore) -> None:
        """Symlink the file from Catalog/{Domain}/ into FINAL/{Domain}/.

        Creates a relative symlink instead of copying to avoid duplicate bytes.
        Updates score.in_final = True and score.promoted_at.
        """
        final_dir = self.catalog_root / "FINAL" / score.domain
        final_dir.mkdir(parents=True, exist_ok=True)

        src = self.catalog_root / score.relative_path
        dst = final_dir / src.name

        if src.exists() and not dst.exists():
            rel_src = os.path.relpath(str(src), str(final_dir))
            dst.symlink_to(rel_src)
            score.in_final = True
            score.promoted_at = time.time()
            # Update stored score
            self._scores[score.relative_path] = score

    def demote_from_final(self, score: CatalogFileScore) -> None:
        """Remove the file from FINAL/ (it stays in the working Catalog).

        Updates score.in_final = False.
        """
        final_path = self.catalog_root / "FINAL" / score.domain / Path(score.relative_path).name
        if final_path.exists():
            final_path.unlink()
        score.in_final = False
        score.promoted_at = 0.0
        self._scores[score.relative_path] = score

    # ── Main Pipeline ──

    def scan_and_score_batch(self, batch_size: int = 50) -> List[CatalogFileScore]:
        """Main entry point called each cycle.

        1. Get next batch of least-recently-examined files
        2. Compute structural scores for all
        3. Filter to files with structural_score >= 5.0
        4. For filtered files, run LLM scoring
        5. For files with final_score >= 7.0, run two-pass confirmation
        6. Promote confirmed files to FINAL/
        7. Save updated scores

        Returns list of scored files (including promoted ones).
        """
        batch = self.get_next_batch(batch_size)
        if not batch:
            return []

        results = []

        # Phase 1: Structural scoring (all files)
        structurally_qualified = []
        for summary in batch:
            struct_score = self.score_structural(summary)

            # Update or create score entry
            existing = self._scores.get(summary.relative_path)
            if existing:
                existing.structural_score = struct_score
                existing.last_examined = time.time()
                existing.domain = summary.domain
            else:
                existing = CatalogFileScore(
                    relative_path=summary.relative_path,
                    domain=summary.domain,
                    structural_score=struct_score,
                    last_examined=time.time(),
                )
                self._scores[summary.relative_path] = existing

            if struct_score >= STRUCTURAL_FILTER_THRESHOLD:
                structurally_qualified.append((summary, existing))
            else:
                results.append(existing)

        # Phase 2: LLM scoring (only structurally qualified files)
        for summary, score in structurally_qualified:
            llm_score = self.score_llm(summary, score.structural_score)
            if llm_score is not None:
                # Update score with LLM dimensions
                score.llm_score = llm_score.llm_score
                score.final_score = llm_score.final_score
                score.novelty = llm_score.novelty
                score.depth = llm_score.depth
                score.impact = llm_score.impact
                score.fun = llm_score.fun
                score.solid = llm_score.solid
                score.last_examined = llm_score.last_examined
            else:
                # LLM call failed — use structural score only
                score.final_score = score.structural_score

            results.append(score)

        # Phase 3: Two-pass confirmation for high-scoring files
        for score in results:
            if score.final_score >= FINAL_SCORE_THRESHOLD and not score.in_final and not score.confirmed:
                confirmed = self._confirm_promotion(score)
                if confirmed:
                    score.confirmed = True
                    self.promote_to_final(score)
                else:
                    score.confirmed = False

        self.save_scores()
        return results

    def rebuild_final_from_scores(self, threshold: float = 7.0) -> int:
        """One-time rebuild: promote all files with final_score >= threshold.

        Called after initial scoring pass or manual rebuild.
        Returns the number of files promoted.
        """
        promoted = 0
        for score in self._scores.values():
            if score.final_score >= threshold and not score.in_final and score.confirmed:
                self.promote_to_final(score)
                promoted += 1

        # Also check structural-only scores that are high enough
        for score in self._scores.values():
            if (not score.in_final
                    and score.llm_score == 0
                    and score.structural_score >= 8.0):
                # High structural score without LLM evaluation — needs confirmation
                if self._confirm_promotion(score):
                    score.confirmed = True
                    self.promote_to_final(score)
                    promoted += 1

        self.save_scores()
        return promoted

    def get_stats(self) -> Dict[str, Any]:
        """Return summary statistics about the scoring pipeline."""
        total = len(self._scores)
        if total == 0:
            return {
                "total_scored": 0,
                "in_final": 0,
                "avg_structural": 0.0,
                "avg_final": 0.0,
                "confirmed": 0,
            }

        in_final = sum(1 for s in self._scores.values() if s.in_final)
        confirmed = sum(1 for s in self._scores.values() if s.confirmed)
        avg_struct = sum(s.structural_score for s in self._scores.values()) / total
        scored = [s for s in self._scores.values() if s.llm_score > 0]
        avg_final = (
            sum(s.final_score for s in scored) / len(scored) if scored else 0.0
        )

        return {
            "total_scored": total,
            "in_final": in_final,
            "confirmed": confirmed,
            "avg_structural": round(avg_struct, 2),
            "avg_final": round(avg_final, 2),
            "llm_scored": len(scored),
        }
#!/usr/bin/env python3
"""ResearchMemory: Persistent memory of what has been explored.

Tracks completed experiments, concepts, and outcomes to avoid repetition
and guide future research toward novel ground.
"""

import json
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Set

# Default maximum number of available non-seed directions to keep
DEFAULT_DIRECTION_CAP = 100


@dataclass
class ExperimentRecord:
    """Record of a single experiment."""
    exp_id: str
    domain: str
    concept_title: str
    concept_description: str
    status: str  # "success", "failure", "timeout", "trivial_rejected"
    files_produced: int = 0
    timestamp: str = ""
    key_theorems: List[str] = field(default_factory=list)
    # v2: quality tracking fields
    prompt_text: str = ""
    proof_quality: str = ""  # "trivial", "substantial", "partial"
    retry_of: str = ""       # parent exp_id if this is a retry
    retry_count: int = 0     # how many retries for this concept


class ResearchMemory:
    """Persistent memory to avoid repetitive research."""

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        self.memory_file = self.workspace / "research_memory.jsonl"
        self._cache: List[ExperimentRecord] = []
        self._titles: Set[str] = set()
        self._descriptions: Set[str] = set()
        self._load()

    def _load(self) -> None:
        """Load memory from disk."""
        if not self.memory_file.exists():
            return
        with open(self.memory_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                    record = ExperimentRecord(
                        exp_id=data.get("exp_id", ""),
                        domain=data.get("domain", ""),
                        concept_title=data.get("concept_title", ""),
                        concept_description=data.get("concept_description", ""),
                        status=data.get("status", ""),
                        files_produced=data.get("files_produced", 0),
                        timestamp=data.get("timestamp", ""),
                        key_theorems=data.get("key_theorems", []),
                        prompt_text=data.get("prompt_text", ""),
                        proof_quality=data.get("proof_quality", ""),
                        retry_of=data.get("retry_of", ""),
                        retry_count=data.get("retry_count", 0),
                    )
                    self._cache.append(record)
                    self._titles.add(record.concept_title.lower())
                    self._descriptions.add(record.concept_description.lower()[:100])
                except Exception:
                    pass

    def record(self, record: ExperimentRecord) -> None:
        """Record an experiment."""
        if not record.timestamp:
            record.timestamp = datetime.now(timezone.utc).isoformat()
        self._cache.append(record)
        self._titles.add(record.concept_title.lower())
        self._descriptions.add(record.concept_description.lower()[:100])
        with open(self.memory_file, "a", encoding="utf-8") as f:
            f.write(json.dumps({
                "exp_id": record.exp_id,
                "domain": record.domain,
                "concept_title": record.concept_title,
                "concept_description": record.concept_description,
                "status": record.status,
                "files_produced": record.files_produced,
                "timestamp": record.timestamp,
                "key_theorems": record.key_theorems,
                "prompt_text": record.prompt_text,
                "proof_quality": record.proof_quality,
                "retry_of": record.retry_of,
                "retry_count": record.retry_count,
            }) + "\n")

    def has_been_explored(self, title: str, description: str) -> bool:
        """Check if a concept has already been explored (exact match)."""
        title_lower = title.lower()
        desc_snippet = description.lower()[:100]
        return title_lower in self._titles or desc_snippet in self._descriptions

    def get_domain_history(self, domain: str, limit: int = 50) -> List[ExperimentRecord]:
        """Get recent experiments in a domain."""
        return [r for r in self._cache if r.domain == domain][-limit:]

    def get_successful_titles(self, domain: str = "") -> Set[str]:
        """Get titles of successful experiments."""
        return {
            r.concept_title.lower()
            for r in self._cache
            if r.status == "success" and (not domain or r.domain == domain)
        }

    def get_all_titles(self) -> Set[str]:
        """Get all explored titles."""
        return self._titles.copy()

    def suggest_novel_direction(self, domain: str) -> str:
        """Suggest a research direction based on history."""
        history = self.get_domain_history(domain)
        if not history:
            return "Explore foundational theorems in this domain."

        # Identify gaps: what hasn't been tried?
        successful = [r for r in history if r.status == "success"]
        failed = [r for r in history if r.status != "success"]

        if len(successful) > len(failed):
            return (
                f"Domain {domain} has {len(successful)} successes. "
                "Try pushing into adjacent domains or harder theorems."
            )
        elif len(failed) > len(successful):
            return (
                f"Domain {domain} has many failures. "
                "Try simpler, more concrete theorems with stronger lemmas."
            )
        else:
            return (
                f"Domain {domain} is balanced. "
                "Explore connections to other domains for cross-pollination."
            )

    def build_exclusion_prompt(self) -> str:
        """Build a prompt fragment listing explored concepts to avoid."""
        recent = self._cache[-20:] if len(self._cache) > 20 else self._cache
        if not recent:
            return ""

        lines = ["Previously explored concepts (AVOID these exact ideas):"]
        for r in recent:
            lines.append(f"  - {r.concept_title} ({r.domain}): {r.concept_description[:80]}...")

        return "\n".join(lines)

    def build_success_patterns(self) -> str:
        """Analyze successful experiments and extract patterns."""
        successes = [r for r in self._cache if r.status == "success"][-10:]
        if not successes:
            return ""
        lines = ["Successful concept patterns (EMULATE these):"]
        for r in successes:
            lines.append(f"  - {r.concept_title}: {r.concept_description[:80]}...")
        return "\n".join(lines)

    def get_trivial_count(self, domain: str = "") -> int:
        """Count how many trivial proofs were produced."""
        return sum(
            1 for r in self._cache
            if r.proof_quality == "trivial" and (not domain or r.domain == domain)
        )

    def get_best_prompts(self, domain: str, min_quality: str = "substantial") -> List[ExperimentRecord]:
        """Return prompts that produced good results for a domain."""
        quality_order = {"trivial": 0, "partial": 1, "substantial": 2}
        min_score = quality_order.get(min_quality, 2)
        results = []
        for r in self._cache:
            if r.domain == domain and r.prompt_text:
                score = quality_order.get(r.proof_quality, 0)
                if score >= min_score:
                    results.append(r)
        return results[-20:]  # most recent 20

    def suggest_improved_prompt(self, failed_exp_id: str) -> str:
        """Analyze a failed experiment and suggest prompt improvements."""
        failed = next((r for r in self._cache if r.exp_id == failed_exp_id), None)
        if not failed:
            return ""
        # Find successful experiments in the same domain
        successes = [r for r in self._cache
                     if r.domain == failed.domain
                     and r.proof_quality in ("substantial", "partial")
                     and r.prompt_text]
        if not successes:
            return ""
        best = successes[-1]
        lines = [
            "PROMPT AUTORESEARCH ANALYSIS:",
            f"Failed experiment: {failed.concept_title} ({failed.exp_id})",
            f"Proof quality: {failed.proof_quality}",
            f"Status: {failed.status}",
            "",
            "Best successful prompt in this domain:",
            f"  Concept: {best.concept_title}",
            f"  Quality: {best.proof_quality}",
            f"  Prompt excerpt (first 500 chars): {best.prompt_text[:500]}...",
            "",
            "SUGGESTED IMPROVEMENTS:",
            "1. Make the theorem statement more concrete — avoid True/Prop tautologies.",
            "2. Reference specific mathlib lemmas or catalog theorems in the prompt.",
            "3. Add a concrete numerical or structural constraint to the theorem.",
            "4. Use the creativity directives to force a non-obvious proof strategy.",
        ]
        return "\n".join(lines)

    def get_retry_history(self, original_exp_id: str) -> List[ExperimentRecord]:
        """Get all retries for an original experiment."""
        return [r for r in self._cache if r.retry_of == original_exp_id]


@dataclass
class FutureDirection:
    """A research direction extracted from Aristotle's FUTURE_DIRECTIONS.md output."""
    id: str
    title: str
    description: str
    source_exp_id: str
    source_path: str
    domains: List[str] = field(default_factory=list)
    proof_strategy: str = ""
    research_mode: str = "prove"
    depth_estimate: int = 3
    priority_score: float = 0.5
    status: str = "available"  # available, in_progress, completed
    consumed_by_exp_id: str = ""
    timestamp: str = ""
    prune_reason: str = ""
    pruned_at: str = ""

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "source_exp_id": self.source_exp_id,
            "source_path": self.source_path,
            "domains": self.domains,
            "proof_strategy": self.proof_strategy,
            "research_mode": self.research_mode,
            "depth_estimate": self.depth_estimate,
            "priority_score": self.priority_score,
            "status": self.status,
            "consumed_by_exp_id": self.consumed_by_exp_id,
            "timestamp": self.timestamp,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "FutureDirection":
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})


class FutureDirectionsManager:
    """Manages a persistent list of future research directions extracted from
    Aristotle's outputs. Tracks consumption status so directions are removed
    from the available list when they're being researched."""

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        self._file = self.workspace / "future_directions.json"
        self._directions: List[FutureDirection] = []
        self._pruned: List[FutureDirection] = []
        self._load()

    def _load(self) -> None:
        if not self._file.exists():
            return
        try:
            data = json.loads(self._file.read_text(encoding="utf-8"))
            if isinstance(data, list):
                # Legacy format: flat list of directions
                self._directions = [FutureDirection.from_dict(d) for d in data]
                self._pruned = []
            elif isinstance(data, dict):
                self._directions = [FutureDirection.from_dict(d) for d in data.get("directions", [])]
                self._pruned = [FutureDirection.from_dict(d) for d in data.get("pruned", [])]
        except Exception:
            self._directions = []
            self._pruned = []

        # Recover stale in_progress directions whose jobs no longer exist
        self._recover_stale_directions()

    def _recover_stale_directions(self) -> None:
        """Release in_progress directions whose consumed_by_exp_id references a job
        that no longer exists in inflight_jobs.json."""
        inflight_path = self.workspace / "inflight_jobs.json"
        if not inflight_path.exists():
            # No active jobs file — all in_progress directions are stale
            active_job_ids = set()
        else:
            try:
                inflight_data = json.loads(inflight_path.read_text(encoding="utf-8"))
                # Handle both dict format {uuid: {job_id: ...}} and list format
                if isinstance(inflight_data, dict):
                    active_job_ids = {
                        v.get("job_id", "") for v in inflight_data.values()
                        if isinstance(v, dict) and v.get("job_id")
                    }
                elif isinstance(inflight_data, list):
                    active_job_ids = {
                        j.get("job_id", "") for j in inflight_data
                        if isinstance(j, dict) and j.get("job_id")
                    }
                else:
                    active_job_ids = set()
            except Exception:
                active_job_ids = set()

        recovered = 0
        for d in self._directions:
            if d.status == "in_progress" and d.consumed_by_exp_id:
                if d.consumed_by_exp_id not in active_job_ids:
                    d.status = "available"
                    d.consumed_by_exp_id = ""
                    recovered += 1
        if recovered:
            self._save()
            print(f"Recovered {recovered} stale direction(s) back to available")

    def _save(self) -> None:
        self.workspace.mkdir(parents=True, exist_ok=True)
        self._file.write_text(
            json.dumps({
                "directions": [d.to_dict() for d in self._directions],
                "pruned": [d.to_dict() for d in self._pruned],
            }, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        self._update_snapshot()

    def _update_snapshot(self) -> None:
        """Write a display-friendly snapshot for CI/GitHub Pages consumption."""
        # Walk up from .aether_workspace to find repo root, then into Catalog
        repo_root = self.workspace.parent
        snapshot_path = repo_root / "Catalog" / "Applications" / "Packages" / "future_directions_snapshot.json"
        if not snapshot_path.parent.exists():
            return
        active = [d for d in self._directions if d.status not in ("completed", "pruned")]
        display = []
        for d in active:
            display.append({
                "id": d.id,
                "title": d.title,
                "description": d.description,
                "domains": d.domains,
                "priority_score": d.priority_score,
                "status": d.status,
                "research_mode": d.research_mode,
                "source_exp_id": d.source_exp_id,
                "consumed_by_exp_id": d.consumed_by_exp_id,
                "timestamp": d.timestamp,
            })
        display.sort(key=lambda x: x["priority_score"], reverse=True)
        snapshot_path.write_text(
            json.dumps(display, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    def add_direction(self, direction: FutureDirection) -> None:
        """Add a new future direction. Skips if a very similar title already exists."""
        title_lower = direction.title.lower().strip()
        for existing in self._directions:
            if existing.title.lower().strip() == title_lower:
                return
            # Also skip if descriptions are very similar (>80% word overlap)
            existing_words = set(existing.description.lower().split())
            new_words = set(direction.description.lower().split())
            if existing_words and new_words:
                overlap = len(existing_words & new_words) / max(len(existing_words), len(new_words))
                if overlap > 0.8:
                    return
        if not direction.timestamp:
            direction.timestamp = datetime.now(timezone.utc).isoformat()
        self._directions.append(direction)
        self._save()

    def add_directions_from_text(
        self, text: str, source_exp_id: str, source_path: str
    ) -> int:
        """Parse a FUTURE_DIRECTIONS.md text and add structured directions.

        Returns the number of directions added.
        """
        import re
        added = 0
        current_title = ""
        current_body = ""

        # Pattern 1: Bold-numbered sections like "1. **Title.** Description..."
        for m in re.finditer(r'\d+\.\s+\*\*([^*]+?)\*\*\s*', text):
            title = m.group(1).strip().rstrip(".")
            # Capture description from end of bold marker to next numbered item
            remaining = text[m.end():]
            next_item = re.search(r'\n\s*\d+\.\s+\*\*', remaining)
            if next_item:
                desc = remaining[:next_item.start()].strip()
            else:
                end_match = re.search(r'\n\n(?!\s)', remaining)
                desc = remaining[:end_match.start()].strip() if end_match else remaining.strip()

            desc = desc[:800]
            if len(desc) > 30:
                fd = FutureDirection(
                    id=f"fd_{len(self._directions):04d}",
                    title=title,
                    description=desc,
                    source_exp_id=source_exp_id,
                    source_path=source_path,
                    domains=self._infer_domains(title + " " + desc),
                    depth_estimate=3,
                    priority_score=0.75,
                )
                self.add_direction(fd)
                added += 1

        # Pattern 2: Markdown headers with research content
        if added == 0:
            for m in re.finditer(
                r'#{2,4}\s+(.+?)\n(.*?)(?=#{2,4}|\Z)',
                text, re.DOTALL
            ):
                header = m.group(1).strip()
                body = m.group(2).strip()
                if len(body) > 100 and any(
                    kw in (header + body).lower()
                    for kw in ["prove", "show", "extend", "formalize", "conjecture",
                                "theorem", "establish", "open", "future", "direction"]
                ):
                    fd = FutureDirection(
                        id=f"fd_{len(self._directions):04d}",
                        title=header[:80],
                        description=body[:800],
                        source_exp_id=source_exp_id,
                        source_path=source_path,
                        domains=self._infer_domains(header + " " + body),
                        depth_estimate=3,
                        priority_score=0.7,
                    )
                    self.add_direction(fd)
                    added += 1

        # Pattern 3: Bullet items with mathematical content
        if added == 0:
            for m in re.finditer(r'[-•]\s+(.+?)(?=\n[-•]|\n\n|\Z)', text, re.DOTALL):
                item = m.group(1).strip()
                if len(item) > 80 and any(
                    kw in item.lower()
                    for kw in ["prove", "show", "extend", "formalize", "conjecture", "theorem"]
                ):
                    fd = FutureDirection(
                        id=f"fd_{len(self._directions):04d}",
                        title=item[:60].rstrip() + "...",
                        description=item[:800],
                        source_exp_id=source_exp_id,
                        source_path=source_path,
                        domains=self._infer_domains(item),
                        depth_estimate=3,
                        priority_score=0.65,
                    )
                    self.add_direction(fd)
                    added += 1

        # Auto-prune if the list has grown beyond the cap
        if len(self._directions) > DEFAULT_DIRECTION_CAP:
            self.prune_directions(cap=DEFAULT_DIRECTION_CAP)

        return added

    @staticmethod
    def _infer_domains(text: str) -> List[str]:
        """Infer likely Catalog domains from text content."""
        text_lower = text.lower()
        domain_keywords = {
            "Tropical": ["tropical", "min-plus", "semiring", "maslov", "dequantization"],
            "Physics": ["quantum", "feynman", "path integral", "wave", "lorentz"],
            "Pythagorean": ["pythagorean", "berggren", "fibonacci", "carmichael", "primitive triple"],
            "Cryptography": ["crypto", "spb", "diffie-hellman", "discrete log", "lattice", "dilithium"],
            "EML": ["eml", "exponential", "multiplicative", "logarithmic", "closure"],
            "Bridges": ["bridge", "cross-domain", "unification", "functor", "correspondence"],
            "Algebra": ["algebra", "ring", "group", "field", "galois", "module", "spectral"],
            "MachineLearning": ["neural", "learning", "tropical robust", "approximation", "deep learning"],
            "Logic": ["logic", "type theory", "homotopy", "proof", "decidable", "constructive"],
            "Computation": ["turing", "complexity", "circuit", "reversible", "automaton"],
            "Speculative": ["speculative", "science fiction", "hyperspace", "alien"],
            "Geometry": ["geometry", "geometric", "curve", "surface", "manifold"],
        }
        domains = []
        for domain, keywords in domain_keywords.items():
            if any(kw in text_lower for kw in keywords):
                domains.append(domain)
        return domains or ["Bridges"]

    def get_available_directions(
        self, limit: int = 10, domain_filter: Optional[str] = None
    ) -> List[FutureDirection]:
        """Return available directions, optionally filtered by domain, sorted by priority."""
        available = [d for d in self._directions if d.status == "available"]
        if domain_filter:
            available = [d for d in available if domain_filter in d.domains or not d.domains]
        available.sort(key=lambda d: d.priority_score, reverse=True)
        return available[:limit]

    def select_direction_weighted(
        self, domain_filter: Optional[str] = None
    ) -> Optional[FutureDirection]:
        """Select a direction from a probability distribution weighted by priority_score.

        Higher priority directions are more likely to be selected, but lower-priority
        directions still have a chance. The sampling probability for each direction is
        proportional to its priority_score.
        """
        available = [d for d in self._directions if d.status == "available"]
        if domain_filter:
            available = [d for d in available if domain_filter in d.domains or not d.domains]
        if not available:
            return None
        import random
        weights = [d.priority_score for d in available]
        return random.choices(available, weights=weights, k=1)[0]

    def mark_direction_consumed(self, direction_id: str, exp_id: str) -> None:
        """Mark a direction as in-progress when it's selected for research."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "in_progress"
                d.consumed_by_exp_id = exp_id
                break
        self._save()

    def get_source_exp_ids_for(self, exp_id: str) -> list:
        """Return source_exp_ids of all directions consumed by this exp_id.

        This establishes provenance: the experiment with this exp_id was
        inspired by future directions produced by these source experiments.
        """
        return list(set(
            d.source_exp_id for d in self._directions
            if d.consumed_by_exp_id == exp_id and d.source_exp_id
        ))

    def mark_direction_completed(self, direction_id: str) -> None:
        """Mark a direction as completed after successful research."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "completed"
                break
        self._save()

    def mark_direction_abandoned(self, direction_id: str) -> None:
        """Mark a direction as abandoned (e.g., trivial proof).
        Deprecated: now resets to available so the direction can be retried."""
        self.mark_direction_available(direction_id)

    def mark_direction_available(self, direction_id: str) -> None:
        """Reset a direction back to available so it can be retried."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "available"
                d.consumed_by_exp_id = ""
                break
        self._save()

    def get_direction_for_exp(self, exp_id: str) -> Optional[FutureDirection]:
        """Find the direction being researched by a given experiment."""
        for d in self._directions:
            if d.consumed_by_exp_id == exp_id:
                return d
        return None

    def get_stats(self) -> dict:
        """Return stats about direction consumption."""
        from collections import Counter
        statuses = Counter(d.status for d in self._directions)
        return {
            "total": len(self._directions),
            "available": statuses.get("available", 0),
            "in_progress": statuses.get("in_progress", 0),
            "completed": statuses.get("completed", 0),
            "pruned": len(self._pruned),
        }

    def reset_directions(self, new_directions: Optional[List["FutureDirection"]] = None) -> dict:
        """Reset: mark in_progress as available, then optionally re-seed.

        Returns a summary dict of what was done.
        """
        reset_count = 0
        for d in self._directions:
            if d.status == "in_progress":
                d.status = "available"
                d.consumed_by_exp_id = ""
                reset_count += 1
        seeded = 0
        if new_directions:
            for nd in new_directions:
                self.add_direction(nd)
                seeded += 1
        self._save()
        return {
            "released": reset_count,
            "seeded": seeded,
            "total": len(self._directions),
        }

    def clear_and_reseed(self, new_directions: List["FutureDirection"]) -> dict:
        """Wipe all directions and re-seed from scratch.

        Returns a summary dict.
        """
        old_count = len(self._directions)
        self._directions = []
        for nd in new_directions:
            self.add_direction(nd)
        self._save()
        return {
            "cleared": old_count,
            "seeded": len(self._directions),
        }

    # ── Quality Scoring & Pruning ──

    @staticmethod
    def _compute_quality_score(direction: FutureDirection) -> float:
        """Compute a composite quality score for a direction.

        Weights: priority 35%, source 20%, domains 15%, description 10%,
                 strategy 10%, freshness 10%, plus fun bonus.
        """
        # priority_score: already 0-1
        priority = direction.priority_score

        # source_bonus: seed directions are higher quality
        if direction.source_path == "seed:manual_v2":
            source_bonus = 1.0
        elif direction.source_path.startswith("seed:"):
            source_bonus = 0.5
        else:
            source_bonus = 0.3

        # domain_richness: well-classified directions are better
        if not direction.domains:
            domain_richness = 0.1
        elif direction.domains == ["Bridges"]:
            domain_richness = 0.1
        else:
            domain_richness = min(1.0, len(direction.domains) / 3.0)

        # description_depth: longer, more detailed descriptions
        desc_len = len(direction.description)
        if desc_len < 80:
            description_depth = 0.0
        else:
            description_depth = min(1.0, (desc_len - 80) / 300.0)

        # strategy_bonus: having a proof strategy means more actionable
        strategy_bonus = 1.0 if direction.proof_strategy else 0.0

        # freshness: newer directions get a slight bonus
        if direction.timestamp:
            try:
                added = datetime.fromisoformat(direction.timestamp)
                days_old = (datetime.now(timezone.utc) - added).days
                freshness = max(0.0, 1.0 - days_old / 90.0)
            except (ValueError, TypeError):
                freshness = 0.5
        else:
            freshness = 0.5

        # fun_bonus: preserve speculative directions
        fun_bonus = 0.05 if "Speculative" in direction.domains else 0.0

        return (
            0.35 * priority
            + 0.20 * source_bonus
            + 0.15 * domain_richness
            + 0.10 * description_depth
            + 0.10 * strategy_bonus
            + 0.10 * freshness
            + fun_bonus
        )

    def prune_directions(
        self,
        cap: int = DEFAULT_DIRECTION_CAP,
        dry_run: bool = False,
        min_quality: float = 0.0,
    ) -> dict:
        """Remove low-quality available directions, keeping up to `cap` best.

        Never prunes: in_progress, completed, or seed directions.
        Pruned directions are archived (recoverable via restore_direction).

        Args:
            cap: Maximum number of available non-seed directions to keep.
            dry_run: If True, compute but do not actually prune.
            min_quality: If set, also prune directions below this threshold.

        Returns:
            Dict with pruned_count, kept counts, pruned_ids, etc.
        """
        seed_available = []
        auto_available = []
        protected = []

        for d in self._directions:
            if d.status in ("in_progress", "completed"):
                protected.append(d)
            elif d.status == "available":
                if d.source_path.startswith("seed:"):
                    seed_available.append(d)
                else:
                    auto_available.append(d)

        # Score and sort auto-parsed available directions
        scored = [(d, self._compute_quality_score(d)) for d in auto_available]
        scored.sort(key=lambda x: x[1], reverse=True)

        # Determine which to keep and which to prune
        if min_quality > 0:
            above_threshold = [(d, s) for d, s in scored if s >= min_quality]
            keep_count = min(cap, len(above_threshold))
        else:
            keep_count = min(cap, len(auto_available))

        to_keep = [d for d, s in scored[:keep_count]]
        to_prune = [d for d, s in scored[keep_count:]]

        # Also prune below min_quality even if within cap
        if min_quality > 0:
            to_prune = [d for d, s in scored if s < min_quality]
            to_keep = [d for d, s in scored if s >= min_quality][:cap]

        quality_threshold = scored[keep_count][1] if keep_count < len(scored) else 0.0

        result = {
            "pruned_count": len(to_prune),
            "kept_auto": len(to_keep),
            "kept_seed": len(seed_available),
            "kept_protected": len(protected),
            "total_available_after": len(seed_available) + len(to_keep),
            "quality_threshold": round(quality_threshold, 4),
            "pruned_ids": [d.id for d in to_prune],
            "pruned_details": [
                {"id": d.id, "title": d.title[:60], "quality_score": round(s, 4)}
                for d, s in scored[keep_count:]
            ] if len(scored) > keep_count else [],
        }

        if dry_run:
            return result

        # Move pruned directions to archive
        pruned_ids = {d.id for d in to_prune}
        for d in to_prune:
            d.status = "pruned"
            d.prune_reason = "quality_below_threshold"
            d.pruned_at = datetime.now(timezone.utc).isoformat()
            self._pruned.append(d)

        self._directions = [d for d in self._directions if d.id not in pruned_ids]
        self._save()

        return result

    def restore_direction(self, direction_id: str) -> bool:
        """Restore a pruned direction back to available.

        Returns True if the direction was found and restored.
        """
        for i, d in enumerate(self._pruned):
            if d.id == direction_id:
                d.status = "available"
                d.prune_reason = ""
                d.pruned_at = ""
                d.consumed_by_exp_id = ""
                self._directions.append(d)
                self._pruned.pop(i)
                self._save()
                return True
        return False

    def get_pruned(self, limit: int = 50) -> List[FutureDirection]:
        """Return pruned directions, most recently pruned first."""
        return list(reversed(self._pruned[-limit:]))


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Manage future directions")
    sub = parser.add_subparsers(dest="command")

    reset_p = sub.add_parser("reset", help="Clear and re-seed directions")
    reset_p.add_argument("--keep-completed", action="store_true",
                         help="Keep completed directions (default: wipe all)")

    stats_p = sub.add_parser("stats", help="Show direction statistics")

    prune_p = sub.add_parser("prune", help="Prune low-quality future directions")
    prune_p.add_argument("--cap", type=int, default=DEFAULT_DIRECTION_CAP,
                         help=f"Max available non-seed directions to keep (default: {DEFAULT_DIRECTION_CAP})")
    prune_p.add_argument("--dry-run", action="store_true",
                         help="Show what would be pruned without actually pruning")
    prune_p.add_argument("--min-quality", type=float, default=0.0,
                         help="Minimum quality score threshold (0-1); prune directions below this")
    prune_p.add_argument("--restore", type=str, default=None,
                         help="Restore a pruned direction by ID")

    args = parser.parse_args()
    workspace = Path(".aether_workspace")

    if args.command == "reset":
        from seed_directions import get_seed_directions
        mgr = FutureDirectionsManager(workspace)
        if args.keep_completed:
            result = mgr.reset_directions(get_seed_directions())
        else:
            result = mgr.clear_and_reseed(get_seed_directions())
        print(f"Reset complete: {result}")
    elif args.command == "stats":
        mgr = FutureDirectionsManager(workspace)
        stats = mgr.get_stats()
        print(json.dumps(stats, indent=2))
        available = mgr.get_available_directions()
        print(f"\nTop available directions:")
        for d in available[:5]:
            print(f"  [{d.priority_score:.2f}] {d.title} ({d.status})")
    elif args.command == "prune":
        mgr = FutureDirectionsManager(workspace)
        if args.restore:
            success = mgr.restore_direction(args.restore)
            print(f"Direction {args.restore} restored: {success}")
        else:
            result = mgr.prune_directions(
                cap=args.cap,
                dry_run=args.dry_run,
                min_quality=args.min_quality,
            )
            print(json.dumps(result, indent=2))
            if result["pruned_details"]:
                print(f"\nPruned directions:")
                for d in result["pruned_details"]:
                    print(f"  [{d['quality_score']:.4f}] {d['id']}: {d['title']}")
    else:
        parser.print_help()

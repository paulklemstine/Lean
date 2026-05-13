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
    status: str = "available"  # available, in_progress, completed, abandoned
    consumed_by_exp_id: str = ""
    timestamp: str = ""

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
        self._load()

    def _load(self) -> None:
        if not self._file.exists():
            return
        try:
            data = json.loads(self._file.read_text(encoding="utf-8"))
            self._directions = [FutureDirection.from_dict(d) for d in data]
        except Exception:
            self._directions = []

    def _save(self) -> None:
        self.workspace.mkdir(parents=True, exist_ok=True)
        self._file.write_text(
            json.dumps([d.to_dict() for d in self._directions], indent=2, ensure_ascii=False),
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
        """Mark a direction as abandoned (e.g., trivial proof)."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "abandoned"
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
            "abandoned": statuses.get("abandoned", 0),
        }

    def reset_directions(self, new_directions: Optional[List["FutureDirection"]] = None) -> dict:
        """Reset: mark in_progress as abandoned, then optionally re-seed.

        Returns a summary dict of what was done.
        """
        reset_count = 0
        for d in self._directions:
            if d.status == "in_progress":
                d.status = "abandoned"
                d.consumed_by_exp_id = ""
                reset_count += 1
        seeded = 0
        if new_directions:
            for nd in new_directions:
                self.add_direction(nd)
                seeded += 1
        self._save()
        return {
            "abandoned": reset_count,
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


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Manage future directions")
    sub = parser.add_subparsers(dest="command")

    reset_p = sub.add_parser("reset", help="Clear and re-seed directions")
    reset_p.add_argument("--keep-completed", action="store_true",
                         help="Keep completed directions (default: wipe all)")

    stats_p = sub.add_parser("stats", help="Show direction statistics")

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
    else:
        parser.print_help()

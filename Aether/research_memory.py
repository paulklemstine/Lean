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
        """Check if a concept has already been explored."""
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

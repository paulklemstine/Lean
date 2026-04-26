#!/usr/bin/env python3
"""AutoresearchBridge: Python interface to the pi-autoresearch optimization loop.

Uses the pi-autoresearch extension pattern for pipeline optimization:
- Tracks concept quality as the primary metric
- Keeps improvements (auto-commit), discards regressions (auto-revert)
- Provides strategy hints based on experiment history
"""

import json
import subprocess
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Any


@dataclass
class AutoresearchResult:
    """Result from a pi-autoresearch experiment run."""
    experiment_number: int
    metric_value: float
    status: str  # "keep" | "discard" | "crash" | "checks_failed"
    description: str
    checks_pass: bool
    duration_seconds: float
    raw_output: str = ""
    secondary_metrics: Dict[str, float] = field(default_factory=dict)


class AutoresearchBridge:
    """Python interface to the pi-autoresearch optimization loop.

    Provides a Python API that can:
    1. Track concept quality metrics over research cycles
    2. Run benchmark scripts and parse METRIC lines
    3. Log results with keep/discard semantics
    4. Provide best-strategy hints based on history

    The primary metric is "concept_quality" (0-1 scale) which evaluates
    how good a concept and prompt were, based on Aristotle's result quality.
    """

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        self.autoresearch_dir = self.workspace / "autoresearch"
        self.autoresearch_dir.mkdir(parents=True, exist_ok=True)
        self.history_file = self.autoresearch_dir / "autoresearch.jsonl"
        self.history: List[Dict[str, Any]] = self._load_history()

    def _load_history(self) -> List[Dict[str, Any]]:
        """Load experiment history from JSONL file."""
        if not self.history_file.exists():
            return []
        entries = []
        with open(self.history_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        entries.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue
        return entries

    def _save_entry(self, entry: Dict[str, Any]) -> None:
        """Append an entry to the history file."""
        with open(self.history_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        self.history.append(entry)

    def init_session(
        self,
        name: str = "aether_concept_quality",
        metric_name: str = "concept_quality",
        metric_unit: str = "",
        direction: str = "higher",
    ) -> None:
        """Initialize an autoresearch session.

        Creates autoresearch.md with session config and autoresearch.sh
        as a placeholder benchmark script.
        """
        # Write autoresearch.md
        session_md = self.autoresearch_dir / "autoresearch.md"
        md_content = f"""# Aether v3 Autoresearch: {name}

## Metric
- **Name**: {metric_name}
- **Unit**: {metric_unit}
- **Direction**: {direction} (higher is better)

## How It Works
1. Pi-Agent generates a concept and prompt
2. Aristotle produces a result
3. Result quality is evaluated (trivial=0.1, partial=0.5, substantial=0.9)
4. Quality score is logged as METRIC
5. Successful patterns are kept, failures are analyzed for improvement

## Current Best
- Check autoresearch.jsonl for experiment history
"""
        session_md.write_text(md_content, encoding="utf-8")

        # Write autoresearch.sh (placeholder benchmark)
        benchmark_sh = self.autoresearch_dir / "autoresearch.sh"
        sh_content = """#!/bin/bash
# Aether v3 autoresearch benchmark script
# This script evaluates concept quality from the most recent cycle.
# It reads the last entry from autoresearch.jsonl and outputs METRIC lines.

LAST_ENTRY=$(tail -1 autoresearch.jsonl 2>/dev/null)
if [ -z "$LAST_ENTRY" ]; then
    echo "METRIC 0.0 no_experiments_yet"
    exit 0
fi

QUALITY=$(echo "$LAST_ENTRY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('quality_score', 0.0))" 2>/dev/null)
if [ -z "$QUALITY" ]; then
    QUALITY="0.0"
fi

echo "METRIC $QUALITY concept_quality"
"""
        benchmark_sh.write_text(sh_content, encoding="utf-8")
        benchmark_sh.chmod(0o755)

    def evaluate_concept_quality(
        self,
        concept_title: str,
        concept_domain: str,
        quality_assessment: Dict[str, Any],
        catalog_references: List[str],
        research_mode: str,
        prompt_length: int = 0,
    ) -> float:
        """Evaluate concept quality using a composite score.

        Quality score (0-1) based on:
        - Aristotle result quality: substantial=0.9, partial=0.5, trivial=0.1
        - Novelty vs. history (ResearchMemory dedup)
        - Number of @ Catalog references used (more = better context)
        - Research mode appropriateness

        Returns a float 0-1.
        """
        # Base quality from Aristotle result
        quality_map = {
            "substantial": 0.9,
            "partial": 0.5,
            "trivial": 0.1,
        }
        base_quality = quality_map.get(quality_assessment.get("quality", "partial"), 0.5)

        # Bonus for catalog references (more context = better research)
        ref_bonus = min(len(catalog_references) * 0.02, 0.1)

        # Bonus for diverse research modes (not always "prove")
        mode_bonus = 0.0
        if research_mode in ("formalize", "counterexample", "sorry_fill"):
            # Non-default modes get a small bonus for variety
            mode_bonus = 0.05

        # Penalty for very short prompts (likely not enough context)
        length_penalty = 0.0
        if prompt_length < 500:
            length_penalty = 0.1
        elif prompt_length < 1000:
            length_penalty = 0.05

        # Novelty check: penalize if we've seen similar concepts recently
        novelty_penalty = 0.0
        if self.history:
            recent_titles = [
                h.get("concept_title", "") for h in self.history[-10:]
            ]
            # Simple similarity check
            title_lower = concept_title.lower()
            for recent in recent_titles:
                recent_lower = recent.lower()
                if title_lower == recent_lower:
                    novelty_penalty = 0.3
                    break
                # Check if too similar (shared words)
                title_words = set(title_lower.split("_"))
                recent_words = set(recent_lower.split("_"))
                overlap = len(title_words & recent_words)
                if overlap > len(title_words) * 0.7 and len(title_words) > 2:
                    novelty_penalty = max(novelty_penalty, 0.15)

        score = base_quality + ref_bonus + mode_bonus - length_penalty - novelty_penalty
        return max(0.0, min(1.0, score))

    def log_result(
        self,
        exp_id: str,
        concept_title: str,
        concept_domain: str,
        research_mode: str,
        quality: str,
        quality_score: float,
        catalog_references: List[str],
        prompt_length: int = 0,
        files_placed: int = 0,
    ) -> None:
        """Log an experiment result to autoresearch.jsonl.

        This is the primary recording mechanism. Each entry captures
        the concept, quality, and strategy used.
        """
        entry = {
            "timestamp": time.time(),
            "experiment_id": exp_id,
            "concept_title": concept_title,
            "concept_domain": concept_domain,
            "research_mode": research_mode,
            "quality": quality,
            "quality_score": quality_score,
            "catalog_references": catalog_references,
            "prompt_length": prompt_length,
            "files_placed": files_placed,
            "status": "keep" if quality_score >= 0.5 else "discard",
        }
        self._save_entry(entry)

    def run_benchmark(self, command: str, timeout: int = 300) -> AutoresearchResult:
        """Run a command and capture METRIC lines from output.

        Used to evaluate concept quality by running a benchmark script.
        """
        start_time = time.time()
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=str(self.autoresearch_dir),
            )
            duration = time.time() - start_time
            output = result.stdout + result.stderr

            # Parse METRIC lines
            metric_value = 0.0
            description = ""
            for line in output.splitlines():
                if line.strip().startswith("METRIC"):
                    parts = line.strip().split(maxsplit=2)
                    if len(parts) >= 2:
                        try:
                            metric_value = float(parts[1])
                        except ValueError:
                            pass
                        if len(parts) >= 3:
                            description = parts[2]

            status = "keep" if metric_value >= 0.5 else "discard"
            if result.returncode != 0:
                status = "crash"

            return AutoresearchResult(
                experiment_number=len(self.history) + 1,
                metric_value=metric_value,
                status=status,
                description=description,
                checks_pass=result.returncode == 0,
                duration_seconds=duration,
                raw_output=output,
            )
        except subprocess.TimeoutExpired:
            return AutoresearchResult(
                experiment_number=len(self.history) + 1,
                metric_value=0.0,
                status="crash",
                description=f"Benchmark timed out after {timeout}s",
                checks_pass=False,
                duration_seconds=timeout,
            )
        except Exception as e:
            return AutoresearchResult(
                experiment_number=len(self.history) + 1,
                metric_value=0.0,
                status="crash",
                description=str(e),
                checks_pass=False,
                duration_seconds=0.0,
            )

    def get_best_strategy(self) -> Dict[str, Any]:
        """Analyze experiment history and return the best-performing strategy.

        Returns: {
            "best_domain": str,
            "best_research_mode": str,
            "best_avg_quality": float,
            "best_prompt_length_range": tuple,
            "avg_references": float,
            "total_experiments": int,
            "success_rate": float,
            "confidence": float,
        }
        """
        if not self.history:
            return {
                "best_domain": "speculative",
                "best_research_mode": "prove",
                "best_avg_quality": 0.0,
                "best_prompt_length_range": (1000, 3000),
                "avg_references": 0.0,
                "total_experiments": 0,
                "success_rate": 0.0,
                "confidence": 0.0,
            }

        # Aggregate by domain
        domain_stats: Dict[str, List[float]] = {}
        mode_stats: Dict[str, List[float]] = {}
        prompt_lengths: List[int] = []
        ref_counts: List[int] = []
        successes = 0

        for entry in self.history:
            domain = entry.get("concept_domain", "unknown")
            mode = entry.get("research_mode", "prove")
            score = entry.get("quality_score", 0.0)

            domain_stats.setdefault(domain, []).append(score)
            mode_stats.setdefault(mode, []).append(score)

            pl = entry.get("prompt_length", 0)
            if pl > 0:
                prompt_lengths.append(pl)

            rc = len(entry.get("catalog_references", []))
            ref_counts.append(rc)

            if entry.get("status") == "keep":
                successes += 1

        # Find best domain
        best_domain = "speculative"
        best_domain_avg = 0.0
        for domain, scores in domain_stats.items():
            avg = sum(scores) / len(scores)
            if avg > best_domain_avg:
                best_domain_avg = avg
                best_domain = domain

        # Find best research mode
        best_mode = "prove"
        best_mode_avg = 0.0
        for mode, scores in mode_stats.items():
            avg = sum(scores) / len(scores)
            if avg > best_mode_avg:
                best_mode_avg = avg
                best_mode = mode

        # Find best prompt length range
        if prompt_lengths:
            sorted_lengths = sorted(prompt_lengths)
            mid = len(sorted_lengths) // 2
            best_length_range = (
                sorted_lengths[max(0, mid - 5)],
                sorted_lengths[min(len(sorted_lengths) - 1, mid + 5)],
            )
        else:
            best_length_range = (1000, 3000)

        # Calculate overall stats
        total = len(self.history)
        success_rate = successes / total if total > 0 else 0.0
        avg_refs = sum(ref_counts) / len(ref_counts) if ref_counts else 0.0
        confidence = min(1.0, total / 20.0)  # Confidence grows with more experiments

        return {
            "best_domain": best_domain,
            "best_research_mode": best_mode,
            "best_avg_quality": best_domain_avg,
            "best_prompt_length_range": best_length_range,
            "avg_references": avg_refs,
            "total_experiments": total,
            "success_rate": success_rate,
            "confidence": confidence,
        }
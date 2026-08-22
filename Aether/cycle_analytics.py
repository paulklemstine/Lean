#!/usr/bin/env python3
"""CycleAnalytics: Track per-cycle metrics for Aether research engine.

Stores cycle analytics in .aether_workspace/cycle_analytics.json with:
  - Cycle number, domain, duration
  - Theorem count, sorry count/density
  - Quality score (composite and per-axis)
  - Novelty audit score
  - Insight extraction stats

Provides trending and summary views for the dashboard.
"""

import json
import time
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional


@dataclass
class CycleRecord:
    """A single completed research cycle's analytics."""
    cycle_n: int = 0
    job_id: str = ""
    domain: str = ""
    title: str = ""
    start_time: float = 0.0
    end_time: float = 0.0
    duration_seconds: float = 0.0
    theorem_count: int = 0
    sorry_count: int = 0
    sorry_density: float = 0.0  # sorry_count / max(theorem_count, 1)
    theorem_novelty_new: int = 0
    theorem_novelty_strengthening: int = 0
    theorem_novelty_duplicate: int = 0
    theorem_novelty_disproof: int = 0
    quality_score: float = 0.0
    quality_breakdown: Optional[Dict[str, float]] = None
    novelty_score: Optional[float] = None
    outcome_quality: float = 0.0
    files_integrated: int = 0
    failed: bool = False  # True if cycle produced no output (0 files, 0 theorems)
    error_message: Optional[str] = None
    prompt_version: str = "v1"  # "v1" (original) | "v2" (master-class) | "v3" (PEGB+structures)
    # Two-phase fields
    phase: str = "A"  # "A" | "B" | "complete" | "A_only"
    phase_a_prompt_version: Optional[str] = None  # v3 or v4 used for the math prompt
    phase_a_quality_score: float = 0.0
    phase_b_prompt_version: Optional[str] = None  # v1 packaging prompt (only one for now)
    phase_b_skipped: bool = False  # True if Phase B was skipped (low quality or failure)
    phase_b_skip_reason: Optional[str] = None  # "low_quality" | "threshold_not_met" | "phase_a_failed"
    adversarial_agreement: str = ""  # "agree", "tiebreak", "disagree", or "" (not run)
    adversarial_delta: float = 0.0   # delta between primary and adversarial scores
    barrier_count: int = 0
    strategy_count: int = 0
    bridge_count: int = 0
    timestamp: str = ""

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        # Remove None values and empty strings for cleanliness
        # Keep boolean fields (failed) even if False
        return {k: v for k, v in d.items()
                if v is not None and v != "" and not (k == "failed" and v is False)}

    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> "CycleRecord":
        known = {f.name for f in cls.__dataclass_fields__.values()}
        filtered = {k: v for k, v in d.items() if k in known}
        return cls(**filtered)


class CycleAnalytics:
    """Persistent store and analysis of per-cycle research metrics."""

    MAX_RECORDS = 2000  # Keep at most 2000 records, prune oldest
    CURRENT_PROMPT_VERSION = "v3"  # PEGB + novel structures + stricter Novelty

    def __init__(self, workspace: Path):
        self.workspace = workspace
        self.path = workspace / "cycle_analytics.json"
        self.records: List[CycleRecord] = []
        self._load()

    def _load(self) -> None:
        if self.path.exists():
            try:
                data = json.loads(self.path.read_text())
                if isinstance(data, dict) and "records" in data:
                    self.records = [CycleRecord.from_dict(r) for r in data["records"]]
                elif isinstance(data, list):
                    self.records = [CycleRecord.from_dict(r) for r in data]
            except (json.JSONDecodeError, KeyError, TypeError):
                self.records = []
        self._prune()

    def _save(self) -> None:
        self._prune()
        data = {
            "records": [r.to_dict() for r in self.records],
            "last_updated": datetime.now(timezone.utc).isoformat(),
        }
        self.path.write_text(json.dumps(data, indent=2, sort_keys=True))

    def _prune(self) -> None:
        """Keep only the most recent MAX_RECORDS."""
        if len(self.records) > self.MAX_RECORDS:
            self.records = self.records[-self.MAX_RECORDS:]

    @property
    def successful_records(self) -> List[CycleRecord]:
        """Return only non-failed records for analytics."""
        return [r for r in self.records if not r.failed]

    def record_cycle(self, job, insight_extractor=None) -> None:
        """Record analytics for a completed cycle.

        Args:
            job: ResearchJob with completed cycle data
            insight_extractor: Optional InsightExtractor for insight stats
        """
        record = CycleRecord(
            cycle_n=getattr(job, "cycle_n", 0),
            job_id=getattr(job, "job_id", ""),
            domain="",
            title="",
            start_time=getattr(job, "dispatch_time", 0.0),
            end_time=getattr(job, "complete_time", 0.0),
            duration_seconds=0.0,
            theorem_count=getattr(job, "theorem_count", 0),
            sorry_count=getattr(job, "sorry_count", 0),
            theorem_novelty_new=getattr(job, "theorem_novelty", {}).get("new", 0) if getattr(job, "theorem_novelty", None) else 0,
            theorem_novelty_strengthening=getattr(job, "theorem_novelty", {}).get("strengthening", 0) if getattr(job, "theorem_novelty", None) else 0,
            theorem_novelty_duplicate=getattr(job, "theorem_novelty", {}).get("duplicate", 0) if getattr(job, "theorem_novelty", None) else 0,
            theorem_novelty_disproof=getattr(job, "theorem_novelty", {}).get("disproof", 0) if getattr(job, "theorem_novelty", None) else 0,
            quality_score=getattr(job, "quality_score", 0.0),
            phase_a_quality_score=getattr(job, "phase_a_quality_score", 0.0),
            outcome_quality=0.0,
            files_integrated=getattr(job, "files_integrated", 0),
            error_message=getattr(job, "error_message", None),
            timestamp=datetime.now(timezone.utc).isoformat(),
        )

        # Compute derived fields
        record.sorry_density = record.sorry_count / max(record.theorem_count, 1)

        # Duration
        if record.end_time and record.start_time:
            try:
                record.duration_seconds = float(record.end_time) - float(record.start_time)
            except (TypeError, ValueError):
                pass

        # Domain from concept (handle both ResearchConcept object and dict)
        # Note: serialized concept uses "domain" (singular), object uses "domains" (plural)
        concept = getattr(job, "concept", None)
        if concept:
            if isinstance(concept, dict):
                domains = concept.get("domains", [])
                domain_singular = concept.get("domain", "")
                record.domain = domains[0] if domains else (domain_singular if domain_singular else "")
                record.title = concept.get("title", "")[:100]
            else:
                domains = getattr(concept, "domains", [])
                domain_singular = getattr(concept, "domain", "")
                record.domain = domains[0] if domains else (domain_singular if domain_singular else "")
                record.title = getattr(concept, "title", "")[:100]

        # Quality breakdown from quality_detail
        qd = getattr(job, "quality_detail", None)
        if qd and hasattr(qd, "to_dict"):
            record.quality_breakdown = qd.to_dict()
        elif qd and isinstance(qd, dict):
            record.quality_breakdown = qd

        # Novelty score from insight_extractor
        if insight_extractor:
            try:
                stats = insight_extractor.stats()
                record.barrier_count = stats.get("barriers", 0)
                record.strategy_count = stats.get("strategies", 0)
                record.bridge_count = stats.get("cross_domain_bridges", 0)
            except Exception:
                pass

        # Outcome quality from the direction
        try:
            from research_memory import FutureDirectionsManager
            fd_mgr = FutureDirectionsManager(self.workspace)
            direction = fd_mgr.get_direction_for_exp(record.job_id)
            if direction:
                record.outcome_quality = direction.outcome_quality
        except Exception:
            pass

        # Mark as failed if job status is failed or cycle produced no output
        if getattr(job, "status", "") == "failed" or (record.files_integrated == 0 and record.theorem_count == 0):
            record.failed = True

        # Tag with current prompt version (or job's version if specified)
        job_version = getattr(job, "prompt_version", None)
        record.prompt_version = job_version if job_version else self.CURRENT_PROMPT_VERSION

        # Two-phase metadata
        record.phase = getattr(job, "phase", "A")
        record.phase_a_prompt_version = getattr(job, "phase_a_prompt_version", None)
        record.phase_b_prompt_version = getattr(job, "phase_b_prompt_version", None)
        skip_reason = getattr(job, "phase_b_skipped_reason", None)
        if skip_reason:
            record.phase_b_skipped = True
            record.phase_b_skip_reason = skip_reason

        # Adversarial judging metadata
        adv = getattr(job, "adversarial_result", None)
        if adv and isinstance(adv, dict):
            record.adversarial_agreement = adv.get("agreement", "")
            record.adversarial_delta = adv.get("delta", 0.0)

        self.records.append(record)
        self._save()

    def get_summary(self, last_n: int = 50) -> Dict[str, Any]:
        """Get summary statistics for the last N cycles."""
        recent = self.successful_records[-last_n:]
        if not recent:
            return {
                "total_cycles": 0,
                "avg_quality": 0.0,
                "avg_theorem_count": 0.0,
                "avg_sorry_density": 0.0,
                "avg_duration_minutes": 0.0,
                "domain_distribution": {},
                "last_n": last_n,
            }

        qualities = [r.quality_score for r in recent if r.quality_score > 0]
        theorems = [r.theorem_count for r in recent]
        sorry_densities = [r.sorry_density for r in recent]
        durations = [r.duration_seconds for r in recent if r.duration_seconds > 0]
        domains = [r.domain for r in recent if r.domain]

        from collections import Counter
        domain_dist = Counter(domains)

        return {
            "total_cycles": len(self.records),
            "recent_cycles": len(recent),
            "avg_quality": sum(qualities) / len(qualities) if qualities else 0.0,
            "avg_theorem_count": sum(theorems) / len(theorems) if theorems else 0.0,
            "avg_sorry_density": sum(sorry_densities) / len(sorry_densities) if sorry_densities else 0.0,
            "avg_duration_minutes": (sum(durations) / len(durations) / 60) if durations else 0.0,
            "domain_distribution": dict(domain_dist.most_common()),
            "last_n": last_n,
        }



    def get_phase_split_stats(self) -> Dict[str, Any]:
        """Get statistics for the two-phase (A: math, B: packaging) split.

        Returns:
        - n_complete: cycles that ran both Phase A and Phase B
        - n_a_only: cycles where Phase B was skipped (low quality or failure)
        - pct_packaged: fraction of cycles that got packaged
        - skip_reasons: dict mapping reason -> count
        - avg_q_packaged: avg quality of cycles that ran both phases
        - avg_q_a_only: avg quality of cycles that were A-only
        - p70_quality: 70th percentile of quality_score (used as Phase B threshold)
        """
        from collections import Counter

        complete = [r for r in self.successful_records if r.phase == "complete"]
        a_only = [r for r in self.successful_records if r.phase_b_skipped]
        skip_reasons = Counter(r.phase_b_skip_reason for r in a_only if r.phase_b_skip_reason)

        n_total = len(complete) + len(a_only)
        n_recent = max(50, n_total // 4)
        recent_scores = sorted(
            r.quality_score for r in self.successful_records[-n_recent:] if r.quality_score
        )
        p70 = recent_scores[int(0.7 * (len(recent_scores) - 1))] if recent_scores else 0.5

        return {
            "n_complete": len(complete),
            "n_a_only": len(a_only),
            "n_total": n_total,
            "pct_packaged": round(len(complete) / n_total * 100, 1) if n_total else 0.0,
            "skip_reasons": dict(skip_reasons),
            "avg_q_packaged": round(
                sum(r.quality_score for r in complete) / len(complete), 3
            ) if complete else 0.0,
            "avg_q_a_only": round(
                sum(r.quality_score for r in a_only) / len(a_only), 3
            ) if a_only else 0.0,
            "p70_quality_recent": round(p70, 3),
        }

    def get_domain_stats(self) -> Dict[str, Dict[str, float]]:
        """Get per-domain statistics."""
        from collections import defaultdict
        domain_data = defaultdict(list)
        for r in self.successful_records:
            if r.domain:
                domain_data[r.domain].append(r)

        stats = {}
        for domain, records in domain_data.items():
            qualities = [r.quality_score for r in records if r.quality_score > 0]
            theorems = [r.theorem_count for r in records]
            sorry = [r.sorry_density for r in records]
            stats[domain] = {
                "count": len(records),
                "avg_quality": sum(qualities) / len(qualities) if qualities else 0.0,
                "avg_theorems": sum(theorems) / len(theorems) if theorems else 0.0,
                "avg_sorry_density": sum(sorry) / len(sorry) if sorry else 0.0,
            }
        return stats



    def get_breakthroughs(self, threshold: float = 0.8) -> List[CycleRecord]:
        """Return cycles with quality_score above threshold (breakthroughs)."""
        return [r for r in self.successful_records if r.quality_score >= threshold]

    def get_direction_funnel(self) -> Dict[str, Any]:
        """Compute direction funnel metrics: seeded vs organic, conversion rates.

        Requires FutureDirectionsManager for full data; falls back to cycle records.
        """
        try:
            from research_memory import FutureDirectionsManager
            fd_mgr = FutureDirectionsManager(self.workspace)
            all_dirs = fd_mgr._directions
            available = [d for d in all_dirs if d.status == "available"]
            completed = [d for d in all_dirs if d.status == "completed"]
            pruned = [d for d in all_dirs if d.status == "pruned"]
            in_progress = [d for d in all_dirs if d.status == "in_progress"]

            seed_avail = [d for d in available if (d.source_exp_id or "").startswith("seed")]
            organic_avail = [d for d in available if not (d.source_exp_id or "").startswith("seed")]
            seed_comp = [d for d in completed if (d.source_exp_id or "").startswith("seed")]
            organic_comp = [d for d in completed if not (d.source_exp_id or "").startswith("seed")]

            return {
                "seed_available": len(seed_avail),
                "organic_available": len(organic_avail),
                "in_progress": len(in_progress),
                "completed": len(completed),
                "completed_seed": len(seed_comp),
                "completed_organic": len(organic_comp),
                "pruned": len(pruned),
                "total": len(all_dirs),
                "conversion_rate": len(completed) / max(len(all_dirs), 1),
                "seed_conversion_rate": len(seed_comp) / max(len(seed_avail) + len(seed_comp), 1),
                "organic_conversion_rate": len(organic_comp) / max(len(organic_avail) + len(organic_comp), 1),
            }
        except Exception:
            # Fallback: just cycle records
            return {
                "total_cycles": len(self.successful_records),
                "avg_quality": sum(r.quality_score for r in self.successful_records if r.quality_score > 0) / max(
                    sum(1 for r in self.successful_records if r.quality_score > 0), 1
                ),
            }

    def detect_quality_decay(self, window: int = 5, threshold: float = -0.05) -> List[Dict[str, Any]]:
        """Detect domains with declining quality over recent cycles.

        Compares average quality of the last `window` cycles per domain
        against the prior `window` cycles. If the delta is below `threshold`,
        the domain is flagged as declining.

        Returns list of dicts: [{domain, recent_avg, prior_avg, delta, count}]
        """
        from collections import defaultdict
        domain_data = defaultdict(list)
        for r in self.successful_records:
            if r.domain and r.quality_score > 0:
                domain_data[r.domain].append(r.quality_score)

        declining = []
        for domain, scores in domain_data.items():
            if len(scores) < window * 2:
                continue  # Not enough data to compare
            recent = scores[-window:]
            prior = scores[-window * 2:-window]
            recent_avg = sum(recent) / len(recent)
            prior_avg = sum(prior) / len(prior)
            delta = recent_avg - prior_avg
            if delta < threshold:
                declining.append({
                    "domain": domain,
                    "recent_avg": round(recent_avg, 4),
                    "prior_avg": round(prior_avg, 4),
                    "delta": round(delta, 4),
                    "count": len(scores),
                })
        return sorted(declining, key=lambda x: x["delta"])


    def get_domain_correlations(self, min_cycles: int = 2) -> List[Dict[str, Any]]:
        """Find domain pairs that tend to produce quality together.

        For each pair of domains that co-occur in cycles (via multi-domain
        directions), compute the correlation of their quality scores.

        Returns list of {domain_a, domain_b, correlation, co_occurrences}.
        """
        from itertools import combinations
        # Group cycles by their timestamp (same cycle = multi-domain direction)
        domain_scores = defaultdict(list)
        for r in self.successful_records:
            if r.domain and r.quality_score > 0:
                domain_scores[r.domain].append(r.quality_score)

        # For pairs: compute Pearson-like correlation
        # We need cycles where both domains appear
        cycles_by_time = defaultdict(dict)
        for r in self.successful_records:
            if r.domain and r.quality_score > 0:
                cycles_by_time[r.start_time or r.timestamp][r.domain] = r.quality_score

        correlations = []
        domains = sorted(domain_scores.keys())
        for i, dom_a in enumerate(domains):
            for dom_b in domains[i+1:]:
                # Find cycles where both domains appear
                shared = []
                scores_a = []
                scores_b = []
                for time_key, domain_map in cycles_by_time.items():
                    if dom_a in domain_map and dom_b in domain_map:
                        shared.append(time_key)
                        scores_a.append(domain_map[dom_a])
                        scores_b.append(domain_map[dom_b])

                if len(shared) >= min_cycles:
                    # Compute correlation
                    n = len(shared)
                    mean_a = sum(scores_a) / n
                    mean_b = sum(scores_b) / n
                    cov = sum((a - mean_a) * (b - mean_b) for a, b in zip(scores_a, scores_b)) / n
                    var_a = sum((a - mean_a) ** 2 for a in scores_a) / n
                    var_b = sum((b - mean_b) ** 2 for b in scores_b) / n
                    if var_a > 0 and var_b > 0:
                        corr = cov / (var_a ** 0.5 * var_b ** 0.5)
                        correlations.append({
                            "domain_a": dom_a,
                            "domain_b": dom_b,
                            "correlation": round(corr, 3),
                            "co_occurrences": n,
                        })

        return sorted(correlations, key=lambda x: abs(x["correlation"]), reverse=True)

    def get_reasoning_log_stats(self) -> Dict[str, Any]:
        """Aggregate statistics from per-project reasoning logs.

        Reasoning logs are JSON files in .aether_workspace/reasoning_logs/
        that capture observable progress traces (status, percent_complete,
        elapsed time) for each Aristotle project.

        Returns summary stats: total projects, avg duration, completion
        rate, avg checkpoints per project, and stall metrics.
        """
        logs_dir = self.workspace / "reasoning_logs"
        if not logs_dir.exists():
            return {
                "total_projects": 0,
                "completed_projects": 0,
                "failed_projects": 0,
                "completion_rate": 0.0,
                "avg_duration_seconds": 0.0,
                "avg_checkpoints_per_project": 0.0,
                "total_stalls": 0,
                "avg_stall_seconds": 0.0,
            }

        log_files = list(logs_dir.glob("*.json"))
        if not log_files:
            return {
                "total_projects": 0,
                "completed_projects": 0,
                "failed_projects": 0,
                "completion_rate": 0.0,
                "avg_duration_seconds": 0.0,
                "avg_checkpoints_per_project": 0.0,
                "total_stalls": 0,
                "avg_stall_seconds": 0.0,
            }

        completed = 0
        failed = 0
        durations = []
        checkpoint_counts = []
        total_stalls = 0
        stall_durations = []

        for path in log_files:
            try:
                data = json.loads(path.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                continue

            final_status = data.get("final_status", "")
            if "IDLE" in final_status and data.get("has_files", False):
                completed += 1
            elif final_status == "FAILED":
                failed += 1
            duration = data.get("total_duration_seconds", 0) or 0
            if duration > 0:
                durations.append(duration)

            checkpoints = data.get("checkpoints", [])
            checkpoint_counts.append(len(checkpoints))

            # Detect stalls
            for i in range(1, len(checkpoints)):
                prev, curr = checkpoints[i-1], checkpoints[i]
                if (curr.get("percent_complete", 0) == prev.get("percent_complete", 0)
                    and curr.get("elapsed_seconds", 0) - prev.get("elapsed_seconds", 0) > 60):
                    total_stalls += 1
                    stall_durations.append(
                        curr.get("elapsed_seconds", 0) - prev.get("elapsed_seconds", 0)
                    )

        n = len(log_files)
        return {
            "total_projects": n,
            "completed_projects": completed,
            "failed_projects": failed,
            "completion_rate": round(completed / n, 3) if n > 0 else 0.0,
            "avg_duration_seconds": round(sum(durations) / len(durations), 1) if durations else 0.0,
            "avg_duration_minutes": round(sum(durations) / len(durations) / 60, 1) if durations else 0.0,
            "max_duration_minutes": round(max(durations) / 60, 1) if durations else 0.0,
            "min_duration_minutes": round(min(durations) / 60, 1) if durations else 0.0,
            "avg_checkpoints_per_project": round(sum(checkpoint_counts) / n, 1) if n > 0 else 0.0,
            "total_stalls": total_stalls,
            "avg_stall_seconds": round(sum(stall_durations) / len(stall_durations), 0) if stall_durations else 0.0,
        }
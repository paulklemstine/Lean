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
    quality_score: float = 0.0
    quality_breakdown: Optional[Dict[str, float]] = None
    novelty_score: Optional[float] = None
    outcome_quality: float = 0.0
    files_integrated: int = 0
    barrier_count: int = 0
    strategy_count: int = 0
    bridge_count: int = 0
    timestamp: str = ""

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        # Remove None values for cleanliness
        return {k: v for k, v in d.items() if v is not None and v != ""}

    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> "CycleRecord":
        known = {f.name for f in cls.__dataclass_fields__.values()}
        filtered = {k: v for k, v in d.items() if k in known}
        return cls(**filtered)


class CycleAnalytics:
    """Persistent store and analysis of per-cycle research metrics."""

    MAX_RECORDS = 2000  # Keep at most 2000 records, prune oldest

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
            quality_score=getattr(job, "quality_score", 0.0),
            outcome_quality=0.0,
            files_integrated=getattr(job, "files_integrated", 0),
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
        concept = getattr(job, "concept", None)
        if concept:
            if isinstance(concept, dict):
                domains = concept.get("domains", [])
                record.domain = domains[0] if domains else ""
                record.title = concept.get("title", "")[:100]
            else:
                domains = getattr(concept, "domains", [])
                record.domain = domains[0] if domains else ""
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

        self.records.append(record)
        self._save()

    def get_summary(self, last_n: int = 50) -> Dict[str, Any]:
        """Get summary statistics for the last N cycles."""
        recent = self.records[-last_n:]
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

    def get_quality_trend(self, last_n: int = 20) -> List[Dict[str, Any]]:
        """Get quality scores over the last N cycles for trend display."""
        recent = self.records[-last_n:]
        return [
            {"cycle": r.cycle_n, "quality": r.quality_score, "domain": r.domain}
            for r in recent
        ]

    def get_domain_stats(self) -> Dict[str, Dict[str, float]]:
        """Get per-domain statistics."""
        from collections import defaultdict
        domain_data = defaultdict(list)
        for r in self.records:
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
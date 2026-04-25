#!/usr/bin/env python3
"""Telemetry, benchmarking, and experiment registry for AETHER.

Tracks every proposal, dispatch, and integration with structured logging
and a rolling benchmark leaderboard.
"""

import json
import time
import uuid
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Any


@dataclass
class ExperimentRecord:
    """Single experiment tracking record."""
    experiment_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    arc_id: str = ""
    arc_name: str = ""
    concept_combination: List[str] = field(default_factory=list)
    domain: str = ""
    file_path: str = ""
    difficulty: str = ""

    # Generation phase
    generation_latency_ms: float = 0.0
    hypothesis_text: str = ""

    # Dispatch phase
    aristotle_job_id: Optional[str] = None
    dispatch_timestamp: Optional[str] = None

    # Result phase
    status: str = "pending"  # pending, proven, counterexample, timeout, rejected, integrated
    completion_timestamp: Optional[str] = None
    proof_length_lines: int = 0
    sorry_count_before: int = 0
    sorry_count_after: int = 0
    lean_build_time_ms: float = 0.0

    # Integration
    integrated_commit: Optional[str] = None
    rollback_reason: Optional[str] = None

    # Artifact tracking
    has_research_report: bool = False
    has_python_demo: bool = False
    has_svg_demo: bool = False
    has_sciam_discussion: bool = False
    artifact_paths: Dict[str, str] = field(default_factory=dict)

    # Pi-Agent metadata
    pi_agent_model: str = ""
    pi_agent_concept_title: str = ""
    prompt_creativity_score: float = 0.0
    novelty_score: float = 0.0
    epicness_score: float = 0.0


class TelemetryLogger:
    """Central telemetry and experiment registry."""

    def __init__(self, config: Dict[str, Any]):
        self.log_dir = Path(config.get("log_dir", "./logs"))
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.registry_path = self.log_dir / Path(config.get("experiment_registry", "./logs/experiments.jsonl")).name
        self.benchmark_path = self.log_dir / Path(config.get("benchmark_file", "./logs/benchmarks.json")).name
        self.report_path = self.log_dir / Path(config.get("report_output", "./logs/telemetry_report.html")).name

    def log_experiment(self, record: ExperimentRecord) -> None:
        """Append an experiment record to the registry."""
        with open(self.registry_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(asdict(record), ensure_ascii=False) + "\n")

    def load_experiments(self) -> List[Dict[str, Any]]:
        """Load all experiment records."""
        records = []
        if self.registry_path.exists():
            with open(self.registry_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line:
                        records.append(json.loads(line))
        return records

    def update_experiment(self, experiment_id: str, **kwargs) -> None:
        """Update fields of an existing experiment record."""
        records = self.load_experiments()
        updated = False
        for r in records:
            if r.get("experiment_id") == experiment_id:
                for k, v in kwargs.items():
                    r[k] = v
                updated = True
                break
        if updated:
            with open(self.registry_path, "w", encoding="utf-8") as f:
                for r in records:
                    f.write(json.dumps(r, ensure_ascii=False) + "\n")

    def get_stats(self) -> Dict[str, Any]:
        """Compute aggregate statistics."""
        records = self.load_experiments()
        total = len(records)
        if total == 0:
            return {"total_experiments": 0}

        by_status = {}
        by_arc = {}
        by_domain = {}
        latencies = []

        for r in records:
            status = r.get("status", "unknown")
            by_status[status] = by_status.get(status, 0) + 1

            arc = r.get("arc_name", "unknown")
            by_arc[arc] = by_arc.get(arc, 0) + 1

            domain = r.get("domain", "unknown")
            by_domain[domain] = by_domain.get(domain, 0) + 1

            if r.get("generation_latency_ms"):
                latencies.append(r["generation_latency_ms"])

        proven = by_status.get("proven", 0) + by_status.get("integrated", 0)

        return {
            "total_experiments": total,
            "by_status": by_status,
            "by_arc": by_arc,
            "by_domain": by_domain,
            "success_rate": proven / total if total > 0 else 0.0,
            "avg_generation_latency_ms": sum(latencies) / len(latencies) if latencies else 0.0,
            "proven_count": proven,
        }

    def generate_html_report(self) -> str:
        """Generate an HTML dashboard of experiments."""
        stats = self.get_stats()
        records = self.load_experiments()

        # Sort by timestamp desc, take last 50
        recent = sorted(records, key=lambda r: r.get("timestamp", ""), reverse=True)[:50]

        rows = ""
        for r in recent:
            rows += f"""
            <tr>
                <td>{r.get('timestamp', '')[:19]}</td>
                <td>{r.get('arc_name', '')}</td>
                <td>{r.get('domain', '')}</td>
                <td><code>{r.get('experiment_id', '')[:8]}</code></td>
                <td><span class="status-{r.get('status', '')}">{r.get('status', '')}</span></td>
                <td>{r.get('novelty_score', 0):.2f}</td>
                <td>{r.get('epicness_score', 0):.2f}</td>
            </tr>
            """

        html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>AETHER Telemetry Dashboard</title>
    <style>
        body {{ font-family: monospace; background: #0d1117; color: #c9d1d9; padding: 2rem; }}
        h1 {{ color: #58a6ff; }}
        .stats {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin: 2rem 0; }}
        .stat-card {{ background: #161b22; border: 1px solid #30363d; padding: 1rem; border-radius: 6px; }}
        .stat-value {{ font-size: 2rem; color: #3fb950; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 2rem; }}
        th, td {{ padding: 0.5rem; text-align: left; border-bottom: 1px solid #30363d; }}
        th {{ color: #8b949e; }}
        .status-proven {{ color: #3fb950; }}
        .status-integrated {{ color: #58a6ff; }}
        .status-pending {{ color: #d29922; }}
        .status-timeout {{ color: #f85149; }}
        .status-rejected {{ color: #f85149; }}
        .status-counterexample {{ color: #a371f7; }}
    </style>
</head>
<body>
    <h1>AETHER Telemetry Dashboard</h1>
    <p>Generated: {datetime.utcnow().isoformat()}</p>
    <div class="stats">
        <div class="stat-card">
            <div class="stat-label">Total Experiments</div>
            <div class="stat-value">{stats['total_experiments']}</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Success Rate</div>
            <div class="stat-value">{stats['success_rate']:.1%}</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Proven</div>
            <div class="stat-value">{stats['proven_count']}</div>
        </div>
    </div>
    <h2>Recent Experiments</h2>
    <table>
        <tr><th>Time</th><th>Arc</th><th>Domain</th><th>ID</th><th>Status</th><th>Novelty</th><th>Epicness</th></tr>
        {rows}
    </table>
</body>
</html>
"""

        with open(self.report_path, "w", encoding="utf-8") as f:
            f.write(html)

        return str(self.report_path)

    def log_artifacts(self, experiment_id: str, artifacts: Dict[str, str]) -> None:
        """Log artifact paths for an experiment."""
        self.update_experiment(
            experiment_id,
            artifact_paths=artifacts,
            has_research_report="research_report" in artifacts,
            has_python_demo="python_demo" in artifacts,
            has_svg_demo="svg_demo" in artifacts,
            has_sciam_discussion="sciam_discussion" in artifacts,
        )

    def log_event(self, level: str, message: str, context: Optional[Dict] = None) -> None:
        """Log a structured event."""
        event = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": level,
            "message": message,
            "context": context or {}
        }
        log_file = self.log_dir / "events.jsonl"
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(event, ensure_ascii=False) + "\n")

        # Also print to stdout
        print(f"[{level.upper()}] {message}")

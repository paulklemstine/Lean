#!/usr/bin/env python3
"""ReasoningLog: Capture observable progress traces of Aristotle projects.

While a project is running, we poll its status and percent_complete.
Each poll becomes a "checkpoint" in a timeline. Saved to .aether_workspace/reasoning_logs/{job_id}.json.

This is NOT capturing the LLM's actual reasoning tokens (we don't have
access to those via the SDK). But it DOES capture:
  - Status transitions (RUNNING -> IDLE, etc.)
  - Percent-complete over time (to detect stalling, slow progress, jumps)
  - Error messages if the project fails
  - Total wall-clock duration
  - Submission and completion timestamps

Enough to analyze:
  - Which project types stall vs. progress steadily
  - How long Aristotle typically takes to reach various milestones
  - Failure modes and error patterns
  - Correlation between project duration and final quality
"""

import json
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional


class ReasoningLog:
    """Per-project progress trace."""

    MAX_LOGS = 100  # Keep at most 100 logs, prune oldest

    def __init__(self, workspace: Path, project_id: str, job_id: str = ""):
        self.workspace = workspace
        self.project_id = project_id
        self.job_id = job_id
        self.logs_dir = workspace / "reasoning_logs"
        self.logs_dir.mkdir(parents=True, exist_ok=True)
        # Use job_id if available, else project_id
        self._id = job_id or project_id
        self._log_path = self.logs_dir / f"{self._id}.json"
        self._data: Dict[str, Any] = self._load()
        # Lazy cleanup of old logs (only when creating a new one)
        self._cleanup_old_logs()

    def _load(self) -> Dict[str, Any]:
        if self._log_path.exists():
            try:
                return json.loads(self._log_path.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                pass
        return {
            "project_id": self.project_id,
            "job_id": self.job_id,
            "submitted_at": "",
            "completed_at": "",
            "total_duration_seconds": 0.0,
            "final_status": "",
            "final_percent": 0.0,
            "has_files": False,
            "error": "",
            "checkpoints": [],  # List of {timestamp, status, percent, elapsed_s}
            "stages": [],      # Status transitions [{from, to, at_seconds}]
        }

    def _save(self) -> None:
        self._log_path.write_text(
            json.dumps(self._data, indent=2, ensure_ascii=False, sort_keys=True),
            encoding="utf-8",
        )

    def _cleanup_old_logs(self) -> None:
        """Remove oldest logs if total exceeds MAX_LOGS."""
        try:
            all_logs = list(self.logs_dir.glob("*.json"))
            if len(all_logs) > self.MAX_LOGS:
                # Sort by modification time, oldest first
                all_logs.sort(key=lambda p: p.stat().st_mtime)
                # Delete the oldest excess
                n_to_delete = len(all_logs) - self.MAX_LOGS
                for log in all_logs[:n_to_delete]:
                    try:
                        log.unlink()
                    except OSError:
                        pass
        except Exception:
            pass  # Don't break on cleanup errors

    def record_submission(self, prompt: str = "", domain: str = "") -> None:
        """Mark the project as submitted. Captures metadata at submission time."""
        self._data["submitted_at"] = datetime.now(timezone.utc).isoformat()[:19]
        self._data["domain"] = domain
        self._data["prompt_length"] = len(prompt)
        # First checkpoint
        self.add_checkpoint(status="SUBMITTED", percent=0.0)
        self._save()

    def add_checkpoint(self, status: str, percent: float, extra: Optional[Dict] = None) -> None:
        """Add a progress checkpoint."""
        now = datetime.now(timezone.utc)
        # Compute elapsed since submission
        if self._data.get("submitted_at"):
            try:
                start = datetime.fromisoformat(self._data["submitted_at"])
                # If the parsed datetime is naive, assume UTC
                if start.tzinfo is None:
                    start = start.replace(tzinfo=timezone.utc)
                elapsed = (now - start).total_seconds()
            except (ValueError, TypeError):
                elapsed = 0.0
        else:
            elapsed = 0.0

        checkpoint = {
            "timestamp": now.isoformat()[:19],
            "elapsed_seconds": round(elapsed, 1),
            "status": status,
            "percent_complete": round(percent, 1),
        }
        if extra:
            checkpoint.update(extra)
        self._data["checkpoints"].append(checkpoint)

        # Detect stage transitions
        if self._data["checkpoints"]:
            prev = self._data["checkpoints"][-2] if len(self._data["checkpoints"]) >= 2 else None
            if prev and prev["status"] != status:
                self._data["stages"].append({
                    "from": prev["status"],
                    "to": status,
                    "at_elapsed_seconds": round(elapsed, 1),
                })

        self._save()

    def record_completion(self, status: str, percent: float, has_files: bool, error: str = "") -> None:
        """Mark the project as completed (success or failure)."""
        now = datetime.now(timezone.utc)
        self._data["completed_at"] = now.isoformat()[:19]
        self._data["final_status"] = status
        self._data["final_percent"] = percent
        self._data["has_files"] = has_files
        self._data["error"] = error

        if self._data.get("submitted_at"):
            try:
                start = datetime.fromisoformat(self._data["submitted_at"])
                self._data["total_duration_seconds"] = round(
                    (now - start).total_seconds(), 1
                )
            except (ValueError, TypeError):
                pass

        # Final checkpoint
        self.add_checkpoint(status=f"FINAL:{status}", percent=percent, extra={
            "has_files": has_files,
            "error": error,
        })
        self._save()

    def get_summary(self) -> Dict[str, Any]:
        """Return a compact summary for analysis."""
        checkpoints = self._data.get("checkpoints", [])
        if not checkpoints:
            return {"error": "no checkpoints"}

        # Compute progress rate (avg %/min)
        total_duration = self._data.get("total_duration_seconds", 0) or 0
        if total_duration > 0:
            final_pct = self._data.get("final_percent", 0)
            pct_per_min = round(final_pct / (total_duration / 60), 2)
        else:
            pct_per_min = 0

        # Detect stalls: long flat periods at the same percent
        stalls = []
        for i in range(1, len(checkpoints)):
            prev = checkpoints[i-1]
            curr = checkpoints[i]
            if (curr["percent_complete"] == prev["percent_complete"]
                and curr["elapsed_seconds"] - prev["elapsed_seconds"] > 60):
                stalls.append({
                    "from": prev["elapsed_seconds"],
                    "to": curr["elapsed_seconds"],
                    "duration_seconds": curr["elapsed_seconds"] - prev["elapsed_seconds"],
                    "stuck_at_percent": prev["percent_complete"],
                })

        return {
            "project_id": self._data.get("project_id", ""),
            "job_id": self._data.get("job_id", ""),
            "domain": self._data.get("domain", ""),
            "submitted_at": self._data.get("submitted_at", ""),
            "completed_at": self._data.get("completed_at", ""),
            "total_duration_seconds": total_duration,
            "final_status": self._data.get("final_status", ""),
            "final_percent": self._data.get("final_percent", 0),
            "has_files": self._data.get("has_files", False),
            "n_checkpoints": len(checkpoints),
            "n_stage_transitions": len(self._data.get("stages", [])),
            "pct_per_minute": pct_per_min,
            "n_stalls": len(stalls),
            "longest_stall_seconds": max((s["duration_seconds"] for s in stalls), default=0),
        }

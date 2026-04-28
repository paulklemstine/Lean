"""Persistent tracker for in-flight Aristotle projects.

Stores project IDs, concept info, and timestamps in a JSONL file
so that projects are tracked across restarts of the research loop.
"""
import json
import time
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Optional, List


@dataclass
class TrackedProject:
    project_id: str
    exp_id: str
    concept: str
    domain: str
    mode: str
    dispatch_time: float
    status: str = "queued"        # queued, in_progress, complete, failed, error
    percent_complete: int = 0
    result_summary: str = ""
    quality: str = ""
    quality_score: float = 0.0
    complete_time: float = 0.0

    def to_dict(self):
        return asdict(self)

    @classmethod
    def from_dict(cls, d):
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})


class ProjectTracker:
    """Journalling project tracker — append-only log with latest state."""

    def __init__(self, path: Path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._projects: dict[str, TrackedProject] = {}
        self._load()

    def _load(self):
        if not self.path.exists():
            return
        for line in self.path.read_text().strip().splitlines():
            if not line.strip():
                continue
            try:
                d = json.loads(line)
                proj = TrackedProject.from_dict(d)
                self._projects[proj.project_id] = proj
            except Exception:
                pass

    def _append(self, proj: TrackedProject):
        with open(self.path, "a") as f:
            f.write(json.dumps(proj.to_dict()) + "\n")

    def track(self, project: TrackedProject):
        self._projects[project.project_id] = project
        self._append(project)

    def update(self, project_id: str, **kwargs):
        if project_id not in self._projects:
            return
        proj = self._projects[project_id]
        for k, v in kwargs.items():
            if hasattr(proj, k):
                setattr(proj, k, v)
        self._append(proj)  # Append updated state

    def get_active(self) -> List[TrackedProject]:
        return [p for p in self._projects.values()
                if p.status in ("queued", "in_progress")]

    def get_completed(self) -> List[TrackedProject]:
        return [p for p in self._projects.values()
                if p.status in ("complete",)]

    def get_all(self) -> List[TrackedProject]:
        return list(self._projects.values())

    @property
    def active_count(self) -> int:
        return len(self.get_active())

    @property
    def completed_count(self) -> int:
        return len(self.get_completed())

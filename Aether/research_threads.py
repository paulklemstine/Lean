#!/usr/bin/env python3
"""ResearchThreadManager: tracks multi-cycle research threads for Aether.

A thread is a sequence of related research cycles (jobs) pursuing a single
line of inquiry.  The manager records each cycle's extracted identifiers
(theorems, lemmas, definitions) and decides whether the thread has produced a
knowledge delta since the last cycle.

Threads are created when a future direction is consumed.  They remain
``active`` until:
  * they produce a terminal positive result (counterexample or publishable
    theorem) -> ``completed``
  * they stagnate (4 cycles without a knowledge delta) -> ``terminated``
  * the direction is released/failed/quarantined externally -> ``terminated``
"""

import json
import re
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Set


@dataclass
class ResearchThread:
    """A multi-cycle research thread rooted in a single future direction."""
    thread_id: str
    root_direction_id: str
    status: str = "active"  # active, completed, terminated
    cycles: List[str] = field(default_factory=list)
    cycle_idents: List[List[str]] = field(default_factory=list)
    cycle_quality_scores: List[float] = field(default_factory=list)
    last_progress_cycle: int = -1
    termination_reason: str = ""
    thread_context: str = ""
    created_at: str = ""
    updated_at: str = ""

    def to_dict(self) -> dict:
        return {
            "thread_id": self.thread_id,
            "root_direction_id": self.root_direction_id,
            "status": self.status,
            "cycles": self.cycles,
            "cycle_idents": self.cycle_idents,
            "cycle_quality_scores": self.cycle_quality_scores,
            "last_progress_cycle": self.last_progress_cycle,
            "termination_reason": self.termination_reason,
            "thread_context": self.thread_context,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "ResearchThread":
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})


class ResearchThreadManager:
    """Persistent manager for research threads."""

    STAGNATION_LIMIT = 4  # kill after this many consecutive cycles without delta

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        self._file = self.workspace / "research_threads.json"
        self._threads: Dict[str, ResearchThread] = {}
        self._load()

    def _load(self) -> None:
        if not self._file.exists():
            return
        try:
            data = json.loads(self._file.read_text(encoding="utf-8"))
            for d in data.get("threads", []):
                thread = ResearchThread.from_dict(d)
                self._threads[thread.thread_id] = thread
        except Exception:
            self._threads = {}

    def _save(self) -> None:
        self.workspace.mkdir(parents=True, exist_ok=True)
        now = datetime.now(timezone.utc).isoformat()
        for t in self._threads.values():
            if not t.created_at:
                t.created_at = now
            t.updated_at = now
        self._file.write_text(
            json.dumps(
                {"threads": [t.to_dict() for t in self._threads.values()]},
                indent=2,
                ensure_ascii=False,
                sort_keys=True,
            ),
            encoding="utf-8",
        )

    @staticmethod
    def _extract_idents(lean_source: str) -> Set[str]:
        """Extract theorem, lemma, and definition names from Lean source."""
        if not lean_source:
            return set()
        # Match "theorem foo", "lemma bar", "def baz", "abbrev qux"
        pattern = re.compile(
            r"\b(?:theorem|lemma|def|abbrev|instance|structure)\s+([A-Za-z_][A-Za-z0-9_']*)",
            re.IGNORECASE,
        )
        return set(pattern.findall(lean_source))

    def start_thread(self, root_direction_id: str, job_id: str) -> ResearchThread:
        """Create a new active thread rooted in the given future direction."""
        thread_id = f"th_{uuid.uuid4().hex[:8]}"
        now = datetime.now(timezone.utc).isoformat()
        thread = ResearchThread(
            thread_id=thread_id,
            root_direction_id=root_direction_id,
            status="active",
            cycles=[job_id],
            cycle_idents=[list(self._extract_idents(""))],
            cycle_quality_scores=[0.0],
            last_progress_cycle=0,
            created_at=now,
            updated_at=now,
        )
        self._threads[thread_id] = thread
        self._save()
        print(f"[Thread] Started {thread_id} for direction {root_direction_id} (job {job_id})")
        return thread

    def get_thread(self, thread_id: str) -> Optional[ResearchThread]:
        return self._threads.get(thread_id)

    def get_active_threads(self) -> List[ResearchThread]:
        return [t for t in self._threads.values() if t.status == "active"]

    def append_cycle(
        self, thread_id: str, job_id: str, lean_source: str, quality_score: float = 0.0
    ) -> bool:
        """Append a new cycle to a thread and evaluate progress.

        Returns True if the thread is still active after appending;
        returns False if the thread was terminated due to stagnation.
        """
        thread = self._threads.get(thread_id)
        if not thread:
            return False
        if thread.status != "active":
            return False

        current_idents = self._extract_idents(lean_source)
        if thread.cycles and thread.cycles[-1] == job_id:
            # Idempotent: update the already-recorded cycle (e.g., result now available).
            thread.cycle_idents[-1] = sorted(current_idents)
            thread.cycle_quality_scores[-1] = quality_score
        else:
            thread.cycles.append(job_id)
            thread.cycle_idents.append(sorted(current_idents))
            thread.cycle_quality_scores.append(quality_score)

        # Knowledge delta = any new identifier not seen in previous cycles
        previous_idents: Set[str] = set()
        for idents in thread.cycle_idents[:-1]:
            previous_idents.update(idents)
        new_idents = current_idents - previous_idents

        cycle_index = len(thread.cycles) - 1
        if new_idents:
            thread.last_progress_cycle = cycle_index
            print(f"[Thread] {thread_id} cycle {cycle_index} ({job_id[:8]}) knowledge delta: {len(new_idents)} new idents")
        else:
            print(f"[Thread] {thread_id} cycle {cycle_index} ({job_id[:8]}) no knowledge delta")

        # Stagnation check
        stagnant_cycles = cycle_index - thread.last_progress_cycle
        if stagnant_cycles >= self.STAGNATION_LIMIT:
            self.terminate_thread(thread_id, "stagnation")
            return False

        self._save()
        return True

    def terminate_thread(self, thread_id: str, reason: str) -> None:
        """Mark a thread as terminated with a reason."""
        thread = self._threads.get(thread_id)
        if not thread:
            return
        thread.status = "terminated"
        thread.termination_reason = reason
        self._save()
        print(f"[Thread] {thread_id} terminated: {reason}")

    def complete_thread(self, thread_id: str) -> None:
        """Mark a thread as completed with a positive terminal result."""
        thread = self._threads.get(thread_id)
        if not thread:
            return
        thread.status = "completed"
        thread.termination_reason = ""
        self._save()
        print(f"[Thread] {thread_id} completed")

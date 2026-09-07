"""Adaptive Concurrency Manager for Aether.

Dynamically detects, auto-tunes, and recovers Aristotle concurrency limits to match
server capacity and Harmonic backend quota/throttling policies.
"""
from dataclasses import dataclass
import json
import time
from pathlib import Path
from typing import Optional, Dict, Any


@dataclass
class ConcurrencyState:
    detected_limit: int
    last_queue_full_time: float
    success_count_at_limit: int = 0
    cooldown_seconds: float = 3600.0  # 1 hour before attempting to ramp back up


class AdaptiveConcurrencyManager:
    """Tracks remote concurrency limits and auto-tunes local dispatching."""

    def __init__(self, workspace: Path, default_max: int = 9, cooldown_seconds: float = 3600.0):
        self.workspace = Path(workspace)
        self.file_path = self.workspace / "adaptive_concurrency.json"
        self.default_max = default_max
        self.cooldown_seconds = cooldown_seconds

    def load_state(self) -> Optional[ConcurrencyState]:
        """Load persisted concurrency state if present."""
        if not self.file_path.exists():
            return None
        try:
            with open(self.file_path, "r", encoding="utf-8") as f:
                d = json.load(f)
            return ConcurrencyState(
                detected_limit=int(d.get("detected_limit", self.default_max)),
                last_queue_full_time=float(d.get("last_queue_full_time", 0.0)),
                success_count_at_limit=int(d.get("success_count_at_limit", 0)),
                cooldown_seconds=float(d.get("cooldown_seconds", self.cooldown_seconds)),
            )
        except Exception:
            return None

    def save_state(self, state: ConcurrencyState) -> None:
        """Persist concurrency state to disk."""
        try:
            self.workspace.mkdir(parents=True, exist_ok=True)
            with open(self.file_path, "w", encoding="utf-8") as f:
                json.dump({
                    "detected_limit": state.detected_limit,
                    "last_queue_full_time": state.last_queue_full_time,
                    "success_count_at_limit": state.success_count_at_limit,
                    "cooldown_seconds": state.cooldown_seconds,
                }, f, indent=2)
        except Exception as e:
            print(f"[AutoTune] Failed to save concurrency state: {e}")

    def record_queue_full(self, current_active: int) -> int:
        """Called when Aristotle returns 'QUEUE FULL' (HTTP 400/429 concurrency limit).

        Sets detected limit to the active job count at the time of rejection.
        """
        new_limit = max(1, current_active)
        state = ConcurrencyState(
            detected_limit=new_limit,
            last_queue_full_time=time.time(),
            success_count_at_limit=0,
            cooldown_seconds=self.cooldown_seconds,
        )
        self.save_state(state)
        print(f"[AutoTune] Aristotle remote concurrency cap detected: {new_limit} active project(s). "
              f"Setting effective max_inflight to {new_limit}.")
        return new_limit

    def record_dispatch_success(self, current_active: int, configured_max: int) -> None:
        """Called upon successful project creation on Aristotle."""
        state = self.load_state()
        if not state:
            return
        if current_active > state.detected_limit:
            state.detected_limit = min(configured_max, current_active)
            state.success_count_at_limit = 1
            print(f"[AutoTune] Remote capacity expanded! Raising detected limit to {state.detected_limit}.")
            self.save_state(state)
        else:
            state.success_count_at_limit += 1
            self.save_state(state)

    def get_effective_max_inflight(self, configured_max: int) -> int:
        """Returns the auto-tuned max_inflight, respecting cooldown probing."""
        state = self.load_state()
        if not state:
            return configured_max

        if state.detected_limit >= configured_max:
            return configured_max

        now = time.time()
        elapsed = now - state.last_queue_full_time

        # If cooldown expired, allow probing with +1 slot to test if Harmonic restored capacity
        if elapsed >= state.cooldown_seconds:
            probe_limit = min(configured_max, state.detected_limit + 1)
            print(f"[AutoTune] Cooldown expired ({elapsed/60:.1f}m >= {state.cooldown_seconds/60:.1f}m). "
                  f"Probing with limit={probe_limit} (configured={configured_max}).")
            return probe_limit

        return min(configured_max, state.detected_limit)

"""
AutoHealer — Top-level façade
==============================

Wires together every component into a single, easy-to-use entry point:

    >>> healer = AutoHealer("app.log", watch_dir="src/")
    >>> healer.start()

The heal loop:

    log line → TailWatcher → Diagnostician → CodeSurgeon → Compiler → HotSwapper
                                  ↑                            |
                                  └──── Oracle / OracleTeam ───┘

Events are emitted at each stage so external code can hook in for
monitoring dashboards, Slack alerts, etc.
"""

from __future__ import annotations

import logging
import time
import threading
from pathlib import Path
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional

from autoheal.core.tail_watcher import TailWatcher, LogLine
from autoheal.core.diagnostician import Diagnostician, Diagnosis, Severity
from autoheal.core.code_surgeon import CodeSurgeon, Patch
from autoheal.core.compiler import Compiler, CompileResult
from autoheal.core.hot_swapper import HotSwapper
from autoheal.core.oracle import Oracle, OracleTeam

logger = logging.getLogger(__name__)


@dataclass
class HealEvent:
    """Record of a single heal cycle."""
    timestamp: float
    diagnosis: Diagnosis
    patch: Optional[Patch]
    compile_result: Optional[CompileResult]
    swapped: bool
    elapsed_seconds: float


class AutoHealer:
    """
    Self-healing supervisor for a Python application.

    Parameters
    ----------
    log_path : str | Path
        Path to the parent application's log file.
    watch_dir : str | Path
        Root of the source tree to monitor and patch.
    oracle_backend : callable, optional
        ``(prompt: str) -> str`` AI backend.  If None, only heuristic
        fixes are attempted.
    use_team : bool
        If True, use the full OracleTeam (council pattern) instead of
        a single Oracle.
    auto_apply : bool
        If True, patches are applied automatically.  If False, patches
        are generated but require manual ``apply()``.
    min_severity : Severity
        Only attempt healing for diagnoses at this level or above.
    cooldown : float
        Minimum seconds between heal attempts for the *same* file.
    poll_interval : float
        Log-file poll interval passed to TailWatcher.
    """

    def __init__(
        self,
        log_path: str | Path,
        watch_dir: str | Path = ".",
        oracle_backend: Optional[Callable[[str], str]] = None,
        use_team: bool = False,
        auto_apply: bool = True,
        min_severity: Severity = Severity.ERROR,
        cooldown: float = 10.0,
        poll_interval: float = 0.25,
    ) -> None:
        self.log_path = Path(log_path)
        self.watch_dir = Path(watch_dir).resolve()
        self.min_severity = min_severity
        self.cooldown = cooldown
        self.auto_apply = auto_apply

        # Components
        self.watcher = TailWatcher(log_path, poll_interval=poll_interval)
        self.diagnostician = Diagnostician()
        self.compiler = Compiler(watch_dir)
        self.swapper = HotSwapper()

        # Oracle setup
        self.oracle: Optional[Oracle] = None
        self.oracle_team: Optional[OracleTeam] = None

        if oracle_backend:
            if use_team:
                self.oracle_team = OracleTeam(oracle_backend)
            else:
                self.oracle = Oracle(oracle_backend, name="healer-oracle")

        self.surgeon = CodeSurgeon(
            watch_dir=watch_dir,
            oracle=self.oracle,
            auto_apply=False,  # we handle apply ourselves
        )

        # State
        self._heal_history: List[HealEvent] = []
        self._cooldowns: Dict[str, float] = {}
        self._event_callbacks: List[Callable[[HealEvent], None]] = []

        # Wire the watcher to our handler
        self.watcher.on_line(self._on_log_line)

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def start(self) -> None:
        """Begin watching and healing."""
        logger.info("AutoHealer starting — watching %s", self.log_path)
        self.watcher.start()

    def stop(self) -> None:
        """Graceful shutdown."""
        self.watcher.stop()
        logger.info("AutoHealer stopped. %d heal events recorded.", len(self._heal_history))

    def on_heal(self, callback: Callable[[HealEvent], None]) -> None:
        """Register a callback invoked after each heal cycle."""
        self._event_callbacks.append(callback)

    @property
    def history(self) -> List[HealEvent]:
        return list(self._heal_history)

    @property
    def is_running(self) -> bool:
        return self.watcher.is_running

    def heal_now(self, diagnosis: Diagnosis) -> HealEvent:
        """Manually trigger a heal cycle for a given Diagnosis."""
        return self._heal(diagnosis)

    # ------------------------------------------------------------------
    # Internal pipeline
    # ------------------------------------------------------------------

    def _on_log_line(self, log_line: LogLine) -> None:
        diag = self.diagnostician.classify(log_line)
        if diag is None:
            return
        if diag.severity < self.min_severity:
            return

        # Cooldown check
        key = diag.source_file or "unknown"
        now = time.time()
        if key in self._cooldowns and (now - self._cooldowns[key]) < self.cooldown:
            logger.debug("Cooldown active for %s — skipping.", key)
            return
        self._cooldowns[key] = now

        # Run heal in a separate thread to not block the dispatcher
        threading.Thread(
            target=self._heal,
            args=(diag,),
            name="autoheal-heal",
            daemon=True,
        ).start()

    def _heal(self, diagnosis: Diagnosis) -> HealEvent:
        t0 = time.time()
        patch: Optional[Patch] = None
        compile_result: Optional[CompileResult] = None
        swapped = False

        try:
            # Step 1: Generate patch
            if self.oracle_team and diagnosis.source_file:
                src = Path(diagnosis.source_file).read_text(errors="replace")
                diag_text = (
                    f"Category: {diagnosis.category}\n"
                    f"Message: {diagnosis.message}\n"
                    f"File: {diagnosis.source_file}\n"
                    f"Line: {diagnosis.source_line}\n"
                )
                fixed = self.oracle_team.run_repair_cycle(diag_text, src)
                if fixed and fixed != src:
                    from autoheal.core.code_surgeon import Patch as PatchClass
                    import difflib
                    diff = "".join(difflib.unified_diff(
                        src.splitlines(keepends=True),
                        fixed.splitlines(keepends=True),
                    ))
                    patch = PatchClass(
                        target_file=diagnosis.source_file,
                        original_source=src,
                        patched_source=fixed,
                        unified_diff=diff,
                        diagnosis=diagnosis,
                        is_valid=self.surgeon._validate_syntax(fixed),
                    )
            else:
                patch = self.surgeon.propose_patch(diagnosis)

            if patch is None or not patch.is_valid:
                logger.info("No valid patch for: %s", diagnosis.message)
            else:
                # Step 2: Apply patch
                if self.auto_apply:
                    self.surgeon.apply_patch(patch)

                    # Step 3: Compile
                    compile_result = self.compiler.compile_and_load(patch.target_file)

                    # Step 4: Hot-swap
                    if compile_result.success and compile_result.module:
                        n = self.swapper.swap_module(
                            compile_result.module_name, compile_result.module
                        )
                        swapped = n > 0
                        logger.info(
                            "Heal complete: %s — %d attributes swapped.",
                            diagnosis.category, n,
                        )
                    else:
                        logger.warning(
                            "Compile failed after patch — rolling back: %s",
                            compile_result.error if compile_result else "unknown",
                        )
                        # Rollback: restore from backup
                        if patch.applied:
                            backup = Path(patch.target_file + ".autoheal.bak")
                            if backup.exists():
                                import shutil
                                shutil.move(str(backup), patch.target_file)
                                logger.info("Rolled back %s from backup.", patch.target_file)

        except Exception:
            logger.exception("Heal cycle failed for %s", diagnosis.message)

        elapsed = time.time() - t0
        event = HealEvent(
            timestamp=t0,
            diagnosis=diagnosis,
            patch=patch,
            compile_result=compile_result,
            swapped=swapped,
            elapsed_seconds=elapsed,
        )
        self._heal_history.append(event)

        for cb in self._event_callbacks:
            try:
                cb(event)
            except Exception:
                logger.exception("Event callback error")

        return event

    def get_report(self) -> str:
        """Generate a human-readable report of all heal events."""
        lines = ["AutoHeal Report", "=" * 60]
        for i, ev in enumerate(self._heal_history, 1):
            status = "✓ HEALED" if ev.swapped else "✗ FAILED"
            lines.append(
                f"\n[{i}] {status} — {ev.diagnosis.category}: {ev.diagnosis.message[:80]}"
            )
            lines.append(f"    File: {ev.diagnosis.source_file}:{ev.diagnosis.source_line}")
            lines.append(f"    Time: {ev.elapsed_seconds:.2f}s")
            if ev.patch:
                lines.append(f"    Patch valid: {ev.patch.is_valid}")
            if ev.compile_result:
                lines.append(f"    Compile: {'OK' if ev.compile_result.success else ev.compile_result.error}")
        lines.append("\n" + "=" * 60)
        lines.append(f"Total: {len(self._heal_history)} events, "
                     f"{sum(1 for e in self._heal_history if e.swapped)} healed")
        return "\n".join(lines)

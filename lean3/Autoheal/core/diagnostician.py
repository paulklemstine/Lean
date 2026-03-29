"""
Diagnostician — Log-line classification and error diagnosis
=============================================================

Classifies every incoming log line into a severity level and, for errors
and warnings, extracts structured diagnostic records:

    - exception type & message
    - originating file and line number
    - stack-trace context (when available)
    - suggested error category (syntax, runtime, import, timeout, …)

The classifier uses a cascade:

1. **Regex rules** — fast, zero-cost pattern matches for common formats.
2. **Heuristic scorer** — keyword / TF-IDF lightweight scoring.
3. **Oracle fallback** — forwards ambiguous lines to the Oracle AI for
   deeper semantic analysis (optional, behind a flag).
"""

from __future__ import annotations

import re
import enum
import logging
from dataclasses import dataclass, field
from typing import List, Optional, Dict

from autoheal.core.tail_watcher import LogLine

logger = logging.getLogger(__name__)


class Severity(enum.IntEnum):
    DEBUG = 0
    INFO = 1
    WARNING = 2
    ERROR = 3
    CRITICAL = 4


@dataclass
class Diagnosis:
    """Structured diagnosis of a problematic log line."""
    severity: Severity
    category: str                       # e.g. "SyntaxError", "ImportError"
    message: str                        # human-readable summary
    source_file: Optional[str] = None   # file that caused the error
    source_line: Optional[int] = None   # line number in that file
    raw_log: str = ""                   # original log text
    traceback_lines: List[str] = field(default_factory=list)
    suggested_fix: Optional[str] = None


# ──────────────────────────────────────────────────────────────────────
# Built-in regex rules
# ──────────────────────────────────────────────────────────────────────

_PATTERNS: List[Dict] = [
    {
        "name": "python_exception",
        "pattern": re.compile(
            r"^(?P<exc_type>\w+Error|\w+Exception|\w+Warning):\s*(?P<msg>.+)$"
        ),
        "severity": Severity.ERROR,
    },
    {
        "name": "traceback_file",
        "pattern": re.compile(
            r'^\s*File "(?P<file>.+?)", line (?P<lineno>\d+)'
        ),
        "severity": Severity.ERROR,
    },
    {
        "name": "generic_error",
        "pattern": re.compile(r"\b(ERROR|FATAL|CRITICAL)\b", re.IGNORECASE),
        "severity": Severity.ERROR,
    },
    {
        "name": "generic_warning",
        "pattern": re.compile(r"\bWARN(?:ING)?\b", re.IGNORECASE),
        "severity": Severity.WARNING,
    },
    {
        "name": "segfault",
        "pattern": re.compile(r"Segmentation fault|SIGSEGV|core dumped", re.IGNORECASE),
        "severity": Severity.CRITICAL,
    },
    {
        "name": "oom",
        "pattern": re.compile(r"Out[Oo]f[Mm]emory|MemoryError|Cannot allocate", re.IGNORECASE),
        "severity": Severity.CRITICAL,
    },
]

_SEVERITY_KEYWORDS = {
    Severity.CRITICAL: ["fatal", "panic", "abort", "segfault", "core dump"],
    Severity.ERROR: ["error", "exception", "failed", "traceback", "raise"],
    Severity.WARNING: ["warning", "warn", "deprecated", "caution"],
}


class Diagnostician:
    """
    Classify log lines and produce structured Diagnosis objects.

    Parameters
    ----------
    use_oracle : bool
        If True, ambiguous lines are forwarded to the Oracle for deeper
        analysis (requires an Oracle instance to be attached later).
    traceback_window : int
        Number of preceding lines to retain for traceback context.
    """

    def __init__(
        self,
        use_oracle: bool = False,
        traceback_window: int = 20,
    ) -> None:
        self.use_oracle = use_oracle
        self.traceback_window = traceback_window
        self._recent_lines: List[LogLine] = []
        self._oracle = None  # set via attach_oracle()
        self.history: List[Diagnosis] = []

    def attach_oracle(self, oracle) -> None:
        """Attach an Oracle instance for deep classification."""
        self._oracle = oracle

    def classify(self, log_line: LogLine) -> Optional[Diagnosis]:
        """
        Classify a single log line.

        Returns a Diagnosis if the line is WARNING or above, else None.
        """
        self._recent_lines.append(log_line)
        if len(self._recent_lines) > self.traceback_window:
            self._recent_lines.pop(0)

        text = log_line.text

        # ── Phase 1: Regex rules ──────────────────────────────────────
        for rule in _PATTERNS:
            m = rule["pattern"].search(text)
            if m:
                diag = self._build_diagnosis(rule, m, log_line)
                if diag.severity >= Severity.WARNING:
                    self.history.append(diag)
                    return diag

        # ── Phase 2: Keyword heuristic ────────────────────────────────
        lower = text.lower()
        for sev in (Severity.CRITICAL, Severity.ERROR, Severity.WARNING):
            if any(kw in lower for kw in _SEVERITY_KEYWORDS[sev]):
                diag = Diagnosis(
                    severity=sev,
                    category="heuristic",
                    message=text.strip(),
                    raw_log=text,
                )
                self.history.append(diag)
                return diag

        return None

    def get_recent_errors(self, n: int = 10) -> List[Diagnosis]:
        """Return the last *n* diagnoses at ERROR level or above."""
        return [d for d in self.history if d.severity >= Severity.ERROR][-n:]

    # ──────────────────────────────────────────────────────────────────
    # Internals
    # ──────────────────────────────────────────────────────────────────

    def _build_diagnosis(self, rule: Dict, match: re.Match, log_line: LogLine) -> Diagnosis:
        groups = match.groupdict()
        category = groups.get("exc_type", rule["name"])
        message = groups.get("msg", log_line.text.strip())
        src_file = groups.get("file")
        src_line = int(groups["lineno"]) if "lineno" in groups else None

        traceback_ctx = [
            ll.text for ll in self._recent_lines[-self.traceback_window:]
        ]

        return Diagnosis(
            severity=rule["severity"],
            category=category,
            message=message,
            source_file=src_file,
            source_line=src_line,
            raw_log=log_line.text,
            traceback_lines=traceback_ctx,
        )

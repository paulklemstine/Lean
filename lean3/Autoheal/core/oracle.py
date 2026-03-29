"""
Oracle & OracleTeam — Pluggable AI reasoning backends
=======================================================

The **Oracle** is a single AI reasoning unit that can:

- Classify ambiguous log lines (used by Diagnostician).
- Propose source-code fixes given a repair context (used by CodeSurgeon).
- Evaluate whether a proposed patch is safe (guard-rail check).

The **OracleTeam** implements a *council of oracles* pattern: multiple
Oracle instances with different roles collaborate through structured
rounds to research, hypothesize, experiment, validate, update, and
iterate on a diagnosis and fix.

Oracle Roles
------------
- **Researcher**   — gathers context, reads code, understands the domain
- **Hypothesizer** — proposes candidate root causes
- **Experimenter** — designs & runs minimal experiments / test patches
- **Validator**    — checks proposed fixes for correctness & safety
- **Updater**      — merges validated fixes and updates project state
- **Iterator**     — decides if another round is needed or we converge

Each role can be backed by a different model, temperature, or prompt
strategy. The default implementation uses a single callable backend
for all roles (suitable for a single LLM endpoint).
"""

from __future__ import annotations

import logging
import textwrap
from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Optional, Protocol
from enum import Enum

logger = logging.getLogger(__name__)


# ──────────────────────────────────────────────────────────────────────
# Backend protocol
# ──────────────────────────────────────────────────────────────────────

class AIBackend(Protocol):
    """
    Minimal protocol for an AI completion backend.

    Any callable ``(prompt: str) -> str`` satisfies this protocol.
    """
    def __call__(self, prompt: str) -> str: ...


# ──────────────────────────────────────────────────────────────────────
# Oracle
# ──────────────────────────────────────────────────────────────────────

class Oracle:
    """
    A single AI reasoning unit.

    Parameters
    ----------
    backend : callable
        ``(prompt: str) -> str`` that returns the AI's response.
    name : str
        Human-readable name (for logging).
    system_prompt : str
        Persistent system-level instruction prepended to every query.
    """

    def __init__(
        self,
        backend: Callable[[str], str],
        name: str = "oracle",
        system_prompt: str = "",
    ) -> None:
        self.backend = backend
        self.name = name
        self.system_prompt = system_prompt
        self.conversation_log: List[Dict[str, str]] = []

    def query(self, prompt: str) -> str:
        full_prompt = f"{self.system_prompt}\n\n{prompt}" if self.system_prompt else prompt
        self.conversation_log.append({"role": "user", "content": prompt})
        try:
            response = self.backend(full_prompt)
        except Exception as exc:
            logger.exception("Oracle '%s' backend error", self.name)
            response = f"[Oracle error: {exc}]"
        self.conversation_log.append({"role": "assistant", "content": response})
        return response

    def suggest_fix(self, repair_prompt: str, original_source: str) -> Optional[str]:
        """
        Ask the oracle for a corrected version of the source code.

        Returns the full patched source, or None if the oracle declines.
        """
        combined = textwrap.dedent(f"""\
        You are a code-repair AI. Given the error diagnosis and source code
        below, return ONLY the complete corrected Python source file.

        {repair_prompt}

        === ORIGINAL SOURCE (for reference) ===
        {original_source}
        """)
        result = self.query(combined)

        # Try to extract a code block if the oracle wraps it
        if "```python" in result:
            start = result.index("```python") + len("```python")
            end = result.index("```", start)
            return result[start:end].strip() + "\n"
        if "```" in result:
            start = result.index("```") + 3
            end = result.index("```", start)
            return result[start:end].strip() + "\n"

        return result.strip() + "\n" if result.strip() else None

    def classify_line(self, line: str) -> Dict[str, Any]:
        """Ask the oracle to classify a single log line."""
        prompt = (
            "Classify this log line. Return JSON with keys: "
            "severity (DEBUG/INFO/WARNING/ERROR/CRITICAL), "
            "category (string), message (string).\n\n"
            f"Log line: {line}"
        )
        raw = self.query(prompt)
        # Naive JSON extraction
        import json
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            return {"severity": "INFO", "category": "unknown", "message": line}


# ──────────────────────────────────────────────────────────────────────
# Oracle roles for the team
# ──────────────────────────────────────────────────────────────────────

class OracleRole(Enum):
    RESEARCHER = "researcher"
    HYPOTHESIZER = "hypothesizer"
    EXPERIMENTER = "experimenter"
    VALIDATOR = "validator"
    UPDATER = "updater"
    ITERATOR = "iterator"


_ROLE_PROMPTS = {
    OracleRole.RESEARCHER: (
        "You are the Researcher oracle. Your job is to gather context, "
        "read the relevant source code, understand the error domain, and "
        "produce a concise research brief for the team."
    ),
    OracleRole.HYPOTHESIZER: (
        "You are the Hypothesizer oracle. Given the Researcher's brief, "
        "propose 2-3 ranked hypotheses about the root cause of the error. "
        "For each hypothesis, state the expected evidence and a falsification test."
    ),
    OracleRole.EXPERIMENTER: (
        "You are the Experimenter oracle. For each hypothesis, design a "
        "minimal experiment (a small code change or test) that can confirm "
        "or refute it. Return concrete diffs."
    ),
    OracleRole.VALIDATOR: (
        "You are the Validator oracle. Evaluate the proposed fix for: "
        "(1) correctness — does it fix the root cause? "
        "(2) safety — can it introduce regressions? "
        "(3) minimality — is this the smallest effective change?"
    ),
    OracleRole.UPDATER: (
        "You are the Updater oracle. Merge the validated fix into the "
        "source code. Ensure consistent formatting and that all related "
        "call sites are updated."
    ),
    OracleRole.ITERATOR: (
        "You are the Iterator oracle. Review the full repair cycle. "
        "Decide: CONVERGED (fix is good), or RETRY (with specific guidance "
        "for what to change in the next round)."
    ),
}


@dataclass
class RoundNote:
    """Structured notes from one oracle-team round."""
    round_number: int
    researcher_brief: str = ""
    hypotheses: str = ""
    experiments: str = ""
    validation: str = ""
    merged_fix: str = ""
    iterator_verdict: str = ""


class OracleTeam:
    """
    Council-of-oracles pattern for collaborative diagnosis and repair.

    Parameters
    ----------
    backend : callable
        Shared AI backend for all oracles (or per-role dict).
    max_rounds : int
        Safety cap on iteration rounds.
    """

    def __init__(
        self,
        backend: Callable[[str], str],
        max_rounds: int = 5,
    ) -> None:
        self.max_rounds = max_rounds
        self.oracles: Dict[OracleRole, Oracle] = {}
        for role in OracleRole:
            self.oracles[role] = Oracle(
                backend=backend,
                name=role.value,
                system_prompt=_ROLE_PROMPTS[role],
            )
        self.notes: List[RoundNote] = []

    def run_repair_cycle(
        self, diagnosis_text: str, source_code: str
    ) -> Optional[str]:
        """
        Execute the full research → iterate cycle.

        Returns the final patched source code, or None if no convergence.
        """
        context = (
            f"## Error Diagnosis\n{diagnosis_text}\n\n"
            f"## Source Code\n```python\n{source_code}\n```"
        )

        for rnd in range(1, self.max_rounds + 1):
            note = RoundNote(round_number=rnd)
            logger.info("Oracle team — round %d/%d", rnd, self.max_rounds)

            # 1. Research
            note.researcher_brief = self.oracles[OracleRole.RESEARCHER].query(
                f"Round {rnd}. {context}"
            )

            # 2. Hypothesize
            note.hypotheses = self.oracles[OracleRole.HYPOTHESIZER].query(
                f"Research brief:\n{note.researcher_brief}"
            )

            # 3. Experiment
            note.experiments = self.oracles[OracleRole.EXPERIMENTER].query(
                f"Hypotheses:\n{note.hypotheses}\n\nSource:\n```python\n{source_code}\n```"
            )

            # 4. Validate
            note.validation = self.oracles[OracleRole.VALIDATOR].query(
                f"Proposed experiments:\n{note.experiments}"
            )

            # 5. Update
            note.merged_fix = self.oracles[OracleRole.UPDATER].query(
                f"Validated approach:\n{note.validation}\n\n"
                f"Original source:\n```python\n{source_code}\n```\n\n"
                "Return the complete corrected source file."
            )

            # 6. Iterate
            note.iterator_verdict = self.oracles[OracleRole.ITERATOR].query(
                f"Round {rnd} results:\n"
                f"Fix:\n{note.merged_fix[:500]}...\n"
                f"Validation:\n{note.validation}"
            )

            self.notes.append(note)

            if "CONVERGED" in note.iterator_verdict.upper():
                logger.info("Oracle team converged after %d rounds.", rnd)
                return self._extract_code(note.merged_fix) or source_code

            # Update context for next round
            context = (
                f"Previous round feedback:\n{note.iterator_verdict}\n\n"
                f"## Source Code\n```python\n{source_code}\n```"
            )

        logger.warning("Oracle team did not converge in %d rounds.", self.max_rounds)
        # Return last attempt anyway
        if self.notes:
            return self._extract_code(self.notes[-1].merged_fix)
        return None

    @staticmethod
    def _extract_code(text: str) -> Optional[str]:
        if "```python" in text:
            start = text.index("```python") + len("```python")
            end = text.index("```", start)
            return text[start:end].strip() + "\n"
        if "```" in text:
            start = text.index("```") + 3
            end = text.index("```", start)
            return text[start:end].strip() + "\n"
        return text.strip() + "\n" if text.strip() else None

    def get_notes_markdown(self) -> str:
        """Export all round notes as Markdown."""
        lines = ["# Oracle Team — Repair Notes\n"]
        for note in self.notes:
            lines.append(f"## Round {note.round_number}\n")
            lines.append(f"### Researcher Brief\n{note.researcher_brief}\n")
            lines.append(f"### Hypotheses\n{note.hypotheses}\n")
            lines.append(f"### Experiments\n{note.experiments}\n")
            lines.append(f"### Validation\n{note.validation}\n")
            lines.append(f"### Merged Fix\n```python\n{note.merged_fix}\n```\n")
            lines.append(f"### Iterator Verdict\n{note.iterator_verdict}\n")
            lines.append("---\n")
        return "\n".join(lines)

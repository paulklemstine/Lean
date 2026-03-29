"""
CodeSurgeon — AI-driven source-code patch generation
======================================================

Given a ``Diagnosis`` (structured error report), the CodeSurgeon:

1. Reads the offending source file.
2. Builds a *repair context* — the error message, surrounding code, and
   recent log history.
3. Asks the Oracle to propose a minimal diff.
4. Validates the diff syntactically (``ast.parse``) before returning it.
5. Writes the patched file to disk (or returns the patch for review).

Safety
------
- **Backup**: the original file is always copied to ``<file>.autoheal.bak``
  before any write.
- **AST gate**: patches that fail ``ast.parse()`` are rejected and logged.
- **Scope limit**: only files inside the configured ``watch_dir`` may be
  modified — no writes to stdlib, venv, or system paths.
"""

from __future__ import annotations

import ast
import difflib
import shutil
import logging
import textwrap
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, List

from autoheal.core.diagnostician import Diagnosis, Severity

logger = logging.getLogger(__name__)


@dataclass
class Patch:
    """A proposed source-code fix."""
    target_file: str
    original_source: str
    patched_source: str
    unified_diff: str
    diagnosis: Diagnosis
    is_valid: bool = False          # True once AST check passes
    applied: bool = False


class CodeSurgeon:
    """
    Generate and apply source-code patches.

    Parameters
    ----------
    watch_dir : str | Path
        Root directory of source files that may be modified.
    oracle : Oracle, optional
        The AI backend used for generating fix proposals.
    max_context_lines : int
        Lines of surrounding code sent to the Oracle for context.
    auto_apply : bool
        If True, valid patches are written to disk automatically.
    """

    def __init__(
        self,
        watch_dir: str | Path,
        oracle=None,
        max_context_lines: int = 40,
        auto_apply: bool = False,
    ) -> None:
        self.watch_dir = Path(watch_dir).resolve()
        self.oracle = oracle
        self.max_context_lines = max_context_lines
        self.auto_apply = auto_apply
        self.patch_history: List[Patch] = []

    def attach_oracle(self, oracle) -> None:
        self.oracle = oracle

    def propose_patch(self, diagnosis: Diagnosis) -> Optional[Patch]:
        """
        Generate a Patch for the given Diagnosis.

        Returns None if the source file cannot be read or is outside
        ``watch_dir``.
        """
        src_path = self._resolve_source(diagnosis)
        if src_path is None:
            logger.warning("Cannot resolve source file for diagnosis: %s", diagnosis.message)
            return None

        original = src_path.read_text(errors="replace")

        # Build repair context for the Oracle
        repair_prompt = self._build_repair_prompt(diagnosis, original)

        if self.oracle is None:
            # Fallback: attempt simple heuristic fixes
            patched = self._heuristic_fix(diagnosis, original)
        else:
            patched = self.oracle.suggest_fix(repair_prompt, original)

        if patched is None or patched == original:
            logger.info("No patch proposed for %s", diagnosis.category)
            return None

        # Compute unified diff
        diff = difflib.unified_diff(
            original.splitlines(keepends=True),
            patched.splitlines(keepends=True),
            fromfile=f"a/{src_path.name}",
            tofile=f"b/{src_path.name}",
        )
        unified = "".join(diff)

        patch = Patch(
            target_file=str(src_path),
            original_source=original,
            patched_source=patched,
            unified_diff=unified,
            diagnosis=diagnosis,
        )

        # AST validation gate
        patch.is_valid = self._validate_syntax(patched)
        if not patch.is_valid:
            logger.warning("Proposed patch fails AST validation — rejected.")

        self.patch_history.append(patch)

        if patch.is_valid and self.auto_apply:
            self.apply_patch(patch)

        return patch

    def apply_patch(self, patch: Patch) -> bool:
        """
        Write a validated patch to disk.

        Creates a ``.autoheal.bak`` backup of the original file first.
        """
        if not patch.is_valid:
            logger.error("Refusing to apply invalid patch.")
            return False

        target = Path(patch.target_file)

        # Safety: must be inside watch_dir
        try:
            target.resolve().relative_to(self.watch_dir)
        except ValueError:
            logger.error("Target %s is outside watch_dir — aborting.", target)
            return False

        # Backup
        backup = target.with_suffix(target.suffix + ".autoheal.bak")
        shutil.copy2(target, backup)
        logger.info("Backup saved to %s", backup)

        # Write patched source
        target.write_text(patch.patched_source)
        patch.applied = True
        logger.info("Patch applied to %s", target)
        return True

    # ──────────────────────────────────────────────────────────────────
    # Internals
    # ──────────────────────────────────────────────────────────────────

    def _resolve_source(self, diagnosis: Diagnosis) -> Optional[Path]:
        if diagnosis.source_file:
            p = Path(diagnosis.source_file)
            if p.exists():
                try:
                    p.resolve().relative_to(self.watch_dir)
                    return p
                except ValueError:
                    pass
        return None

    def _build_repair_prompt(self, diag: Diagnosis, source: str) -> str:
        lines = source.splitlines()
        if diag.source_line and 1 <= diag.source_line <= len(lines):
            lo = max(0, diag.source_line - self.max_context_lines // 2)
            hi = min(len(lines), diag.source_line + self.max_context_lines // 2)
            context = "\n".join(
                f"{i+1:>4} | {lines[i]}" for i in range(lo, hi)
            )
        else:
            context = "\n".join(f"{i+1:>4} | {l}" for i, l in enumerate(lines[:self.max_context_lines]))

        return textwrap.dedent(f"""\
        ## Error Diagnosis
        Category : {diag.category}
        Severity : {diag.severity.name}
        Message  : {diag.message}
        File     : {diag.source_file}
        Line     : {diag.source_line}

        ## Traceback Context
        {chr(10).join(diag.traceback_lines[-10:])}

        ## Source Code Context
        {context}

        ## Instructions
        Return the COMPLETE corrected source file.
        Make the MINIMAL change that fixes the error.
        Do NOT add comments explaining the fix.
        """)

    def _heuristic_fix(self, diag: Diagnosis, source: str) -> Optional[str]:
        """
        Rule-based quick fixes for trivially patchable errors.
        """
        if diag.category == "SyntaxError" and diag.source_line:
            lines = source.splitlines()
            idx = diag.source_line - 1
            if 0 <= idx < len(lines):
                line = lines[idx]
                # Missing colon at end of def/class/if/for/while
                stripped = line.rstrip()
                if re.match(r"^\s*(def |class |if |elif |else|for |while |try|except|finally)", stripped):
                    if not stripped.endswith(":"):
                        lines[idx] = stripped + ":"
                        return "\n".join(lines) + "\n"

        if diag.category == "IndentationError" and diag.source_line:
            lines = source.splitlines()
            idx = diag.source_line - 1
            if 0 <= idx < len(lines):
                # Simple: ensure at least 4-space indent if previous line ends with ':'
                if idx > 0 and lines[idx - 1].rstrip().endswith(":"):
                    prev_indent = len(lines[idx - 1]) - len(lines[idx - 1].lstrip())
                    curr_indent = len(lines[idx]) - len(lines[idx].lstrip())
                    if curr_indent <= prev_indent:
                        lines[idx] = " " * (prev_indent + 4) + lines[idx].lstrip()
                        return "\n".join(lines) + "\n"

        if diag.category == "ImportError":
            # If a module import fails, comment it out and add a stub
            if "No module named" in diag.message:
                mod_name = diag.message.split("'")[1] if "'" in diag.message else None
                if mod_name:
                    lines = source.splitlines()
                    for i, line in enumerate(lines):
                        if f"import {mod_name}" in line:
                            lines[i] = f"# AUTOHEAL: disabled failing import\n# {line}"
                            break
                    return "\n".join(lines) + "\n"

        return None

    @staticmethod
    def _validate_syntax(source: str) -> bool:
        try:
            ast.parse(source)
            return True
        except SyntaxError:
            return False


# Needed for heuristic_fix regex
import re

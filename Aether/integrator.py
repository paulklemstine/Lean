#!/usr/bin/env python3
"""IntegrationGate: Safely merge Aristotle's output into the Catalog.

Runs validation checks and applies patches atomically.
"""

import json
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Any


@dataclass
class ValidationReport:
    """Results of integration validation."""
    passed: bool = False
    checks: Dict[str, bool] = None
    error_message: Optional[str] = None
    suggestions: List[str] = None

    def __post_init__(self):
        if self.checks is None:
            self.checks = {}
        if self.suggestions is None:
            self.suggestions = []


class IntegrationGate:
    """Safely integrate verified proofs into the Catalog."""

    def __init__(self, config: Dict[str, Any], catalog_root: Path):
        self.config = config
        self.catalog_root = Path(catalog_root)
        self.build_dir = Path(config.get("build_dir", "../../CatalogBuild"))
        self.auto_merge = config.get("auto_merge", False)
        self.require_human_review = config.get("require_human_review", True)
        self.rollback_on_failure = config.get("rollback_on_failure", True)
        self.checks_enabled = config.get("validation_checks", ["syntax", "semantic"])

    def _run_lake_build(self, file_path: Optional[Path] = None) -> tuple[bool, str]:
        """Run lake build and return (success, output)."""
        cwd = self.catalog_root
        cmd = ["lake", "build"]
        if file_path:
            rel = str(file_path.relative_to(self.catalog_root))
            cmd = ["lake", "build", f"./{rel}"]

        try:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=300,
            )
            success = result.returncode == 0
            output = result.stdout + "\n" + result.stderr
            return success, output
        except subprocess.TimeoutExpired:
            return False, "lake build timed out after 300s"
        except FileNotFoundError:
            return False, "lake command not found"

    def _count_sorry(self, text: str) -> int:
        """Count sorry occurrences in Lean text."""
        return text.count("sorry")

    def _check_deduplication(self, lean_text: str) -> tuple[bool, str]:
        """Check if any declaration in lean_text already exists."""
        # Extract theorem/def names from new text
        import re
        new_names = set()
        for pattern in [
            r'^\s*theorem\s+(\S+)',
            r'^\s*lemma\s+(\S+)',
            r'^\s*def\s+(\S+)',
            r'^\s*structure\s+(\S+)',
            r'^\s*class\s+(\S+)',
        ]:
            for m in re.finditer(pattern, lean_text, re.MULTILINE):
                new_names.add(m.group(1))

        # Search existing files for duplicates
        for fp in self.catalog_root.rglob("*.lean"):
            existing = fp.read_text(encoding="utf-8")
            for name in new_names:
                if re.search(rf'\btheorem\s+{re.escape(name)}\b', existing):
                    return False, f"Duplicate declaration: {name} in {fp}"
                if re.search(rf'\bdef\s+{re.escape(name)}\b', existing):
                    return False, f"Duplicate definition: {name} in {fp}"

        return True, "No duplicates found"

    def validate_patch(self, target_file: Path, lean_source: str) -> ValidationReport:
        """Validate a patch before applying."""
        report = ValidationReport()
        report.checks = {}

        # Syntax check: can lake build parse it?
        report.checks["syntax"] = False
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".lean", delete=False, dir=self.catalog_root
        ) as tmp:
            tmp.write(lean_source)
            tmp_path = Path(tmp.name)

        try:
            # Create a minimal test by writing to a temp file and building
            success, output = self._run_lake_build(tmp_path)
            if success:
                report.checks["syntax"] = True
            else:
                report.error_message = f"Syntax/build failure: {output[:500]}"
        finally:
            tmp_path.unlink(missing_ok=True)

        # Semantic check: no new sorries (unless expected)
        report.checks["semantic"] = True
        sorry_count = self._count_sorry(lean_source)
        if sorry_count > 0:
            report.checks["semantic"] = False
            report.suggestions.append(f"Contains {sorry_count} sorry(ies)")

        # Deduplication check
        report.checks["deduplication"] = False
        dup_ok, dup_msg = self._check_deduplication(lean_source)
        if dup_ok:
            report.checks["deduplication"] = True
        else:
            report.error_message = dup_msg

        # Overall pass
        report.passed = all(report.checks.get(c, False) for c in self.checks_enabled)
        return report

    def apply_patch(
        self,
        target_file: Path,
        lean_source: str,
        backup: bool = True,
    ) -> ValidationReport:
        """Apply a patch to the catalog."""
        report = self.validate_patch(target_file, lean_source)
        if not report.passed:
            return report

        # Require human review unless auto-merge is enabled
        if self.require_human_review and not self.auto_merge:
            report.suggestions.append("Patch validated but requires human review before merge.")
            return report

        # Backup existing file
        if target_file.exists() and backup:
            backup_path = target_file.with_suffix(".lean.bak")
            shutil.copy2(target_file, backup_path)

        # Ensure parent directory exists
        target_file.parent.mkdir(parents=True, exist_ok=True)

        # Write the file
        target_file.write_text(lean_source, encoding="utf-8")

        # Run rescan to update catalog database
        try:
            tools_dir = self.catalog_root / "Tools"
            rescan_script = tools_dir / "rescan"
            if rescan_script.exists():
                result = subprocess.run(
                    ["bash", str(rescan_script)],
                    cwd=self.catalog_root,
                    capture_output=True,
                    text=True,
                    timeout=120,
                )
                if result.returncode != 0:
                    report.suggestions.append(f"Rescan warning: {result.stderr[:200]}")
        except Exception as e:
            report.suggestions.append(f"Rescan skipped: {e}")

        return report

    def rollback(self, target_file: Path) -> bool:
        """Rollback a file from backup."""
        backup_path = target_file.with_suffix(".lean.bak")
        if backup_path.exists():
            shutil.copy2(backup_path, target_file)
            return True
        return False

#!/usr/bin/env python3
"""LeanCatalogBuilder: Build a lean-only copy of the catalog for Aristotle.

The catalog is ~172MB with demos, visuals, python files, markdown, etc.
Aristotle only needs .lean files + lake config. This reduces upload size
to ~12MB and focuses Aristotle on the math.
"""

import shutil
from pathlib import Path
from typing import Set


class LeanCatalogBuilder:
    """Build a lean-only project directory from the catalog."""

    def __init__(self, catalog_root: Path):
        self.catalog_root = Path(catalog_root)

    def build_lean_project(
        self,
        project_dir: Path,
        domain: str = "",
        lean_source: str = "",
    ) -> Path:
        """Build a lean-only project directory.

        Copies:
        - All .lean files (or domain-filtered subset)
        - lakefile.toml, lean-toolchain, lake-manifest.json
        - README.md (optional)

        Ignores:
        - Python demos, SVGs, markdown docs
        - .lake, build artifacts, __pycache__
        - Aether tools, logs, output
        """
        project_dir.mkdir(parents=True, exist_ok=True)

        # Clear existing contents
        for item in project_dir.iterdir():
            if item.is_dir():
                shutil.rmtree(item)
            else:
                item.unlink()

        # Domain filter
        domain_dirs = self._domain_dirs(domain)

        # Copy .lean files
        lean_files_copied = 0
        for src in self.catalog_root.rglob("*.lean"):
            rel = src.relative_to(self.catalog_root)

            # Skip if in ignored paths
            if self._should_ignore(rel):
                continue

            # Domain filter
            if domain_dirs and not any(
                str(rel).startswith(d) for d in domain_dirs
            ):
                continue

            dest = project_dir / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            lean_files_copied += 1

        print(f"[LeanCatalog] Copied {lean_files_copied} .lean files")

        # Copy lake config
        for fname in ["lakefile.toml", "lean-toolchain", "lake-manifest.json"]:
            src = self.catalog_root / fname
            if src.exists():
                shutil.copy2(src, project_dir / fname)

        # Write the target theorem as Main.lean
        if lean_source:
            main_file = project_dir / "Main.lean"
            main_file.write_text(lean_source, encoding="utf-8")

        return project_dir

    def _domain_dirs(self, domain: str) -> list:
        """Return top-level dirs for a domain."""
        mapping = {
            "factoring": ["Pythagorean", "Cryptography", "Computation", "Shared"],
            "compression": ["Tropical", "Computation", "Logic", "Shared"],
            "AI": ["MachineLearning", "Logic", "Computation", "Shared"],
            "neural nets": ["MachineLearning", "Logic", "Computation", "Shared"],
            "quantum mechanics": ["Physics", "Cryptography", "Algebra", "Shared"],
            "computation": ["Computation", "Logic", "Bridges", "Shared"],
            "physics": ["Physics", "EML", "Bridges", "Shared"],
        }
        return mapping.get(domain, [])

    def _should_ignore(self, rel_path: Path) -> bool:
        """Check if a relative path should be ignored."""
        parts = rel_path.parts
        ignored = {
            ".lake", "Aether", "Tools", "tools", "output", "logs",
            "aristotle_results", "test_job", "node_modules", "build",
            "lake-packages", "__pycache__", ".git",
        }
        return any(p in ignored for p in parts)

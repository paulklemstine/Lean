#!/usr/bin/env python3
"""LeanCatalogBuilder: Build a lean-only copy of the catalog for Aristotle.

The catalog is ~172MB with demos, visuals, python files, markdown, etc.
Aristotle only needs .lean files + lake config. This reduces upload size
to ~12MB and focuses Aristotle on the math.
"""

import re
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

        # Copy ONLY necessary .lean files based on transitive imports from lean_source
        lean_files_copied = 0
        
        needed_files = self._get_transitive_imports(lean_source)
        
        for src in needed_files:
            rel = src.relative_to(self.catalog_root)

            # Skip if in ignored paths
            if self._should_ignore(rel):
                continue

            dest = project_dir / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            lean_files_copied += 1

        print(f"[LeanCatalog] Copied {lean_files_copied} .lean files (import subset)")

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

    def _get_transitive_imports(self, lean_source: str) -> Set[Path]:
        """Recursively find all catalog files imported by lean_source."""
        if not lean_source:
            return set()
            
        visited_files = set()
        queue = [lean_source]
        import_regex = re.compile(r'^import\s+([A-Za-z0-9_.]+)', re.MULTILINE)
        
        while queue:
            content = queue.pop(0)
            imports = import_regex.findall(content)
            for imp in imports:
                # Skip standard dependencies
                if imp.startswith('Mathlib') or imp.startswith('Init') or imp.startswith('Lean'):
                    continue
                    
                # Convert Module.Path to Module/Path.lean
                rel_path = imp.replace('.', '/') + '.lean'
                file_path = self.catalog_root / rel_path
                
                if file_path.exists() and file_path not in visited_files:
                    visited_files.add(file_path)
                    queue.append(file_path.read_text(encoding='utf-8', errors='ignore'))
                    
        return visited_files

    def _should_ignore(self, rel_path: Path) -> bool:
        """Check if a relative path should be ignored."""
        parts = rel_path.parts
        ignored = {
            ".lake", "Aether", "Tools", "tools", "output", "logs",
            "aristotle_results", "test_job", "node_modules", "build",
            "lake-packages", "__pycache__", ".git",
        }
        return any(p in ignored for p in parts)

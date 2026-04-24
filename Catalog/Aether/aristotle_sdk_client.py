#!/usr/bin/env python3
"""AristotleSDKClient: Native integration with Harmonic's aristotlelib SDK.

Uses the official Python SDK for directory-based project submission.
"""

import asyncio
import os
import shutil
import tarfile
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Dict, Any

import aristotlelib
from aristotlelib import Project, ProjectStatus


@dataclass
class AristotleResult:
    """Result from an Aristotle proof job."""
    project_id: str
    status: str
    lean_source: Optional[str] = None
    error_message: Optional[str] = None
    latency_seconds: float = 0.0
    result_path: Optional[Path] = None


class AristotleSDKClient:
    """Client using the official aristotlelib SDK."""

    def __init__(self, config: Dict[str, Any]):
        raw_key = config.get("api_key", "")
        # Handle ${VAR} placeholder by falling back to environment
        if raw_key and raw_key.startswith("${") and raw_key.endswith("}"):
            var_name = raw_key[2:-1]
            raw_key = os.environ.get(var_name, raw_key)
        self.api_key = raw_key or os.environ.get("ARISTOTLE_API_KEY", "")
        self.timeout = config.get("timeout_seconds", 300)
        self.polling_interval = config.get("polling_interval_seconds", 30)

        if self.api_key:
            aristotlelib.set_api_key(self.api_key)

    async def submit_lean_project(
        self,
        prompt: str,
        project_dir: Path,
    ) -> AristotleResult:
        """Submit a Lean project directory to Aristotle."""
        start = asyncio.get_event_loop().time()

        try:
            project = await Project.create_from_directory(
                prompt=prompt,
                project_dir=str(project_dir),
            )
            print(f"[Aristotle] Project created: {project.project_id} ({project.status})")

            # Wait for completion
            result_path = await project.wait_for_completion(
                destination=str(project_dir / "result.tar.gz"),
                polling_interval_seconds=self.polling_interval,
            )

            elapsed = asyncio.get_event_loop().time() - start

            # Refresh to get final status
            await project.refresh()
            print(f"[Aristotle] Project complete: {project.project_id} ({project.status})")

            if project.status in (ProjectStatus.COMPLETE, ProjectStatus.COMPLETE_WITH_ERRORS):
                lean_source = None
                if result_path:
                    lean_source = self._extract_lean_from_result(Path(result_path), project_dir)
                return AristotleResult(
                    project_id=project.project_id,
                    status=project.status.value,
                    lean_source=lean_source,
                    latency_seconds=elapsed,
                    result_path=Path(result_path) if result_path else None,
                )
            else:
                return AristotleResult(
                    project_id=project.project_id,
                    status=project.status.value,
                    error_message=f"Project ended with status: {project.status.value}",
                    latency_seconds=elapsed,
                )

        except Exception as e:
            elapsed = asyncio.get_event_loop().time() - start
            return AristotleResult(
                project_id="",
                status="failed",
                error_message=str(e),
                latency_seconds=elapsed,
            )

    def _extract_lean_from_result(self, tar_path: Path, project_dir: Path) -> Optional[str]:
        """Extract the proven Lean file from the result tarball."""
        extract_dir = project_dir / "result_extracted"
        extract_dir.mkdir(exist_ok=True)

        with tarfile.open(tar_path, "r:gz") as tar:
            tar.extractall(path=extract_dir)

        # Find the main .lean file
        lean_files = list(extract_dir.rglob("*.lean"))
        if not lean_files:
            return None

        # Prefer Main.lean or the largest .lean file
        main_file = next((f for f in lean_files if f.name == "Main.lean"), None)
        if main_file is None:
            main_file = max(lean_files, key=lambda f: f.stat().st_size)

        return main_file.read_text(encoding="utf-8")

    def _copy_catalog_into_project(self, catalog_root: Path, project_dir: Path) -> None:
        """Copy the full Catalog source tree into the project directory."""
        TOP_LEVEL_IGNORE = {
            "aristotle_results", "__pycache__", "logs", "output",
            "jobs", "node_modules", "build", "lake-packages",
            ".lake", "lakefile.olean", "Manifesto",
            "CATALOG.md", "DECLARATION_INDEX.md", "ARISTOTLE_SUMMARY.md",
        }

        def ignore_patterns(src: str, names: list) -> set:
            return {
                n for n in names
                if n.startswith(".") or n in {
                    "aristotle_results", "__pycache__", "*.pyc", "*.tar.gz",
                    "result.tar.gz", "result_extracted", "logs", "output",
                    "jobs", "*.output", "node_modules", "build", "lake-packages",
                    ".lake", "lakefile.olean", "Manifesto",
                } or n.endswith(".output")
            }

        for item in catalog_root.iterdir():
            if item.name in TOP_LEVEL_IGNORE:
                continue
            dest = project_dir / item.name
            if item.is_dir():
                if dest.exists():
                    shutil.rmtree(dest)
                shutil.copytree(item, dest, ignore=ignore_patterns)
            else:
                shutil.copy2(item, dest)

    async def submit_with_catalog_context(
        self,
        lean_source: str,
        catalog_root: Path,
        project_dir: Path,
        prompt: str = "Fill in all the sorries",
    ) -> AristotleResult:
        """Submit a Lean project with the full Catalog as context."""
        project_dir.mkdir(parents=True, exist_ok=True)

        # Copy full catalog into project
        print(f"[Aristotle] Copying catalog from {catalog_root} into {project_dir}...")
        self._copy_catalog_into_project(catalog_root, project_dir)
        print(f"[Aristotle] Catalog copied.")

        # Write the target Lean source as Main.lean at project root
        main_file = project_dir / "Main.lean"
        main_file.write_text(lean_source, encoding="utf-8")

        # Use the Catalog's lakefile if available, else minimal
        catalog_lakefile = catalog_root / "lakefile.toml"
        project_lakefile = project_dir / "lakefile.toml"
        if catalog_lakefile.exists():
            shutil.copy2(catalog_lakefile, project_lakefile)

        # Use the Catalog's lean-toolchain if available
        catalog_toolchain = catalog_root / "lean-toolchain"
        project_toolchain = project_dir / "lean-toolchain"
        if catalog_toolchain.exists():
            shutil.copy2(catalog_toolchain, project_toolchain)

        return await self.submit_lean_project(prompt, project_dir)

    async def submit_sorry_filling(
        self,
        lean_source: str,
        project_dir: Path,
        prompt: str = "Fill in all the sorries",
    ) -> AristotleResult:
        """Submit a single Lean file for sorry filling."""
        # Write the Lean source to project_dir/Main.lean
        main_file = project_dir / "Main.lean"
        main_file.write_text(lean_source, encoding="utf-8")

        # Ensure lakefile.toml exists
        lakefile = project_dir / "lakefile.toml"
        if not lakefile.exists():
            lakefile.write_text("""name = \"aether-job\"
version = \"0.1\"
defaultTargets = [\"Main\"]

[[lean_lib]]
name = \"Main\"

[[require]]
name = \"mathlib\"
scope = \"leanprover-community\"
version = \"v4.28.0\"
""", encoding="utf-8")

        # Ensure lean-toolchain exists
        toolchain = project_dir / "lean-toolchain"
        if not toolchain.exists():
            toolchain.write_text("leanprover/lean4:v4.28.0\n", encoding="utf-8")

        return await self.submit_lean_project(prompt, project_dir)

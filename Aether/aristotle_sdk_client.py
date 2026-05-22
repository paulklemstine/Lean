#!/usr/bin/env python3
"""AristotleSDKClient: Native integration with Harmonic's aristotlelib SDK.

Uses the official Python SDK for directory-based project submission.
"""

import asyncio
import os
import shutil
import ssl
import tarfile
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Dict, Any

import aristotlelib
from aristotlelib import Project, ProjectStatus

# Maximum retries for transient SSL/network errors
MAX_SSL_RETRIES = 3
SSL_RETRY_DELAY = 5  # seconds between retries


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

    async def submit_lean_project_only(
        self,
        prompt: str,
        project_dir: Path,
    ) -> str:
        """Submit a Lean project and return immediately with project_id."""
        project = await Project.create_from_directory(
            prompt=prompt,
            project_dir=str(project_dir),
        )
        print(f"[Aristotle] Project queued: {project.project_id} ({project.status})")
        return project.project_id

    async def poll_project(self, project_id: str) -> Dict[str, Any]:
        """Poll a project by ID. Returns dict with status, percent_complete.

        Retries on transient SSL errors before giving up.
        """
        for attempt in range(MAX_SSL_RETRIES):
            try:
                project = await Project.from_id(project_id)
                await project.refresh()
                return {
                    "project_id": project.project_id,
                    "status": project.status.value if hasattr(project.status, "value") else str(project.status),
                    "percent_complete": project.percent_complete or 0,
                    "complete": project.status in (ProjectStatus.COMPLETE, ProjectStatus.COMPLETE_WITH_ERRORS),
                    "error": None,
                }
            except ssl.SSLError as e:
                if attempt < MAX_SSL_RETRIES - 1:
                    print(f"[Aristotle] SSL error polling {project_id} (attempt {attempt+1}/{MAX_SSL_RETRIES}): {e}")
                    await asyncio.sleep(SSL_RETRY_DELAY)
                    continue
                # Final attempt failed
                print(f"[Aristotle] SSL error exhausted retries for {project_id}: {e}")
                return {
                    "project_id": project_id,
                    "status": "error",
                    "percent_complete": 0,
                    "complete": False,
                    "error": f"SSL error after {MAX_SSL_RETRIES} retries: {e}",
                }
            except Exception as e:
                error_str = str(e)
                # Don't treat transient network/SSL errors as terminal
                if "SSL" in error_str or "CERTIFICATE" in error_str or "ConnectionReset" in error_str:
                    if attempt < MAX_SSL_RETRIES - 1:
                        print(f"[Aristotle] Transient error polling {project_id} (attempt {attempt+1}/{MAX_SSL_RETRIES}): {e}")
                        await asyncio.sleep(SSL_RETRY_DELAY)
                        continue
                return {
                    "project_id": project_id,
                    "status": "error",
                    "percent_complete": 0,
                    "complete": False,
                    "error": error_str,
                }

    async def download_result(
        self,
        project_id: str,
        project_dir: Path,
    ) -> Optional[Path]:
        """Download result tarball for a completed project.

        Retries on transient SSL errors before giving up.
        """
        for attempt in range(MAX_SSL_RETRIES):
            try:
                project = await Project.from_id(project_id)
                await project.refresh()
                if project.status not in (ProjectStatus.COMPLETE, ProjectStatus.COMPLETE_WITH_ERRORS):
                    return None
                dest = project_dir / "result.tar.gz"
                await project.get_solution(destination=str(dest))
                return dest if dest.exists() else None
            except (ssl.SSLError, Exception) as e:
                error_str = str(e)
                is_ssl = isinstance(e, ssl.SSLError) or "SSL" in error_str or "CERTIFICATE" in error_str
                if is_ssl and attempt < MAX_SSL_RETRIES - 1:
                    print(f"[Aristotle] SSL error downloading {project_id} (attempt {attempt+1}/{MAX_SSL_RETRIES}): {e}")
                    await asyncio.sleep(SSL_RETRY_DELAY)
                    continue
                print(f"[Aristotle] Download error for {project_id}: {e}")
                # Return a special marker for auth errors so callers can distinguish
                if "403" in error_str or "Forbidden" in error_str or "401" in error_str or "Unauthorized" in error_str:
                    return Path("__AUTH_ERROR__")
                return None

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

            # Wait for completion with timeout
            try:
                result_path = await asyncio.wait_for(
                    project.wait_for_completion(
                        destination=str(project_dir / "result.tar.gz"),
                        polling_interval_seconds=self.polling_interval,
                    ),
                    timeout=self.timeout,
                )
            except asyncio.TimeoutError:
                elapsed = asyncio.get_event_loop().time() - start
                print(f"[Aristotle] Timeout after {elapsed:.1f}s — project still {project.status}")
                try:
                    await project.cancel()
                    print(f"[Aristotle] Cancelled project {project.project_id}")
                except Exception:
                    pass
                return AristotleResult(
                    project_id=project.project_id,
                    status="timeout",
                    error_message=f"Timed out after {self.timeout}s",
                    latency_seconds=elapsed,
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
            "Aether", "Tools", "test_job",
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

    def _copy_domain_context(self, catalog_root: Path, project_dir: Path, domain: str) -> None:
        """Copy only relevant domain + Shared into project."""
        TOP_LEVEL_IGNORE = {
            "aristotle_results", "__pycache__", "logs", "output",
            "jobs", "node_modules", "build", "lake-packages",
            ".lake", "lakefile.olean", "Manifesto",
            "CATALOG.md", "DECLARATION_INDEX.md", "ARISTOTLE_SUMMARY.md",
            "Aether", "Tools", "test_job",
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

        # Map domain IDs to directory names
        domain_dirs = {
            "factoring": ["Pythagorean", "Cryptography", "Computation"],
            "compression": ["Tropical", "Computation", "Logic"],
            "AI": ["MachineLearning", "Logic", "Computation"],
            "neural nets": ["MachineLearning", "Logic", "Computation"],
            "quantum mechanics": ["Physics", "Cryptography", "Algebra"],
            "computation": ["Computation", "Logic", "Bridges"],
            "physics": ["Physics", "EML", "Bridges"],
        }

        dirs_to_copy = domain_dirs.get(domain, [])
        if not dirs_to_copy:
            # Fallback: copy all Lean source dirs
            dirs_to_copy = [
                "Algebra", "Applications", "Bridges", "Computation",
                "Cryptography", "EML", "Geometry", "Logic",
                "MachineLearning", "Physics", "Pythagorean",
                "Shared", "Speculative", "Tropical",
            ]

        # Always include Shared/
        if "Shared" not in dirs_to_copy:
            dirs_to_copy.insert(0, "Shared")

        for dir_name in dirs_to_copy:
            src = catalog_root / dir_name
            if not src.exists():
                continue
            dest = project_dir / dir_name
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(src, dest, ignore=ignore_patterns)

        # Copy top-level files
        for file_name in ["lakefile.toml", "lean-toolchain", "README.md", "lake-manifest.json"]:
            src = catalog_root / file_name
            if src.exists():
                shutil.copy2(src, project_dir / file_name)

    async def submit_with_catalog_context(
        self,
        lean_source: str,
        catalog_root: Path,
        project_dir: Path,
        prompt: str = "Fill in all the sorries",
        domain: str = "",
    ) -> AristotleResult:
        """Submit a Lean project with full Catalog context (v2: always full catalog)."""
        project_dir.mkdir(parents=True, exist_ok=True)

        # v2: Always pass the entire catalog for maximum context
        print(f"[Aristotle] Copying full catalog from {catalog_root} into {project_dir}...")
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

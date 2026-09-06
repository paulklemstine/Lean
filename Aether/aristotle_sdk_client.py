#!/usr/bin/env python3
"""AristotleSDKClient: Native integration with Harmonic's aristotlelib SDK.

Uses the official Python SDK (v2+) for directory-based project submission.
Handles v2 API where ProjectStatus has IDLE/RUNNING/UNKNOWN and completion
is indicated by has_files=True.
"""

import asyncio
import os
import shutil
import ssl
import tarfile
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
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
        print(f"[Aristotle] Loaded API key: {self.api_key[:10]}... (len={len(self.api_key)})")
        self.timeout = config.get("timeout_seconds", 300)
        self.polling_interval = config.get("polling_interval_seconds", 30)

        if self.api_key:
            aristotlelib.set_api_key(self.api_key)

    async def get_active_jobs_count(self) -> int:
        """Get the number of currently running jobs on the Aristotle server."""
        try:
            res = await aristotlelib.Project.list_projects()
            projs = res[0] if isinstance(res, tuple) else res
            running = [p for p in projs if getattr(p, "status", None) == aristotlelib.ProjectStatus.RUNNING]
            return len(running)
        except Exception as e:
            print(f"[Aristotle] Failed to list projects: {e}")
            return -1

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
        In v2: IDLE means not running. has_files=True means results available.
        Estimates percent_complete by looking at task events.
        """
        for attempt in range(MAX_SSL_RETRIES):
            try:
                project = await Project.from_id(project_id)
                status_str = project.status.name if hasattr(project.status, 'name') else str(project.status)
                pct = getattr(project, 'percent_complete', 0) or 0
                
                # In v2, IDLE + has_files = complete; IDLE + no files = failed/not started
                is_complete = (
                    project.status == ProjectStatus.IDLE and project.has_files
                )

                # On completion, check whether any task ended incomplete
                # (OUT_OF_BUDGET = ran out of compute; COMPLETE_WITH_ERRORS =
                # finished but with errors, e.g. truncated/non-compiling Lean).
                # The caller can resume such a project via resume_project()
                # (project.ask — "Tell Aristotle what to do next" -> Instruct).
                needs_resume = False
                if is_complete:
                    pct = 100
                    try:
                        _tasks, _ = await project.get_tasks(limit=10)
                        _bad = any(
                            getattr(t, "status", None) is not None
                            and t.status.name in ("OUT_OF_BUDGET", "COMPLETE_WITH_ERRORS")
                            for t in _tasks
                        )
                        # A stale OUT_OF_BUDGET task from an earlier resume round
                        # must not force a fresh paid resume once ANY task has
                        # actually completed — that produced repeated paid
                        # resumes of already-finished projects (audit 2026-08-21).
                        _any_complete = any(
                            getattr(t, "status", None) is not None
                            and t.status.name == "COMPLETE"
                            for t in _tasks
                        )
                        needs_resume = _bad and not _any_complete
                    except Exception:
                        pass
                elif pct == 0 and project.status != ProjectStatus.IDLE:
                    # Try to estimate from sub-events if API returns 0%
                    try:
                        tasks, _ = await project.get_tasks(limit=10)
                        if tasks:
                            total_events_expected = 0
                            completed_events = 0
                            
                            for task in tasks:
                                if task.status.name in ("COMPLETE", "COMPLETE_WITH_ERRORS", "FAILED", "OUT_OF_BUDGET"):
                                    completed_events += 15
                                    total_events_expected += 15
                                else:
                                    events, _ = await task.get_events(limit=50)
                                    total_events_expected += 15  # Assume ~15 events per task
                                    completed_events += min(len(events), 14) # Cap at 14 until complete
                            
                            if total_events_expected > 0:
                                pct = int((completed_events / total_events_expected) * 100)
                                pct = min(99, pct) # Cap at 99% until project is actually IDLE
                        elif status_str == "RUNNING":
                            pct = 5 # Just started
                    except Exception as e:
                        print(f"[Aristotle] Failed to estimate progress from events for {project_id}: {e}")

                latest_task_status = "UNKNOWN"
                is_queued = False
                try:
                    _tasks_check, _ = await project.get_tasks(limit=10)
                    if _tasks_check:
                        latest_t = _tasks_check[0]
                        latest_task_status = getattr(latest_t.status, "name", str(getattr(latest_t, "status", "UNKNOWN")))
                        if latest_task_status == "QUEUED":
                            is_queued = True
                except Exception:
                    pass

                return {
                    "project_id": project.project_id,
                    "status": status_str,
                    "percent_complete": pct,
                    "complete": is_complete,
                    "has_files": project.has_files,
                    "has_input": project.has_input,
                    "needs_resume": needs_resume,
                    "latest_task_status": latest_task_status,
                    "is_queued": is_queued,
                    "error": None,
                }
            except ssl.SSLError as e:
                if attempt < MAX_SSL_RETRIES - 1:
                    print(f"[Aristotle] SSL error polling {project_id} (attempt {attempt+1}/{MAX_SSL_RETRIES}): {e}")
                    await asyncio.sleep(SSL_RETRY_DELAY)
                    continue
                # Final attempt failed — report NON-terminal unreachability so
                # poll_all keeps the job dispatched instead of failing it.
                print(f"[Aristotle] SSL error exhausted retries for {project_id}: {e}")
                return {
                    "project_id": project_id,
                    "status": "unreachable",
                    "percent_complete": 0,
                    "complete": False,
                    "has_files": False,
                    "has_input": False,
                    "error": f"SSL error after {MAX_SSL_RETRIES} retries: {e}",
                }
            except Exception as e:
                error_str = str(e)
                _lower = error_str.lower()
                # Auth failures are NEVER the job's fault: a 401 storm (expired/
                # revoked key) must not fail in-flight research — report
                # non-terminal unreachability so jobs survive until the key is
                # fixed (audit 2026-08-21: one 401 window dropped a live
                # Phase A + Phase B pair and burned every queued direction).
                if "401" in error_str or "invalid api key" in _lower or "unauthorized" in _lower:
                    return {
                        "project_id": project_id,
                        "status": "unreachable",
                        "percent_complete": 0,
                        "complete": False,
                        "has_files": False,
                        "has_input": False,
                        "error": f"auth error (non-terminal): {error_str}",
                    }
                # Don't treat transient network/API errors as terminal: SSL
                # failures, timeouts, DNS hiccups, and 429/5xx responses all
                # recover. Failing a job on one blip abandoned every in-flight
                # project in a single tick while the remote research kept
                # running (audit 2026-08-21).
                _transient = (
                    "ssl" in _lower
                    or "certificate" in _lower
                    or "connectionreset" in _lower
                    or "timeout" in _lower
                    or "timed out" in _lower
                    or "connect" in _lower
                    or "temporarily unavailable" in _lower
                    or "rate limit" in _lower
                    or " 429" in error_str or " 500" in error_str
                    or " 502" in error_str or " 503" in error_str or " 504" in error_str
                )
                if _transient and attempt < MAX_SSL_RETRIES - 1:
                    print(f"[Aristotle] Transient error polling {project_id} (attempt {attempt+1}/{MAX_SSL_RETRIES}): {e}")
                    await asyncio.sleep(SSL_RETRY_DELAY)
                    continue
                if _transient:
                    # Retries exhausted: non-terminal unreachability — the job
                    # stays dispatched and is retried on the next poll pass.
                    return {
                        "project_id": project_id,
                        "status": "unreachable",
                        "percent_complete": 0,
                        "complete": False,
                        "has_files": False,
                        "has_input": False,
                        "error": f"transient error after {MAX_SSL_RETRIES} retries: {error_str}",
                    }
                return {
                    "project_id": project_id,
                    "status": "error",
                    "percent_complete": 0,
                    "complete": False,
                    "has_files": False,
                    "has_input": False,
                    "error": error_str,
                }

    async def resume_project(self, project_id: str, prompt: str) -> str:
        """Resume a (typically OUT_OF_BUDGET / truncated) project by telling
        Aristotle what to do next — the same mechanism as the web UI's
        "Tell Aristotle what to do next" → Instruct button.

        POSTs /project/{id}/ask with the prompt and returns the new
        AgentTask's id. The project re-enters RUNNING; poll_project() will
        report completion when the new task finishes.
        """
        project = await Project.from_id(project_id)
        task = await project.ask(prompt)
        print(f"[Aristotle] Resumed project {project_id} via ask() -> task {task.agent_task_id}")
        return task.agent_task_id

    async def cancel_project(self, project_id: str) -> bool:
        """Cancel a running project on Aristotle server via the cancel API.

        Fetches the Project object by ID, cancels its running tasks,
        or calls project.cancel() if available.
        Returns True if successful, False otherwise.
        """
        try:
            project = await Project.from_id(project_id)
            canceled_any = False
            # Try canceling through project's active tasks
            try:
                tasks, _ = await project.get_tasks(limit=10)
                for task in tasks:
                    status_name = getattr(task.status, "name", str(getattr(task, "status", "")))
                    if status_name in ("QUEUED", "IN_PROGRESS"):
                        if hasattr(task, "cancel"):
                            cancel_res = task.cancel()
                            if asyncio.iscoroutine(cancel_res):
                                await cancel_res
                            print(f"[Aristotle] Canceled active task {task.agent_task_id} for project {project_id}")
                            canceled_any = True
            except Exception as task_err:
                print(f"[Aristotle] Task inspection failed during cancel for {project_id}: {task_err}")

            if canceled_any:
                print(f"[Aristotle] Successfully canceled running task(s) for project {project_id}")
                return True

            if callable(getattr(project, "cancel", None)):
                cancel_res = project.cancel()
                if asyncio.iscoroutine(cancel_res):
                    await cancel_res
                print(f"[Aristotle] Successfully canceled project {project_id}")
                return True
            elif callable(getattr(aristotlelib, "cancel", None)):
                cancel_res = aristotlelib.cancel(project_id=project_id)
                if asyncio.iscoroutine(cancel_res):
                    await cancel_res
                print(f"[Aristotle] Canceled project {project_id} via aristotlelib")
                return True
            print(f"[Aristotle] Cancel API not directly available on Project object for {project_id}")
            return False
        except Exception as e:
            print(f"[Aristotle] Error canceling project {project_id}: {e}")
            return False

    async def cleanup_stale_server_tasks(self, max_age_hours: float = 4.0) -> int:
        """Find and cancel orphaned/stuck running tasks on Aristotle server older than max_age_hours."""
        try:
            res = await Project.list_projects(limit=30)
            projs = res[0] if isinstance(res, tuple) else res
            canceled_count = 0
            now = datetime.now(timezone.utc)
            for p in projs:
                st = getattr(p, "status", None)
                if st == ProjectStatus.RUNNING:
                    # Check age
                    created_raw = getattr(p, "created_at", None)
                    is_stale = False
                    if created_raw:
                        try:
                            if isinstance(created_raw, str):
                                created_dt = datetime.fromisoformat(created_raw.replace("Z", "+00:00"))
                            elif isinstance(created_raw, (int, float)):
                                created_dt = datetime.fromtimestamp(created_raw, tz=timezone.utc)
                            else:
                                created_dt = created_raw
                            age_hours = (now - created_dt).total_seconds() / 3600.0
                            if age_hours >= max_age_hours:
                                is_stale = True
                                print(f"[Aristotle] Project {p.project_id} running for {age_hours:.1f}h (>= {max_age_hours}h cap)")
                        except Exception:
                            pass
                    if is_stale:
                        print(f"[Aristotle] Cleaning up stale running server project {p.project_id}...")
                        success = await self.cancel_project(p.project_id)
                        if success:
                            canceled_count += 1
            return canceled_count
        except Exception as e:
            print(f"[Aristotle] Failed during cleanup_stale_server_tasks: {e}")
            return 0

    async def download_result(
        self,
        project_id: str,
        project_dir: Path,
    ) -> Optional[Path]:
        """Download result tarball for a completed project.

        Uses get_files() in v2 (replaces get_solution).
        Retries on transient SSL errors before giving up.
        """
        for attempt in range(MAX_SSL_RETRIES):
            try:
                project = await Project.from_id(project_id)
                if not project.has_files:
                    print(f"[Aristotle] download_result: project {project_id} has_files={project.has_files}, skipping")
                    return None
                dest = project_dir / "result.tar.gz"
                print(f"[Aristotle] download_result: fetching files for {project_id} -> {dest}")
                await project.get_files(destination=str(dest))
                if not dest.exists():
                    print(f"[Aristotle] Download succeeded but file missing: {dest}")
                    # Check if get_files wrote to a different location
                    import glob
                    candidates = list(Path(project_dir).glob("**/*.tar.gz")) + list(Path(project_dir).glob("**/*.zip"))
                    if candidates:
                        print(f"[Aristotle] Found alternative archive: {candidates}")
                        return candidates[0]
                if dest.exists():
                    size = dest.stat().st_size
                    if size < 100:
                        print(f"[Aristotle] Downloaded file suspiciously small: {size} bytes for {project_id}")
                        dest.unlink()
                        return None
                    print(f"[Aristotle] download_result: success, {size} bytes for {project_id}")
                return dest if dest.exists() else None
            except (ssl.SSLError, Exception) as e:
                error_str = str(e)
                is_ssl = isinstance(e, ssl.SSLError) or "SSL" in error_str or "CERTIFICATE" in error_str
                if is_ssl and attempt < MAX_SSL_RETRIES - 1:
                    print(f"[Aristotle] SSL error downloading {project_id} (attempt {attempt+1}/{MAX_SSL_RETRIES}): {e}")
                    await asyncio.sleep(SSL_RETRY_DELAY)
                    continue
                print(f"[Aristotle] Download error for {project_id}: {e}")
                # Return special markers so callers can handle different failure modes
                if "403" in error_str or "Forbidden" in error_str or "401" in error_str or "Unauthorized" in error_str:
                    return Path("__AUTH_ERROR__")
                if "500" in error_str or "Internal Server Error" in error_str:
                    return Path("__SERVER_ERROR__")
                if "404" in error_str or "Not Found" in error_str:
                    return Path("__NOT_FOUND__")
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

            # Poll for completion with timeout (v2 has no wait_for_completion)
            try:
                while True:
                    await asyncio.sleep(self.polling_interval)
                    project = await Project.from_id(project.project_id)
                    status_str = project.status.name if hasattr(project.status, 'name') else str(project.status)

                    if project.status == ProjectStatus.IDLE:
                        # Terminal state — check if we got results
                        break

                    elapsed = asyncio.get_event_loop().time() - start
                    if elapsed > self.timeout:
                        raise asyncio.TimeoutError()

            except asyncio.TimeoutError:
                elapsed = asyncio.get_event_loop().time() - start
                print(f"[Aristotle] Timeout after {elapsed:.1f}s — project still {project.status}")
                return AristotleResult(
                    project_id=project.project_id,
                    status="timeout",
                    error_message=f"Timed out after {self.timeout}s",
                    latency_seconds=elapsed,
                )

            elapsed = asyncio.get_event_loop().time() - start
            status_str = project.status.name if hasattr(project.status, 'name') else str(project.status)
            print(f"[Aristotle] Project done: {project.project_id} status={status_str} has_files={project.has_files}")

            if project.has_files:
                # Download result
                result_path = None
                try:
                    dest = project_dir / "result.tar.gz"
                    await project.get_files(destination=str(dest))
                    result_path = dest if dest.exists() else None
                except Exception as e:
                    print(f"[Aristotle] Download failed: {e}")

                lean_source = None
                if result_path:
                    lean_source = self._extract_lean_from_result(result_path, project_dir)

                return AristotleResult(
                    project_id=project.project_id,
                    status=status_str,
                    lean_source=lean_source,
                    latency_seconds=elapsed,
                    result_path=result_path,
                )
            else:
                return AristotleResult(
                    project_id=project.project_id,
                    status=status_str,
                    error_message="Project completed but has no result files",
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

        # Explicitly copy the .lake directory for phase A upload
        lake_src = catalog_root / ".lake"
        if lake_src.exists():
            lake_dest = project_dir / ".lake"
            if lake_dest.exists():
                shutil.rmtree(lake_dest)
            shutil.copytree(lake_src, lake_dest, ignore=ignore_patterns)

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
            lakefile.write_text("""name = "aether-job"
version = "0.1"
defaultTargets = ["Main"]

[[lean_lib]]
name = "Main"

[[require]]
name = "mathlib"
scope = "leanprover-community"
version = "v4.28.0"
""", encoding="utf-8")

        # Ensure lean-toolchain exists
        toolchain = project_dir / "lean-toolchain"
        if not toolchain.exists():
            toolchain.write_text("leanprover/lean4:v4.28.0\n", encoding="utf-8")

        return await self.submit_lean_project(prompt, project_dir)
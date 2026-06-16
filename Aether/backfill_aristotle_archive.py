#!/usr/bin/env python3
"""Backfill the Aristotle archive from the Harmonic API and local project dirs.

This script is idempotent: re-running it will only download/archive projects
that are not already in Archive/catalog.sqlite.

Usage:
    cd Aether && python3 backfill_aristotle_archive.py
    python3 backfill_aristotle_archive.py --archive-root ../Archive --max-pages 5
    python3 backfill_aristotle_archive.py --from-local-projects --no-api
    python3 backfill_aristotle_archive.py --log Aether/backfill_aristotle_archive.log
"""

import argparse
import asyncio
import datetime
import hashlib
import json
import logging
import os
import shutil
import sys
import tempfile
import time
import traceback
from pathlib import Path
from typing import Any, Dict, List, Optional

sys.path.insert(0, str(Path(__file__).parent))

from aristotlelib import Project, set_api_key
import aristotlelib.api_request as api_request
from archive_manager import ArchiveManager
from archive_utils import (
    get_api_key,
    get_api_base_url,
    stream_download,
    set_max_memory_mb,
    mem_mb as _mem_mb,
    log_extra_context as _log_extra_context,
)
from theorem_extractor import TheoremExtractor


def _now() -> str:
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def _fmt_duration(seconds: float) -> str:
    if seconds < 60:
        return f"{seconds:.2f}s"
    if seconds < 3600:
        return f"{seconds/60:.2f}m"
    return f"{seconds/3600:.2f}h"


def _setup_logging(log_path: Optional[Path]):
    # Some imported modules call logging.basicConfig before we do, which makes
    # basicConfig a no-op and drops our handlers. Work around this by clearing
    # the root logger handlers and installing ours explicitly.
    root = logging.getLogger()
    for h in list(root.handlers):
        try:
            h.flush()
            h.close()
        except Exception:
            pass
        root.removeHandler(h)

    formatter = logging.Formatter(
        "%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%SZ",
    )
    # Force UTC for %(asctime)s
    formatter.converter = time.gmtime

    handlers: List[logging.Handler] = [logging.StreamHandler(sys.stdout)]
    if log_path:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        handlers.append(logging.FileHandler(log_path, mode="a"))

    for h in handlers:
        h.setFormatter(formatter)
        h.setLevel(logging.INFO)
        root.addHandler(h)

    root.setLevel(logging.INFO)


class Telemetry:
    """Collect counters and timing for the backfill run."""

    def __init__(self):
        self.started_at = time.time()
        self.api_pages = 0
        self.projects_seen = 0
        self.projects_skipped = 0
        self.projects_archived = 0
        self.projects_failed = 0
        self.projects_input_only = 0  # existed with input but no output -> fetched output
        self.inputs_downloaded = 0
        self.outputs_downloaded = 0
        self.input_download_failed = 0
        self.output_download_failed = 0
        self.files_archived = 0
        self.theorems_extracted = 0
        self.theorem_metadata_extracted = 0
        self.packages_stored = 0
        self.summaries_printed = 0
        self.errors: List[Dict[str, Any]] = []

    def elapsed(self) -> float:
        return time.time() - self.started_at

    def rate(self, count: int) -> str:
        elapsed = self.elapsed()
        if elapsed == 0:
            return "N/A"
        return f"{count / elapsed * 60:.1f}/min"

    def summary(self, label: str = "RUNNING") -> str:
        elapsed = self.elapsed()
        return (
            f"[{label}] pages={self.api_pages} seen={self.projects_seen} "
            f"archived={self.projects_archived} skipped={self.projects_skipped} "
            f"failed={self.projects_failed} input_only={self.projects_input_only} "
            f"dl_in={self.inputs_downloaded} dl_out={self.outputs_downloaded} "
            f"files={self.files_archived} theorems={self.theorems_extracted} "
            f"theorem_metadata={self.theorem_metadata_extracted} packages={self.packages_stored} "
            f"elapsed={_fmt_duration(elapsed)} rate={self.rate(self.projects_seen)}"
        )

    def add_error(self, stage: str, project_id: str, exc: Exception):
        self.errors.append({
            "stage": stage,
            "project_id": project_id,
            "error": str(exc),
            "traceback": traceback.format_exc(),
            "ts": _now(),
        })


def _find_package_json(directory: Path) -> Optional[Path]:
    """Locate a PACKAGE.json file in a project directory tree."""
    if not directory.exists():
        return None
    candidates = []
    for src in directory.rglob("*.json"):
        if not src.is_file():
            continue
        name = src.name.lower()
        if name == "package.json" or name.endswith(".package.json"):
            candidates.append(src)
    # Prefer exact PACKAGE.json
    for c in candidates:
        if c.name == "PACKAGE.json":
            return c
    return candidates[0] if candidates else None


def _extract_packages(am: ArchiveManager, project_id: str, input_dir: Optional[Path], output_dir: Optional[Path], telemetry: Telemetry) -> None:
    """Find and store PACKAGE.json files from a project's extracted dirs."""
    found = []
    for directory in (input_dir, output_dir):
        if not directory or not directory.exists():
            continue
        pkg_path = _find_package_json(directory)
        if pkg_path:
            found.append(pkg_path)
    for pkg_path in found:
        try:
            package_json = pkg_path.read_text(encoding="utf-8", errors="ignore")
            # Basic JSON sanity check
            json.loads(package_json)
            am.store_package(project_id, package_json)
            telemetry.packages_stored += 1
            logging.info(
                "[Backfill]   %s stored package %s (%s bytes)",
                project_id[:8], pkg_path.name, len(package_json)
            )
        except Exception as e:
            telemetry.add_error("store_package", project_id, e)
            logging.warning("[Backfill]   %s failed to store package %s: %s", project_id[:8], pkg_path, e)


def _extract_theorem_metadata(
    am: ArchiveManager,
    project_id: str,
    input_dir: Optional[Path],
    output_dir: Optional[Path],
    telemetry: Telemetry,
) -> None:
    """Scan all .lean files in extracted dirs and store rich theorem metadata."""
    extractor = TheoremExtractor()
    all_records: List[Dict] = []
    for directory in (input_dir, output_dir):
        if not directory or not directory.exists():
            continue
        for lean_file in directory.rglob("*.lean"):
            if not lean_file.is_file():
                continue
            rel = str(lean_file.relative_to(directory)).replace("\\", "/")
            data = lean_file.read_bytes()
            file_hash = hashlib.sha256(data).hexdigest()
            records = extractor.extract_from_bytes(
                data,
                file_hash=file_hash,
                file_path=rel,
                project_id=project_id,
            )
            all_records.extend(extractor.records_to_db_rows(records))
    if all_records:
        conn = am._connect()
        conn.executemany(
            "INSERT OR IGNORE INTO theorems "
            "(name, file_hash, project_id, domain, statement_text, full_statement, "
            "proof_text, docstring, line_number, file_path, theorem_type, declaration_kind, "
            "is_sorry, uses_sorry, is_complete, parameters, return_type, metadata_json) "
            "VALUES (:name, :file_hash, :project_id, :domain, :statement_text, :full_statement, "
            ":proof_text, :docstring, :line_number, :file_path, :theorem_type, :declaration_kind, "
            ":is_sorry, :uses_sorry, :is_complete, :parameters, :return_type, :metadata_json)",
            all_records,
        )
        conn.commit()
        telemetry.theorem_metadata_extracted += len(all_records)
        logging.info(
            "[Backfill]   %s extracted theorem metadata for %s theorems",
            project_id[:8], len(all_records)
        )


def _reprocess_existing(
    am: ArchiveManager,
    telemetry: Telemetry,
    extract_packages: bool = True,
    extract_theorem_metadata: bool = True,
    domain_filter: Optional[str] = None,
) -> None:
    """Re-extract packages and theorem metadata from already-archived projects."""
    conn = am._connect()
    rows = conn.execute(
        "SELECT project_id FROM projects ORDER BY archived_at"
    ).fetchall()
    logging.info("[Backfill] Reprocessing %s existing projects", len(rows))

    extractor = TheoremExtractor()
    for row in rows:
        project_id = row["project_id"]
        project_t0 = time.time()

        # Find output .lean and package files for this project
        file_rows = conn.execute(
            "SELECT pf.file_hash, pf.path_inside_archive, f.content_type "
            "FROM project_files pf JOIN files f ON pf.file_hash = f.hash "
            "WHERE pf.project_id=? AND pf.role='output'",
            (project_id,),
        ).fetchall()

        if extract_packages:
            package_found = False
            for fr in file_rows:
                path = fr["path_inside_archive"].lower()
                if path == "package.json" or path.endswith(".package.json") or path.endswith("package.json"):
                    data = am.read_file(fr["file_hash"])
                    if not data:
                        continue
                    try:
                        package_json = data.decode("utf-8", errors="ignore")
                        json.loads(package_json)
                        am.store_package(project_id, package_json)
                        telemetry.packages_stored += 1
                        package_found = True
                        logging.info(
                            "[Backfill]   %s re-stored package from %s",
                            project_id[:8], fr["path_inside_archive"]
                        )
                        break
                    except Exception as e:
                        telemetry.add_error("reprocess_package", project_id, e)

        if extract_theorem_metadata:
            all_records: List[Dict] = []
            for fr in file_rows:
                if not fr["path_inside_archive"].endswith(".lean"):
                    continue
                data = am.read_file(fr["file_hash"])
                if not data:
                    continue
                if domain_filter:
                    domain = extractor._extract_domain_from_path(fr["path_inside_archive"])
                    if domain != domain_filter:
                        continue
                records = extractor.extract_from_bytes(
                    data,
                    file_hash=fr["file_hash"],
                    file_path=fr["path_inside_archive"],
                    project_id=project_id,
                )
                all_records.extend(extractor.records_to_db_rows(records))
            if all_records:
                conn.executemany(
                    "INSERT OR IGNORE INTO theorems "
                    "(name, file_hash, project_id, domain, statement_text, full_statement, "
                    "proof_text, docstring, line_number, file_path, theorem_type, declaration_kind, "
                    "is_sorry, uses_sorry, is_complete, parameters, return_type, metadata_json) "
                    "VALUES (:name, :file_hash, :project_id, :domain, :statement_text, :full_statement, "
                    ":proof_text, :docstring, :line_number, :file_path, :theorem_type, :declaration_kind, "
                    ":is_sorry, :uses_sorry, :is_complete, :parameters, :return_type, :metadata_json)",
                    all_records,
                )
                conn.commit()
                telemetry.theorem_metadata_extracted += len(all_records)
                logging.info(
                    "[Backfill]   %s re-extracted theorem metadata for %s theorems in %.2fs",
                    project_id[:8], len(all_records), time.time() - project_t0
                )


async def backfill_from_api(
    am: ArchiveManager,
    max_pages: Optional[int],
    page_size: int,
    telemetry: Telemetry,
    summary_every: int = 25,
    download_timeout: float = 600.0,
    extract_packages: bool = True,
    extract_theorem_metadata: bool = True,
):
    """List projects via API and archive any not already in the catalog."""
    key = await get_api_key()
    set_api_key(key)

    pagination_key: Optional[str] = None
    page = 0
    while True:
        page += 1
        if max_pages and page > max_pages:
            logging.info("[Backfill] Stopping after %s pages", max_pages)
            break

        page_fetch_start = time.time()
        try:
            projects, pagination_key = await Project.list_projects(
                pagination_key=pagination_key, limit=page_size
            )
        except Exception as e:
            telemetry.add_error("list_projects", "", e)
            logging.error("[Backfill] Failed to list API page %s: %s", page, e)
            break

        telemetry.api_pages += 1
        page_fetch_elapsed = time.time() - page_fetch_start
        logging.info(
            "[Backfill] API page %s fetched in %.2fs: %s projects (next_page=%s)",
            page, page_fetch_elapsed, len(projects), pagination_key is not None
        )

        for idx, project in enumerate(projects, 1):
            telemetry.projects_seen += 1
            project_t0 = time.time()
            exists = am.project_exists(project.project_id)
            has_output = am.project_has_output(project.project_id)

            if exists and (has_output or not project.has_files):
                telemetry.projects_skipped += 1
                logging.info(
                    "[Backfill] %s/%s page=%s skipping %s "
                    "(exists=%s, has_output=%s, has_files=%s)",
                    idx, len(projects), page, project.project_id[:8],
                    exists, has_output, project.has_files
                )
                _maybe_print_summary(telemetry, summary_every)
                continue

            if exists and project.has_files and not has_output:
                telemetry.projects_input_only += 1
                logging.info(
                    "[Backfill] %s/%s page=%s %s already archived input; downloading output",
                    idx, len(projects), page, project.project_id[:8]
                )

            try:
                manifest = await _archive_one_api(
                    am, project, telemetry, download_timeout,
                    extract_packages=extract_packages,
                    extract_theorem_metadata=extract_theorem_metadata,
                )
                telemetry.projects_archived += 1
                telemetry.files_archived += len(manifest.input_files) + len(manifest.output_files)
                telemetry.theorems_extracted += _count_theorems(am, project.project_id)
                project_elapsed = time.time() - project_t0
                logging.info(
                    "[Backfill] %s/%s page=%s archived %s in %.2fs "
                    "(input_files=%s, output_files=%s, prompt_hash=%s, main_lean_hash=%s)%s",
                    idx, len(projects), page, project.project_id[:8], project_elapsed,
                    len(manifest.input_files), len(manifest.output_files),
                    manifest.prompt_hash[:12] if manifest.prompt_hash else None,
                    manifest.main_lean_hash[:12] if manifest.main_lean_hash else None,
                    _log_extra_context()
                )
            except Exception as e:
                telemetry.projects_failed += 1
                telemetry.add_error("archive_one_api", project.project_id, e)
                logging.exception(
                    "[Backfill] %s/%s page=%s FAILED to archive %s: %s",
                    idx, len(projects), page, project.project_id[:8], e
                )

            _maybe_print_summary(telemetry, summary_every)
            await asyncio.sleep(0.05)

        if not pagination_key:
            logging.info("[Backfill] No further API pages")
            break


def _count_theorems(am: ArchiveManager, project_id: str) -> int:
    try:
        conn = am._connect()
        row = conn.execute(
            "SELECT COUNT(*) AS c FROM theorems t "
            "JOIN project_files pf ON t.file_hash = pf.file_hash "
            "WHERE pf.project_id = ?",
            (project_id,)
        ).fetchone()
        return row["c"] if row else 0
    except Exception:
        return 0


def _maybe_print_summary(telemetry: Telemetry, every: int):
    total_processed = telemetry.projects_archived + telemetry.projects_skipped + telemetry.projects_failed
    if total_processed % every == 0 and total_processed // every > telemetry.summaries_printed:
        telemetry.summaries_printed = total_processed // every
        logging.info(telemetry.summary("PROGRESS"))


async def _archive_one_api(
    am: ArchiveManager,
    project: Project,
    telemetry: Telemetry,
    download_timeout: float = 600.0,
    extract_packages: bool = True,
    extract_theorem_metadata: bool = True,
):
    """Download input/output archives for one project and archive them."""
    tmpdir = Path(tempfile.mkdtemp(prefix=f"backfill_{project.project_id}_"))
    input_archive: Optional[Path] = None
    output_archive: Optional[Path] = None
    input_dir: Optional[Path] = None
    output_dir: Optional[Path] = None
    try:
        key = await get_api_key()
        base_url = get_api_base_url()

        # Input archive
        dl_in_start = time.time()
        try:
            input_archive = tmpdir / "input.tar.gz"
            await stream_download(
                f"{base_url}/project/{project.project_id}/input",
                input_archive,
                key,
                timeout=download_timeout,
            )
            telemetry.inputs_downloaded += 1
            logging.info(
                "[Backfill]   %s input download: %s bytes in %.2fs",
                project.project_id[:8], input_archive.stat().st_size, time.time() - dl_in_start
            )
        except Exception as e:
            telemetry.input_download_failed += 1
            input_archive = None
            logging.warning(
                "[Backfill]   %s input download failed: %s",
                project.project_id[:8], e
            )

        # Output archive (agent result files); endpoint is /result, not /files
        if project.has_files:
            dl_out_start = time.time()
            try:
                output_archive = tmpdir / "output.tar.gz"
                await stream_download(
                    f"{base_url}/project/{project.project_id}/result",
                    output_archive,
                    key,
                    timeout=download_timeout,
                )
                telemetry.outputs_downloaded += 1
                logging.info(
                    "[Backfill]   %s output download: %s bytes in %.2fs",
                    project.project_id[:8], output_archive.stat().st_size, time.time() - dl_out_start
                )
            except Exception as e:
                telemetry.output_download_failed += 1
                output_archive = None
                logging.warning(
                    "[Backfill]   %s output download failed: %s",
                    project.project_id[:8], e
                )

        # Extract tarballs once so we can both archive and derive metadata.
        if input_archive and input_archive.exists():
            input_dir = am._extract_tar(input_archive)
        if output_archive and output_archive.exists():
            output_dir = am._extract_tar(output_archive)

        archive_start = time.time()
        manifest = am.archive_project(
            project_id=project.project_id,
            description=project.description or "",
            status=project.status.name if hasattr(project.status, "name") else str(project.status),
            created_at=project.created_at.isoformat() if hasattr(project.created_at, "isoformat") else str(project.created_at),
            last_updated=project.last_updated.isoformat() if hasattr(project.last_updated, "isoformat") else str(project.last_updated),
            input_dir=input_dir,
            output_dir=output_dir,
        )
        logging.info(
            "[Backfill]   %s archive_project took %.2fs",
            project.project_id[:8], time.time() - archive_start
        )

        if extract_packages:
            _extract_packages(am, project.project_id, input_dir, output_dir, telemetry)
        if extract_theorem_metadata:
            _extract_theorem_metadata(am, project.project_id, input_dir, output_dir, telemetry)

        return manifest
    finally:
        cleanup_start = time.time()
        for d in (input_dir, output_dir):
            if d:
                shutil.rmtree(d, ignore_errors=True)
        shutil.rmtree(tmpdir, ignore_errors=True)
        logging.debug(
            "[Backfill]   %s temp cleanup took %.3fs",
            project.project_id[:8], time.time() - cleanup_start
        )


def backfill_from_local_projects(
    am: ArchiveManager,
    projects_root: Path,
    telemetry: Telemetry,
    summary_every: int = 25,
    extract_packages: bool = True,
    extract_theorem_metadata: bool = True,
):
    """Archive from locally-cached project directories (input only)."""
    if not projects_root.exists():
        logging.info("[Backfill] Local projects dir not found: %s", projects_root)
        return
    project_dirs = [d for d in sorted(projects_root.iterdir()) if d.is_dir()]
    logging.info("[Backfill] Found %s local project directories in %s", len(project_dirs), projects_root)
    for i, project_dir in enumerate(project_dirs, 1):
        telemetry.projects_seen += 1
        project_id = project_dir.name
        if am.project_exists(project_id):
            telemetry.projects_skipped += 1
            logging.info("[Backfill] %s/%s Skipping %s (already archived)", i, len(project_dirs), project_id[:8])
            _maybe_print_summary(telemetry, summary_every)
            continue
        input_dir = project_dir
        output_dir: Optional[Path] = None
        if (project_dir / "result_extracted").exists():
            output_dir = project_dir / "result_extracted"

        project_t0 = time.time()
        try:
            manifest = am.archive_project(
                project_id=project_id,
                description=project_id,
                status="UNKNOWN",
                created_at="",
                last_updated="",
                input_dir=input_dir,
                output_dir=output_dir,
                skip_input_catalog_context=False if output_dir else True,
            )
            telemetry.projects_archived += 1
            telemetry.files_archived += len(manifest.input_files) + len(manifest.output_files)
            telemetry.theorems_extracted += _count_theorems(am, project_id)
            if extract_packages:
                _extract_packages(am, project_id, input_dir, output_dir, telemetry)
            if extract_theorem_metadata:
                _extract_theorem_metadata(am, project_id, input_dir, output_dir, telemetry)
            logging.info(
                "[Backfill] %s/%s Archived local project %s in %.2fs "
                "(output=%s, input_files=%s, output_files=%s)%s",
                i, len(project_dirs), project_id[:8], time.time() - project_t0,
                output_dir is not None, len(manifest.input_files), len(manifest.output_files),
                _log_extra_context()
            )
        except Exception as e:
            telemetry.projects_failed += 1
            telemetry.add_error("archive_local", project_id, e)
            logging.exception("[Backfill] %s/%s Failed to archive %s: %s", i, len(project_dirs), project_id[:8], e)

        _maybe_print_summary(telemetry, summary_every)


def main():
    parser = argparse.ArgumentParser(description="Backfill Aristotle archive")
    parser.add_argument("--archive-root", default=str(Path(__file__).parent.parent / "Archive"), help="Archive root directory")
    parser.add_argument("--max-pages", type=int, default=None, help="Max API pages")
    parser.add_argument("--page-size", type=int, default=100, help="Projects per API page")
    parser.add_argument("--from-local-projects", action="store_true",
                        help="Archive from Aether/.aether_workspace/projects instead of API")
    parser.add_argument("--projects-root", default="./.aether_workspace/projects",
                        help="Local projects root")
    parser.add_argument("--no-api", action="store_true", help="Skip API calls entirely")
    parser.add_argument("--log", default=None, help="Path to log file (in addition to stdout)")
    parser.add_argument("--summary-every", type=int, default=25, help="Emit a progress summary every N projects")
    parser.add_argument("--max-memory-mb", type=int, default=6000,
                        help="Cap process virtual memory (Linux/WSL) to avoid OOM-killing the VM (0=disable)")
    parser.add_argument("--download-timeout", type=float, default=600,
                        help="Seconds to wait while streaming a project archive")
    parser.add_argument("--extract-packages", action="store_true", default=True,
                        help="Store research PACKAGE.json files found in project output (default: on)")
    parser.add_argument("--no-extract-packages", dest="extract_packages", action="store_false",
                        help="Disable package extraction")
    parser.add_argument("--extract-theorem-metadata", action="store_true", default=True,
                        help="Extract rich theorem metadata (docstrings, statements, proofs) (default: on)")
    parser.add_argument("--no-extract-theorem-metadata", dest="extract_theorem_metadata", action="store_false",
                        help="Disable theorem metadata extraction")
    parser.add_argument("--reprocess-existing", action="store_true",
                        help="Re-scan already-archived projects for packages and theorem metadata")
    parser.add_argument("--domain", default=None,
                        help="When reprocessing, only process theorem metadata for this Catalog domain")
    args = parser.parse_args()

    log_path = Path(args.log) if args.log else None
    _setup_logging(log_path)
    set_max_memory_mb(args.max_memory_mb)

    telemetry = Telemetry()
    logging.info("[Backfill] Starting run at %s pid=%s", _now(), os.getpid())
    logging.info("[Backfill] args=%s", vars(args))

    am = ArchiveManager(Path(args.archive_root))
    before_stats = am.get_stats()
    logging.info("[Backfill] Before stats: %s", json.dumps(before_stats, indent=2))

    try:
        if args.reprocess_existing:
            _reprocess_existing(
                am,
                telemetry,
                extract_packages=args.extract_packages,
                extract_theorem_metadata=args.extract_theorem_metadata,
                domain_filter=args.domain,
            )
        if args.from_local_projects:
            backfill_from_local_projects(
                am, Path(args.projects_root), telemetry, args.summary_every,
                extract_packages=args.extract_packages,
                extract_theorem_metadata=args.extract_theorem_metadata,
            )
        elif not args.no_api:
            asyncio.run(backfill_from_api(
                am, args.max_pages, args.page_size, telemetry,
                args.summary_every, args.download_timeout,
                extract_packages=args.extract_packages,
                extract_theorem_metadata=args.extract_theorem_metadata,
            ))
    except Exception as e:
        telemetry.add_error("main", "", e)
        logging.exception("[Backfill] Fatal error in main loop: %s", e)
    finally:
        after_stats = am.get_stats()
        logging.info("[Backfill] After stats: %s", json.dumps(after_stats, indent=2))
        delta = {k: after_stats.get(k, 0) - before_stats.get(k, 0) for k in before_stats}
        logging.info("[Backfill] Delta stats: %s", json.dumps(delta, indent=2))
        logging.info("[Backfill] Final telemetry: %s", telemetry.summary("DONE"))
        if telemetry.errors:
            logging.warning("[Backfill] %s errors recorded", len(telemetry.errors))
            for err in telemetry.errors[:10]:
                logging.warning("  - %(stage)s %(project_id)s: %(error)s", err)
            if len(telemetry.errors) > 10:
                logging.warning("  ... and %s more errors", len(telemetry.errors) - 10)
        logging.info("[Backfill] Finished at %s", _now())


if __name__ == "__main__":
    main()

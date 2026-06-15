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


async def get_api_key() -> str:
    key = os.environ.get("ARISTOTLE_API_KEY", "")
    if not key:
        try:
            import yaml
            cfg_path = Path(__file__).parent / "config.yaml"
            if cfg_path.exists():
                cfg = yaml.safe_load(cfg_path.read_text())
                key = cfg.get("aristotle", {}).get("api_key", "")
                if key.startswith("${"):
                    key = os.environ.get(key.strip("${}"), "")
        except Exception:
            pass
    if not key:
        raise RuntimeError("ARISTOTLE_API_KEY required")
    return key


def _mem_mb() -> Optional[float]:
    try:
        import psutil
        proc = psutil.Process(os.getpid())
        return round(proc.memory_info().rss / (1024 * 1024), 2)
    except Exception:
        return None


def _log_extra_context() -> str:
    mem = _mem_mb()
    if mem is not None:
        return f" mem={mem}MB"
    return ""


async def backfill_from_api(am: ArchiveManager, max_pages: Optional[int], page_size: int, telemetry: Telemetry, summary_every: int = 25):
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
                manifest = await _archive_one_api(am, project, telemetry)
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


async def _archive_one_api(am: ArchiveManager, project: Project, telemetry: Telemetry):
    """Download input/output archives for one project and archive them."""
    tmpdir = Path(tempfile.mkdtemp(prefix=f"backfill_{project.project_id}_"))
    input_archive: Optional[Path] = None
    output_archive: Optional[Path] = None
    try:
        async with api_request.AristotleRequestClient() as client:
            # Input archive
            dl_in_start = time.time()
            try:
                r = await client.get(f"/project/{project.project_id}/input")
                input_archive = tmpdir / "input.tar.gz"
                input_archive.write_bytes(r.content)
                telemetry.inputs_downloaded += 1
                logging.info(
                    "[Backfill]   %s input download: %s bytes in %.2fs",
                    project.project_id[:8], len(r.content), time.time() - dl_in_start
                )
            except Exception as e:
                telemetry.input_download_failed += 1
                logging.warning(
                    "[Backfill]   %s input download failed: %s",
                    project.project_id[:8], e
                )

            # Output archive (agent result files); endpoint is /result, not /files
            if project.has_files:
                dl_out_start = time.time()
                try:
                    r = await client.get(f"/project/{project.project_id}/result")
                    output_archive = tmpdir / "output.tar.gz"
                    output_archive.write_bytes(r.content)
                    telemetry.outputs_downloaded += 1
                    logging.info(
                        "[Backfill]   %s output download: %s bytes in %.2fs",
                        project.project_id[:8], len(r.content), time.time() - dl_out_start
                    )
                except Exception as e:
                    telemetry.output_download_failed += 1
                    logging.warning(
                        "[Backfill]   %s output download failed: %s",
                        project.project_id[:8], e
                    )

        archive_start = time.time()
        manifest = am.archive_project(
            project_id=project.project_id,
            description=project.description or "",
            status=project.status.name if hasattr(project.status, "name") else str(project.status),
            created_at=project.created_at.isoformat() if hasattr(project.created_at, "isoformat") else str(project.created_at),
            last_updated=project.last_updated.isoformat() if hasattr(project.last_updated, "isoformat") else str(project.last_updated),
            input_archive_path=input_archive,
            output_archive_path=output_archive,
        )
        logging.info(
            "[Backfill]   %s archive_project took %.2fs",
            project.project_id[:8], time.time() - archive_start
        )
        return manifest
    finally:
        cleanup_start = time.time()
        shutil.rmtree(tmpdir, ignore_errors=True)
        logging.debug(
            "[Backfill]   %s temp cleanup took %.3fs",
            project.project_id[:8], time.time() - cleanup_start
        )


def backfill_from_local_projects(am: ArchiveManager, projects_root: Path, telemetry: Telemetry, summary_every: int = 25):
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
    args = parser.parse_args()

    log_path = Path(args.log) if args.log else None
    _setup_logging(log_path)

    telemetry = Telemetry()
    logging.info("[Backfill] Starting run at %s pid=%s", _now(), os.getpid())
    logging.info("[Backfill] args=%s", vars(args))

    am = ArchiveManager(Path(args.archive_root))
    before_stats = am.get_stats()
    logging.info("[Backfill] Before stats: %s", json.dumps(before_stats, indent=2))

    try:
        if args.from_local_projects:
            backfill_from_local_projects(am, Path(args.projects_root), telemetry, args.summary_every)
        elif not args.no_api:
            asyncio.run(backfill_from_api(am, args.max_pages, args.page_size, telemetry, args.summary_every))
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

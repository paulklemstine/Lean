#!/usr/bin/env python3
"""Backfill the Aristotle archive from the Harmonic API and local project dirs.

This script is idempotent: re-running it will only download/archive projects
that are not already in Archive/catalog.sqlite.

Usage:
    cd Aether && python3 backfill_aristotle_archive.py
    python3 backfill_aristotle_archive.py --archive-root ../Archive --max-pages 5
    python3 backfill_aristotle_archive.py --from-local-projects --no-api
"""

import argparse
import asyncio
import os
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Optional

sys.path.insert(0, str(Path(__file__).parent))

from aristotlelib import Project, set_api_key
import aristotlelib.api_request as api_request
from archive_manager import ArchiveManager


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


async def backfill_from_api(am: ArchiveManager, max_pages: Optional[int], page_size: int):
    """List projects via API and archive any not already in the catalog."""
    key = await get_api_key()
    set_api_key(key)

    pagination_key: Optional[str] = None
    page = 0
    while True:
        page += 1
        if max_pages and page > max_pages:
            print(f"[Backfill] Stopping after {max_pages} pages")
            break
        projects, pagination_key = await Project.list_projects(
            pagination_key=pagination_key, limit=page_size
        )
        print(f"[Backfill] API page {page}: {len(projects)} projects")
        for project in projects:
            if am.project_exists(project.project_id):
                print(f"[Backfill] Skipping {project.project_id[:8]} (already archived)")
                continue
            await _archive_one_api(am, project)
            await asyncio.sleep(0.05)
        if not pagination_key:
            break


async def _archive_one_api(am: ArchiveManager, project: Project):
    """Download input/output archives for one project and archive them."""
    tmpdir = Path(tempfile.mkdtemp(prefix=f"backfill_{project.project_id}_"))
    input_archive: Optional[Path] = None
    output_archive: Optional[Path] = None
    try:
        async with api_request.AristotleRequestClient() as client:
            # Input archive
            try:
                r = await client.get(f"/project/{project.project_id}/input")
                input_archive = tmpdir / "input.tar.gz"
                input_archive.write_bytes(r.content)
            except Exception as e:
                print(f"[Backfill] Input download failed for {project.project_id[:8]}: {e}")

            # Output archive
            if project.has_files:
                try:
                    r = await client.get(f"/project/{project.project_id}/files")
                    output_archive = tmpdir / "output.tar.gz"
                    output_archive.write_bytes(r.content)
                except Exception as e:
                    print(f"[Backfill] Output download failed for {project.project_id[:8]}: {e}")

        am.archive_project(
            project_id=project.project_id,
            description=project.description or "",
            status=project.status.name if hasattr(project.status, "name") else str(project.status),
            created_at=project.created_at.isoformat() if hasattr(project.created_at, "isoformat") else str(project.created_at),
            last_updated=project.last_updated.isoformat() if hasattr(project.last_updated, "isoformat") else str(project.last_updated),
            input_archive_path=input_archive,
            output_archive_path=output_archive,
        )
        print(f"[Backfill] Archived {project.project_id[:8]} "
              f"(input={input_archive is not None}, output={output_archive is not None})")
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def backfill_from_local_projects(am: ArchiveManager, projects_root: Path):
    """Archive from locally-cached project directories (input only)."""
    if not projects_root.exists():
        print(f"[Backfill] Local projects dir not found: {projects_root}", flush=True)
        return
    project_dirs = [d for d in sorted(projects_root.iterdir()) if d.is_dir()]
    print(f"[Backfill] Found {len(project_dirs)} local project directories", flush=True)
    for i, project_dir in enumerate(project_dirs, 1):
        project_id = project_dir.name
        if am.project_exists(project_id):
            print(f"[Backfill] {i}/{len(project_dirs)} Skipping {project_id[:8]} (already archived)", flush=True)
            continue
        input_dir = project_dir
        output_dir: Optional[Path] = None
        if (project_dir / "result_extracted").exists():
            output_dir = project_dir / "result_extracted"

        try:
            am.archive_project(
                project_id=project_id,
                description=project_id,
                status="UNKNOWN",
                created_at="",
                last_updated="",
                input_dir=input_dir,
                output_dir=output_dir,
            )
            print(f"[Backfill] {i}/{len(project_dirs)} Archived local project {project_id[:8]} "
                  f"(output={output_dir is not None})", flush=True)
        except Exception as e:
            print(f"[Backfill] {i}/{len(project_dirs)} Failed to archive {project_id[:8]}: {e}", flush=True)


def main():
    parser = argparse.ArgumentParser(description="Backfill Aristotle archive")
    parser.add_argument("--archive-root", default="../Archive", help="Archive root directory")
    parser.add_argument("--max-pages", type=int, default=None, help="Max API pages")
    parser.add_argument("--page-size", type=int, default=100, help="Projects per API page")
    parser.add_argument("--from-local-projects", action="store_true",
                        help="Archive from Aether/.aether_workspace/projects instead of API")
    parser.add_argument("--projects-root", default="./.aether_workspace/projects",
                        help="Local projects root")
    parser.add_argument("--no-api", action="store_true", help="Skip API calls entirely")
    args = parser.parse_args()

    am = ArchiveManager(Path(args.archive_root))

    if args.from_local_projects:
        backfill_from_local_projects(am, Path(args.projects_root))
    elif not args.no_api:
        asyncio.run(backfill_from_api(am, args.max_pages, args.page_size))

    stats = am.get_stats()
    print("\n[Backfill] Final stats:")
    for k, v in stats.items():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()

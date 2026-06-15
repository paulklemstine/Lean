#!/usr/bin/env python3
"""Gather every Aristotle project input from the Harmonic API.

This script pages through all projects accessible to the configured API key,
downloads each project's `/input` archive, extracts the submitted prompt and
Lean source, and writes a JSON manifest plus an optional CSV summary.

Usage:
    cd Aether && python3 gather_aristotle_inputs.py
    python3 gather_aristotle_inputs.py --output-dir ./aristotle_inputs --max-pages 5
    python3 gather_aristotle_inputs.py --skip-download --output-dir ./aristotle_inputs

Environment:
    ARISTOTLE_API_KEY (required unless set in config.yaml)
"""

import argparse
import asyncio
import csv
import io
import json
import os
import sys
import tarfile
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple

sys.path.insert(0, str(Path(__file__).parent))

import aristotlelib
from aristotlelib import Project, set_api_key
import aristotlelib.api_request as api_request


@dataclass
class ProjectInput:
    """Captured metadata and file paths for one Aristotle project input."""
    project_id: str
    description: str
    status: str
    created_at: str
    last_updated: str
    has_input: bool
    has_files: bool
    prompt: str = ""
    prompt_length: int = 0
    main_lean: str = ""
    main_lean_length: int = 0
    input_files: List[str] = field(default_factory=list)
    error: Optional[str] = None


class AristotleInputGatherer:
    """Scrape Aristotle project inputs via the Harmonic API."""

    def __init__(
        self,
        output_dir: Path,
        api_key: Optional[str] = None,
        max_pages: Optional[int] = None,
        page_size: int = 100,
        skip_download: bool = False,
    ):
        self.output_dir = Path(output_dir)
        self.archive_dir = self.output_dir / "archives"
        self.prompt_dir = self.output_dir / "prompts"
        self.lean_dir = self.output_dir / "lean"
        self.max_pages = max_pages
        self.page_size = min(max(page_size, 1), 100)
        self.skip_download = skip_download

        # Configure API key
        key = api_key or os.environ.get("ARISTOTLE_API_KEY", "")
        if not key:
            # Try config.yaml
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
            raise RuntimeError(
                "ARISTOTLE_API_KEY is required. Set the env var or pass --api-key."
            )
        set_api_key(key)
        self.api_key = key

        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.archive_dir.mkdir(parents=True, exist_ok=True)
        self.prompt_dir.mkdir(parents=True, exist_ok=True)
        self.lean_dir.mkdir(parents=True, exist_ok=True)

    async def list_all_projects(self) -> List[Project]:
        """Paginate through all accessible projects."""
        projects: List[Project] = []
        pagination_key: Optional[str] = None
        page = 0
        while True:
            page += 1
            if self.max_pages and page > self.max_pages:
                print(f"[Gather] Stopping after {self.max_pages} pages")
                break
            batch, pagination_key = await Project.list_projects(
                pagination_key=pagination_key, limit=self.page_size
            )
            print(f"[Gather] Page {page}: {len(batch)} projects")
            projects.extend(batch)
            if not pagination_key:
                break
        print(f"[Gather] Total projects listed: {len(projects)}")
        return projects

    async def download_project_input(self, project: Project) -> Optional[bytes]:
        """Download the raw input archive for a project."""
        archive_path = self.archive_dir / f"{project.project_id}.tar.gz"
        if archive_path.exists():
            return archive_path.read_bytes()

        async with api_request.AristotleRequestClient() as client:
            response = await client.get(f"/project/{project.project_id}/input")
            data = response.content
            archive_path.write_bytes(data)
            return data

    def extract_input(self, project_id: str, data: bytes) -> Tuple[str, str, List[str]]:
        """Extract PROMPT.md, Main.lean, and file list from the tar archive."""
        prompt_text = ""
        main_lean = ""
        files: List[str] = []
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tf:
            for member in tf.getmembers():
                if not member.isfile():
                    continue
                files.append(member.name)
                if member.name.endswith("PROMPT.md"):
                    f = tf.extractfile(member)
                    if f:
                        prompt_text = f.read().decode("utf-8", errors="replace")
                elif member.name.endswith("Main.lean") and not main_lean:
                    # Prefer root Main.lean if multiple exist
                    f = tf.extractfile(member)
                    if f:
                        main_lean = f.read().decode("utf-8", errors="replace")

        # Save extracted prompt and lean to disk
        if prompt_text:
            (self.prompt_dir / f"{project_id}.md").write_text(
                prompt_text, encoding="utf-8"
            )
        if main_lean:
            (self.lean_dir / f"{project_id}.lean").write_text(
                main_lean, encoding="utf-8"
            )
        return prompt_text, main_lean, files

    async def process_project(self, project: Project) -> ProjectInput:
        """Download and extract input for one project."""
        record = ProjectInput(
            project_id=project.project_id,
            description=project.description or "",
            status=project.status.name if hasattr(project.status, "name") else str(project.status),
            created_at=project.created_at.isoformat() if hasattr(project.created_at, "isoformat") else str(project.created_at),
            last_updated=project.last_updated.isoformat() if hasattr(project.last_updated, "isoformat") else str(project.last_updated),
            has_input=project.has_input,
            has_files=project.has_files,
        )
        if not project.has_input:
            record.error = "No input archive"
            return record

        try:
            if self.skip_download:
                archive_path = self.archive_dir / f"{project.project_id}.tar.gz"
                if not archive_path.exists():
                    record.error = "Archive not cached and --skip-download set"
                    return record
                data = archive_path.read_bytes()
            else:
                data = await self.download_project_input(project)

            if not data:
                record.error = "Empty input archive"
                return record

            prompt, lean, files = self.extract_input(project.project_id, data)
            record.prompt = prompt[:2000]
            record.prompt_length = len(prompt)
            record.main_lean = lean[:2000]
            record.main_lean_length = len(lean)
            record.input_files = files
        except Exception as e:
            record.error = str(e)
        return record

    async def run(self) -> List[ProjectInput]:
        """Run the full gather pipeline."""
        projects = await self.list_all_projects()
        records: List[ProjectInput] = []
        for i, project in enumerate(projects, 1):
            record = await self.process_project(project)
            records.append(record)
            if i % 10 == 0 or i == len(projects):
                print(
                    f"[Gather] Processed {i}/{len(projects)} — "
                    f"prompts={sum(1 for r in records if r.prompt_length > 0)}, "
                    f"errors={sum(1 for r in records if r.error)}"
                )
            # Be polite to the API
            await asyncio.sleep(0.05)
        return records

    def save_manifest(self, records: List[ProjectInput]) -> None:
        """Write JSON manifest and CSV summary."""
        manifest_path = self.output_dir / "manifest.json"
        csv_path = self.output_dir / "summary.csv"

        # JSON manifest
        data = []
        for r in records:
            data.append({
                "project_id": r.project_id,
                "description": r.description,
                "status": r.status,
                "created_at": r.created_at,
                "last_updated": r.last_updated,
                "has_input": r.has_input,
                "has_files": r.has_files,
                "prompt_length": r.prompt_length,
                "main_lean_length": r.main_lean_length,
                "input_file_count": len(r.input_files),
                "error": r.error,
                "prompt_excerpt": r.prompt[:500],
            })
        manifest_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8"
        )

        # CSV summary
        with open(csv_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "project_id", "description", "status", "created_at", "last_updated",
                "has_input", "has_files", "prompt_length", "main_lean_length",
                "input_file_count", "error", "prompt_excerpt",
            ])
            for r in records:
                writer.writerow([
                    r.project_id,
                    r.description,
                    r.status,
                    r.created_at,
                    r.last_updated,
                    r.has_input,
                    r.has_files,
                    r.prompt_length,
                    r.main_lean_length,
                    len(r.input_files),
                    r.error or "",
                    r.prompt[:300].replace("\n", " "),
                ])

        print(f"[Gather] Saved manifest: {manifest_path}")
        print(f"[Gather] Saved CSV: {csv_path}")
        print(f"[Gather] Archives: {self.archive_dir}")
        print(f"[Gather] Prompts: {self.prompt_dir}")
        print(f"[Gather] Lean: {self.lean_dir}")


def main():
    parser = argparse.ArgumentParser(
        description="Gather all Aristotle project inputs from the Harmonic API."
    )
    parser.add_argument(
        "--output-dir",
        default="./aristotle_inputs",
        help="Directory to save archives, prompts, manifest, and CSV.",
    )
    parser.add_argument(
        "--api-key",
        default=None,
        help="Aristotle API key (defaults to ARISTOTLE_API_KEY env var).",
    )
    parser.add_argument(
        "--max-pages",
        type=int,
        default=None,
        help="Maximum number of project pages to fetch (default: all).",
    )
    parser.add_argument(
        "--page-size",
        type=int,
        default=100,
        help="Projects per page (1-100).",
    )
    parser.add_argument(
        "--skip-download",
        action="store_true",
        help="Only process already-cached archives.",
    )
    args = parser.parse_args()

    gatherer = AristotleInputGatherer(
        output_dir=Path(args.output_dir),
        api_key=args.api_key,
        max_pages=args.max_pages,
        page_size=args.page_size,
        skip_download=args.skip_download,
    )
    records = asyncio.run(gatherer.run())
    gatherer.save_manifest(records)

    # Final stats
    total = len(records)
    with_prompt = sum(1 for r in records if r.prompt_length > 0)
    with_lean = sum(1 for r in records if r.main_lean_length > 0)
    errors = sum(1 for r in records if r.error)
    print(
        f"\n[Gather] Done: {total} projects, {with_prompt} with prompts, "
        f"{with_lean} with Main.lean, {errors} errors."
    )


if __name__ == "__main__":
    main()

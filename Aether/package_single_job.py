#!/usr/bin/env python3
"""Package a single Aristotle project into a research JSON package.

Usage:
    cd Aether
    python3 package_single_job.py <project-id> \
        --archive-root ../Archive \
        --output ../Archive/packages/<project-id>.package.json

If the project is not already in the local archive, the script downloads
its input and result archives from the API, extracts them, and then either:

  * stores an existing PACKAGE.json found in the output, or
  * builds a minimal research package from the available artifacts.

The package is always stored in ArchiveManager's `packages` table.
"""

import argparse
import asyncio
import datetime
import json
import logging
import os
import re
import shutil
import sys
import tempfile
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

sys.path.insert(0, str(Path(__file__).parent))

from archive_manager import ArchiveManager
from archive_utils import get_api_base_url, get_api_key, stream_download
from theorem_extractor import TheoremExtractor


PACKAGE_JSON_PLACEHOLDER = re.compile(r"^[A-Z_0-9]+\.(md|py|txt|json|lean)$", re.IGNORECASE)


def _now() -> str:
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def _setup_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%SZ",
    )
    logging.Formatter.converter = time.gmtime


def _find_artifacts(directory: Path) -> Dict[str, List[Path]]:
    """Categorize files in an extracted project directory."""
    result: Dict[str, List[Path]] = {
        "package_jsons": [],
        "lean": [],
        "python": [],
        "article": [],
        "research_paper": [],
        "future_directions": [],
        "prompt": [],
        "other_md": [],
    }
    if not directory.exists():
        return result
    for src in directory.rglob("*"):
        if not src.is_file():
            continue
        name = src.name.lower()
        rel = str(src.relative_to(directory)).replace("\\", "/")
        # Skip build artifacts and the live Catalog context tree
        if any(part in (".lake", "build", "lake-packages", "__pycache__") for part in src.parts):
            continue
        if rel.startswith("Catalog/"):
            continue
        if name == "package.json":
            result["package_jsons"].append(src)
        elif name == "prompt.md":
            result["prompt"].append(src)
        elif name.endswith(".lean") and name != "main.lean":
            result["lean"].append(src)
        elif name.endswith(".py"):
            result["python"].append(src)
        elif name.startswith("article") or name == "article.md":
            result["article"].append(src)
        elif "research_paper" in name or "research-paper" in name:
            result["research_paper"].append(src)
        elif "future_directions" in name or "future-directions" in name:
            result["future_directions"].append(src)
        elif name.endswith(".md") and name not in ("readme.md",):
            result["other_md"].append(src)
    for k in result:
        result[k] = sorted(result[k], key=lambda p: str(p))
    return result


def _read_text(path: Optional[Path], limit: Optional[int] = None) -> str:
    if not path or not path.exists():
        return ""
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""
    if limit and len(text) > limit:
        text = text[:limit] + "\n\n[...truncated...]"
    return text


def _extract_title_and_description(artifacts: Dict[str, List[Path]]) -> tuple:
    """Derive title and description from PROMPT.md or project artifacts."""
    prompt_text = ""
    for p in artifacts.get("prompt", []):
        prompt_text = _read_text(p)
        if prompt_text:
            break

    title = ""
    description = ""
    if prompt_text:
        # First non-empty line that looks like a title
        for line in prompt_text.splitlines():
            stripped = line.strip().lstrip("#").strip()
            if stripped and len(stripped) > 10:
                title = stripped
                break
        # Use the first paragraph as description
        paragraphs = [p.strip() for p in prompt_text.split("\n\n") if p.strip()]
        if paragraphs:
            description = paragraphs[0][:500]
    return title, description


def _infer_domain(lean_paths: List[Path], default: str = "Novelty") -> str:
    from output_organizer import DOMAIN_DIRS
    counts: Dict[str, int] = {}
    for p in lean_paths:
        rel = str(p).replace("\\", "/")
        parts = rel.split("/")
        for i, part in enumerate(parts):
            if part.lower() == "catalog" and i + 1 < len(parts):
                domain = parts[i + 1]
                if domain in DOMAIN_DIRS:
                    counts[domain] = counts.get(domain, 0) + 1
                break
            elif part in DOMAIN_DIRS:
                counts[part] = counts.get(part, 0) + 1
                break
    if counts:
        return max(counts.items(), key=lambda x: x[1])[0]
    return default


def _build_minimal_package(
    project_id: str,
    artifacts: Dict[str, List[Path]],
    all_artifacts: Dict[str, List[Path]],
) -> str:
    """Build a minimal research package from project artifacts."""
    title, description = _extract_title_and_description(all_artifacts)
    if not title:
        title = f"Research results for {project_id}"

    lean_paths = artifacts.get("lean", [])
    lean_entries: List[Dict[str, Any]] = []
    key_results: List[str] = []
    keywords: List[str] = []
    extractor = TheoremExtractor()

    for lp in lean_paths:
        rel = str(lp.relative_to(lp.parent.parent if "output" in lp.parts else lp.parent)).replace("\\", "/")
        text = _read_text(lp)
        if not text:
            continue
        records = extractor.extract_from_text(text, file_path=rel)
        theorem_names = [r.name for r in records if r.name and r.name != "example"]
        lean_entries.append({
            "file": rel,
            "name": lp.name,
            "code": text,
            "theorems": len(theorem_names),
            "description": f"Lean 4 proof file ({len(theorem_names)} declarations)",
        })
        key_results.extend([f"{r.declaration_kind.capitalize()} `{r.name}`" for r in records if r.name != "example"])
        # crude keyword extraction from identifiers and docstrings
        for r in records:
            for word in re.findall(r"[A-Za-z]{4,}", r.docstring + " " + r.full_statement):
                if word.lower() not in {"theorem", "lemma", "example", "where", "import", "open"}:
                    keywords.append(word)

    lean_files = [e["file"] for e in lean_entries]
    key_results = list(dict.fromkeys(key_results))[:50]
    keywords = list(dict.fromkeys(keywords))[:30]

    algorithms: List[Dict[str, Any]] = []
    demos: List[Dict[str, Any]] = []
    modules: Dict[str, str] = {}
    for py_path in artifacts.get("python", []):
        text = _read_text(py_path)
        if not text:
            continue
        name = py_path.stem.replace("_", " ").title()
        entry = {"name": name, "code": text, "description": f"Python artifact from {py_path.name}"}
        fname = py_path.name.lower()
        if "algorithm" in fname or fname == "algorithms.py":
            algorithms.append(entry)
            modules.setdefault("algorithms", "")
            modules["algorithms"] += f"\n\n# --- {py_path.name}\n" + text
        else:
            demos.append(entry)
            modules.setdefault("demo", "")
            modules["demo"] += f"\n\n# --- {py_path.name}\n" + text

    pkg = {
        "title": title,
        "description": description or f"Research package for project {project_id}",
        "domain": _infer_domain(lean_paths),
        "date": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "exp_id": project_id,
        "authors": ["Aether"],
        "lean_files": lean_files,
        "lean_proofs": lean_entries,
        "key_results": key_results,
        "keywords": keywords,
        "algorithms": algorithms,
        "demos": demos,
        "article": _read_text(artifacts.get("article", [None])[0], limit=50_000),
        "research_paper": _read_text(artifacts.get("research_paper", [None])[0], limit=100_000),
        "future_directions": _read_text(artifacts.get("future_directions", [None])[0], limit=50_000),
        "modules": modules,
    }

    # Remove empty optional fields for cleanliness
    for key in list(pkg.keys()):
        if pkg[key] in (None, "", [], {}):
            del pkg[key]

    return json.dumps(pkg, indent=2, ensure_ascii=False)


def _resolve_existing_package(artifacts: Dict[str, List[Path]]) -> Optional[str]:
    if not artifacts.get("package_jsons"):
        return None
    for p in sorted(artifacts["package_jsons"], key=lambda x: x.name == "PACKAGE.json", reverse=True):
        try:
            return p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
    return None


async def _ensure_project_archived(
    am: ArchiveManager,
    project_id: str,
    download_timeout: float = 600.0,
) -> tuple:
    """Return (input_dir, output_dir) temp dirs for the project, downloading if needed."""
    if am.project_exists(project_id):
        # Re-extract from existing tarballs in blobs? We don't have direct access.
        # Download again for single-job processing.
        logging.info("[PackageSingle] Project exists in archive; re-downloading for processing")

    key = await get_api_key()
    base_url = get_api_base_url()
    tmpdir = Path(tempfile.mkdtemp(prefix=f"pkg_{project_id}_"))
    input_dir: Optional[Path] = None
    output_dir: Optional[Path] = None

    try:
        input_archive = tmpdir / "input.tar.gz"
        try:
            await stream_download(
                f"{base_url}/project/{project_id}/input",
                input_archive,
                key,
                timeout=download_timeout,
            )
            input_dir = am._extract_tar(input_archive)
        except Exception as e:
            logging.warning("[PackageSingle] Input download/extract failed: %s", e)

        output_archive = tmpdir / "output.tar.gz"
        try:
            await stream_download(
                f"{base_url}/project/{project_id}/result",
                output_archive,
                key,
                timeout=download_timeout,
            )
            output_dir = am._extract_tar(output_archive)
        except Exception as e:
            logging.warning("[PackageSingle] Output download/extract failed: %s", e)

        # Also archive the project if it wasn't already present
        if not am.project_exists(project_id):
            try:
                am.archive_project(
                    project_id=project_id,
                    description="",
                    status="UNKNOWN",
                    created_at=_now(),
                    last_updated=_now(),
                    input_dir=input_dir,
                    output_dir=output_dir,
                )
                logging.info("[PackageSingle] Archived project %s", project_id[:8])
            except Exception as e:
                logging.warning("[PackageSingle] Could not archive project: %s", e)

        return input_dir, output_dir, tmpdir
    except Exception:
        shutil.rmtree(tmpdir, ignore_errors=True)
        raise


def _merge_artifacts(input_artifacts: Dict[str, List[Path]], output_artifacts: Dict[str, List[Path]]) -> Dict[str, List[Path]]:
    merged: Dict[str, List[Path]] = {}
    keys = set(input_artifacts.keys()) | set(output_artifacts.keys())
    for k in keys:
        seen: set = set()
        merged[k] = []
        for p in input_artifacts.get(k, []) + output_artifacts.get(k, []):
            key = str(p.resolve())
            if key in seen:
                continue
            seen.add(key)
            merged[k].append(p)
        merged[k].sort(key=lambda p: str(p))
    return merged


async def package_single_job(
    am: ArchiveManager,
    project_id: str,
    output_path: Optional[Path] = None,
    download_timeout: float = 600.0,
    store_in_db: bool = True,
) -> str:
    """Create or extract a research package for a single project."""
    _setup_logging()
    logging.info("[PackageSingle] Processing project %s", project_id)

    input_dir, output_dir, tmpdir = await _ensure_project_archived(
        am, project_id, download_timeout
    )

    try:
        input_artifacts = _find_artifacts(input_dir) if input_dir else {}
        output_artifacts = _find_artifacts(output_dir) if output_dir else {}
        all_artifacts = _merge_artifacts(input_artifacts, output_artifacts)

        package_json = _resolve_existing_package(all_artifacts)
        if package_json:
            logging.info("[PackageSingle] Found existing PACKAGE.json for %s", project_id[:8])
        else:
            logging.info("[PackageSingle] Building minimal package for %s", project_id[:8])
            package_json = _build_minimal_package(project_id, output_artifacts, all_artifacts)

        if store_in_db:
            try:
                am.store_package(project_id, package_json)
                logging.info("[PackageSingle] Stored package in database for %s", project_id[:8])
            except Exception as e:
                logging.exception("[PackageSingle] Failed to store package in DB: %s", e)
                raise

        if output_path:
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(package_json, encoding="utf-8")
            logging.info("[PackageSingle] Wrote package to %s", output_path)

        return package_json
    finally:
        for d in (input_dir, output_dir):
            if d:
                shutil.rmtree(d, ignore_errors=True)
        shutil.rmtree(tmpdir, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(description="Package a single Aristotle project")
    parser.add_argument("project_id", help="Aristotle project id to package")
    parser.add_argument("--archive-root", default=str(Path(__file__).parent.parent / "Archive"), help="Archive root directory (contains catalog.sqlite + manifests/)")
    parser.add_argument("--blobs-root", default=None, help="Optional separate blobs directory (defaults to archive-root/blobs)")
    parser.add_argument("--output", default=None, help="Path to write the package JSON file")
    parser.add_argument("--download-timeout", type=float, default=600, help="Seconds to wait per archive download")
    parser.add_argument("--no-store", action="store_true", help="Do not store the package in the database")
    args = parser.parse_args()

    am = ArchiveManager(Path(args.archive_root), blobs_root=Path(args.blobs_root) if args.blobs_root else None)
    output_path = Path(args.output) if args.output else None
    package_json = asyncio.run(package_single_job(
        am,
        args.project_id,
        output_path=output_path,
        download_timeout=args.download_timeout,
        store_in_db=not args.no_store,
    ))
    print(package_json[:200] + "..." if len(package_json) > 200 else package_json)


if __name__ == "__main__":
    main()

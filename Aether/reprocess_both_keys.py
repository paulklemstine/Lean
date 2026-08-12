#!/usr/bin/env python3
"""Fetch and reprocess Aristotle projects from configured API keys, strictly ignoring pre-July 2026 projects.
"""

import os
import sys
import json
import glob
import re
import tarfile
import tempfile
import asyncio
import urllib.request
import urllib.error
import datetime
import subprocess
from pathlib import Path

# Add Aether to path
sys.path.insert(0, str(Path(__file__).parent))

from aristotlelib import Project, set_api_key

API_KEYS = [k for k in [os.getenv("ARISTOTLE_API_KEY_1"), os.getenv("ARISTOTLE_API_KEY_2"), os.getenv("ARISTOTLE_API_KEY")] if k]

BASE_URL = "https://aristotle.harmonic.fun/api/v1"
JULY_CUTOFF = "2026-07-01"

def _now():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def derive_artifact_name(title: str, ext: str) -> str:
    base = title.replace(" ", "_").replace("-", "_").lower()
    base = re.sub(r'[^a-z0-9_]', '', base)[:50]
    return f"{base}.{ext}"

def is_before_july(date_str: str) -> bool:
    if not date_str:
        return False
    match = re.search(r'(\d{4}-\d{2}-\d{2})', date_str)
    if match:
        return match.group(1) < JULY_CUTOFF
    return False

async def get_projects_for_key(api_key: str):
    """List projects created on or after July 1, 2026 for an Aristotle API key."""
    set_api_key(api_key)
    july_projects = []
    pagination_key = None
    page = 1

    while True:
        try:
            print(f"[Fetch] Listing projects page {page} for key {api_key[:12]}...")
            projects, pagination_key = await Project.list_projects(
                pagination_key=pagination_key, limit=50
            )
            if not projects:
                break
            
            added_in_page = 0
            for p in projects:
                created_at = getattr(p, "created_at", None) or getattr(p, "created", None) or getattr(p, "date", None)
                if created_at and is_before_july(str(created_at)):
                    continue
                july_projects.append(p)
                added_in_page += 1

            print(f"[Fetch] Page {page} returned {len(projects)} total projects ({added_in_page} in July+ | Total July+: {len(july_projects)})")
            
            if added_in_page == 0 and len(projects) > 0:
                print(f"[Fetch] Reached projects created before July 2026. Stopping pagination for key {api_key[:12]}.")
                break

            if not pagination_key:
                break
            page += 1
        except Exception as e:
            print(f"[Fetch] Error listing page {page}: {e}")
            break

    return july_projects

def download_and_extract_result(project_id: str, api_key: str, dest_dir: Path) -> bool:
    """Download project result tarball from Aristotle and extract to dest_dir."""
    import shutil
    url = f"{BASE_URL}/project/{project_id}/result"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {api_key}"})
    try:
        dest_dir.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(suffix=".tar.gz", delete=False) as tmp:
            tmp_path = Path(tmp.name)
            with urllib.request.urlopen(req, timeout=120) as resp:
                shutil.copyfileobj(resp, tmp)

        with tarfile.open(tmp_path, "r:gz") as tar:
            tar.extractall(path=dest_dir)
        tmp_path.unlink(missing_ok=True)
        return True
    except Exception:
        return False

def purge_pre_july_packages(packages_dir: Path, catalog_packages_dir: Path, docs_dir: Path):
    """Purge packages from disk if their date field is before July 2026."""
    purged_count = 0
    for pdir in [packages_dir, catalog_packages_dir, docs_dir]:
        if not pdir.exists():
            continue
        for pkg_file in pdir.glob("*.json"):
            if pkg_file.name in ("package_index.json", "future_directions.json", "lineage.json"):
                continue
            try:
                data = json.loads(pkg_file.read_text(encoding="utf-8", errors="ignore"))
                if isinstance(data, dict):
                    pkg_date = data.get("date") or data.get("created_at") or ""
                    if is_before_july(str(pkg_date)):
                        pkg_file.unlink(missing_ok=True)
                        purged_count += 1
            except Exception:
                pass
    if purged_count > 0:
        print(f"[Purge] Purged {purged_count} pre-July package files from disk.")

async def main_async():
    repo_root = Path(__file__).parent.parent
    aether_ws = repo_root / "Aether" / ".aether_workspace"
    projects_dir = aether_ws / "projects"
    packages_dir = repo_root / "Packages"
    catalog_packages_dir = repo_root / "Catalog" / "Packages"
    docs_dir = repo_root / "docs"

    packages_dir.mkdir(parents=True, exist_ok=True)
    catalog_packages_dir.mkdir(parents=True, exist_ok=True)

    print(f"[KeyReprocess] Filtering out pre-July 2026 packages...")
    purge_pre_july_packages(packages_dir, catalog_packages_dir, docs_dir)

    # Collect existing package identifiers
    existing_packages = set()
    for pdir in [packages_dir, catalog_packages_dir]:
        for pkg_file in pdir.glob("*.json"):
            if pkg_file.name in ("package_index.json", "future_directions.json", "lineage.json"):
                continue
            try:
                data = json.loads(pkg_file.read_text(encoding="utf-8", errors="ignore"))
                if isinstance(data, dict):
                    if data.get("exp_id"):
                        existing_packages.add(data["exp_id"])
                    if data.get("title"):
                        existing_packages.add(data["title"].strip().lower())
            except Exception:
                pass

    print(f"[KeyReprocess] Starting reprocessing across {len(API_KEYS)} Aristotle API keys (July 2026+ only)...")
    print(f"[KeyReprocess] Currently tracking {len(existing_packages)} existing July+ packages.")

    total_downloaded = 0
    total_reprocessed = 0

    for idx, key in enumerate(API_KEYS, 1):
        print(f"\n==========================================")
        print(f"[KeyReprocess] Processing API Key #{idx}: {key[:14]}...")
        print(f"==========================================")

        projects = await get_projects_for_key(key)
        print(f"[KeyReprocess] Found {len(projects)} July 2026+ projects for Key #{idx}")

        for p in projects:
            pid = getattr(p, "project_id", None) or getattr(p, "id", None)
            if not pid:
                continue

            title_raw = getattr(p, "title", "") or ""
            title_key = title_raw.strip().lower()

            if pid in existing_packages or (title_key and title_key in existing_packages):
                continue

            # Ensure local project dir exists or download result tarball
            pdir = projects_dir / pid
            if not pdir.exists() or not list(pdir.glob("*")):
                print(f"[Fetch] Downloading results for project {pid[:8]}...")
                ok = download_and_extract_result(pid, key, pdir)
                if ok:
                    total_downloaded += 1

            if not pdir.exists():
                continue

            # Parse deliverables
            json_files = list(pdir.glob("*.json"))
            md_files = list(pdir.glob("*.md"))
            py_files = list(pdir.glob("*.py"))
            lean_files = list(pdir.glob("**/*.lean"))

            pkg_json_data = None
            for jf in json_files:
                fname = jf.name.lower()
                if "package" in fname or "self_eval" in fname or jf.name == "PACKAGE.json":
                    try:
                        raw = jf.read_text(encoding="utf-8", errors="ignore")
                        parsed = json.loads(raw)
                        if isinstance(parsed, dict):
                            pkg_json_data = parsed
                            break
                    except Exception:
                        pass

            article = ""
            research_paper = ""
            future_directions = ""
            for mf in md_files:
                mname = mf.name.lower()
                if "article" in mname:
                    article = mf.read_text(encoding="utf-8", errors="ignore")
                elif "research_paper" in mname or "research-paper" in mname:
                    research_paper = mf.read_text(encoding="utf-8", errors="ignore")
                elif "future_directions" in mname or "future-directions" in mname:
                    future_directions = mf.read_text(encoding="utf-8", errors="ignore")

            has_deliverables = pkg_json_data or article or research_paper or py_files or lean_files
            if not has_deliverables:
                continue

            title = (pkg_json_data.get("title") if pkg_json_data else "") or title_raw or f"Research Results {pid[:8]}"
            description = (pkg_json_data.get("description") if pkg_json_data else "") or f"Phase B research package for project {pid[:8]}"

            lean_entries = []
            key_results = []
            for lf in lean_files:
                rel = str(lf.name)
                code = lf.read_text(encoding="utf-8", errors="ignore")
                lean_entries.append({
                    "file": rel,
                    "name": lf.name,
                    "code": code,
                    "theorems": code.count("theorem ") + code.count("lemma "),
                    "description": f"Lean 4 proof file from {lf.name}"
                })
                for line in code.splitlines():
                    if line.strip().startswith("theorem ") or line.strip().startswith("lemma "):
                        key_results.append(line.strip()[:100])

            demos = []
            modules = {}
            for pyf in py_files:
                code = pyf.read_text(encoding="utf-8", errors="ignore")
                entry = {"name": pyf.name, "code": code, "description": f"Python algorithm/demo {pyf.name}"}
                demos.append(entry)
                modules["demo"] = modules.get("demo", "") + f"\n\n# --- {pyf.name}\n" + code

            created_at = getattr(p, "created_at", None) or getattr(p, "created", None) or _now()

            final_pkg = {
                "title": title,
                "description": description[:500],
                "domain": pkg_json_data.get("domain", "Novelty") if pkg_json_data else "Novelty",
                "date": str(created_at),
                "exp_id": pid,
                "authors": ["Aristotle", "Aether"],
                "lean_proofs": lean_entries,
                "key_results": key_results[:30],
                "demos": demos,
                "article": article[:50000],
                "research_paper": research_paper[:100000],
                "future_directions": future_directions[:50000],
                "modules": modules,
            }

            out_filename = derive_artifact_name(title, "json")
            out_path1 = packages_dir / out_filename
            out_path2 = catalog_packages_dir / out_filename
            pkg_str = json.dumps(final_pkg, indent=2, ensure_ascii=False)

            out_path1.write_text(pkg_str, encoding="utf-8")
            out_path2.write_text(pkg_str, encoding="utf-8")
            print(f"[KeyReprocess] Created July+ package: {out_filename} ({len(pkg_str)} bytes) [Key: {key[:8]}]")
            existing_packages.add(pid)
            if title_key:
                existing_packages.add(title_key)
            total_reprocessed += 1

    print(f"\n==========================================")
    print(f"[KeyReprocess] Downloaded {total_downloaded} missing project archives.")
    print(f"[KeyReprocess] Total July 2026+ packages created: {total_reprocessed}")
    print(f"==========================================")

    update_script = packages_dir / "update_index.py"
    if update_script.exists():
        print("[KeyReprocess] Rebuilding website index (update_index.py)...")
        res = subprocess.run([sys.executable, "update_index.py"], cwd=str(packages_dir), capture_output=True, text=True)
        if res.returncode == 0:
            print(f"[KeyReprocess] update_index.py output: {res.stdout.strip()[:200]}")
        else:
            print(f"[KeyReprocess] update_index.py error: {res.stderr[:200]}")

    if docs_dir.exists():
        print("[KeyReprocess] Syncing Packages/ to docs/ for website deployment...")
        subprocess.run(["rsync", "-a", "--delete", str(packages_dir) + "/", str(docs_dir) + "/"], capture_output=True)
        print("[KeyReprocess] Synced to docs/.")

if __name__ == "__main__":
    asyncio.run(main_async())

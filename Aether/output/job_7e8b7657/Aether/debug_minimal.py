#!/usr/bin/env python3
"""Minimal debug: test Project.create_from_directory with daemon setup."""
import asyncio
import os
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

import aristotlelib
from aristotlelib import Project


def setup_project_dir(project_dir: Path):
    catalog_root = Path('/home/raver1975/lean/Catalog')
    if project_dir.exists():
        shutil.rmtree(project_dir)
    project_dir.mkdir(parents=True, exist_ok=True)

    def ignore_patterns(src, names):
        return {
            n for n in names
            if n.startswith(".") or n in {
                "aristotle_results", "__pycache__", "*.pyc", "*.tar.gz",
                "result.tar.gz", "result_extracted", "logs", "output",
                "jobs", "*.output", "node_modules", "build", "lake-packages",
                ".lake", "lakefile.olean", "Manifesto",
                "CATALOG.md", "DECLARATION_INDEX.md", "ARISTOTLE_SUMMARY.md",
            } or n.endswith(".output")
        }

    for item in catalog_root.iterdir():
        if item.name in {"aristotle_results", "__pycache__", "logs", "output",
                           "jobs", "node_modules", "build", "lake-packages",
                           ".lake", "lakefile.olean", "Manifesto",
                           "CATALOG.md", "DECLARATION_INDEX.md", "ARISTOTLE_SUMMARY.md"}:
            continue
        dest = project_dir / item.name
        if item.is_dir():
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(item, dest, ignore=ignore_patterns)
        else:
            shutil.copy2(item, dest)

    main_file = project_dir / "Main.lean"
    main_file.write_text("""import Mathlib\n\ntheorem tropical_kolmogorov_bound {X : Type*} [Inhabited X] :\n    True := by\n  sorry""", encoding="utf-8")

    catalog_lakefile = catalog_root / "lakefile.toml"
    if catalog_lakefile.exists():
        shutil.copy2(catalog_lakefile, project_dir / "lakefile.toml")
    catalog_toolchain = catalog_root / "lean-toolchain"
    if catalog_toolchain.exists():
        shutil.copy2(catalog_toolchain, project_dir / "lean-toolchain")


async def main():
    api_key = os.environ.get("ARISTOTLE_API_KEY", "")
    print(f"API key present: {bool(api_key)}")
    aristotlelib.set_api_key(api_key)

    project_dir = Path("output/job_minimal_debug")
    setup_project_dir(project_dir)
    print(f"Project dir setup complete: {project_dir}")

    prompt = "Fill in all the sorries in Main.lean. Provide complete formal proofs using standard mathlib tactics. Do not modify definitions or theorem statements. You have the full Catalog source tree as context."

    try:
        print("Creating project...")
        project = await Project.create_from_directory(
            prompt=prompt,
            project_dir=str(project_dir),
        )
        print(f"Project created: {project.project_id} ({project.status})")
        print("SUCCESS")
    except Exception as e:
        print(f"FAILED: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(main())

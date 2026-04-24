#!/usr/bin/env python3
"""Dispatch remaining sci-fi theorems to Aristotle one at a time."""

import asyncio
import os
import tarfile
from pathlib import Path

import aristotlelib
from aristotlelib import Project, ProjectStatus

# Files to dispatch (excluding TropicalFirewall which is already proven)
THEOREMS = [
    "ChronologicalProtection.lean",
    "SETIOrthogonality.lean",
    "MindUploading.lean",
    "PadicHyperdrive.lean",
]

async def dispatch_theorem(file_name: str) -> bool:
    source_file = Path("/home/raver1975/lean/Catalog/Speculative/SciFi") / file_name
    if not source_file.exists():
        print(f"[ERROR] File not found: {source_file}")
        return False

    print(f"\n{'='*60}")
    print(f"[DISPATCH] {file_name}")
    print(f"{'='*60}")

    lean_source = source_file.read_text(encoding="utf-8")
    import shutil
    catalog_root = Path("/home/raver1975/lean/Catalog")
    project_dir = Path(f"./aristotle_results/job_{source_file.stem}")
    project_dir.mkdir(parents=True, exist_ok=True)

    # Copy full Catalog into project directory for context
    def ignore_patterns(src, names):
        return {n for n in names if n.startswith(".") or n in {
            "aristotle_results", "__pycache__", "*.pyc", "*.tar.gz",
            "result.tar.gz", "result_extracted", "logs", "output",
            "jobs", "*.output", "node_modules", "build", "lake-packages",
            ".lake", "lakefile.olean", "Manifesto",
        } or n.endswith(".output")}

    for item in catalog_root.iterdir():
        dest = project_dir / item.name
        if item.is_dir():
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(item, dest, ignore=ignore_patterns)
        else:
            shutil.copy2(item, dest)

    # Write the target theorem as Main.lean at project root
    (project_dir / "Main.lean").write_text(lean_source, encoding="utf-8")

    try:
        project = await Project.create_from_directory(
            prompt=f"Fill in all the sorries in {file_name}. Provide complete formal proofs using standard mathlib tactics. Do not modify definitions or theorem statements. You have the full Catalog source tree as context.",
            project_dir=str(project_dir),
        )
        print(f"[DISPATCH] Project created: {project.project_id}")

        result_path = await project.wait_for_completion(
            destination=str(project_dir / "result.tar.gz"),
            polling_interval_seconds=30,
        )

        await project.refresh()
        print(f"[DISPATCH] Status: {project.status.value}")

        if project.status == ProjectStatus.COMPLETE and result_path:
            # Extract proof
            extract_dir = project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            with tarfile.open(result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            lean_files = list(extract_dir.rglob("*.lean"))
            if lean_files:
                main_file = next((f for f in lean_files if f.name == "Main.lean"), max(lean_files, key=lambda f: f.stat().st_size))
                proof = main_file.read_text(encoding="utf-8")
                source_file.write_text(proof, encoding="utf-8")
                print(f"[INTEGRATE] Proof applied to {file_name}")
                return True

        return False

    except Exception as e:
        print(f"[ERROR] {file_name}: {e}")
        return False


async def main():
    for theorem in THEOREMS:
        success = await dispatch_theorem(theorem)
        if not success:
            print(f"[WARN] Failed to prove {theorem}, continuing...")

    print("\n[BATCH] All theorems dispatched!")


if __name__ == "__main__":
    asyncio.run(main())

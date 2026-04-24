#!/usr/bin/env python3
"""Batch dispatcher: Submit all sci-fi theorems to Aristotle in parallel.

Usage:
    python3 batch_dispatch.py --target-dir ../Speculative/SciFi/
"""

import asyncio
import argparse
import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

import aristotlelib
from aristotlelib import Project, ProjectStatus


@dataclass
class DispatchResult:
    file: str
    project_id: str
    status: str
    proof: Optional[str] = None
    error: Optional[str] = None


async def dispatch_file(lean_file: Path, output_dir: Path) -> DispatchResult:
    """Submit a single .lean file to Aristotle and wait for completion."""
    file_name = lean_file.name
    print(f"[DISPATCH] Submitting {file_name}...")

    # Create project directory
    project_dir = output_dir / f"job_{lean_file.stem}"
    project_dir.mkdir(parents=True, exist_ok=True)

    # Read and prepare the Lean source
    lean_source = lean_file.read_text(encoding="utf-8")

    # Write the Lean file
    main_file = project_dir / "Main.lean"
    main_file.write_text(lean_source, encoding="utf-8")

    # Write lakefile.toml
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

    # Write lean-toolchain
    toolchain = project_dir / "lean-toolchain"
    if not toolchain.exists():
        toolchain.write_text("leanprover/lean4:v4.28.0\n", encoding="utf-8")

    # Submit to Aristotle
    try:
        project = await Project.create_from_directory(
            prompt=f"Fill in all the sorries in {file_name}. Provide complete formal proofs. Use standard mathlib tactics.",
            project_dir=str(project_dir),
        )
        print(f"[DISPATCH] {file_name}: Project {project.project_id} ({project.status.value})")

        # Wait for completion
        result_path = await project.wait_for_completion(
            destination=str(project_dir / "result.tar.gz"),
            polling_interval_seconds=30,
        )

        await project.refresh()
        print(f"[DISPATCH] {file_name}: Complete ({project.status.value})")

        if project.status == ProjectStatus.COMPLETE:
            # Extract proof
            proof = None
            if result_path:
                import tarfile
                extract_dir = project_dir / "result_extracted"
                extract_dir.mkdir(exist_ok=True)
                with tarfile.open(result_path, "r:gz") as tar:
                    tar.extractall(path=extract_dir)
                lean_files = list(extract_dir.rglob("*.lean"))
                if lean_files:
                    main = next((f for f in lean_files if f.name == "Main.lean"), max(lean_files, key=lambda f: f.stat().st_size))
                    proof = main.read_text(encoding="utf-8")

            return DispatchResult(
                file=str(lean_file),
                project_id=project.project_id,
                status="COMPLETE",
                proof=proof,
            )
        else:
            return DispatchResult(
                file=str(lean_file),
                project_id=project.project_id,
                status=project.status.value,
                error=f"Project ended with status: {project.status.value}",
            )

    except Exception as e:
        return DispatchResult(
            file=str(lean_file),
            project_id="",
            status="FAILED",
            error=str(e),
        )


async def main():
    parser = argparse.ArgumentParser(description="Batch dispatch sci-fi theorems to Aristotle")
    parser.add_argument("--target-dir", default="../Speculative/SciFi", help="Directory with .lean files")
    parser.add_argument("--output-dir", default="./aristotle_results", help="Output directory")
    parser.add_argument("--max-concurrent", type=int, default=2, help="Max concurrent jobs")
    parser.add_argument("--filter", default="AutoGen", help="Filter files containing this substring")

    args = parser.parse_args()

    target_dir = Path(args.target_dir)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Find all .lean files
    lean_files = sorted(target_dir.glob("*.lean"))
    if args.filter:
        lean_files = [f for f in lean_files if args.filter not in str(f)]

    print(f"[BATCH] Found {len(lean_files)} files to dispatch")
    for f in lean_files:
        print(f"  - {f.name}")

    # Dispatch with semaphore for concurrency control
    semaphore = asyncio.Semaphore(args.max_concurrent)

    async def dispatch_with_limit(lean_file: Path) -> DispatchResult:
        async with semaphore:
            return await dispatch_file(lean_file, output_dir)

    results = await asyncio.gather(*[dispatch_with_limit(f) for f in lean_files])

    # Save results
    results_file = output_dir / "results.json"
    with open(results_file, "w", encoding="utf-8") as f:
        json.dump([{
            "file": r.file,
            "project_id": r.project_id,
            "status": r.status,
            "error": r.error,
            "proof_length": len(r.proof) if r.proof else 0,
        } for r in results], f, indent=2)

    print(f"\n[BATCH] Results saved to {results_file}")
    print(f"  Complete: {sum(1 for r in results if r.status == 'COMPLETE')}")
    print(f"  Failed: {sum(1 for r in results if r.status == 'FAILED')}")

    # Apply successful proofs back to catalog
    for r in results:
        if r.status == "COMPLETE" and r.proof:
            source_file = Path(r.file)
            source_file.write_text(r.proof, encoding="utf-8")
            print(f"[INTEGRATE] Updated {source_file.name}")


if __name__ == "__main__":
    asyncio.run(main())

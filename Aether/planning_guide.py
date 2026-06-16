#!/usr/bin/env python3
"""Interactive planning questionnaire for Aether archive/backfill work.

Usage:
    cd Aether && python3 planning_guide.py

Asks a short series of questions and emits a concrete command or writes a
run script to .aether_workspace/run_plan.sh.
"""

import argparse
import os
import platform
import sys
from pathlib import Path
from typing import Dict, List, Optional


def _ask(question: str, options: List[str], default: Optional[str] = None) -> str:
    print(f"\n{question}")
    for i, opt in enumerate(options, 1):
        marker = "*" if opt == default else " "
        print(f"  {marker} {i}. {opt}")
    prompt = "Choice"
    if default:
        prompt += f" [default: {default}]"
    prompt += ": "
    while True:
        raw = input(prompt).strip()
        if not raw and default:
            return default
        if raw.isdigit() and 1 <= int(raw) <= len(options):
            return options[int(raw) - 1]
        lower = raw.lower()
        for opt in options:
            if opt.lower().startswith(lower):
                return opt
        print("Please enter a number or the start of one of the options.")


def _ask_yes_no(question: str, default: bool = False) -> bool:
    default_text = "Y/n" if default else "y/N"
    while True:
        raw = input(f"{question} [{default_text}]: ").strip().lower()
        if not raw:
            return default
        if raw in ("y", "yes"):
            return True
        if raw in ("n", "no"):
            return False
        print("Please answer yes or no.")


def _ask_text(question: str, default: str = "") -> str:
    raw = input(f"{question}: ").strip()
    return raw if raw else default


def _detect_ram_mb() -> int:
    try:
        import psutil
        total = psutil.virtual_memory().total
        return int(total / (1024 * 1024))
    except Exception:
        return 8192


def _is_wsl() -> bool:
    return "microsoft" in platform.release().lower() or "wsl" in platform.release().lower()


def run_interactive(write_script: bool = True, script_path: Optional[Path] = None) -> None:
    print("=" * 60)
    print("Aether Archive / Backfill Planning Guide")
    print("=" * 60)

    goal = _ask(
        "What is your primary goal?",
        [
            "Backfill all past Aristotle jobs into the archive",
            "Package a single job id",
            "Build a clean catalog from archived theorems",
            "Reprocess existing archive for packages/theorems",
            "All of the above",
        ],
        default="Backfill all past Aristotle jobs into the archive",
    )

    total_ram = _detect_ram_mb()
    if _is_wsl():
        print(f"\nDetected WSL2 with ~{total_ram} MB visible RAM.")
    else:
        print(f"\nDetected ~{total_ram} MB RAM.")

    memory_choice = _ask(
        "How much memory (MB) should the backfill process be capped at?",
        [
            f"{max(1024, int(total_ram * 0.65))} (conservative)",
            f"{max(1024, int(total_ram * 0.8))} (balanced)",
            f"{max(1024, int(total_ram * 0.95))} (aggressive)",
            "Custom",
        ],
        default=f"{max(1024, int(total_ram * 0.8))} (balanced)",
    )
    if memory_choice == "Custom":
        max_memory_mb = int(_ask_text("Enter cap in MB", str(int(total_ram * 0.8))))
    else:
        max_memory_mb = int(memory_choice.split()[0])

    domain_filter = _ask_text("Target domain filter (leave blank for all)", "")
    reprocess = _ask_yes_no("Reprocess already-archived projects for packages and theorem metadata?", default=False)
    write_files = _ask_yes_no("Also write package files to disk (not just database)?", default=False)
    dry_run = _ask_yes_no("Dry-run mode (print commands but do not execute)?", default=True)

    commands: List[str] = []
    archive_root = "../Archive"

    if goal in ("Backfill all past Aristotle jobs into the archive", "All of the above"):
        cmd = (
            f"cd Aether && python3 backfill_aristotle_archive.py "
            f"--archive-root {archive_root} "
            f"--max-memory-mb {max_memory_mb} "
            f"--download-timeout 600 "
            f"--log .aether_workspace/backfill_aristotle_archive.log"
        )
        if reprocess:
            cmd += " --reprocess-existing"
        commands.append(cmd)

    if goal in ("Package a single job id", "All of the above"):
        job_id = _ask_text("Enter the Aristotle project/job id")
        out_flag = ""
        if write_files:
            out_flag = f" --output {archive_root}/packages/{job_id}.package.json"
        commands.append(
            f"cd Aether && python3 package_single_job.py {job_id} "
            f"--archive-root {archive_root}{out_flag}"
        )

    if goal in ("Reprocess existing archive for packages/theorems", "All of the above") and not reprocess:
        commands.append(
            f"cd Aether && python3 backfill_aristotle_archive.py "
            f"--archive-root {archive_root} "
            f"--reprocess-existing "
            f"--max-memory-mb {max_memory_mb}"
        )

    if goal in ("Build a clean catalog from archived theorems", "All of the above"):
        domain_arg = f" --domain {domain_filter}" if domain_filter else ""
        commands.append(
            f"cd Aether && python3 -c \"import sys; "
            f"sys.path.insert(0,'.'); "
            f"from archive_manager import ArchiveManager; "
            f"am=ArchiveManager(Path('{archive_root}')); "
            f"print(list(am._connect().execute('SELECT domain, COUNT(*) FROM theorems GROUP BY domain'))); "
            f"print('packages', am.get_stats().get('packages'))\"{domain_arg}"
        )

    print("\n" + "=" * 60)
    print("Recommended commands")
    print("=" * 60)
    for cmd in commands:
        print(f"\n{cmd}")

    if dry_run:
        print("\n[DRY RUN] Commands printed above. Re-run with --no-dry-run to execute.")
    else:
        for cmd in commands:
            print(f"\nExecuting: {cmd}")
            os.system(cmd)

    if write_script:
        sp = script_path or Path("Aether/.aether_workspace/run_plan.sh")
        sp.parent.mkdir(parents=True, exist_ok=True)
        sp.write_text("#!/bin/bash\nset -e\n\n" + "\n\n".join(commands) + "\n", encoding="utf-8")
        sp.chmod(0o755)
        print(f"\nWrote plan script: {sp}")
        print("Run it later with:")
        print(f"  bash {sp}")

    if _is_wsl():
        print("\nWSL2 memory reminder:")
        print("  Add to %UserProfile%\\.wslconfig and run `wsl --shutdown`:")
        print(f"  [wsl2]\n  memory={max(1024, int(total_ram * 0.9))}MB\n  swap=8GB")


def main():
    parser = argparse.ArgumentParser(description="Aether archive/backfill planning guide")
    parser.add_argument("--no-dry-run", action="store_true", help="Execute recommended commands")
    parser.add_argument("--script", default="Aether/.aether_workspace/run_plan.sh", help="Path for generated run script")
    args = parser.parse_args()

    # Map argparse dry-run flag into function behaviour
    run_interactive(
        write_script=True,
        script_path=Path(args.script),
    )
    if args.no_dry_run:
        print("\n[Plan] --no-dry-run requested; script was generated. Execute it with:")
        print(f"  bash {args.script}")


if __name__ == "__main__":
    main()

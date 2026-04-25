#!/usr/bin/env python3
"""Manual Dispatch: Generate Aristotle-ready prompts for web UI copy-paste.

Since the Aristotle API endpoint is not publicly accessible, this module
produces formatted prompts and Lean files that can be submitted manually
through the Aristotle web dashboard at https://aristotle.harmonic.fun/dashboard

Usage:
    python3 manual_dispatch.py --proposal logs/proposals.json --index 0
    python3 manual_dispatch.py --all --output-dir manual_jobs/
"""

import argparse
import json
import textwrap
from pathlib import Path
from typing import Dict, List, Any


def format_aristotle_prompt(proposal: Dict[str, Any]) -> str:
    """Format a proposal into a copy-paste ready Aristotle prompt."""
    title = proposal.get("title", "Untitled")
    domain = proposal.get("domain", "Unknown")
    difficulty = proposal.get("difficulty", "unknown")
    narrative = proposal.get("narrative", "")
    lean_code = proposal.get("conjecture_lean", "")
    concepts = proposal.get("concept_combination", [])

    prompt = f"""# Research Brief: {title}

## Domain
{domain}

## Difficulty
{difficulty}

## Concepts
{', '.join(concepts) if concepts else 'N/A'}

## Narrative
{narrative}

## Task
Please prove the following theorem in Lean 4 using mathlib4 v4.28.0.

```lean
import Mathlib

{lean_code}
```

## Requirements
1. Provide a complete formal proof (no `sorry` remaining).
2. Do not change the theorem statement unless it is false.
3. If false, explain why and suggest a corrected statement.
4. Include proof strategy comments.
5. Use standard mathlib tactics: `ring`, `linarith`, `simp`, `exact`, `apply`, `intro`, `cases`, `rw`, `norm_num`, etc.

## Output Format
Return the complete Lean 4 file in a code block.
"""
    return prompt


def write_manual_job(proposal: Dict[str, Any], output_dir: Path) -> Path:
    """Write a manual job package to disk."""
    exp_id = proposal.get("experiment_id", "unknown")
    job_dir = output_dir / f"job_{exp_id}"
    job_dir.mkdir(parents=True, exist_ok=True)

    # Write the prompt
    prompt_file = job_dir / "prompt.md"
    prompt_file.write_text(format_aristotle_prompt(proposal), encoding="utf-8")

    # Write the Lean file (standalone)
    lean_file = job_dir / "Main.lean"
    lean_content = f"""import Mathlib

-- Research Proposal: {proposal.get('title', '')}
-- Domain: {proposal.get('domain', '')}
-- Difficulty: {proposal.get('difficulty', '')}

{proposal.get('conjecture_lean', '')}
"""
    lean_file.write_text(lean_content, encoding="utf-8")

    # Write lakefile.toml
    lakefile = job_dir / "lakefile.toml"
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
    toolchain = job_dir / "lean-toolchain"
    toolchain.write_text("leanprover/lean4:v4.28.0\n", encoding="utf-8")

    return job_dir


def main():
    parser = argparse.ArgumentParser(description="Generate manual Aristotle dispatch packages")
    parser.add_argument("--proposals", default="logs/proposals.json", help="Path to proposals JSON")
    parser.add_argument("--output-dir", default="manual_jobs", help="Output directory")
    parser.add_argument("--index", type=int, help="Only generate for proposal at index")
    parser.add_argument("--all", action="store_true", help="Generate for all proposals")
    parser.add_argument("--list", action="store_true", help="List proposals with indices")

    args = parser.parse_args()

    proposals_path = Path(args.proposals)
    if not proposals_path.exists():
        print(f"No proposals found at {proposals_path}")
        print("Run: python3 -m aether.engine --mode generate first")
        return

    with open(proposals_path, "r", encoding="utf-8") as f:
        proposals = json.load(f)

    if args.list:
        print(f"Found {len(proposals)} proposals:")
        for i, p in enumerate(proposals):
            print(f"  [{i}] {p.get('title', 'Untitled')} ({p.get('difficulty', '?')}) - {p.get('domain', '?')}")
        return

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    if args.index is not None:
        if 0 <= args.index < len(proposals):
            job_dir = write_manual_job(proposals[args.index], output_dir)
            print(f"Manual job written to: {job_dir}")
            print(f"\n--- PROMPT (copy-paste into Aristotle) ---\n")
            print(format_aristotle_prompt(proposals[args.index]))
        else:
            print(f"Invalid index {args.index}. Use --list to see available proposals.")
    elif args.all:
        for p in proposals:
            job_dir = write_manual_job(p, output_dir)
            print(f"  {job_dir}")
        print(f"\nGenerated {len(proposals)} manual job packages in {output_dir}")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()

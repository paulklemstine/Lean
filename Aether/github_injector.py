#!/usr/bin/env python3
"""
GitHub Injector: Fetches future directions submitted via GitHub Issues
and closes them once they are processed.
"""

import subprocess
import json
import uuid
import datetime
from pathlib import Path
import os
import sys

def run_gh_command(args):
    """Run a gh CLI command and return its stdout as a string or parsed JSON."""
    try:
        repo_root = Path(__file__).resolve().parent.parent
        result = subprocess.run(
            ["gh"] + args,
            capture_output=True,
            text=True,
            check=True,
            cwd=str(repo_root)
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"[GitHub Injector] Error running gh {' '.join(args)}: {e.stderr}", file=sys.stderr)
        return None
    except FileNotFoundError:
        print("[GitHub Injector] Error: gh CLI is not installed or not in PATH.", file=sys.stderr)
        return None

def fetch_injected_directions():
    """Fetch open issues with the 'approved-direction' label."""
    print("[GitHub Injector] Checking for approved directions from GitHub issues...")
    output = run_gh_command(["issue", "list", "--state", "open", "--label", "approved-direction", "--json", "number,title,body"])
    
    if not output:
        return []
    
    try:
        issues = json.loads(output)
        return issues
    except json.JSONDecodeError:
        print("[GitHub Injector] Failed to parse gh CLI output as JSON.", file=sys.stderr)
        return []

def inject_directions_into_memory(workspace_path: Path):
    """Fetch open issues and append them to future_directions.json if they aren't already there."""
    issues = fetch_injected_directions()
    if not issues:
        return 0

    candidates = [
        workspace_path / "future_directions.json",
        workspace_path / "Packages" / "future_directions.json",
        workspace_path.parent / "Packages" / "future_directions.json",
        workspace_path.parent.parent / "Packages" / "future_directions.json",
        Path("Packages/future_directions.json"),
    ]
    fd_file = None
    for candidate in candidates:
        if candidate.exists():
            fd_file = candidate
            break

    if not fd_file:
        print(f"[GitHub Injector] Warning: could not locate future_directions.json.")
        return 0

    try:
        data = json.loads(fd_file.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"[GitHub Injector] Failed to load future_directions.json: {e}", file=sys.stderr)
        return 0

    directions_list = []
    if isinstance(data, list):
        directions_list = data
    elif isinstance(data, dict):
        directions_list = data.get("directions", [])

    # Keep track of existing issue numbers to avoid duplicates
    existing_issues = set()
    for d in directions_list:
        # Only count live (non-pruned) directions — pruned directions
        # should not block re-injection of their GitHub issues.
        if (d.get("source") == "github_injection"
                and "github_issue" in d
                and d.get("status") != "pruned"):
            existing_issues.add(d["github_issue"])

    injected_count = 0
    for issue in issues:
        issue_number = issue.get("number")
        if issue_number in existing_issues:
            continue
            
        title = issue.get("title", "").replace("Injected Direction:", "").strip()
        body = issue.get("body", "")
        
        # Generate a unique ID
        max_num = -1
        for d in directions_list:
            did = d.get("id", "")
            if did.startswith("fd_"):
                try:
                    num = int(did[3:])
                    if num > max_num: max_num = num
                except ValueError:
                    pass
        new_id = f"fd_{max_num + 1:04d}"
        
        new_direction = {
            "id": new_id,
            "title": title,
            "domains": ["Novelty"],  # Default domain, will be bypassed anyway
            "description": body,
            "priority_score": 1000.0,  # Massively high priority
            "status": "available",
            "source": "github_injection",
            "github_issue": issue_number,
            "source_exp_id": "github",
            "source_path": "github",
            "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "attempt_count": 0,
            "ambition_level": "grand_challenge"
        }
        
        directions_list.append(new_direction)
        existing_issues.add(issue_number)
        injected_count += 1
        print(f"[GitHub Injector] Injected new direction: {title} (Issue #{issue_number})")

    if injected_count > 0:
        if isinstance(data, list):
            data = directions_list
        else:
            data["directions"] = directions_list
        
        fd_file.write_text(json.dumps(data, indent=2), encoding="utf-8")
        print(f"[GitHub Injector] Successfully injected {injected_count} directions into memory.")

    return injected_count

def close_injected_direction_with_comment(issue_number: int, comment: str):
    """Close the GitHub issue and leave a comment with research results."""
    print(f"[GitHub Injector] Closing issue #{issue_number} with results...")
    # First add a comment
    run_gh_command(["issue", "comment", str(issue_number), "-b", comment])
    # Then close the issue
    run_gh_command(["issue", "close", str(issue_number)])
    print(f"[GitHub Injector] Closed issue #{issue_number}.")

if __name__ == "__main__":
    # Simple CLI for testing
    workspace = Path(__file__).parent / ".aether_workspace"
    inject_directions_into_memory(workspace)

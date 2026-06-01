#!/usr/bin/env python3
"""GitAutomator: Automated git add, commit, push for research cycles.

Extracted from cycle_master.py for reuse across Aether v3 modules.
"""

import subprocess
import textwrap
from pathlib import Path
from typing import List, Tuple


class GitAutomator:
    """Automate git add, commit, push."""

    def __init__(self, repo_root: Path):
        self.repo_root = Path(repo_root)

    def _run(self, cmd: List[str], cwd: Path = None, timeout: int = 60) -> Tuple[bool, str]:
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd or self.repo_root,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
            return result.returncode == 0, result.stdout + result.stderr
        except Exception as e:
            return False, str(e)

    def status(self) -> str:
        ok, out = self._run(["git", "status", "--short"])
        return out

    def add(self, pathspec: str) -> bool:
        ok, _ = self._run(["git", "add", pathspec])
        return ok

    def commit(self, message: str) -> bool:
        ok, out = self._run(["git", "commit", "-m", message])
        return ok

    def push(self, remote: str = "origin", branch: str = "master") -> bool:
        # Pull with rebase first to handle remote divergence from concurrent pushes
        pull_ok, pull_out = self._run(
            ["git", "pull", "--rebase", remote, branch], timeout=120
        )
        if not pull_ok:
            # Rebase conflict — abort and report failure rather than corrupting files
            self._run(["git", "rebase", "--abort"])
            return False
        ok, out = self._run(["git", "push", remote, branch], timeout=120)
        if not ok:
            ok, out = self._run(["git", "push", "-u", remote, branch], timeout=120)
        return ok

    def create_commit_for_cycle(
        self,
        cycle_num: int,
        domain: str,
        concept_title: str,
        changed_files: List[str],
        artifacts: List[str],
        version: str = "v3",
    ) -> bool:
        """Create a nicely formatted commit for a research cycle."""
        # Add specific files instead of everything
        for f in changed_files:
            self.add(f)
        self.add(".aether_workspace/")

        changed_list = "\n".join(f"  - {c}" for c in changed_files[:10])
        if len(changed_files) > 10:
            changed_list += f"\n  - ... and {len(changed_files) - 10} more"

        artifact_list = "\n".join(f"  - {a}" for a in artifacts[:5])

        message = textwrap.dedent(f"""\
            AETHER {version} cycle #{cycle_num}: {concept_title}

            Domain: {domain}
            Concept: {concept_title}

            New / changed files:
            {changed_list}

            Artifacts:
            {artifact_list}

            Co-Authored-By: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
        """)

        return self.commit(message)
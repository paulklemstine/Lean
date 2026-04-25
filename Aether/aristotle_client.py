#!/usr/bin/env python3
"""AristotleDispatcher: Submit proposals to Harmonic's Aristotle agent.

Manages the proof lifecycle: package, submit, poll, receive, validate.
Supports DEMO mode for testing without actual API calls.
"""

import json
import os
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Dict, Any

import requests


@dataclass
class AristotleResult:
    """Result from an Aristotle proof job."""
    job_id: str
    status: str  # pending, running, completed, failed, timeout, demo
    lean_source: Optional[str] = None
    proof_explanation: Optional[str] = None
    sorry_count: int = 0
    error_message: Optional[str] = None
    latency_seconds: float = 0.0


class AristotleDispatcher:
    """Client for Harmonic's Aristotle verified reasoning API."""

    def __init__(self, config: Dict[str, Any]):
        self.api_base = config.get("api_base_url", "https://aristotle.harmonic.fun/api/v1")
        self.api_key = config.get("api_key") or os.environ.get("ARISTOTLE_API_KEY", "")
        self.timeout = config.get("timeout_seconds", 300)
        self.max_retries = config.get("max_retries", 3)
        self.backoff_base = config.get("retry_backoff_base", 2.0)
        self.concurrent = config.get("concurrent_jobs", 2)
        self.demo_mode = config.get("demo_mode", False)

        if not self.api_key and not self.demo_mode:
            print("[Aristotle] WARNING: API key not configured and demo_mode is False. Set ARISTOTLE_API_KEY or enable demo_mode.")

        self.session = requests.Session()
        if self.api_key:
            self.session.headers.update({
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            })

    def _post(self, endpoint: str, payload: Dict[str, Any], retries: int = 0) -> Dict[str, Any]:
        """POST with retry logic."""
        if self.demo_mode:
            return {"demo": True, "status": "queued", "job_id": f"demo_{int(time.time())}"}

        url = f"{self.api_base}/{endpoint}"
        try:
            resp = self.session.post(url, json=payload, timeout=30)
            resp.raise_for_status()
            return resp.json()
        except requests.exceptions.RequestException as e:
            if retries < self.max_retries:
                wait = self.backoff_base ** retries
                time.sleep(wait)
                return self._post(endpoint, payload, retries + 1)
            return {"error": str(e), "status": "failed"}

    def _get(self, endpoint: str, retries: int = 0) -> Dict[str, Any]:
        """GET with retry logic."""
        if self.demo_mode:
            return {"demo": True, "status": "completed", "lean_code": "-- Demo mode: no actual proof generated\nimport Mathlib\n\n-- TODO: Replace with real Aristotle proof\nsorry", "sorry_count": 1}

        url = f"{self.api_base}/{endpoint}"
        try:
            resp = self.session.get(url, timeout=30)
            resp.raise_for_status()
            return resp.json()
        except requests.exceptions.RequestException as e:
            if retries < self.max_retries:
                wait = self.backoff_base ** retries
                time.sleep(wait)
                return self._get(endpoint, retries + 1)
            return {"error": str(e), "status": "failed"}

    def submit_job(self, title: str, prompt: str, lean_source: str) -> Optional[str]:
        """Submit a proof job to Aristotle. Returns job ID."""
        payload = {
            "title": title,
            "prompt": prompt,
            "language": "lean4",
            "code": lean_source,
            "mathlib_version": "v4.28.0",
            "verification_level": "theorem",
        }

        result = self._post("jobs", payload)
        if "error" in result:
            print(f"[Aristotle] Submission failed: {result['error']}")
            return None
        return result.get("job_id")

    def poll_job(self, job_id: str) -> AristotleResult:
        """Poll for job completion."""
        start = time.time()
        elapsed = 0.0

        while elapsed < self.timeout:
            result = self._get(f"jobs/{job_id}")
            status = result.get("status", "unknown")

            if status in ("completed", "failed", "error"):
                return AristotleResult(
                    job_id=job_id,
                    status=status,
                    lean_source=result.get("lean_code"),
                    proof_explanation=result.get("explanation"),
                    sorry_count=result.get("sorry_count", 0),
                    error_message=result.get("error"),
                    latency_seconds=time.time() - start,
                )

            time.sleep(5)
            elapsed = time.time() - start

        return AristotleResult(
            job_id=job_id,
            status="timeout",
            latency_seconds=time.time() - start,
        )

    def run_sync(self, title: str, prompt: str, lean_source: str) -> AristotleResult:
        """Submit and poll until completion."""
        if self.demo_mode:
            print(f"[Aristotle] DEMO MODE: Simulating proof for '{title}'")
            time.sleep(0.5)  # Simulate latency
            return AristotleResult(
                job_id=f"demo_{title}",
                status="demo",
                lean_source=lean_source + "\n\n-- DEMO MODE: Proof not actually generated\n-- In production, Aristotle would fill the sorry here\n",
                sorry_count=lean_source.count("sorry"),
                latency_seconds=0.5,
            )

        job_id = self.submit_job(title, prompt, lean_source)
        if job_id is None:
            return AristotleResult(
                job_id="",
                status="failed",
                error_message="Failed to submit job",
            )
        return self.poll_job(job_id)

    def package_lean_project(self, proposal: Any, output_dir: Path) -> Path:
        """Package a proposal into a minimal Lean 4 project for Aristotle."""
        from generator import ResearchProposal
        proposal: ResearchProposal

        project_dir = output_dir / f"job_{proposal.experiment_id}"
        project_dir.mkdir(parents=True, exist_ok=True)

        # Write the Lean file
        lean_file = project_dir / "Main.lean"
        imports = "\n".join(proposal.context_imports)
        context = "\n\n".join(proposal.context_theorems)

        content = f"""{imports}

{context}

-- Research Proposal: {proposal.title}
-- Domain: {proposal.domain}
-- Arc: {proposal.arc_name}
-- Difficulty: {proposal.difficulty}

{proposal.conjecture_lean}
"""
        lean_file.write_text(content, encoding="utf-8")

        # Write lakefile.toml
        lakefile = project_dir / "lakefile.toml"
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
        toolchain.write_text("leanprover/lean4:v4.28.0\n", encoding="utf-8")

        return project_dir

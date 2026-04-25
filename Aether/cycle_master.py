#!/usr/bin/env python3
"""CycleMaster: Continuous autonomous research engine.

Orchestrates a never-ending loop:
1. PI-AGENT analyzes past experiments and evolves better Aristotle prompts
2. PI-AGENT generates a novel breakthrough concept
3. Lean-only catalog is built and dispatched to Aristotle
4. When Aristotle returns results, PI-AGENT analyzes what changed
5. Integration agent merges changes back into Catalog
6. Git commit + push
7. Repeat

Usage:
    python3 cycle_master.py --workspace ../workspace
    python3 cycle_master.py --single-cycle --dry-run
"""

import argparse
import asyncio
import difflib
import json
import os
import re
import shutil
import subprocess
import sys
import textwrap
import time
import uuid
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Any

import yaml

# Aether subsystems
from pi_agent_client import PiAgentClient, ResearchConcept
from prompt_engine import PromptEngine, ArtifactRequests
from aristotle_sdk_client import AristotleSDKClient
from lean_catalog_builder import LeanCatalogBuilder
from smart_integrator import SmartIntegrator
from telemetry import TelemetryLogger, ExperimentRecord

from research_memory import ResearchMemory, ExperimentRecord as MemoryExperimentRecord

@dataclass
class CycleState:
    """Persisted state for the continuous cycle."""
    cycle_count: int = 0
    last_domain: str = ""
    total_experiments: int = 0
    successful_proofs: int = 0
    prompt_evolution_history: List[Dict] = field(default_factory=list)
    integration_history: List[Dict] = field(default_factory=list)
    best_prompts: List[Dict] = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2)

    @classmethod
    def from_json(cls, raw: str) -> "CycleState":
        return cls(**json.loads(raw))


@dataclass
class InFlightJob:
    """Track an Aristotle job from dispatch to completion."""
    cycle_n: int
    exp_id: str
    domain: Dict[str, Any]
    concept: Any  # ResearchConcept
    prompt: Any  # PromptEngine result
    lean_source: str
    project_dir: Path
    project_id: Optional[str] = None
    status: str = "queued"
    percent_complete: int = 0
    result_path: Optional[Path] = None
    error_message: Optional[str] = None
    dispatch_time: float = 0.0
    complete_time: Optional[float] = None
    retry_count: int = 0
    failure_reasons: List[str] = field(default_factory=list)


class GitAutomator:
    """Automate git add, commit, push."""

    def __init__(self, repo_root: Path):
        self.repo_root = Path(repo_root)

    def _run(self, cmd: List[str], cwd: Optional[Path] = None) -> Tuple[bool, str]:
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd or self.repo_root,
                capture_output=True,
                text=True,
                timeout=60,
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
        ok, out = self._run(["git", "push", remote, branch])
        if not ok:
            # Try with -u if first push
            ok, out = self._run(["git", "push", "-u", remote, branch])
        return ok

    def create_commit_for_cycle(
        self,
        cycle_num: int,
        domain: str,
        concept_title: str,
        changed_files: List[str],
        artifacts: List[str],
    ) -> bool:
        """Create a nicely formatted commit for a research cycle."""
        # Stage all changes
        self.add(".")

        # Build commit message
        changed_list = "\n".join(f"  - {c}" for c in changed_files[:10])
        if len(changed_files) > 10:
            changed_list += f"\n  - ... and {len(changed_files) - 10} more"

        artifact_list = "\n".join(f"  - {a}" for a in artifacts[:5])

        message = textwrap.dedent(f"""\
            AETHER cycle #{cycle_num}: {concept_title}

            Domain: {domain}
            Concept: {concept_title}

            New / changed files:
            {changed_list}

            Artifacts:
            {artifact_list}

            Co-Authored-By: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
        """)

        return self.commit(message)


class PromptEvolver:
    """Evolve Aristotle prompts based on past success/failure."""

    def __init__(self, pi_agent: PiAgentClient, workspace: Path):
        self.pi_agent = pi_agent
        self.workspace = Path(workspace)
        self.workspace.mkdir(parents=True, exist_ok=True)
        self.history_file = self.workspace / "prompt_history.jsonl"

    def record_prompt_outcome(
        self,
        prompt_text: str,
        concept: ResearchConcept,
        success: bool,
        result_status: str,
        changed_files: int,
    ) -> None:
        """Record a prompt and its outcome."""
        entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "concept": concept.title,
            "domain": concept.domain,
            "success": success,
            "status": result_status,
            "changed_files": changed_files,
            "prompt_length": len(prompt_text),
        }
        with open(self.history_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")

    def load_history(self) -> List[Dict]:
        """Load prompt history."""
        if not self.history_file.exists():
            return []
        entries = []
        with open(self.history_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    entries.append(json.loads(line))
        return entries

    def evolve_prompt_for_domain(self, domain: str) -> Dict[str, str]:
        """Use Pi-Agent to generate an improved prompt strategy for a domain."""
        history = self.load_history()
        domain_history = [h for h in history if h.get("domain") == domain][-10:]

        if len(domain_history) < 3:
            return {}  # Not enough data

        successes = [h for h in domain_history if h.get("success")]
        failures = [h for h in domain_history if not h.get("success")]

        system = textwrap.dedent("""\
            You are a meta-prompt engineer specializing in formal mathematics.
            Your job is to analyze prompt outcomes and suggest improvements.
            Output ONLY structured JSON.
        """)

        user = textwrap.dedent(f"""\
            Domain: {domain}

            Successful cycles ({len(successes)}):
            {json.dumps(successes, indent=2)}

            Failed cycles ({len(failures)}):
            {json.dumps(failures, indent=2)}

            Based on this history, suggest improvements to the Aristotle prompt strategy.
            Respond with ONLY this JSON:
            {{
              "creativity_boosters": ["specific instruction 1", "instruction 2"],
              "style_adjustments": "How to rephrase prompts for this domain",
              "artifact_focus": "Which artifacts matter most",
              "theorem_structure_hint": "How to structure the Lean guess for better results"
            }}
        """)

        raw = self.pi_agent._call_ollama(system, user)
        try:
            match = re.search(r'\{.*\}', raw, re.DOTALL)
            if match:
                return json.loads(match.group())
        except Exception:
            pass
        return {}


class CycleMaster:
    """Continuous research cycle orchestrator."""

    def __init__(
        self,
        config: Dict[str, Any],
        domains_config: Dict[str, Any],
        workspace: Path,
    ):
        self.config = config
        self.domains = domains_config.get("domains", [])
        self.global_settings = domains_config.get("global_settings", {})
        self.workspace = Path(workspace)
        self.workspace.mkdir(parents=True, exist_ok=True)

        # Paths
        self.catalog_root = Path(config.get("catalog", {}).get("root_dir", "../Catalog")).resolve()
        self.state_path = self.workspace / "cycle_state.json"
        self.output_dir = self.workspace / "output"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.artifacts_dir = self.workspace / "artifacts"
        self.artifacts_dir.mkdir(parents=True, exist_ok=True)

        # State
        self.state = self._load_state()

        # Subsystems
        self.memory = ResearchMemory(self.workspace)

        self.pi_agent = PiAgentClient(
            memory=self.memory,
            model=config.get("pi_agent", {}).get("model", "kimi-k2.6:cloud"),
        ) if self.global_settings.get("pi_agent_enabled", True) else None

        self.prompt_engine = PromptEngine(config.get("prompts", {}))
        self.aristotle = AristotleSDKClient(config.get("aristotle", {}))
        self.telemetry = TelemetryLogger(config.get("telemetry", {}))
        self.lean_builder = LeanCatalogBuilder(self.catalog_root)
        self.git = GitAutomator(self.catalog_root.parent)  # repo root
        self.integrator = SmartIntegrator(self.catalog_root, self.pi_agent, self.workspace)
        self.prompt_evolver = PromptEvolver(self.pi_agent, self.workspace)

        # Control
        self._shutdown_requested = False
        self._domain_weights = {d["id"]: d.get("weight", 1.0) for d in self.domains}

    def _load_state(self) -> CycleState:
        if self.state_path.exists():
            try:
                return CycleState.from_json(self.state_path.read_text(encoding="utf-8"))
            except Exception:
                pass
        return CycleState()

    def _save_state(self) -> None:
        self.state_path.write_text(self.state.to_json(), encoding="utf-8")

    def _select_domain(self) -> Dict[str, Any]:
        """Weighted random, avoiding immediate repeats."""
        candidates = [d for d in self.domains if d["id"] != self.state.last_domain]
        if not candidates:
            candidates = self.domains
        weights = [self._domain_weights.get(d["id"], 1.0) for d in candidates]
        total = sum(weights)
        if total == 0:
            import random
            return random.choice(candidates)
        import random
        r = random.uniform(0, total)
        cumulative = 0.0
        for d, w in zip(candidates, weights):
            cumulative += w
            if r <= cumulative:
                return d
        return candidates[-1]

    def _generate_lean_source(self, concept: ResearchConcept) -> str:
        """Generate Lean source from concept."""
        exp_id = str(uuid.uuid4())[:8]
        header = textwrap.dedent(f"""\
            import Mathlib

            /-! # CatalogBuild.Speculative.AutoResearch.{concept.title}

            Auto-generated by CycleMaster (Pi-Agent + Aristotle).
            Domain: {concept.domain}
            Novelty: {concept.novelty_estimate:.2f}
            Experiment: {exp_id}
            Date: {datetime.now(timezone.utc).isoformat()}
            -/

            /-
            {concept.concept_description}

            Mathematical Concept: {concept.mathematical_framing}
            -/
        """)
        lean_body = concept.lean_guess.strip()
        if not lean_body or "theorem" not in lean_body:
            lean_body = textwrap.dedent(f"""\
                theorem {concept.title.lower().replace(' ', '_')}_breakthrough
                    {{X : Type*}} [Inhabited X] :
                    True := by
                  sorry
            """)
        if "sorry" not in lean_body:
            lean_body += "\n  sorry\n"
        return header + "\n" + lean_body

    def _extract_artifacts(self, result_dir: Path, exp_id: str, domain: str = "", concept_title: str = "") -> Dict[str, Path]:
        """Extract research artifacts to both workspace and Catalog/ResearchOutput."""
        artifacts: Dict[str, Path] = {}
        patterns = {
            "research_report": ["RESEARCH_REPORT.md", "*report*.md"],
            "python_demo": ["demo.py", "*demo*.py"],
            "svg_demo": ["diagram.svg", "*.svg"],
            "sciam_discussion": ["DISCUSSION.md", "*discussion*.md"],
            "summary": ["ARISTOTLE_SUMMARY.md", "*summary*.md"],
            "readme": ["README.md"],
        }

        # 1. Save to workspace (outside git)
        exp_dir = self.artifacts_dir / exp_id
        exp_dir.mkdir(parents=True, exist_ok=True)

        # 2. Save to Catalog/ResearchOutput (inside git)
        catalog_output_dir = self.catalog_root / "ResearchOutput" / exp_id
        catalog_output_dir.mkdir(parents=True, exist_ok=True)

        # Write metadata
        meta = {
            "experiment_id": exp_id,
            "domain": domain,
            "concept": concept_title,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        (catalog_output_dir / "metadata.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")

        for artifact_type, filenames in patterns.items():
            for pattern in filenames:
                matches = list(result_dir.rglob(pattern))
                if matches:
                    src = matches[0]
                    # Copy to workspace
                    dest_ws = exp_dir / src.name
                    shutil.copy2(src, dest_ws)
                    artifacts[artifact_type] = dest_ws

                    # Copy to Catalog/ResearchOutput (git-tracked)

                    dest_cat = catalog_output_dir / src.name
                    shutil.copy2(src, dest_cat)
                    # Also track catalog path for git commits
                    artifacts[f"catalog_{artifact_type}"] = dest_cat
                    break
        return artifacts

    async def _prepare_job(self, forced_domain: Optional[str] = None) -> Optional[InFlightJob]:
        """Prepare a job: select domain, generate concept, build prompt, prepare lean project.
        Returns InFlightJob ready for dispatch, or None if preparation fails."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count

        # Phase 1: Domain selection
        domain = self._select_domain() if forced_domain is None else next(
            (d for d in self.domains if d["id"] == forced_domain), self.domains[0]
        )
        self.state.last_domain = domain["id"]
        print(f"[Prepare] Domain: {domain['name']} ({domain['id']})")

        # Phase 1b: Load failure patterns for autoresearch
        failure_context = ""
        if self.memory:
            failure_context = self.memory.build_prompt_optimization_context(domain["id"])
            if failure_context:
                print(f"[Prepare] Autoresearch context: {failure_context.count(chr(10))} failure patterns loaded")

        # Phase 2: Pi-Agent concept generation
        exp_id = str(uuid.uuid4())[:8]
        print(f"[Prepare] Pi-Agent generating concept (exp={exp_id})...")

        if self.pi_agent:
            # Inject failure patterns into memory context temporarily
            if failure_context and self.memory:
                original_exclusion = self.memory.build_exclusion_prompt()
                # Temporarily augment memory with failure patterns
                # The generate_breakthrough_concept reads from self.memory
                # We don't modify memory permanently, just log it
                print(f"[Prepare] Pi-Agent optimizing prompt based on past failures...")
            concept = self.pi_agent.generate_breakthrough_concept(
                domain=domain["id"],
                seed_concepts=domain.get("seed_concepts", []),
                target="theorem",
            )
        else:
            concept = ResearchConcept(
                title=f"auto_concept_{exp_id}",
                domain=domain["id"],
                concept_description="Auto-generated placeholder.",
                mathematical_framing="TBD",
            )
        print(f"[Prepare] Concept: {concept.title} (novelty={concept.novelty_estimate:.2f})")

        # Phase 3: Build prompt
        print(f"[Prepare] Building Aristotle prompt...")
        prompt = self.prompt_engine.build_prompt(
            title=concept.title,
            domain=domain["id"],
            concept_description=concept.concept_description,
            mathematical_framing=concept.mathematical_framing,
            lean_guess=concept.lean_guess,
            difficulty=domain.get("difficulty_target", "phd"),
            artifacts=ArtifactRequests(
                research_report=True,
                python_demo=True,
                svg_demo=True,
                sciam_discussion=True,
                lean_proof=True,
            ),
        )
        print(f"[Prepare] Prompt: {len(prompt.prompt_text)} chars")

        # Phase 4: Generate Lean source
        lean_source = self._generate_lean_source(concept)
        print(f"[Prepare] Lean source: {len(lean_source)} chars")

        # Phase 5: Build lean-only project
        project_dir = self.output_dir / f"job_{exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)

        print(f"[Prepare] Building lean-only catalog...")
        self.lean_builder.build_lean_project(
            project_dir=project_dir,
            domain=domain["id"],
            lean_source=lean_source,
        )

        return InFlightJob(
            cycle_n=cycle_n,
            exp_id=exp_id,
            domain=domain,
            concept=concept,
            prompt=prompt,
            lean_source=lean_source,
            project_dir=project_dir,
            dispatch_time=time.time(),
        )

    async def _dispatch_job(self, job: InFlightJob) -> None:
        """Dispatch a prepared job to Aristotle (non-blocking)."""
        print(f"[Dispatch] Submitting {job.exp_id} to Aristotle...")
        try:
            project_id = await self.aristotle.submit_lean_project_only(
                prompt=job.prompt.prompt_text,
                project_dir=job.project_dir,
            )
            job.project_id = project_id
            job.status = "queued"
            self.state.total_experiments += 1
            print(f"[Dispatch] {job.exp_id} queued as {project_id}")
        except Exception as e:
            job.status = "failed"
            job.error_message = str(e)
            print(f"[Dispatch] {job.exp_id} failed: {e}")

    async def _poll_jobs(self, jobs: List[InFlightJob]) -> List[InFlightJob]:
        """Poll all in-flight jobs. Returns list of newly completed jobs."""
        completed = []
        for job in jobs:
            if job.status in ("complete", "failed", "timeout", "error"):
                continue
            if not job.project_id:
                continue

            try:
                info = await self.aristotle.poll_project(job.project_id)
                job.status = info["status"]
                job.percent_complete = info.get("percent_complete", 0)

                if info.get("complete"):
                    print(f"[Poll] {job.exp_id} ({job.project_id}) is complete ({job.percent_complete}%)")
                    result_path = await self.aristotle.download_result(
                        job.project_id, job.project_dir
                    )
                    job.result_path = result_path
                    job.complete_time = time.time()
                    completed.append(job)
                elif info.get("error"):
                    print(f"[Poll] {job.exp_id} ({job.project_id}) error: {info['error']}")
                    job.status = "error"
                    job.error_message = info["error"]
                    completed.append(job)
                else:
                    print(f"[Poll] {job.exp_id} ({job.project_id}) {job.status} {job.percent_complete}%")
            except Exception as e:
                print(f"[Poll] {job.exp_id} poll error: {e}")

        return completed

    async def _process_job_result(self, job: InFlightJob) -> None:
        """Process a completed job: quality gate, integration, git commit/push."""
        print(f"\n[Process] Processing results for {job.exp_id}...")
        cycle_n = job.cycle_n
        exp_id = job.exp_id
        domain = job.domain
        concept = job.concept
        elapsed = (job.complete_time or time.time()) - job.dispatch_time

        if not job.result_path or not job.result_path.exists():
            print(f"[Process] No result for {exp_id}. Recording failure.")
            self._record_failure(job, "No result downloaded")
            return

        extract_dir = job.project_dir / "result_extracted"
        extract_dir.mkdir(exist_ok=True)
        import tarfile
        with tarfile.open(job.result_path, "r:gz") as tar:
            tar.extractall(path=extract_dir)

        # --- QUALITY GATE ---
        main_lean = self._find_main_lean(extract_dir)
        if not main_lean:
            print(f"[Process] No Main.lean found. Recording failure.")
            self._record_failure(job, "No Main.lean in result")
            return

        lean_text = main_lean.read_text(encoding="utf-8")
        print(f"[QualityGate] Analyzing proof quality for {exp_id}...")
        analysis = self.pi_agent.analyze_trivial_proof(
            lean_source=lean_text,
            prompt=job.prompt.prompt_text,
            concept=concept,
        )
        print(f"[QualityGate] Trivial={analysis.trivial}, Reason: {analysis.reason}")

        if analysis.trivial:
            print(f"[QualityGate] REJECTED: {analysis.reason}")
            job.failure_reasons.append(analysis.reason)
            self._record_failure(job, f"Trivial proof: {analysis.reason}")
            # Do NOT integrate trivial proofs. The failure is recorded in ResearchMemory
            # and Pi-Agent will use it to optimize future prompts.
            return

        # --- PI-AGENT DIFF ANALYSIS ---
        print(f"[Process] Pi-Agent analyzing diff for integration...")
        integration_plan = self.pi_agent.analyze_diff_and_decide(
            result_dir=extract_dir,
            catalog_root=self.catalog_root,
            exp_id=exp_id,
        )
        print(f"[Process] Integration plan: {len(integration_plan.decisions)} decisions")

        # Execute Pi-Agent's integration plan
        decisions = self.integrator.execute_integration_plan(
            plan=integration_plan,
            result_dir=extract_dir,
            exp_id=exp_id,
            dry_run=False,
        )
        manifest = self.integrator.generate_manifest(decisions, exp_id)
        print(f"[Process] Manifest: {manifest}")
        print(f"[Process] Placed: {len(decisions['placed'])}, Artifacts: {len(decisions['artifacts'])}, Unchanged: {len(decisions['unchanged'])}, Rejected: {len(decisions['rejected'])}")

        # Extract artifacts
        artifacts = self._extract_artifacts(extract_dir, exp_id, domain=job.domain["id"], concept_title=job.concept.title)
        print(f"[Process] Artifacts: {list(artifacts.keys())}")

        changed_count = len(decisions["placed"])
        success = job.status in ("complete", "COMPLETE", "COMPLETE_WITH_ERRORS")
        self.prompt_evolver.record_prompt_outcome(
            prompt_text=job.prompt.prompt_text,
            concept=concept,
            success=success,
            result_status=job.status,
            changed_files=changed_count,
        )

        # Git commit + push
        if success and (changed_count > 0 or len(decisions["artifacts"]) > 0):
            print(f"[Process] Integrating {changed_count} files into Catalog...")
            for d in decisions["placed"][:5]:
                print(f"  + [{d.domain}] {d.target_path.relative_to(self.catalog_root)} ({d.reason})")
            if len(decisions["placed"]) > 5:
                print(f"  + ... and {len(decisions['placed']) - 5} more")

            changed_paths = [
                str(d.target_path.relative_to(self.catalog_root))
                for d in decisions["placed"]
            ]
            artifact_paths = [
                str(p.relative_to(self.catalog_root.parent))
                for p in artifacts.values()
            ]

            print(f"[Process] Git operations...")
            commit_ok = self.git.create_commit_for_cycle(
                cycle_num=cycle_n,
                domain=domain["name"],
                concept_title=concept.title,
                changed_files=changed_paths,
                artifacts=artifact_paths,
            )
            if commit_ok:
                print(f"[Process] Commit created.")
                push_ok = self.git.push()
                if push_ok:
                    print(f"[Process] Pushed to GitHub.")
                else:
                    print(f"[Process] Push failed (will retry next cycle).")
            else:
                print(f"[Process] No changes to commit.")

            self.state.successful_proofs += 1
            self.state.integration_history.append({
                "cycle": cycle_n,
                "exp_id": exp_id,
                "files_changed": changed_count,
                "domains_touched": list(set(d.domain for d in decisions["placed"])),
            })

            # Record success in ResearchMemory
            if self.memory:
                self.memory.record(MemoryExperimentRecord(
                    exp_id=exp_id,
                    domain=domain["id"],
                    concept_title=concept.title,
                    concept_description=concept.concept_description,
                    status="success",
                    files_produced=changed_count,
                    key_theorems=[concept.title],
                    prompt_version=job.retry_count,
                    prompt_quality_score=0.85 if not analysis.trivial else 0.0,
                    aristotle_retries=job.retry_count,
                    rejection_reason="",
                ))
        else:
            print(f"[Process] No changes to integrate (status={job.status}).")

    def _record_failure(self, job: InFlightJob, reason: str) -> None:
        """Record a failed experiment in ResearchMemory."""
        if self.memory:
            self.memory.record(MemoryExperimentRecord(
                exp_id=job.exp_id,
                domain=job.domain["id"],
                concept_title=job.concept.title,
                concept_description=job.concept.concept_description,
                status="rejected_trivial",
                files_produced=0,
                key_theorems=[],
                prompt_version=job.retry_count,
                prompt_quality_score=0.0,
                aristotle_retries=job.retry_count,
                rejection_reason=reason,
            ))
        self.prompt_evolver.record_prompt_outcome(
            prompt_text=job.prompt.prompt_text,
            concept=job.concept,
            success=False,
            result_status="rejected_trivial",
            changed_files=0,
        )

    def _find_main_lean(self, extract_dir: Path) -> Optional[Path]:
        """Find the main Lean theorem file in an extracted result."""
        lean_files = list(extract_dir.rglob("*.lean"))
        if not lean_files:
            return None
        main_file = next((f for f in lean_files if f.name == "Main.lean"), None)
        if main_file is None:
            main_file = max(lean_files, key=lambda f: f.stat().st_size)
        return main_file

    async def run_single_cycle(self, forced_domain: Optional[str] = None, dry_run: bool = False) -> bool:
        """Run one complete research cycle."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count
        print(f"\n{'='*70}")
        print(f"CYCLE MASTER — Cycle #{cycle_n}")
        print(f"{'='*70}")

        # Phase 1: Domain selection
        domain = self._select_domain() if forced_domain is None else next(
            (d for d in self.domains if d["id"] == forced_domain), self.domains[0]
        )
        self.state.last_domain = domain["id"]
        print(f"[Phase 1] Domain: {domain['name']} ({domain['id']})")

        # Phase 2: Prompt evolution (if we have history)
        evolved_hints = {}
        if self.pi_agent and cycle_n > 3:
            print(f"[Phase 1b] Evolving prompt strategy for {domain['id']}...")
            evolved_hints = self.prompt_evolver.evolve_prompt_for_domain(domain["id"])
            if evolved_hints:
                print(f"[Phase 1b] Evolved hints: {list(evolved_hints.keys())}")

        # Phase 3: Pi-Agent concept generation
        exp_id = str(uuid.uuid4())[:8]
        print(f"[Phase 2] Pi-Agent generating concept (exp={exp_id})...")

        if self.pi_agent:
            concept = self.pi_agent.generate_breakthrough_concept(
                domain=domain["id"],
                seed_concepts=domain.get("seed_concepts", []),
                target="theorem",
            )
        else:
            concept = ResearchConcept(
                title=f"auto_concept_{exp_id}",
                domain=domain["id"],
                concept_description="Auto-generated placeholder.",
                mathematical_framing="TBD",
            )
        print(f"[Phase 2] Concept: {concept.title} (novelty={concept.novelty_estimate:.2f})")

        # Phase 4: Build prompt
        print(f"[Phase 3] Building Aristotle prompt...")
        prompt = self.prompt_engine.build_prompt(
            title=concept.title,
            domain=domain["id"],
            concept_description=concept.concept_description,
            mathematical_framing=concept.mathematical_framing,
            lean_guess=concept.lean_guess,
            difficulty=domain.get("difficulty_target", "phd"),
            artifacts=ArtifactRequests(
                research_report=True,
                python_demo=True,
                svg_demo=True,
                sciam_discussion=True,
                lean_proof=True,
            ),
        )
        print(f"[Phase 3] Prompt: {len(prompt.prompt_text)} chars")

        # Phase 5: Generate Lean source
        lean_source = self._generate_lean_source(concept)
        print(f"[Phase 4] Lean source: {len(lean_source)} chars")

        if dry_run:
            print("\n[DRY RUN] Stopping before dispatch.")
            return True

        # Phase 6: Build lean-only project and dispatch
        project_dir = self.output_dir / f"job_{exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)

        print(f"[Phase 5] Building lean-only catalog...")
        self.lean_builder.build_lean_project(
            project_dir=project_dir,
            domain=domain["id"],
            lean_source=lean_source,
        )

        print(f"[Phase 5] Dispatching to Aristotle...")
        start_time = time.time()
        result = await self.aristotle.submit_lean_project(
            prompt=prompt.prompt_text,
            project_dir=project_dir,
        )
        elapsed = time.time() - start_time
        print(f"[Phase 5] Aristotle: {result.status} ({elapsed:.1f}s)")
        if result.error_message:
            print(f"[Phase 5] Error: {result.error_message}")

        self.state.total_experiments += 1

        # Phase 7: Quality gate + integration
        if result.result_path and result.result_path.exists():
            extract_dir = project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            import tarfile
            with tarfile.open(result.result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            # --- QUALITY GATE ---
            main_lean = self._find_main_lean(extract_dir)
            if not main_lean:
                print(f"[Phase 6] No Main.lean found. Recording failure.")
                self._record_failure_single(exp_id, domain, concept, prompt, "No Main.lean in result")
                self._save_state()
                return False

            lean_text = main_lean.read_text(encoding="utf-8")
            print(f"[QualityGate] Analyzing proof quality for {exp_id}...")
            analysis = self.pi_agent.analyze_trivial_proof(
                lean_source=lean_text,
                prompt=prompt.prompt_text,
                concept=concept,
            )
            print(f"[QualityGate] Trivial={analysis.trivial}, Reason: {analysis.reason}")

            if analysis.trivial:
                print(f"[QualityGate] REJECTED: {analysis.reason}")
                self._record_failure_single(exp_id, domain, concept, prompt, f"Trivial proof: {analysis.reason}")
                self._save_state()
                return False

            # --- PI-AGENT DIFF ANALYSIS ---
            print(f"[Phase 6] Pi-Agent analyzing diff for integration...")
            integration_plan = self.pi_agent.analyze_diff_and_decide(
                result_dir=extract_dir,
                catalog_root=self.catalog_root,
                exp_id=exp_id,
            )
            decisions = self.integrator.execute_integration_plan(
                plan=integration_plan,
                result_dir=extract_dir,
                exp_id=exp_id,
                dry_run=False,
            )
            manifest = self.integrator.generate_manifest(decisions, exp_id)
            print(f"[Phase 6] Manifest: {manifest}")
            print(f"[Phase 6] Placed: {len(decisions['placed'])}, Artifacts: {len(decisions['artifacts'])}, Unchanged: {len(decisions['unchanged'])}, Rejected: {len(decisions['rejected'])}")

            # Extract artifacts
            artifacts = self._extract_artifacts(extract_dir, exp_id, domain=domain["id"], concept_title=concept.title)
            print(f"[Phase 6] Artifacts: {list(artifacts.keys())}")

            changed_count = len(decisions["placed"])
            success = result.status in ("complete", "COMPLETE", "COMPLETE_WITH_ERRORS")
            self.prompt_evolver.record_prompt_outcome(
                prompt_text=prompt.prompt_text,
                concept=concept,
                success=success,
                result_status=result.status,
                changed_files=changed_count,
            )

            # Phase 8: Git commit + push
            if success and (changed_count > 0 or len(decisions["artifacts"]) > 0):
                print(f"[Phase 7] Integrating {changed_count} files into Catalog...")
                for d in decisions["placed"][:5]:
                    print(f"  + [{d.domain}] {d.target_path.relative_to(self.catalog_root)} ({d.reason})")
                if len(decisions["placed"]) > 5:
                    print(f"  + ... and {len(decisions['placed']) - 5} more")

                changed_paths = [
                    str(d.target_path.relative_to(self.catalog_root))
                    for d in decisions["placed"]
                ]
                artifact_paths = [
                    str(p.relative_to(self.catalog_root.parent))
                    for p in artifacts.values()
                ]

                print(f"[Phase 8] Git operations...")
                commit_ok = self.git.create_commit_for_cycle(
                    cycle_num=cycle_n,
                    domain=domain["name"],
                    concept_title=concept.title,
                    changed_files=changed_paths,
                    artifacts=artifact_paths,
                )
                if commit_ok:
                    print(f"[Phase 8] Commit created.")
                    push_ok = self.git.push()
                    if push_ok:
                        print(f"[Phase 8] Pushed to GitHub.")
                    else:
                        print(f"[Phase 8] Push failed (will retry next cycle).")
                else:
                    print(f"[Phase 8] No changes to commit.")

                self.state.successful_proofs += 1
                self.state.integration_history.append({
                    "cycle": cycle_n,
                    "exp_id": exp_id,
                    "files_changed": changed_count,
                    "domains_touched": list(set(d.domain for d in decisions["placed"])),
                })

                # Record success in ResearchMemory
                if self.memory:
                    self.memory.record(MemoryExperimentRecord(
                        exp_id=exp_id,
                        domain=domain["id"],
                        concept_title=concept.title,
                        concept_description=concept.concept_description,
                        status="success",
                        files_produced=changed_count,
                        key_theorems=[concept.title],
                        prompt_version=0,
                        prompt_quality_score=0.85,
                        aristotle_retries=0,
                        rejection_reason="",
                    ))
            else:
                print(f"[Phase 7] No changes to integrate (status={result.status}).")
        else:
            print(f"[Phase 6] No result tarball. Status: {result.status}")

        # Save state
        self._save_state()
        print(f"[Phase 9] Cycle #{cycle_n} complete. State saved.")
        return result.lean_source is not None

    def _record_failure_single(self, exp_id: str, domain: Dict[str, Any], concept: Any, prompt: Any, reason: str) -> None:
        """Record a failed single-cycle experiment."""
        if self.memory:
            self.memory.record(MemoryExperimentRecord(
                exp_id=exp_id,
                domain=domain["id"],
                concept_title=concept.title,
                concept_description=concept.concept_description,
                status="rejected_trivial",
                files_produced=0,
                key_theorems=[],
                prompt_version=0,
                prompt_quality_score=0.0,
                aristotle_retries=0,
                rejection_reason=reason,
            ))
        self.prompt_evolver.record_prompt_outcome(
            prompt_text=prompt.prompt_text,
            concept=concept,
            success=False,
            result_status="rejected_trivial",
            changed_files=0,
        )

    async def run_continuous(self, parallel: bool = False, max_jobs: int = 10) -> None:
        """Run continuous cycles until shutdown.

        parallel=True: dispatch up to max_jobs concurrently to Aristotle.
        parallel=False: run one cycle at a time sequentially.
        """
        print("="*70)
        print("CYCLE MASTER: CONTINUOUS RESEARCH ENGINE STARTED")
        print(f"Workspace: {self.workspace}")
        print(f"Catalog: {self.catalog_root}")
        print(f"Mode: {'PARALLEL (max %d jobs)' % max_jobs if parallel else 'SEQUENTIAL'}")
        print("Press Ctrl+C to shutdown.")
        print("="*70)

        if parallel:
            await self._run_parallel(max_jobs=max_jobs)
        else:
            await self._run_sequential()

    async def _run_sequential(self) -> None:
        """Original sequential mode."""
        interval = self.global_settings.get("cycle_interval_seconds", 300)
        while not self._shutdown_requested:
            try:
                await self.run_single_cycle()
            except Exception as e:
                print(f"[ERROR] Cycle failed: {e}")
                import traceback
                traceback.print_exc()

            if self._shutdown_requested:
                break

            print(f"[CYCLE MASTER] Sleeping {interval}s before next cycle...")
            await asyncio.sleep(interval)

        print("[CYCLE MASTER] Shutdown complete.")

    async def _run_parallel(self, max_jobs: int = 10) -> None:
        """Parallel mode: keep up to max_jobs in flight with Aristotle."""
        poll_interval = self.global_settings.get("polling_interval_seconds", 30)
        in_flight: List[InFlightJob] = []

        print(f"[PARALLEL] Starting with max {max_jobs} concurrent jobs")

        while not self._shutdown_requested:
            # Fill queue up to max_jobs
            while len(in_flight) < max_jobs and not self._shutdown_requested:
                print(f"[PARALLEL] Queue: {len(in_flight)}/{max_jobs} — dispatching new job...")
                try:
                    job = await self._prepare_job()
                    if job:
                        await self._dispatch_job(job)
                        in_flight.append(job)
                        print(f"[PARALLEL] Dispatched {job.exp_id} ({job.project_id})")
                    else:
                        print("[PARALLEL] Job preparation failed, will retry.")
                        break
                except Exception as e:
                    print(f"[ERROR] Prepare/dispatch failed: {e}")
                    import traceback
                    traceback.print_exc()
                    break

            if self._shutdown_requested:
                break

            # Poll all jobs
            print(f"[PARALLEL] Polling {len(in_flight)} jobs...")
            completed = await self._poll_jobs(in_flight)

            # Process completed jobs
            for job in completed:
                try:
                    await self._process_job_result(job)
                except Exception as e:
                    print(f"[ERROR] Processing {job.exp_id} failed: {e}")
                    import traceback
                    traceback.print_exc()
                in_flight.remove(job)

            # Also remove failed/error jobs that won't complete
            to_remove = [j for j in in_flight if j.status in ("failed", "error", "timeout")]
            for job in to_remove:
                print(f"[PARALLEL] Removing failed job {job.exp_id} ({job.status})")
                in_flight.remove(job)

            print(f"[PARALLEL] Queue: {len(in_flight)}/{max_jobs} jobs in flight")
            print(f"[PARALLEL] Sleeping {poll_interval}s before next poll...")
            await asyncio.sleep(poll_interval)

        # Process any remaining jobs at shutdown
        if in_flight:
            print(f"[PARALLEL] Waiting for {len(in_flight)} remaining jobs...")
            while in_flight and not self._shutdown_requested:
                completed = await self._poll_jobs(in_flight)
                for job in completed:
                    try:
                        await self._process_job_result(job)
                    except Exception as e:
                        print(f"[ERROR] Processing {job.exp_id} failed: {e}")
                    in_flight.remove(job)
                if in_flight:
                    await asyncio.sleep(poll_interval)

        print("[CYCLE MASTER] Shutdown complete.")

    def request_shutdown(self) -> None:
        print("[CYCLE MASTER] Shutdown requested...")
        self._shutdown_requested = True


async def main():
    parser = argparse.ArgumentParser(description="CycleMaster: Continuous Aristotle Research")
    parser.add_argument("--config", default="config.yaml", help="Path to config.yaml")
    parser.add_argument("--domains", default="research_domains.json", help="Path to research_domains.json")
    parser.add_argument("--workspace", default="../workspace", help="Workspace directory (outside catalog)")
    parser.add_argument("--single-cycle", action="store_true", help="Run one cycle and exit")
    parser.add_argument("--domain", help="Force a specific domain")
    parser.add_argument("--dry-run", action="store_true", help="Generate but do not dispatch")
    parser.add_argument("--parallel", action="store_true", help="Dispatch up to 10 jobs concurrently")
    parser.add_argument("--max-jobs", type=int, default=10, help="Max concurrent Aristotle jobs (default: 10)")

    args = parser.parse_args()

    config_path = Path(args.config)
    config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}

    domains_path = Path(args.domains)
    domains_config = json.loads(domains_path.read_text(encoding="utf-8")) if domains_path.exists() else {}

    # Override paths to workspace
    config["catalog"] = config.get("catalog", {})
    config["catalog"]["root_dir"] = "../Catalog"

    master = CycleMaster(
        config=config,
        domains_config=domains_config,
        workspace=Path(args.workspace).resolve(),
    )

    if args.single_cycle:
        success = await master.run_single_cycle(
            forced_domain=args.domain,
            dry_run=args.dry_run,
        )
        sys.exit(0 if success else 1)
    else:
        loop = asyncio.get_event_loop()
        for sig in (__import__("signal").SIGINT, __import__("signal").SIGTERM):
            loop.add_signal_handler(sig, master.request_shutdown)
        try:
            await master.run_continuous(
                parallel=args.parallel,
                max_jobs=args.max_jobs,
            )
        except asyncio.CancelledError:
            pass


if __name__ == "__main__":
    asyncio.run(main())

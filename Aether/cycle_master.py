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
from prompt_engine import PromptEngine, ArtifactRequests, ResearchPrompt
from prompt_dna import PromptDNA
from quality_evaluator import QualityEvaluator, QualityScore
from catalog_scorer import CatalogScorer
from catalog_analyzer import CatalogAnalyzer
from arxiv_miner import ArxivMiner
from aristotle_sdk_client import AristotleSDKClient
from lean_catalog_builder import LeanCatalogBuilder
from smart_integrator import SmartIntegrator
from telemetry import TelemetryLogger, ExperimentRecord

import random

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
    retry_of: str = ""       # parent exp_id if this is a retry
    retry_count: int = 0    # how many retries so far
    source_exp_ids: list = None  # exp_ids of parent experiments whose future directions inspired this one


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

        _pi_cfg = config.get("pi_agent", {})
        self.pi_agent = PiAgentClient(
            memory=self.memory,
            model=_pi_cfg.get("model", "kimi-k2.6:cloud"),
            use_ollama=_pi_cfg.get("use_ollama", False),
            ollama_base_url=_pi_cfg.get("ollama_base_url"),
            ollama_model=_pi_cfg.get("ollama_model"),
            ollama_cloud=_pi_cfg.get("ollama_cloud", {}),
        ) if self.global_settings.get("pi_agent_enabled", True) else None

        self.prompt_engine = PromptEngine(config.get("prompts", {}))
        self.aristotle = AristotleSDKClient(config.get("aristotle", {}))
        self.telemetry = TelemetryLogger(config.get("telemetry", {}))
        self.lean_builder = LeanCatalogBuilder(self.catalog_root)
        self.git = GitAutomator(self.catalog_root.parent)  # repo root
        self.integrator = SmartIntegrator(self.catalog_root, self.pi_agent, self.workspace)
        self.prompt_evolver = PromptEvolver(self.pi_agent, self.workspace)

        # v3: Evolving prompt DNA + quality evaluator
        self.prompt_dna = PromptDNA.load_or_create(self.workspace)
        self.quality_evaluator = QualityEvaluator(
            pi_agent=self.pi_agent,
            catalog_root=self.catalog_root,
        )

        # v3: Catalog scoring for FINAL/ promotion
        self.catalog_scorer = CatalogScorer(
            catalog_root=self.catalog_root,
            workspace=self.workspace,
            pi_agent=self.pi_agent,
        )
        self.catalog_scorer.load_scores()

        # v3: ArXiv mining for fresh mathematical ideas
        from research_memory import FutureDirectionsManager
        self.arxiv_miner = ArxivMiner(
            pi_agent=self.pi_agent,
            catalog_analyzer=CatalogAnalyzer(self.catalog_root),
            research_memory=FutureDirectionsManager(self.workspace),
            config=config.get("arxiv", {}),
        )

        # Free exploration rate (10%)
        self.free_exploration_rate = config.get("free_exploration_rate", 0.10)

        # Control
        self._shutdown_requested = False
        self._domain_weights = {d["id"]: d.get("weight", 1.0) for d in self.domains}

        # Arc-driven selection: round-robin through research arcs
        self._arc_index = self.state.cycle_count % len(self.domains) if self.domains else 0

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
        """Arc-driven round-robin domain selection.

        Cycles through research arcs from config.yaml in order, ensuring
        every arc gets attention. Falls back to weighted random if no arcs.
        """
        if not self.domains:
            raise ValueError("No domains configured")

        # Round-robin through arcs based on cycle count
        idx = self._arc_index % len(self.domains)
        selected = self.domains[idx]

        # Advance for next cycle
        self._arc_index = idx + 1

        print(f"[Domain] Arc-driven selection: {selected['id']} (arc {idx+1}/{len(self.domains)})")
        return selected

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
                -- TODO: Aristotle — replace this stub with a genuine, non-trivial theorem.
                -- Use concrete types (Nat, Real, Matrix, Finset) not True/Prop tautologies.
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
        """Prepare a job: select domain, gather presearch, generate concept, build prompt, prepare lean project.
        Returns InFlightJob ready for dispatch, or None if preparation fails."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count

        # Phase 1: Arc-driven domain selection
        domain = self._select_domain() if forced_domain is None else next(
            (d for d in self.domains if d["id"] == forced_domain), self.domains[0]
        )
        self.state.last_domain = domain["id"]
        print(f"[Prepare] Domain: {domain['name']} ({domain['id']})")

        # Phase 1b: Gather presearch context for this arc
        presearch = ""
        future_direction_candidates = []
        if self.pi_agent:
            presearch = self.pi_agent.gather_presearch(domain)

            # Analyze future directions from previous cycles
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            available = fd_manager.get_available_directions(limit=5, domain_filter=domain["id"])
            if not available:
                # No domain-filtered directions — try any available
                available = fd_manager.get_available_directions(limit=5)

            if available and self.pi_agent.catalog_analyzer:
                # Use the LLM to analyze and rank future directions
                fd_text = self.pi_agent.catalog_analyzer.collect_future_directions(limit=3)
                future_direction_candidates = self.pi_agent.analyze_future_directions(
                    fd_text, domain
                )
                print(f"[Prepare] Found {len(future_direction_candidates)} future direction candidates")

        # Phase 2: Pi-Agent concept generation — prefer future directions over LLM generation
        exp_id = str(uuid.uuid4())[:8]
        print(f"[Prepare] Pi-Agent generating concept (exp={exp_id})...")

        concept = None
        source_exp_ids = []  # bound even when no future-direction candidate is chosen

        # Try to use a future direction candidate first
        if future_direction_candidates:
            best = future_direction_candidates[0]
            from output_organizer import normalize_domain
            concept = ResearchConcept(
                title=best["title"],
                domain=normalize_domain(best.get("domain", domain["id"])),
                concept_description=best["description"],
                mathematical_framing=best.get("description", ""),
                lean_guess="",
                catalog_references=best.get("catalog_references", []),
                research_mode=best.get("research_mode", "prove"),
                novelty_estimate=0.85,
                breakthrough_potential=best.get("priority_score", 0.8),
                key_references=best.get("catalog_references", [])[:3],
            )
            # Mark the direction as in-progress
            source_exp_ids = []
            if available:
                fd_manager.mark_direction_consumed(available[0].id, exp_id)
                source_exp_ids = fd_manager.get_source_exp_ids_for(exp_id)
            print(f"[Prepare] Using future direction: {concept.title}")

        if concept is None and self.pi_agent:
            concept = self.pi_agent.select_research_direction(
                domains=[domain],
                research_context=presearch,
                inflight_concepts=[j.concept.title for j in getattr(self, '_inflight_jobs', [])],
            )
        if concept is None:
            concept = ResearchConcept(
                title=f"auto_concept_{exp_id}",
                domain=domain["id"],
                concept_description=domain.get("frontier", "Explore this domain."),
                mathematical_framing="TBD",
            )
        print(f"[Prepare] Concept: {concept.title} (novelty={concept.novelty_estimate:.2f})")

        # Phase 3: Build Aristotle prompt using Pi-Agent's write_aristotle_prompt
        print(f"[Prepare] Building Aristotle prompt...")
        if self.pi_agent:
            # Cycle through the enhanced prompt variations
            cycle_variants = ["v16"]
            selected_prompt_version = cycle_variants[cycle_n % len(cycle_variants)]

            prompt_text = self.pi_agent.write_aristotle_prompt(
                concept=concept,
                catalog_references=concept.catalog_references,
                theorem_context=presearch[:1000] if presearch else "",
                prompt_version=selected_prompt_version,
            )
            prompt = ResearchPrompt(
                prompt_text=prompt_text,
                artifact_requests=ArtifactRequests(
                    research_report=True,
                    python_demo=True,
                    svg_demo=False,
                    sciam_discussion=True,
                    lean_proof=True,
                ),
                expected_artifacts=["theorem.lean", "RESEARCH_REPORT.md", "demo.py", "diagram.svg", "DISCUSSION.md"],
            )
        else:
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
                    svg_demo=False,
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
            source_exp_ids=source_exp_ids,
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

    def _is_trivial_proof(self, lean_source: str) -> bool:
        """v2: Detect trivial proofs that should be rejected."""
        lines = [l.strip() for l in lean_source.splitlines() if l.strip()]
        # Pattern 1: True := by trivial
        if "True := by trivial" in lean_source:
            return True
        # Pattern 2: True := by simp
        if "True := by simp" in lean_source and "sorry" not in lean_source:
            return True
        # Pattern 3: Very short proof with only trivial tactics
        proof_lines = [l for l in lines if not l.startswith("--") and not l.startswith("/-")]
        if len(proof_lines) < 5:
            trivial_tactics = {"trivial", "simp", "exact True.intro", "exact trivial"}
            if any(t in lean_source for t in trivial_tactics):
                return True
        # Pattern 4: Theorem is just a tautology
        if "theorem " in lean_source and "True :=" in lean_source:
            return True
        return False

    async def _retry_with_improved_prompt(self, job: InFlightJob) -> Optional[InFlightJob]:
        """v2: Ask Pi-Agent to improve the prompt and create a retry job."""
        retry_count = getattr(job, "retry_count", 0)
        if retry_count >= 3:
            print(f"[QualityGate] Max retries reached for {job.exp_id}. Giving up.")
            return None

        print(f"[QualityGate] Asking Pi-Agent to improve prompt for {job.exp_id}...")
        improved = self.pi_agent.suggest_prompt_improvement(
            concept=job.concept,
            previous_prompt=job.prompt.prompt_text,
            failure_reason="trivial proof (True := by trivial)",
        )
        if improved["confidence"] < 0.5 or not improved["revised_prompt"]:
            print(f"[QualityGate] Pi-Agent confidence too low ({improved['confidence']:.2f}). Giving up.")
            return None

        # Create a revised concept
        revised_concept = ResearchConcept(
            title=job.concept.title + f"_retry{retry_count + 1}",
            domain=job.concept.domain,
            concept_description=improved["revised_concept"] or job.concept.concept_description,
            mathematical_framing=job.concept.mathematical_framing,
            lean_guess=job.concept.lean_guess,
            novelty_estimate=job.concept.novelty_estimate,
            breakthrough_potential=job.concept.breakthrough_potential,
        )

        # Build new prompt with revised text
        from prompt_engine import PromptEngine, ArtifactRequests, ResearchPrompt
        prompt_engine = PromptEngine(self.config.get("prompts", {}))
        revised_prompt = prompt_engine.build_prompt(
            title=revised_concept.title,
            domain=revised_concept.domain,
            concept_description=revised_concept.concept_description,
            mathematical_framing=revised_concept.mathematical_framing,
            lean_guess=revised_concept.lean_guess,
            artifacts=ArtifactRequests(),
        )

        # Generate new lean source
        lean_source = self._generate_lean_source(revised_concept)

        # Prepare new job
        new_exp_id = str(uuid.uuid4())[:8]
        project_dir = self.output_dir / f"job_{new_exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)
        self.lean_builder.build_lean_project(
            project_dir=project_dir,
            domain=revised_concept.domain,
            lean_source=lean_source,
        )

        new_job = InFlightJob(
            cycle_n=job.cycle_n,
            exp_id=new_exp_id,
            domain=job.domain,
            concept=revised_concept,
            prompt=revised_prompt,
            lean_source=lean_source,
            project_dir=project_dir,
            retry_of=job.exp_id,
            retry_count=retry_count + 1,
        )

        print(f"[QualityGate] Retry job prepared: {new_exp_id} (retry #{retry_count + 1})")
        return new_job

    async def _process_job_result(self, job: InFlightJob) -> Optional[InFlightJob]:
        """Process a completed job: integrate results, git commit/push.
        Returns a retry job if quality gate triggered, else None."""
        print(f"\n[Process] Processing results for {job.exp_id}...")
        cycle_n = job.cycle_n
        exp_id = job.exp_id
        domain = job.domain
        concept = job.concept
        lean_source = job.lean_source
        elapsed = (job.complete_time or time.time()) - job.dispatch_time

        if job.result_path and job.result_path.exists():
            extract_dir = job.project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            import tarfile
            with tarfile.open(job.result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            # v2: Quality gate — check for trivial proofs
            result_main = extract_dir / "Main.lean"
            if result_main.exists():
                result_lean = result_main.read_text(encoding="utf-8")
                if self._is_trivial_proof(result_lean):
                    print(f"[QualityGate] Trivial proof detected for {exp_id}. Triggering autoresearch...")
                    # Record failure
                    if self.memory:
                        self.memory.record(MemoryExperimentRecord(
                            exp_id=exp_id,
                            domain=domain["id"],
                            concept_title=concept.title,
                            concept_description=concept.concept_description,
                            status="trivial_rejected",
                            prompt_text=job.prompt.prompt_text,
                            proof_quality="trivial",
                            retry_of=getattr(job, "retry_of", ""),
                            retry_count=getattr(job, "retry_count", 0),
                        ))
                    retry_job = await self._retry_with_improved_prompt(job)
                    if retry_job:
                        await self._dispatch_job(retry_job)
                        return retry_job
                    return None
                else:
                    print(f"[QualityGate] Proof passes quality check for {exp_id}.")

            # Analyze and integrate with SmartIntegrator
            print(f"[Process] Smart integration with Pi-Agent classification...")
            decisions = self.integrator.integrate_result_directory(
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
            pending_dir = self.catalog_root / "Speculative" / "AutoResearch"
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
            else:
                print(f"[Process] No changes to integrate (status={job.status}).")

            # Log experiment
            record = ExperimentRecord(
                experiment_id=exp_id,
                arc_id=domain["id"],
                arc_name=domain["name"],
                domain=domain["id"],
                file_path=str(pending_dir / f"PENDING_{domain['id']}_{exp_id}.lean") if success else "",
                difficulty=domain.get("difficulty_target", "phd"),
                hypothesis_text=lean_source[:500],
                concept_combination=domain.get("seed_concepts", []),
                generation_latency_ms=elapsed * 1000,
                aristotle_job_id=job.project_id or "",
                status="proven" if success else job.status.lower(),
                proof_length_lines=0,
                novelty_score=concept.novelty_estimate,
                epicness_score=concept.breakthrough_potential,
            )
            self.telemetry.log_experiment(record)
            # Also record in ResearchMemory for novelty tracking
            if self.memory:
                # Extract actual theorem names from placed .lean files
                key_theorems = []
                for d in decisions["placed"][:10]:
                    if d.target_path.suffix == ".lean":
                        try:
                            content = d.target_path.read_text(encoding="utf-8", errors="replace")
                            key_theorems.extend(re.findall(r'(?:theorem|lemma)\s+(\w+)', content)[:5])
                        except Exception:
                            pass
                # Fallback to file names if no theorems found
                if not key_theorems:
                    key_theorems = [d.target_path.name for d in decisions["placed"][:5]]

                mem_record = MemoryExperimentRecord(
                    exp_id=exp_id,
                    domain=domain["id"],
                    concept_title=concept.title,
                    concept_description=concept.concept_description,
                    status="success" if success else "failure",
                    files_produced=changed_count,
                    key_theorems=key_theorems,
                    prompt_text=job.prompt.prompt_text,
                    proof_quality="substantial" if not self._is_trivial_proof(lean_source) else "trivial",
                    retry_of=getattr(job, "retry_of", ""),
                    retry_count=getattr(job, "retry_count", 0),
                )
                self.memory.record(mem_record)

                # Also feed future directions from Aristotle's output to FutureDirectionsManager
                from research_memory import FutureDirectionsManager
                fd_manager = FutureDirectionsManager(self.workspace)
                fd_added = 0
                
                # 1. Look for explicit future_directions.json (Phase A v16 upgrade)
                if extract_dir and extract_dir.exists():
                    fd_json_file = extract_dir / "future_directions.json"
                    if fd_json_file.exists():
                        try:
                            import json as _json
                            fd_list = _json.loads(fd_json_file.read_text(encoding="utf-8"))
                            from research_memory import FutureDirection
                            for fd in fd_list:
                                if isinstance(fd, dict) and "title" in fd and "description" in fd:
                                    # add_direction takes a FutureDirection — the old
                                    # kwargs call raised TypeError on every invocation
                                    # and was swallowed (audit 2026-08-21).
                                    fd_manager.add_direction(FutureDirection(
                                        id=fd_manager._next_id(),
                                        title=fd["title"],
                                        description=fd["description"],
                                        source_exp_id=f"{exp_id}_json",
                                        source_path="cycle_master_json",
                                        priority_score=0.85,
                                    ))
                                    fd_added += 1
                        except Exception as e:
                            print(f"[CycleMaster] Failed to parse future_directions.json: {e}")

                # 2. Look for FUTURE_DIRECTIONS.md in the extracted results (Fallback)
                if fd_added == 0 and extract_dir and extract_dir.exists():
                    for fd_pattern in ["FUTURE_DIRECTIONS.md", "future_directions*.md"]:
                        for fd_file in extract_dir.rglob(fd_pattern):
                            try:
                                fd_content = fd_file.read_text(encoding="utf-8", errors="replace")
                                if len(fd_content) > 100:
                                    added, synthesis = fd_manager.add_directions_from_text(
                                        fd_content, exp_id, str(fd_file)
                                    )
                                    if added:
                                        fd_added += added
                                    if synthesis:
                                        fd_manager.store_synthesis(exp_id, synthesis)
                            except Exception:
                                pass
                # Fallback: use result_future_directions from knowledge extraction
                if fd_added == 0 and hasattr(job, 'result_future_directions') and job.result_future_directions:
                    try:
                        added, synthesis = fd_manager.add_directions_from_text(
                            job.result_future_directions, exp_id, "result_future_directions"
                        )
                        if added:
                            fd_added += added
                        if synthesis:
                            fd_manager.store_synthesis(exp_id, synthesis)
                    except Exception:
                        pass
                # Fallback: use the JSON package's future_directions field
                if fd_added == 0 and hasattr(job, 'result_json_package') and job.result_json_package:
                    try:
                        import json as _json
                        pkg = _json.loads(job.result_json_package)
                        fd_text = pkg.get("future_directions", "")
                        if fd_text and len(fd_text) > 100:
                            added, synthesis = fd_manager.add_directions_from_text(
                                fd_text, exp_id, "json_package"
                            )
                            if added:
                                fd_added += added
                            if synthesis:
                                fd_manager.store_synthesis(exp_id, synthesis)
                    except Exception:
                        pass
                if fd_added > 0:
                    print(f"[Process] Added {fd_added} future directions for {exp_id}")
        else:
            print(f"[Process] No result tarball for {exp_id}. Status: {job.status}")

        self._save_state()
        print(f"[Process] Job {exp_id} complete. State saved.")

    async def run_single_cycle(self, forced_domain: Optional[str] = None, dry_run: bool = False) -> bool:
        """Run one complete research cycle."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count
        print(f"\n{'='*70}")
        print(f"CYCLE MASTER — Cycle #{cycle_n} (Prompt DNA v{self.prompt_dna.version})")
        print(f"{'='*70}")

        # Phase 0: Free exploration check (10% chance)
        if forced_domain is None and random.random() < self.free_exploration_rate:
            print(f"[Phase 0] 🔭 FREE EXPLORATION MODE — Aristotle chooses freely")
            return await self._run_free_exploration(cycle_n, dry_run=dry_run)

        # Phase 1: Domain selection
        domain = self._select_domain() if forced_domain is None else next(
            (d for d in self.domains if d["id"] == forced_domain), self.domains[0]
        )
        self.state.last_domain = domain["id"]
        print(f"[Phase 1] Domain: {domain['name']} ({domain['id']})")

        # Phase 2: Prompt evolution — DNA mutates every cycle via the strange loop
        # (The actual mutation happens AFTER results, in the feedback phase below)

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

        # Phase 4: Build prompt using evolving DNA
        print(f"[Phase 3] Building Aristotle prompt (DNA v{self.prompt_dna.version})...")
        memory_summary = self.memory.build_success_patterns() if self.memory else ""
        presearch = self.pi_agent.gather_presearch({"id": domain["id"], **domain}) if self.pi_agent else ""
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
                svg_demo=False,
                sciam_discussion=True,
                lean_proof=True,
            ),
            dna=self.prompt_dna,
            cycle_n=cycle_n,
            memory_summary=memory_summary,
            presearch_context=presearch,
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

        # Phase 7: Process results
        if result.result_path and result.result_path.exists():
            extract_dir = project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            import tarfile
            with tarfile.open(result.result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            # v2: Quality gate — check for trivial proofs
            result_main = extract_dir / "Main.lean"
            if result_main.exists():
                result_lean = result_main.read_text(encoding="utf-8")
                if self._is_trivial_proof(result_lean):
                    print(f"[QualityGate] Trivial proof detected for {exp_id}.")
                    # Record failure
                    if self.memory:
                        self.memory.record(MemoryExperimentRecord(
                            exp_id=exp_id,
                            domain=domain["id"],
                            concept_title=concept.title,
                            concept_description=concept.concept_description,
                            status="trivial_rejected",
                            prompt_text=prompt.prompt_text,
                            proof_quality="trivial",
                        ))
                    print(f"[QualityGate] Skipping integration. Retry in next cycle.")
                    return False
                else:
                    print(f"[QualityGate] Proof passes quality check for {exp_id}.")

            # Analyze and integrate with SmartIntegrator
            print(f"[Phase 6] Smart integration with Pi-Agent classification...")
            decisions = self.integrator.integrate_result_directory(
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
            pending_dir = self.catalog_root / "Speculative" / "AutoResearch"
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

                # Collect changed paths for git
                changed_paths = [
                    str(d.target_path.relative_to(self.catalog_root))
                    for d in decisions["placed"]
                ]
                artifact_paths = [
                    str(p.relative_to(self.catalog_root.parent))
                    for p in artifacts.values()
                ]

                # Phase 9: Git commit + push
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
            else:
                print(f"[Phase 7] No changes to integrate (status={result.status}).")

            # Log experiment
            record = ExperimentRecord(
                experiment_id=exp_id,
                arc_id=domain["id"],
                arc_name=domain["name"],
                domain=domain["id"],
                file_path=str(pending_dir / f"PENDING_{domain['id']}_{exp_id}.lean") if success else "",
                difficulty=domain.get("difficulty_target", "phd"),
                hypothesis_text=lean_source[:500],
                concept_combination=domain.get("seed_concepts", []),
                generation_latency_ms=elapsed * 1000,
                aristotle_job_id=result.project_id,
                status="proven" if success else result.status.lower(),
                proof_length_lines=len(result.lean_source.splitlines()) if result.lean_source else 0,
                novelty_score=concept.novelty_estimate,
                epicness_score=concept.breakthrough_potential,
            )
            self.telemetry.log_experiment(record)
            # Also record in ResearchMemory for novelty tracking
            if self.memory:
                mem_record = MemoryExperimentRecord(
                    exp_id=exp_id,
                    domain=domain["id"],
                    concept_title=concept.title,
                    concept_description=concept.concept_description,
                    status="success" if success else "failure",
                    files_produced=changed_count,
                    key_theorems=[d.target_path.name for d in decisions["placed"][:5]],
                    prompt_text=prompt.prompt_text,
                    proof_quality="substantial" if not self._is_trivial_proof(lean_source) else "trivial",
                    retry_of="",
                    retry_count=0,
                )
                self.memory.record(mem_record)

        else:
            print(f"[Phase 6] No result tarball. Status: {result.status}")

        # Phase 10: Strange Loop — Quality evaluation + DNA mutation
        quality_score = None
        if result.lean_source:
            extract_dir_for_quality = project_dir / "result_extracted"
            print(f"[Phase 10] 🔄 Strange Loop: evaluating quality...")
            quality_score = self.quality_evaluator.evaluate(
                lean_source=result.lean_source,
                result_dir=extract_dir_for_quality if extract_dir_for_quality.exists() else None,
                concept_title=concept.title,
                concept_description=concept.concept_description,
                existing_titles=self.memory.get_all_titles() if self.memory else None,
            )
            print(f"[Phase 10] {quality_score.breakdown_str()}")

            # Mutate DNA based on quality feedback
            feedback = quality_score.to_dict()
            feedback.pop("composite", None)
            feedback.pop("grade", None)
            self.prompt_dna = self.prompt_dna.mutate(quality_score.composite, feedback)
            print(f"[Phase 10] DNA mutated → v{self.prompt_dna.version} (best=v{self.prompt_dna.best_version}, drops={self.prompt_dna.consecutive_drops})")

            # Checkpoint DNA to git
            self.prompt_dna.checkpoint(self.workspace)
            print(f"[Phase 10] DNA checkpointed.")

        # Phase 10.5: Catalog scoring — scan and score a batch for FINAL/ promotion
        try:
            batch_results = self.catalog_scorer.scan_and_score_batch(batch_size=50)
            promoted = [s for s in batch_results if s.in_final]
            if promoted:
                print(f"[Catalog] Promoted {len(promoted)} files to FINAL/: "
                      f"{', '.join(s.relative_path for s in promoted[:3])}")
            stats = self.catalog_scorer.get_stats()
            print(f"[Catalog] Scored: {stats['total_scored']} total, "
                  f"{stats['in_final']} in FINAL, "
                  f"avg structural={stats['avg_structural']:.1f}, "
                  f"avg final={stats['avg_final']:.1f}")
        except Exception as e:
            print(f"[Catalog] Scoring error (non-fatal): {e}")

        # Phase 10.7: ArXiv mining — inject fresh ideas from recent papers
        # Rotate between domain-specific and cross-pollination queries
        if self.arxiv_miner and self.arxiv_miner.enabled:
            try:
                cycle = self.state.cycle_count
                if cycle % 3 == 0:
                    # Every 3rd cycle: use rotating general query for cross-pollination
                    self.arxiv_miner.provider.set_general_query(cycle)
                    direction = self.arxiv_miner.mine_future_direction(
                        domain="",
                        use_domain_query=False,
                    )
                else:
                    # Domain-specific query aligned with current domain
                    direction = self.arxiv_miner.mine_future_direction(
                        domain=domain["id"] if domain else "",
                        use_domain_query=True,
                    )
                if direction:
                    print(f"[ArXiv] Mined direction: {direction.title}")
                else:
                    print(f"[ArXiv] No direction mined this cycle")
            except Exception as e:
                print(f"[ArXiv] Mining error (non-fatal): {e}")

        # Save state
        self._save_state()
        print(f"[Phase 11] Cycle #{cycle_n} complete. State saved.")
        return result.lean_source is not None

    async def _run_free_exploration(self, cycle_n: int, dry_run: bool = False) -> bool:
        """Free exploration mode: Aristotle picks its own topic.

        10% of cycles. No guardrails except all 5 deliverables.
        Best results auto-convert to directed research arcs.
        """
        exp_id = str(uuid.uuid4())[:8]
        print(f"[FREE] Experiment: {exp_id}")

        # Build context
        catalog_summary = ""
        if self.pi_agent and self.pi_agent.catalog_analyzer:
            self.pi_agent.catalog_analyzer.scan()
            catalog_summary = self.pi_agent.catalog_analyzer.build_overview()

        memory_summary = self.memory.build_success_patterns() if self.memory else ""

        # Build frontier summary from seed directions
        frontier_lines = []
        try:
            from seed_directions import get_seed_directions
            for d in get_seed_directions()[:20]:
                frontier_lines.append(f"- {d.title}: {d.description[:100]}...")
        except Exception:
            frontier_lines.append("- Explore the frontiers of mathematics freely.")
        frontier_summary = "\n".join(frontier_lines)

        # Build free exploration prompt via DNA
        prompt_text = self.prompt_dna.assemble_free_exploration(
            cycle_n=cycle_n,
            catalog_summary=catalog_summary[:2000],
            memory_summary=memory_summary[:1000],
            frontier_summary=frontier_summary[:2000],
        )
        print(f"[FREE] Prompt: {len(prompt_text)} chars")

        if dry_run:
            print("[FREE] DRY RUN — stopping.")
            return True

        # Generate minimal Lean source
        lean_source = textwrap.dedent(f"""\
            import Mathlib

            /-! # Free Exploration {exp_id}
            Aristotle-chosen topic. Cycle #{cycle_n}.
            Date: {datetime.now(timezone.utc).isoformat()}
            -/

            -- Aristotle: replace this with your chosen research direction.
            theorem free_exploration_{exp_id} : True := by sorry
        """)

        # Build and dispatch
        project_dir = self.output_dir / f"job_{exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)
        self.lean_builder.build_lean_project(
            project_dir=project_dir, domain="Bridges", lean_source=lean_source,
        )

        print(f"[FREE] Dispatching to Aristotle...")
        start_time = time.time()
        result = await self.aristotle.submit_lean_project(
            prompt=prompt_text, project_dir=project_dir,
        )
        elapsed = time.time() - start_time
        print(f"[FREE] Aristotle: {result.status} ({elapsed:.1f}s)")

        self.state.total_experiments += 1

        # Process results
        if result.result_path and result.result_path.exists():
            extract_dir = project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            import tarfile
            with tarfile.open(result.result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            # Quality evaluation
            quality_score = self.quality_evaluator.evaluate(
                lean_source=result.lean_source or lean_source,
                result_dir=extract_dir,
                concept_title=f"free_exploration_{exp_id}",
                concept_description="Aristotle free exploration",
                existing_titles=self.memory.get_all_titles() if self.memory else None,
            )
            print(f"[FREE] {quality_score.breakdown_str()}")

            # If quality is good, auto-convert to research arcs
            if quality_score.composite >= 0.6:
                print(f"[FREE] ✨ High quality! Auto-converting to directed arcs...")
                from research_memory import FutureDirectionsManager
                fd_manager = FutureDirectionsManager(self.workspace)
                for fd_file in extract_dir.rglob("FUTURE_DIRECTIONS.md"):
                    content = fd_file.read_text(encoding="utf-8", errors="replace")
                    if len(content) > 100:
                        added, synthesis = fd_manager.add_directions_from_text(
                            content, exp_id, f"free_exploration:{exp_id}"
                        )
                        if added:
                            print(f"[FREE] Added {added} new research directions from free exploration")
                        if synthesis:
                            fd_manager.store_synthesis(exp_id, synthesis)

            # Integrate if worth it
            if self.quality_evaluator.is_worth_integrating(quality_score):
                decisions = self.integrator.integrate_result_directory(
                    result_dir=extract_dir, exp_id=exp_id, dry_run=False,
                )
                changed_count = len(decisions["placed"])
                if changed_count > 0:
                    self.git.create_commit_for_cycle(
                        cycle_num=cycle_n, domain="FreeExploration",
                        concept_title=f"free_exploration_{exp_id}",
                        changed_files=[str(d.target_path.relative_to(self.catalog_root)) for d in decisions["placed"][:10]],
                        artifacts=[],
                    )
                    self.git.push()
                    self.state.successful_proofs += 1

            # DNA mutation from free exploration
            feedback = quality_score.to_dict()
            feedback.pop("composite", None)
            feedback.pop("grade", None)
            self.prompt_dna = self.prompt_dna.mutate(quality_score.composite, feedback)
            self.prompt_dna.checkpoint(self.workspace)

        self._save_state()
        print(f"[FREE] Free exploration cycle #{cycle_n} complete.")
        return result.lean_source is not None

    async def run_continuous(self, parallel: bool = False, max_jobs: int = 6) -> None:
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

    async def _run_parallel(self, max_jobs: int = 6) -> None:
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
                    retry_job = await self._process_job_result(job)
                    if retry_job:
                        in_flight.append(retry_job)
                        print(f"[PARALLEL] Retry job {retry_job.exp_id} added to queue")
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
                        retry_job = await self._process_job_result(job)
                        if retry_job:
                            in_flight.append(retry_job)
                            print(f"[PARALLEL] Retry job {retry_job.exp_id} added to queue")
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
    parser.add_argument("--parallel", action="store_true", help="Dispatch up to 6 jobs concurrently")
    parser.add_argument("--max-jobs", type=int, default=6, help="Max concurrent Aristotle jobs (default: 6)")

    args = parser.parse_args()

    # Mirror all console output to a timestamped log file
    _log_dir = Path(__file__).parent / ".aether_workspace" / "logs"
    _log_dir.mkdir(parents=True, exist_ok=True)
    _timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    _log_path = _log_dir / f"cycle_master_{_timestamp}.log"
    _log_file = open(_log_path, "a", encoding="utf-8")

    class _Tee:
        def __init__(self, terminal, log):
            self.terminal = terminal
            self.log = log
            self._is_duplicate = False
            try:
                import os
                if hasattr(terminal, "fileno") and hasattr(log, "fileno"):
                    stat_term = os.fstat(terminal.fileno())
                    stat_log = os.fstat(log.fileno())
                    if stat_term.st_ino > 0 and stat_term.st_ino == stat_log.st_ino and stat_term.st_dev == stat_log.st_dev:
                        self._is_duplicate = True
            except Exception:
                pass

        def write(self, msg):
            self.terminal.write(msg)
            if not self._is_duplicate:
                self.log.write(msg)
                self.log.flush()

        def flush(self):
            self.terminal.flush()
            if not self._is_duplicate:
                self.log.flush()

        def fileno(self):
            return self.terminal.fileno()

        def isatty(self):
            return self.terminal.isatty()

    sys.stdout = _Tee(sys.__stdout__, _log_file)
    sys.stderr = _Tee(sys.__stderr__, _log_file)
    print(f"[CycleMaster] Logging to {_log_path}")

    config_path = Path(args.config)
    config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}

    domains_path = Path(args.domains)
    domains_config = json.loads(domains_path.read_text(encoding="utf-8")) if domains_path.exists() else {}

    # Override paths to workspace
    config["catalog"] = config.get("catalog", {})
    config["catalog"]["root_dir"] = "../Catalog"

    # Enable Ollama Cloud fallback if CLI flag is set

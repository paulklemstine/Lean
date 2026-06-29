#!/usr/bin/env python3
"""PiAgentOrchestrator: The central brain of Aether v3.

Replaces CycleMaster with a Pi-Agent-centered architecture where
Pi-Agent (glm-5.1:cloud) drives ALL decisions:
- Which domain to research next
- What concept to investigate
- How to write the Aristotle prompt (dynamically, no templates)
- Which Catalog files to @ reference
- Whether results are good enough
- Where to place output files

Supports parallel dispatching: up to 10 jobs in Aristotle's queue,
with fire-and-forget dispatch and async polling.

Usage:
    python3 -m aether.pi_orchestrator --single-cycle
    python3 -m aether.pi_orchestrator --single-cycle --domain algebra --dry-run
    python3 -m aether.pi_orchestrator --continuous --max-jobs 10
"""

import argparse
import asyncio
import json
import shutil
import sys
import time
import uuid
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Any

import yaml

from pi_agent_client import PiAgentClient, ResearchConcept
from catalog_analyzer import CatalogAnalyzer
from output_organizer import OutputOrganizer
from autoresearch_bridge import AutoresearchBridge
from aristotle_sdk_client import AristotleSDKClient
from lean_catalog_builder import LeanCatalogBuilder
from research_memory import ResearchMemory, ExperimentRecord as MemoryExperimentRecord
from research_context import ResearchContext
from telemetry import TelemetryLogger, ExperimentRecord
from git_automator import GitAutomator
from output_organizer import normalize_domain
from aristotle_loop import AristotleLoop


@dataclass
class OrchestratorState:
    """Persisted state for the orchestrator."""
    cycle_count: int = 0
    last_domain: str = ""
    total_experiments: int = 0
    successful_proofs: int = 0
    integration_history: List[Dict] = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2)

    @classmethod
    def from_json(cls, raw: str) -> "OrchestratorState":
        return cls(**json.loads(raw))


@dataclass
class InFlightJob:
    """Track a job from concept creation through Aristotle result."""
    exp_id: str
    cycle_n: int
    concept: Any  # ResearchConcept
    prompt: str
    lean_source: str
    references: List[str]
    project_dir: Path
    project_id: Optional[str] = None
    status: str = "prepared"  # prepared | queued | running | complete | failed | timeout
    dispatch_time: float = 0.0
    complete_time: Optional[float] = None
    result_path: Optional[Path] = None
    error_message: Optional[str] = None


class PiAgentOrchestrator:
    """v3: Pi-Agent is the brain. The orchestrator is the body.

    The orchestrator handles I/O (filesystem, git, Aristotle API, ollama).
    Pi-Agent handles ALL decisions (domain, concept, prompt, quality, placement).

    Supports parallel mode: dispatch up to max_jobs to Aristotle concurrently,
    poll for completions, process results as they arrive.
    """

    def __init__(
        self,
        config: Dict[str, Any],
        domains_config: Dict[str, Any],
        workspace: Path,
    ):
        self.config = config
        self.domains = domains_config.get("domains", [])
        self.global_settings = domains_config.get("global_settings", {})
        self.domains_config = domains_config
        self.workspace = Path(workspace)
        self.workspace.mkdir(parents=True, exist_ok=True)

        # Paths
        self.catalog_root = Path(config.get("catalog", {}).get("root_dir", "../Catalog")).resolve()
        if not self.catalog_root.exists():
            self.catalog_root = (Path(__file__).parent.parent / "Catalog").resolve()
        self.state_path = self.workspace / "orchestrator_state.json"
        self.output_dir = self.workspace / "output"
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # State
        self.state = self._load_state()

        # Subsystems
        self.memory = ResearchMemory(self.workspace)

        pi_cfg = config.get("pi_agent", {})
        self.pi_agent = PiAgentClient(
            model=pi_cfg.get("model", "glm-5.1:cloud"),
            memory=self.memory,
            catalog_root=self.catalog_root,
            timeout=pi_cfg.get("timeout", 300),
            compact="cloud" in pi_cfg.get("model", "glm-5.1:cloud").lower(),
            use_ollama=pi_cfg.get("use_ollama", False),
            ollama_base_url=pi_cfg.get("ollama_base_url"),
            ollama_model=pi_cfg.get("ollama_model"),
        )

        self.catalog_analyzer = CatalogAnalyzer(self.catalog_root)
        self.aristotle = AristotleSDKClient(config.get("aristotle", {}))
        self.lean_builder = LeanCatalogBuilder(self.catalog_root)
        self.output_organizer = OutputOrganizer(
            catalog_root=self.catalog_root,
            pi_agent=self.pi_agent,
        )
        self.git = GitAutomator(self.catalog_root.parent)
        self.telemetry = TelemetryLogger(config.get("telemetry", {}))
        self.research_context = ResearchContext(self.workspace)
        self.autoresearch = AutoresearchBridge(self.workspace)

        # Initialize autoresearch session
        ar_cfg = config.get("autoresearch", {})
        if ar_cfg.get("enabled", True):
            self.autoresearch.init_session(
                name=ar_cfg.get("metric_name", "aether_concept_quality"),
                metric_name=ar_cfg.get("metric_name", "concept_quality"),
                direction=ar_cfg.get("direction", "higher"),
            )

        # Aristotle Loop: principled UCB-based prompt selection
        self.aristotle_loop = AristotleLoop(exploration_constant=1.5)

        # Control
        self._shutdown_requested = False

    def _load_state(self) -> OrchestratorState:
        if self.state_path.exists():
            try:
                return OrchestratorState.from_json(self.state_path.read_text(encoding="utf-8"))
            except Exception:
                pass
        return OrchestratorState()

    def _save_state(self) -> None:
        self.state_path.write_text(self.state.to_json(), encoding="utf-8")

    # ------------------------------------------------------------------
    # Job preparation (Pi-Agent concept generation + prompt writing)
    # ------------------------------------------------------------------

    async def _prepare_job(self, forced_domain: Optional[str] = None) -> Optional[InFlightJob]:
        """Prepare a job: generate concept, write prompt, build lean project.
        Returns InFlightJob ready for dispatch, or None if preparation fails.
        
        Retries up to 2 times if concept validation rejects the Pi-Agent output.
        """
        for attempt in range(2):  # Try LLM once, then local fallback
            result = await self._prepare_job_once(forced_domain, attempt)
            if result is not None:
                return result
            if attempt < 2:
                print(f"[Prepare] Retrying concept generation (attempt {attempt+2}/3)")
                await asyncio.sleep(5)
        return None

    async def _prepare_job_once(self, forced_domain: Optional[str] = None, attempt: int = 0) -> Optional[InFlightJob]:
        """Single attempt at preparing a job."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count
        exp_id = str(uuid.uuid4())[:8]

        print(f"\n[Prepare #{cycle_n}] exp={exp_id}")

        # Phase 1: Pi-Agent selects research direction (with Aristotle Loop guidance)
        best_strategy = self.autoresearch.get_best_strategy()

        # Use Aristotle Loop for principled domain selection
        sorry_targets = []
        sorry_files = self.catalog_analyzer.get_files_with_sorries()
        if sorry_files:
            sorry_targets = [f.relative_path for f in sorry_files[:5]]

        # Find missing cross-domain bridges for novel research targeting
        missing_bridges = self.catalog_analyzer.find_missing_bridges(limit=10)

        loop_prompt = self.aristotle_loop.select_prompt(
            forced_domain=forced_domain,
            sorry_targets=sorry_targets,
            missing_bridges=missing_bridges,
        )
        loop_domain = loop_prompt["domain"]
        loop_mode = loop_prompt["mode"]
        ucb_score = loop_prompt["ucb_score"]

        print(f"[Loop #{cycle_n}] UCB domain={loop_domain}, mode={loop_mode}, "
              f"ucb_score={ucb_score:.3f}, synergy_bonus={loop_prompt['synergy_bonus']:.3f}, "
              f"diminishing={loop_prompt['diminishing_returns']}")
        if loop_prompt["recommended_bridges"]:
            for d_exp, d_unexp, syn in loop_prompt["recommended_bridges"][:3]:
                print(f"  Bridge: {d_exp} → {d_unexp} (synergy={syn:.2f})")

        self.catalog_analyzer.invalidate_cache()
        self.catalog_analyzer.scan()

        # Build augmented domain list with research findings context
        domains_with_findings = list(self.domains)
        research_findings = self.global_settings.get("research_findings", self.domains_config.get("research_findings", {}))
        if research_findings:
            # Inject open problems as high-priority sorry_fill domains
            for problem in research_findings.get("open_problems", []):
                domains_with_findings.append({
                    "id": problem.get("id", problem.get("file", "").split("/")[-1].replace(".lean", "")),
                    "name": problem.get("description", problem.get("id", "unknown"))[:60],
                    "description": problem.get("description", ""),
                    "frontier": problem.get("description", ""),
                    "difficulty": problem.get("difficulty", "phd"),
                    "seed_concepts": [problem.get("id", "")],
                    "_is_open_problem": True,
                    "_priority_file": problem.get("file", ""),
                })

        # Inject Aristotle Loop's recommendation as a hint for Pi-Agent
        loop_hint = {
            "id": f"loop_{loop_domain}_{loop_mode}",
            "name": f"Aristotle Loop: {loop_domain} ({loop_mode})",
            "description": f"UCB-recommended direction: {loop_domain} with mode {loop_mode} "
                          f"(UCB score: {ucb_score:.2f}, synergy bonus: {loop_prompt['synergy_bonus']:.2f})",
            "frontier": loop_prompt.get("recommended_bridges", [(loop_domain, "", 0)])[0][1] if loop_prompt.get("recommended_bridges") else loop_domain,
            "difficulty": "phd" if loop_mode == "sorry_fill" else "master",
            "seed_domains": [loop_domain],
            "_is_loop_recommendation": True,
            "_ucb_score": ucb_score,
            "_recommended_mode": loop_mode,
        }
        domains_with_findings.insert(0, loop_hint)  # Priority position

        concept = self.pi_agent.select_research_direction(
            domains=domains_with_findings,
            recent_history=self._get_recent_history(),
            research_context=self.research_context.build_discoveries_prompt(),
        )
        if forced_domain:
            concept.domain = forced_domain
            # If forced domain doesn't match the concept's natural domain,
            # adjust catalog references to match the forced domain
            if concept.research_mode == "sorry_fill" and forced_domain not in (
                "pythagorean", "epythagorean", "number_theory",
            ):
                # Don't force sorry_fill onto unrelated domains
                concept.research_mode = "prove"
                concept.catalog_references = []  # Let Aristotle use the forced domain's files
        elif concept.research_mode == "prove" and loop_mode == "sorry_fill" and sorry_targets:
            # Override to sorry_fill when the Loop recommends it and there are sorry targets
            concept.research_mode = "sorry_fill"

        # Validate concept quality — reject garbage from LLM failures
        # Enhanced validation: reject concepts that will lead to trivial theorems
        is_trivial_pattern = (
            concept.novelty_estimate < 0.1 or
            concept.breakthrough_potential < 0.1 or
            concept.title.startswith("research_concept_") or
            len(concept.concept_description) < 20 or
            # Reject generic placeholder-style concepts
            "{X : Type*}" in concept.lean_guess or
            "[Inhabited X]" in concept.lean_guess or
            "True :=" in concept.lean_guess
        )
        # When mathematical_framing is missing but concept has a good description,
        # it's likely from reasoning text extraction - don't reject outright
        is_missing_framing = concept.mathematical_framing in ("", "TBD", "N/A")
        if is_missing_framing and len(concept.concept_description) < 40:
            is_trivial_pattern = True  # Too vague overall
        # Also reject if concept is too vague (no specific math)
        is_too_vague = (
            len(concept.key_references) == 0 and
            len(concept.catalog_references) == 0 and
            concept.research_mode != "sorry_fill"
        )
        if is_trivial_pattern:
            print(f"[Prepare #{cycle_n}] REJECTED low-quality concept: {concept.title} "
                  f"(novelty={concept.novelty_estimate:.2f}, breakthrough={concept.breakthrough_potential:.2f})")
            return None
        if is_too_vague and attempt > 0:
            print(f"[Prepare #{cycle_n}] REJECTED vague concept (no refs): {concept.title}")
            return None

        print(f"[Prepare #{cycle_n}] Concept: {concept.title} | Domain: {concept.domain} | Mode: {concept.research_mode}")
        print(f"[Pi-Agent] Direction response:")
        print(f"  concept_title: {concept.title}")
        print(f"  domain: {concept.domain}")
        print(f"  description: {concept.concept_description[:200]}")
        print(f"  mathematical_framing: {concept.mathematical_framing[:200]}")
        print(f"  research_mode: {concept.research_mode}")
        print(f"  novelty: {concept.novelty_estimate:.2f} | breakthrough: {concept.breakthrough_potential:.2f}")
        print(f"  catalog_references: {concept.catalog_references[:6]}")
        print(f"  key_references: {concept.key_references[:5]}")

        # Phase 2: Select @ references
        if concept.catalog_references:
            references = concept.catalog_references[:12]
        else:
            references = self.catalog_analyzer.select_references(
                concept_domain=concept.domain,
                concept_keywords=concept.key_references[:10],
                concept_description=concept.concept_description,
                research_mode=concept.research_mode,
            )

        catalog_context = self.catalog_analyzer.build_catalog_context_string(references)

        # Phase 3: Pi-Agent writes the prompt dynamically
        prompt = self.pi_agent.write_aristotle_prompt(
            concept=concept,
            catalog_references=references,
            catalog_context=catalog_context,
            recent_successes=self._get_recent_successes(),
            recent_failures=self._get_recent_failures(),
            theorem_context=self.research_context.build_theorem_context(),
        )
        print(f"[Prepare #{cycle_n}] Prompt: {len(prompt)} chars, {len(references)} @ refs")
        print(f"[Pi-Agent] Aristotle prompt (first 500 chars):")
        print(prompt[:500])
        print(f"[Pi-Agent] ... (total {len(prompt)} chars)")

        # Phase 4: Build lean project
        project_dir = self.output_dir / f"job_{exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)

        lean_source = self._generate_lean_source(concept, exp_id)

        self.lean_builder.build_lean_project(
            project_dir=project_dir,
            domain=concept.domain,
            lean_source=lean_source,
        )

        self.state.last_domain = concept.domain

        return InFlightJob(
            exp_id=exp_id,
            cycle_n=cycle_n,
            concept=concept,
            prompt=prompt,
            lean_source=lean_source,
            references=references,
            project_dir=project_dir,
        )

    # ------------------------------------------------------------------
    # Fire-and-forget dispatch
    # ------------------------------------------------------------------

    async def _dispatch_job(self, job: InFlightJob) -> None:
        """Dispatch a job to Aristotle using fire-and-forget submit_lean_project_only."""
        print(f"[Dispatch] {job.exp_id} -> Aristotle...")
        job.dispatch_time = time.time()
        try:
            project_id = await self.aristotle.submit_lean_project_only(
                prompt=job.prompt,
                project_dir=job.project_dir,
            )
            job.project_id = project_id
            job.status = "queued"
            self.state.total_experiments += 1
            print(f"[Dispatch] {job.exp_id} queued as {project_id}")
        except Exception as e:
            job.status = "failed"
            job.error_message = str(e)
            print(f"[Dispatch] {job.exp_id} FAILED: {e}")

    # ------------------------------------------------------------------
    # Polling
    # ------------------------------------------------------------------

    async def _poll_jobs(self, jobs: List[InFlightJob]) -> List[InFlightJob]:
        """Poll all in-flight jobs. Returns list of newly completed jobs."""
        completed = []
        for job in jobs:
            if job.status in ("complete", "failed", "timeout", "error", "cancelled"):
                continue
            if not job.project_id:
                continue

            try:
                info = await self.aristotle.poll_project(job.project_id)
                prev_status = job.status
                job.status = info.get("status", job.status)

                if info.get("complete"):
                    print(f"[Poll] {job.exp_id} ({job.project_id}) COMPLETE")
                    result_path = await self.aristotle.download_result(
                        job.project_id, job.project_dir
                    )
                    if result_path is None:
                        # Download failed (SSL error, etc.) — keep polling, don't mark complete yet
                        print(f"[Poll] {job.exp_id} ({job.project_id}) download failed, will retry next poll")
                        job.status = prev_status  # Keep previous status to retry
                        continue
                    job.result_path = result_path
                    job.complete_time = time.time()
                    job.status = "complete"
                    completed.append(job)
                elif info.get("error"):
                    error_msg = info.get("error", "")
                    # SSL/certificate errors are transient — don't kill the job
                    if "SSL" in error_msg or "CERTIFICATE" in error_msg or "certificate" in error_msg.lower():
                        print(f"[Poll] {job.exp_id} ({job.project_id}) transient SSL error, will retry next poll: {error_msg}")
                        # Keep the job in its previous status so we retry next poll cycle
                        job.status = prev_status
                    else:
                        print(f"[Poll] {job.exp_id} ({job.project_id}) ERROR: {error_msg}")
                        job.status = "error"
                        job.error_message = error_msg
                    completed.append(job)
                elif prev_status != job.status:
                    print(f"[Poll] {job.exp_id} ({job.project_id}) {job.status}")
                # Still queued or running — just wait
            except Exception as e:
                print(f"[Poll] {job.exp_id} poll error: {e}")

        return completed

    # ------------------------------------------------------------------
    # Process a completed job
    # ------------------------------------------------------------------

    async def _process_completed_job(self, job: InFlightJob) -> None:
        """Process a completed Aristotle job: evaluate, organize, record, git."""
        exp_id = job.exp_id
        concept = job.concept
        cycle_n = job.cycle_n
        elapsed = (job.complete_time or time.time()) - job.dispatch_time
        print(f"\n[Process] {exp_id} — start processing (elapsed={elapsed:.1f}s)")

        # Evaluate quality
        result_lean = ""
        quality_assessment = {"quality": "unknown", "should_retry": False, "confidence": 0.0, "analysis": ""}

        if job.result_path and job.result_path.exists():
            print(f"[Process] {exp_id} extracting result tarball...")
            extract_dir = job.project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            import tarfile
            with tarfile.open(job.result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            # Aristotle tarballs contain a subdirectory like job_xxx_aristotle/
            # Find the actual result directory (may be nested one level deep)
            result_dir = extract_dir
            subdirs = [d for d in extract_dir.iterdir() if d.is_dir()]
            if len(subdirs) == 1 and not (extract_dir / "Main.lean").exists():
                # Tarball had a single top-level directory — use that
                result_dir = subdirs[0]
                print(f"[Process] {exp_id} using nested result dir: {result_dir.name}")

            # Read Main.lean if present
            result_main = result_dir / "Main.lean"
            if result_main.exists():
                result_lean = result_main.read_text(encoding="utf-8")
                print(f"[Process] {exp_id} evaluating quality ({len(result_lean)} chars)...")
                quality_assessment = self.pi_agent.evaluate_result_quality(
                    result_lean=result_lean,
                    concept=concept,
                    prompt=job.prompt,
                )
                
                # ---- Lean Compilation Verification ----
                # Check if the result directory has a lakefile and can be built.
                # This is the gold standard: a theorem that compiles is real.
                result_lakefile = result_dir / "lakefile.toml"
                if result_lakefile.exists():
                    try:
                        import subprocess
                        print(f"[Process] {exp_id} verifying Lean compilation...")
                        comp_result = subprocess.run(
                            ["lake", "build", "Main"],
                            cwd=str(result_dir),
                            capture_output=True, text=True, timeout=120,
                        )
                        if comp_result.returncode == 0:
                            print(f"[Process] {exp_id} ✓ LEAN COMPILATION PASSED")
                            quality_assessment["quality"] = "substantial"
                            quality_assessment["compiles"] = True
                        else:
                            print(f"[Process] {exp_id} ✗ Lean compilation failed")
                            # Extract error count and specific error messages
                            errors = comp_result.stderr.count("error:")
                            print(f"[Process] {exp_id}   {errors} error(s)")
                            # Extract specific error lines for feedback to Pi/Aristotle
                            error_lines = [
                                l.strip() for l in comp_result.stderr.splitlines()
                                if "error:" in l.lower()
                            ][:5]  # Top 5 errors
                            for el in error_lines:
                                print(f"[Process] {exp_id}     {el[:120]}")
                            if quality_assessment.get("quality") == "substantial":
                                quality_assessment["quality"] = "partial"
                            quality_assessment["compiles"] = False
                            quality_assessment["compile_errors"] = errors
                            quality_assessment["compile_errors_detail"] = error_lines
                    except subprocess.TimeoutExpired:
                        print(f"[Process] {exp_id} Lean compilation timed out (120s)")
                        quality_assessment["compiles"] = False
                    except FileNotFoundError:
                        print(f"[Process] {exp_id} lake not found in PATH")
                        quality_assessment["compiles"] = False
                    except Exception as e:
                        print(f"[Process] {exp_id} Lean compilation error: {e}")
                        quality_assessment["compiles"] = False
                print(f"[Process] {exp_id} Quality: {quality_assessment.get('quality', 'unknown')} "
                      f"(confidence: {quality_assessment.get('confidence', 0):.2f})")
                print(f"[Pi-Agent] Quality evaluation:")
                print(f"  quality: {quality_assessment.get('quality', 'unknown')}")
                print(f"  should_retry: {quality_assessment.get('should_retry', False)}")
                print(f"  analysis: {quality_assessment.get('analysis', 'N/A')[:200]}")
            else:
                # Search for any .lean file with theorems as fallback
                lean_files = list(result_dir.rglob("*.lean"))
                main_candidates = [f for f in lean_files if f.name == "Main.lean"]
                if main_candidates:
                    result_main = main_candidates[0]
                    result_lean = result_main.read_text(encoding="utf-8")
                    print(f"[Process] {exp_id} evaluating quality from {result_main.relative_to(extract_dir)} ({len(result_lean)} chars)...")
                    quality_assessment = self.pi_agent.evaluate_result_quality(
                        result_lean=result_lean,
                        concept=concept,
                        prompt=job.prompt,
                    )
                    print(f"[Process] {exp_id} Quality: {quality_assessment.get('quality', 'unknown')} "
                          f"(confidence: {quality_assessment.get('confidence', 0):.2f})")
                    print(f"[Pi-Agent] Quality evaluation:")
                    print(f"  quality: {quality_assessment.get('quality', 'unknown')}")
                    print(f"  should_retry: {quality_assessment.get('should_retry', False)}")
                    print(f"  analysis: {quality_assessment.get('analysis', 'N/A')[:200]}")
                else:
                    print(f"[Process] {exp_id} no Main.lean in result, skipping quality eval")

            # Organize output
            print(f"[Process] {exp_id} organizing output files...")
            t0 = time.time()
            decisions, summary_data = self.output_organizer.organize_results(
                result_dir=result_dir,
                exp_id=exp_id,
                concept=concept,
                dry_run=False,
            )
            print(f"[Process] {exp_id} organized in {time.time()-t0:.1f}s")

            files_placed = []
            artifacts_placed = []
            for category, items in decisions.items():
                for d in items:
                    if d.artifact_type == "theorem":
                        files_placed.append(str(d.target_path))
                    else:
                        artifacts_placed.append(str(d.target_path))

            placed_count = len(decisions.get("theorems", []))
            paper_count = len(decisions.get("papers", []))
            demo_count = len(decisions.get("demos", []))
            visual_count = len(decisions.get("visuals", []))
            article_count = len(decisions.get("articles", []))
            print(f"[Process] {exp_id} placed: {placed_count} thms, {paper_count} papers, "
                  f"{demo_count} demos, {visual_count} visuals, {article_count} articles")

            # ---- Preserve FUTURE_DIRECTIONS.md for the next research cycle ----
            # Aristotle's future directions report feeds back into Pi's
            # concept selection, creating a self-improving research loop.
            future_dir_file = None
            for pattern in ["FUTURE_DIRECTIONS.md", "future_directions*.md"]:
                candidates = list(result_dir.glob(pattern))
                if not candidates:
                    # Also check one level deep
                    candidates = list(result_dir.rglob(pattern))
                if candidates:
                    future_dir_file = candidates[0]
                    break

            if future_dir_file and future_dir_file.exists():
                import shutil
                dest_dir = self.catalog_root / "ResearchOutput" / exp_id
                dest_dir.mkdir(parents=True, exist_ok=True)
                dest = dest_dir / "FUTURE_DIRECTIONS.md"
                shutil.copy2(future_dir_file, dest)
                print(f"[Process] {exp_id} ✓ saved FUTURE_DIRECTIONS.md for next cycle")
            else:
                print(f"[Process] {exp_id} no FUTURE_DIRECTIONS.md found in output")
        else:
            files_placed = []
            artifacts_placed = []
            print(f"[Process] {exp_id} no result tarball, status={job.status}")

        # Record
        proof_quality = quality_assessment.get("quality", "unknown")
        print(f"[Process] {exp_id} recording experiment...")

        # Count theorems and sorries from the result
        result_theorem_count = 0
        result_sorry_count = 0
        result_has_cross_domain = False
        if result_lean:
            result_theorem_count = result_lean.count("theorem ") + result_lean.count("lemma ")
            result_sorry_count = result_lean.count("sorry")
            # Check for cross-domain: imports from multiple domain directories
            import_lines = [l.strip() for l in result_lean.splitlines() if l.strip().startswith("import ")]
            import_domains = set()
            for imp in import_lines:
                for d in ["Algebra", "Bridges", "Computation", "Cryptography", "EML",
                          "Geometry", "Logic", "MachineLearning", "Physics",
                          "Pythagorean", "Shared", "Speculative", "Tropical"]:
                    if d in imp:
                        import_domains.add(d)
            result_has_cross_domain = len(import_domains) >= 2

        quality_score = self.autoresearch.evaluate_concept_quality(
            concept_title=concept.title,
            concept_domain=concept.domain,
            quality_assessment=quality_assessment,
            catalog_references=concept.catalog_references,
            research_mode=concept.research_mode,
            prompt_length=len(job.prompt),
            theorem_count=result_theorem_count,
            sorry_count=result_sorry_count,
            has_cross_domain=result_has_cross_domain,
            advances_open_problem=(concept.research_mode == "sorry_fill"),
        )

        # Record discovery in Aristotle Loop
        loop_result = self.aristotle_loop.record_discovery(
            domain=normalize_domain(concept.domain),
            mode=concept.research_mode,
            reward=quality_score,
            new_theorem_count=result_theorem_count,
            cross_domain=result_has_cross_domain,
        )
        print(f"[Loop] regret={loop_result['regret_estimate']:.3f}, "
              f"superadd={loop_result['superadditivity_ratio']:.3f}, "
              f"status={loop_result['convergence_status']}")

        if self.memory:
            mem_record = MemoryExperimentRecord(
                exp_id=exp_id,
                domain=concept.domain,
                concept_title=concept.title,
                concept_description=concept.concept_description,
                status="success" if proof_quality == "substantial" else "partial" if proof_quality == "partial" else "failure",
                files_produced=len(files_placed),
                key_theorems=[str(p) for p in files_placed[:5]],
                prompt_text=job.prompt[:500],
                proof_quality=proof_quality,
                retry_of="",
                retry_count=0,
            )
            self.memory.record(mem_record)

        self.autoresearch.log_result(
            exp_id=exp_id,
            concept_title=concept.title,
            concept_domain=concept.domain,
            research_mode=concept.research_mode,
            quality=proof_quality,
            quality_score=quality_score,
            catalog_references=concept.catalog_references,
            prompt_length=len(job.prompt),
            files_placed=len(files_placed),
        )

        # Update research context with discoveries from this cycle
        # This closes the feedback loop: discoveries inform next cycle's concept generation
        self.research_context.update_from_summary(
            exp_id=exp_id,
            cycle_n=cycle_n,
            concept_title=concept.title,
            domain=concept.domain,
            research_mode=concept.research_mode,
            quality=proof_quality,
            quality_score=quality_score,
            summary_data=summary_data,
        )
        print(f"[Process] {exp_id} research context updated "
              f"({len(self.research_context.global_theorems_proved)} total theorems, "
              f"{len(self.research_context.global_open_problems)} open problems)")

        record = ExperimentRecord(
            experiment_id=exp_id,
            arc_id=concept.domain,
            arc_name=concept.domain,
            domain=concept.domain,
            file_path=str(self.catalog_root / "Speculative" / "AutoResearch" / f"v3_{normalize_domain(concept.domain)}_{exp_id}.lean"),
            difficulty="phd",
            hypothesis_text=job.lean_source[:500],
            concept_combination=concept.key_references[:5],
            generation_latency_ms=int(elapsed * 1000),
            aristotle_job_id=job.project_id or "",
            status="proven" if proof_quality == "substantial" else proof_quality,
            proof_length_lines=len(result_lean.splitlines()) if result_lean else 0,
            novelty_score=concept.novelty_estimate,
            epicness_score=concept.breakthrough_potential,
        )
        self.telemetry.log_experiment(record)

        # Git
        success = proof_quality in ("substantial", "partial") and len(files_placed) > 0
        if success:
            commit_ok = self.git.create_commit_for_cycle(
                cycle_num=cycle_n,
                domain=concept.domain,
                concept_title=concept.title,
                changed_files=files_placed,
                artifacts=artifacts_placed,
                version="v3",
            )
            if commit_ok:
                print(f"[Process] Commit created.")
                push_ok = self.git.push()
                if push_ok:
                    print(f"[Process] Pushed to GitHub.")
            self.state.successful_proofs += 1
        else:
            print(f"[Process] No commit (quality={proof_quality}).")

        self.state.integration_history.append({
            "cycle": cycle_n,
            "exp_id": exp_id,
            "concept": concept.title,
            "domain": concept.domain,
            "research_mode": concept.research_mode,
            "quality": proof_quality,
            "quality_score": quality_score,
            "files_placed": len(files_placed),
            "artifacts_placed": len(artifacts_placed),
        })
        self._save_state()

        # Mark job as processed so --reprocess skips it
        processed_marker = job.project_dir / ".processed"
        processed_marker.write_text(f"quality={proof_quality} score={quality_score:.2f} at {datetime.now(timezone.utc).isoformat()}\\n")

        # --- NEW PHASE B LOGIC ---
        if proof_quality in ("substantial", "partial") and len(files_placed) > 0:
            print(f"[Process] {exp_id} Scheduling Phase B packaging with Aristotle in the background...")
            asyncio.create_task(self._run_phase_b(job, files_placed))

        print(f"[Process] {exp_id} done. Quality={proof_quality} Score={quality_score:.2f}")

    async def _run_phase_b(self, job: InFlightJob, files_placed: List[str]) -> None:
        """Phase B: Ask Aristotle to package the Lean 4 files into a JSON research package."""
        try:
            phase_b_dir = job.project_dir / "phase_b"
            phase_b_dir.mkdir(parents=True, exist_ok=True)
            
            import shutil
            # 1. Copy Lean files
            for f in files_placed:
                src = Path(f)
                if src.exists():
                    shutil.copy2(src, phase_b_dir / src.name)
            
            # 2. Add build files
            catalog_lakefile = self.catalog_root / "lakefile.toml"
            if catalog_lakefile.exists():
                shutil.copy2(catalog_lakefile, phase_b_dir / "lakefile.toml")
            catalog_toolchain = self.catalog_root / "lean-toolchain"
            if catalog_toolchain.exists():
                shutil.copy2(catalog_toolchain, phase_b_dir / "lean-toolchain")
                
            prompt = (
                "Phase A research is complete. The formal development produced significant mathematical results, "
                "which are provided in this project. Please perform Phase B: write the ARTICLE.md and "
                "RESEARCH_PAPER.md as standalone, publication-ready documents that communicate the mathematics "
                "to human readers, and bundle everything into a valid PACKAGE.json research package (with all "
                "schema fields populated: demos, algorithms, visualizations, interactive_demos, lean_proofs, "
                "future_directions, etc.). "
                "CRITICAL — STANDALONE PUBLICATION: The ARTICLE.md and RESEARCH_PAPER.md must be fully "
                "self-contained and publication-ready. NEVER mention Lean, proof assistants, the Catalog, "
                "source file paths, or formal-proof identifier names. State every theorem and result inline "
                "in natural mathematical prose with full statements and proof sketches; do NOT reference any "
                "file or use code identifiers like `pl_hodge_decomposition`. A reader must understand the work "
                "from the document alone. "
                "CRITICAL: You must create AT LEAST 3 (but more is allowed) of every category: interactive_demos (Interactive html), visualizations, algorithms, and python demos (demos)."
            )
            
            # 3. Submit and wait
            print(f"[Phase B] {job.exp_id} submitting Phase B job...")
            phase_b_result = await self.aristotle.submit_lean_project(
                prompt=prompt,
                project_dir=phase_b_dir
            )
            
            if phase_b_result.result_path:
                print(f"[Phase B] {job.exp_id} complete. Extracting PACKAGE.json...")
                import tarfile
                extract_b_dir = phase_b_dir / "result_extracted"
                extract_b_dir.mkdir(exist_ok=True)
                with tarfile.open(phase_b_result.result_path, "r:gz") as tar:
                    tar.extractall(path=extract_b_dir)
                
                pkg_jsons = list(extract_b_dir.rglob("PACKAGE.json")) + list(extract_b_dir.rglob("package.json"))
                if pkg_jsons:
                    from archive_manager import ArchiveManager
                    am = ArchiveManager(self.catalog_root.parent / "Archive")
                    pkg_text = pkg_jsons[0].read_text(encoding="utf-8")
                    
                    # Inject reasoning traces from Phase A into the package metadata
                    if job.project_id:
                        try:
                            import json
                            import aristotlelib
                            pkg_data = json.loads(pkg_text)
                            reasoning_traces = []
                            print(f"[Phase B] Fetching Phase A reasoning traces from project {job.project_id}...")
                            
                            project = await aristotlelib.Project.from_id(job.project_id)
                            tasks, _ = await project.get_tasks()
                            for task in tasks:
                                # Fetch events oldest-first so they're in chronological order
                                events, _ = await task.get_events(limit=100, newest_first=False)
                                for e in events:
                                    if e.event_type.name == "THINKING":
                                        trace_text = e.explanation or e.content
                                        if trace_text:
                                            reasoning_traces.append(trace_text)
                                            
                            if reasoning_traces:
                                pkg_data["reasoning_traces"] = reasoning_traces
                                pkg_text = json.dumps(pkg_data, indent=2)
                                print(f"[Phase B] Attached {len(reasoning_traces)} reasoning trace(s) to PACKAGE.json.")
                        except Exception as e:
                            print(f"[Phase B] Failed to attach reasoning traces: {e}")

                    am.store_package(job.exp_id, pkg_text)
                    print(f"[Phase B] {job.exp_id} PACKAGE.json stored in archive!")
                else:
                    print(f"[Phase B] {job.exp_id} finished but no PACKAGE.json found.")
            else:
                print(f"[Phase B] {job.exp_id} failed or no result: {phase_b_result.status}")
        except Exception as e:
            print(f"[Phase B] {job.exp_id} Error in Phase B: {e}")

    # ------------------------------------------------------------------
    # Single cycle (for --single-cycle mode, still uses blocking dispatch)
    # ------------------------------------------------------------------

    async def run_single_cycle(self, forced_domain: Optional[str] = None, dry_run: bool = False) -> bool:
        """Run one complete research cycle sequentially."""
        job = await self._prepare_job(forced_domain=forced_domain)
        if not job:
            return False

        if dry_run:
            print(f"\n[DRY RUN] Concept: {job.concept.title}")
            print(f"  Domain: {job.concept.domain} | Mode: {job.concept.research_mode}")
            print(f"  References: {job.references}")
            print(f"  Prompt: {len(job.prompt)} chars")
            self._save_state()
            return True

        # Dispatch and wait
        await self._dispatch_job(job)

        if job.status == "failed":
            return False

        # Poll until complete — no timeout, Aristotle can take hours
        poll_interval = self.config.get("aristotle", {}).get("polling_interval_seconds", 30)
        poll_count = 0

        while job.status not in ("complete", "failed", "timeout", "error", "cancelled"):
            completed = await self._poll_jobs([job])
            poll_count += 1
            if completed:
                break
            if poll_count % 10 == 0:
                elapsed = time.time() - job.dispatch_time
                print(f"[Poll] {job.exp_id} still {job.status} after {elapsed:.0f}s ({poll_count} polls)")
            await asyncio.sleep(poll_interval)

        if job.status in ("complete",):
            await self._process_completed_job(job)
            return True
        else:
            print(f"[Cycle] Job {job.exp_id} ended with status: {job.status}")
            return False

    # ------------------------------------------------------------------
    # Continuous parallel mode (the main production mode)
    # ------------------------------------------------------------------

    async def run_continuous(self, max_jobs: int = 10) -> None:
        """Run continuously with parallel dispatching to Aristotle.

        Keeps up to max_jobs in flight at all times:
        1. Prepare new jobs (Pi-Agent concept + prompt)
        2. Dispatch to Aristotle (fire-and-forget)
        3. Poll all in-flight jobs
        4. Process completed jobs as they arrive
        5. Fill the queue back up to max_jobs
        6. Repeat
        """
        poll_interval = self.config.get("aristotle", {}).get("polling_interval_seconds", 30)
        fill_batch = max(1, max_jobs // 3)  # prepare this many jobs per fill cycle

        print("=" * 70)
        print("AETHER v3: PI-AGENT CENTERED RESEARCH ENGINE (PARALLEL)")
        print(f"Workspace: {self.workspace}")
        print(f"Catalog: {self.catalog_root}")
        print(f"Model: {self.pi_agent.model}")
        print(f"Max jobs: {max_jobs}")
        print(f"Poll interval: {poll_interval}s")
        print("Press Ctrl+C to shutdown.")
        print("=" * 70)

        in_flight: List[InFlightJob] = []

        while not self._shutdown_requested:
            # --- Fill the queue up to max_jobs ---
            slots = max_jobs - len(in_flight)
            if slots > 0:
                # Prepare and dispatch in batches
                for _ in range(min(slots, fill_batch)):
                    try:
                        job = await self._prepare_job()
                        if job:
                            await self._dispatch_job(job)
                            if job.project_id:
                                in_flight.append(job)
                            else:
                                print(f"[Queue] {job.exp_id} dispatch failed, skipping")
                    except Exception as e:
                        print(f"[ERROR] Prepare/dispatch failed: {e}")
                        import traceback
                        traceback.print_exc()

            if self._shutdown_requested:
                break

            print(f"[Queue] {len(in_flight)}/{max_jobs} jobs in flight")

            # --- Poll all in-flight jobs ---
            try:
                completed = await self._poll_jobs(in_flight)
            except Exception as e:
                print(f"[ERROR] Poll failed: {e}")
                completed = []

            # --- Process completed jobs ---
            for job in completed:
                try:
                    if job.status == "complete":
                        await self._process_completed_job(job)
                    else:
                        print(f"[Process] {job.exp_id} ended: {job.status} — skipping")
                except Exception as e:
                    print(f"[ERROR] Processing {job.exp_id} failed: {e}")
                    import traceback
                    traceback.print_exc()
                in_flight.remove(job)

            # Remove permanently failed jobs from queue
            failed = [j for j in in_flight if j.status in ("failed", "error", "cancelled")]
            for j in failed:
                print(f"[Queue] Removing failed job {j.exp_id} ({j.status})")
                in_flight.remove(j)

            # --- Sleep before next poll ---
            if in_flight or not self._shutdown_requested:
                await asyncio.sleep(poll_interval)

        # --- Drain remaining jobs at shutdown ---
        if in_flight:
            print(f"[Shutdown] Waiting for {len(in_flight)} remaining jobs...")
            while in_flight and not self._shutdown_requested:
                completed = await self._poll_jobs(in_flight)
                for job in completed:
                    try:
                        if job.status == "complete":
                            await self._process_completed_job(job)
                    except Exception as e:
                        print(f"[ERROR] Final processing {job.exp_id}: {e}")
                    in_flight.remove(job)
                if in_flight:
                    await asyncio.sleep(poll_interval)

        print("[ORCHESTRATOR] Shutdown complete.")
        self._save_state()

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _generate_lean_source(self, concept: ResearchConcept, exp_id: str) -> str:
        """Generate Lean source from concept.

        Key: the generated file must give Aristotle something real to work with.
        A stub `True := by sorry` is useless — Aristotle needs a concrete
        theorem statement with real types (Nat, Real, Finset, Matrix) and
        a meaningful conclusion to prove.

        IMPORTANT: The actual research happens in the CATALOG FILES referenced
        in the prompt. This Main.lean is a placeholder that compiles cleanly.
        Aristotle reads the prompt, studies the catalog files, and fills sorries
        or adds new theorems there. This file just needs to be valid Lean 4.
        """
        domain_dir = normalize_domain(concept.domain)
        header = f"""import Mathlib

/-! # CatalogBuild.Speculative.AutoResearch.{concept.title}

Auto-generated by Aether v3 (Pi-Agent + Aristotle).
Domain: {domain_dir}
Mode: {concept.research_mode}
Novelty: {concept.novelty_estimate:.2f}
Experiment: {exp_id}
Date: {datetime.now(timezone.utc).isoformat()}
-/

/-
{concept.concept_description}

Mathematical Framing: {concept.mathematical_framing}

NOTE: The real work for this experiment happens in the catalog files
referenced in the research prompt. This file is a valid placeholder.
-/
"""
        lean_body = concept.lean_guess.strip()
        has_real_theorem = (
            lean_body and
            "theorem" in lean_body and
            "True :=" not in lean_body and
            "sorry" not in lean_body
        )

        if has_real_theorem:
            # Pi-Agent provided a compilable theorem — use it
            return header + f"noncomputable section\n\n{lean_body}\n"
        else:
            # No compilable theorem from Pi-Agent.
            # Create a minimal valid placeholder that compiles cleanly.
            # Aristotle's real work is in the catalog files.
            title_slug = concept.title.lower().replace(' ', '_').replace('-', '_')
            import re
            title_slug = re.sub(r'[^a-z0-9_]', '', title_slug)

            if concept.research_mode == "sorry_fill":
                # For sorry_fill, the target is the catalog files.
                # This placeholder compiles but doesn't need to prove anything.
                lean_body = f"""-- The sorry_fill target is in the catalog files referenced in the prompt.
-- See: {', '.join(concept.catalog_references[:3]) if concept.catalog_references else 'referenced files'}
-- Aristotle: fill the sorries in those files, not here.

/-- Placeholder for {concept.title} — the real proof target is in the catalog. -/
theorem {title_slug}_placeholder : True := trivial
"""
            else:
                # For prove/formalize, ask Aristotle to prove something in this file
                # OR in the catalog files.
                lean_body = f"""-- Aristotle: prove a non-trivial theorem related to
-- {concept.title}
-- Use concrete types (Nat, Real, Finset, Matrix) and avoid tautologies.
-- You may also add new theorems to catalog files.

theorem {title_slug}_placeholder : True := trivial
"""
            return header + f"\n{lean_body}"

    def _get_recent_history(self, limit: int = 10) -> List[Dict]:
        """Get recent experiment history for Pi-Agent context."""
        history = []
        for entry in self.state.integration_history[-limit:]:
            history.append({
                "cycle": entry.get("cycle"),
                "concept": entry.get("concept", ""),
                "domain": entry.get("domain", ""),
                "research_mode": entry.get("research_mode", "prove"),
                "quality": entry.get("quality", "unknown"),
                "quality_score": entry.get("quality_score", 0.0),
            })
        return history

    def _get_recent_successes(self, limit: int = 5) -> List[Dict]:
        """Get recent successful experiments."""
        return [
            h for h in self._get_recent_history(limit=20)
            if h.get("quality") in ("substantial", "partial")
        ][:limit]

    def _get_recent_failures(self, limit: int = 5) -> List[Dict]:
        """Get recent failed experiments."""
        return [
            h for h in self._get_recent_history(limit=20)
            if h.get("quality") in ("trivial", "unknown")
        ][:limit]

    def request_shutdown(self) -> None:
        print("[ORCHESTRATOR] Shutdown requested...")
        self._shutdown_requested = True

    # ------------------------------------------------------------------
    # Reprocess unfinished jobs from previous runs
    # ------------------------------------------------------------------

    async def reprocess_unfinished_jobs(self) -> int:
        """Scan workspace for job directories with result.tar.gz that haven't
        been processed yet, and process them.

        This handles the case where the orchestrator was killed or timed out
        before processing completed Aristotle results.

        Returns the number of jobs processed.
        """
        print("\n" + "=" * 70)
        print("AETHER v3: REPROCESSING UNFINISHED JOBS")
        print("=" * 70)

        processed = 0
        job_dirs = sorted(self.output_dir.glob("job_*"))

        for job_dir in job_dirs:
            exp_id = job_dir.name.replace("job_", "")
            result_tar = job_dir / "result.tar.gz"
            processed_marker = job_dir / ".processed"

            # Skip if no result or already processed
            if not result_tar.exists():
                continue
            if processed_marker.exists():
                continue

            print(f"\n[Reprocess] Found unprocessed result: {exp_id}")

            # Extract the tarball to get context
            extract_dir = job_dir / "result_extracted"
            if not extract_dir.exists():
                extract_dir.mkdir(exist_ok=True)
                import tarfile
                with tarfile.open(result_tar, "r:gz") as tar:
                    tar.extractall(path=extract_dir)

            # Find the actual result directory (may be nested)
            result_dir = extract_dir
            subdirs = [d for d in extract_dir.iterdir() if d.is_dir()]
            if len(subdirs) == 1 and not (extract_dir / "Main.lean").exists():
                result_dir = subdirs[0]

            # Try to extract concept info from ARISTOTLE_SUMMARY.md
            domain = "unknown"
            concept_title = f"reprocessed_{exp_id}"
            summary_data = self.output_organizer._parse_aristotle_summary(result_dir)
            if summary_data:
                domains = summary_data.get("domains_touched", [])
                if domains:
                    domain = domains[0]
                theorems = summary_data.get("key_theorems", [])
                if theorems:
                    concept_title = theorems[0]

            # Try to read Main.lean for lean_source
            result_lean = ""
            result_main = result_dir / "Main.lean"
            if result_main.exists():
                result_lean = result_main.read_text(encoding="utf-8", errors="replace")

            concept = ResearchConcept(
                title=concept_title,
                domain=domain,
                concept_description=f"Reprocessed from previous run (exp {exp_id})",
                mathematical_framing="",
                lean_guess=result_lean[:500] if result_lean else "",
                research_mode="prove",
            )
            job = InFlightJob(
                exp_id=exp_id,
                cycle_n=self.state.cycle_count,
                concept=concept,
                prompt="(reprocessed)",
                lean_source=result_lean[:500] if result_lean else "",
                references=[],
                project_dir=job_dir,
                status="complete",
                dispatch_time=0.0,
                complete_time=time.time(),
                result_path=result_tar,
            )

            try:
                await self._process_completed_job(job)
                # Mark as processed
                processed_marker.write_text(f"reprocessed at {datetime.now(timezone.utc).isoformat()}\n")
                processed += 1
                self.state.cycle_count += 1
            except Exception as e:
                print(f"[Reprocess] Error processing {exp_id}: {e}")
                import traceback
                traceback.print_exc()

        if processed:
            self._save_state()
            print(f"\n[Reprocess] Processed {processed} previously unfinished jobs")
        else:
            print(f"\n[Reprocess] No unfinished jobs found")

        return processed


async def main():
    parser = argparse.ArgumentParser(description="Aether v3: Pi-Agent Centered Research Engine")
    parser.add_argument("--config", default="config.yaml", help="Path to config.yaml")
    parser.add_argument("--domains", default="research_domains.json", help="Path to research_domains.json")
    parser.add_argument("--workspace", default="../workspace", help="Workspace directory")
    parser.add_argument("--single-cycle", action="store_true", help="Run one cycle and exit")
    parser.add_argument("--domain", help="Force a specific domain")
    parser.add_argument("--dry-run", action="store_true", help="Generate but do not dispatch")
    parser.add_argument("--max-jobs", type=int, default=10, help="Max concurrent Aristotle jobs (default: 10)")
    parser.add_argument("--poll-interval", type=int, default=30, help="Seconds between polls (default: 30)")
    parser.add_argument("--reprocess", action="store_true", help="Reprocess unfinished jobs with result.tar.gz from previous runs")

    args = parser.parse_args()

    config_path = Path(args.config)
    config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}

    domains_path = Path(args.domains)
    domains_config = json.loads(domains_path.read_text(encoding="utf-8")) if domains_path.exists() else {}

    # Override paths
    config["catalog"] = config.get("catalog", {})
    config["catalog"]["root_dir"] = config["catalog"].get("root_dir", "../Catalog")

    # Apply CLI overrides
    if args.poll_interval:
        config.setdefault("aristotle", {})["polling_interval_seconds"] = args.poll_interval

    orchestrator = PiAgentOrchestrator(
        config=config,
        domains_config=domains_config,
        workspace=Path(args.workspace).resolve(),
    )

    if args.reprocess:
        count = await orchestrator.reprocess_unfinished_jobs()
        sys.exit(0 if count >= 0 else 1)
    elif args.single_cycle:
        success = await orchestrator.run_single_cycle(
            forced_domain=args.domain,
            dry_run=args.dry_run,
        )
        sys.exit(0 if success else 1)
    else:
        loop = asyncio.get_event_loop()
        for sig in (__import__("signal").SIGINT, __import__("signal").SIGTERM):
            loop.add_signal_handler(sig, orchestrator.request_shutdown)
        try:
            await orchestrator.run_continuous(
                max_jobs=args.max_jobs,
            )
        except asyncio.CancelledError:
            pass


if __name__ == "__main__":
    asyncio.run(main())

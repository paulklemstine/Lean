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

The orchestrator is the I/O body — it handles filesystem, git,
Aristotle API, and coordination. Pi-Agent is the brain.

Usage:
    python3 -m aether.pi_orchestrator --single-cycle
    python3 -m aether.pi_orchestrator --single-cycle --domain algebra --dry-run
    python3 -m aether.pi_orchestrator --continuous
    python3 -m aether.pi_orchestrator --continuous --parallel --max-jobs 3
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
from telemetry import TelemetryLogger, ExperimentRecord
from git_automator import GitAutomator


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
class CycleResult:
    """Result of one complete research cycle."""
    cycle_id: str
    domain: str
    concept_title: str
    research_mode: str
    aristotle_project_id: str = ""
    aristotle_status: str = ""
    files_placed: List[str] = field(default_factory=list)
    artifacts_placed: List[str] = field(default_factory=list)
    prompt_hash: str = ""
    catalog_references: List[str] = field(default_factory=list)
    proof_quality: str = ""  # "trivial" | "partial" | "substantial"
    quality_score: float = 0.0
    elapsed_seconds: float = 0.0
    retry_of: str = ""
    retry_count: int = 0


class PiAgentOrchestrator:
    """v3: Pi-Agent is the brain. The orchestrator is the body.

    The orchestrator handles I/O (filesystem, git, Aristotle API, ollama).
    Pi-Agent handles ALL decisions (domain, concept, prompt, quality, placement).
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
        self.autoresearch = AutoresearchBridge(self.workspace)

        # Initialize autoresearch session
        ar_cfg = config.get("autoresearch", {})
        if ar_cfg.get("enabled", True):
            self.autoresearch.init_session(
                name=ar_cfg.get("metric_name", "aether_concept_quality"),
                metric_name=ar_cfg.get("metric_name", "concept_quality"),
                direction=ar_cfg.get("direction", "higher"),
            )

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

    async def run_single_cycle(self, forced_domain: Optional[str] = None, dry_run: bool = False) -> bool:
        """Run one complete research cycle. Pi-Agent drives all decisions."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count
        exp_id = str(uuid.uuid4())[:8]
        start_time = time.time()

        print(f"\n{'='*70}")
        print(f"AETHER v3 — Cycle #{cycle_n} (exp={exp_id})")
        print(f"{'='*70}")

        # ---------------------------------------------------------------
        # Phase 1: ANALYZE — Pi-Agent selects research direction
        # ---------------------------------------------------------------
        print(f"[Phase 1] Pi-Agent analyzing catalog and selecting direction...")

        # Get optimization hints from autoresearch
        best_strategy = self.autoresearch.get_best_strategy()
        print(f"[Phase 1] Best strategy: domain={best_strategy['best_domain']}, "
              f"mode={best_strategy['best_research_mode']}, "
              f"success_rate={best_strategy['success_rate']:.1%}")

        # Scan catalog for @ references
        self.catalog_analyzer.scan()
        print(f"[Phase 1] Catalog scanned: {len(self.catalog_analyzer._summaries or [])} files")

        # Pi-Agent selects direction
        concept = self.pi_agent.select_research_direction(
            domains=self.domains,
            recent_history=self._get_recent_history(),
        )
        print(f"[Phase 1] Concept: {concept.title}")
        print(f"[Phase 1] Domain: {concept.domain}, Mode: {concept.research_mode}")
        print(f"[Phase 1] Novelty: {concept.novelty_estimate:.2f}, "
              f"Breakthrough: {concept.breakthrough_potential:.2f}")

        # Override domain if forced
        if forced_domain:
            concept.domain = forced_domain
            print(f"[Phase 1] Domain overridden to: {forced_domain}")

        # ---------------------------------------------------------------
        # Phase 2: REFERENCE — Select @ file references
        # ---------------------------------------------------------------
        print(f"[Phase 2] Selecting @ file references...")

        # Use Pi-Agent's references if provided, otherwise select from catalog
        if concept.catalog_references:
            references = concept.catalog_references[:12]
            print(f"[Phase 2] Using Pi-Agent's references: {references[:5]}...")
        else:
            references = self.catalog_analyzer.select_references(
                concept_domain=concept.domain,
                concept_keywords=concept.key_references[:10],
                concept_description=concept.concept_description,
                research_mode=concept.research_mode,
            )
            print(f"[Phase 2] Selected {len(references)} references from catalog analysis")

        # Build catalog context string
        catalog_context = self.catalog_analyzer.build_catalog_context_string(references)

        # ---------------------------------------------------------------
        # Phase 3: WRITE — Pi-Agent dynamically writes Aristotle prompt
        # ---------------------------------------------------------------
        print(f"[Phase 3] Pi-Agent writing Aristotle prompt...")

        prompt = self.pi_agent.write_aristotle_prompt(
            concept=concept,
            catalog_references=references,
            catalog_context=catalog_context,
            recent_successes=self._get_recent_successes(),
            recent_failures=self._get_recent_failures(),
        )
        print(f"[Phase 3] Prompt: {len(prompt)} chars, {len(references)} @ references")

        if dry_run:
            print(f"\n[DRY RUN] Stopping before dispatch.")
            print(f"  Concept: {concept.title}")
            print(f"  Domain: {concept.domain}")
            print(f"  Mode: {concept.research_mode}")
            print(f"  References: {references}")
            print(f"  Prompt length: {len(prompt)} chars")
            self._save_state()
            return True

        # ---------------------------------------------------------------
        # Phase 4: BUILD & DISPATCH — Lean project + Aristotle
        # ---------------------------------------------------------------
        print(f"[Phase 4] Building lean-only catalog...")
        project_dir = self.output_dir / f"job_{exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)

        # Generate lean source from concept
        lean_source = self._generate_lean_source(concept, exp_id)
        print(f"[Phase 4] Lean source: {len(lean_source)} chars")

        # Build the lean-only project with full catalog context
        self.lean_builder.build_lean_project(
            project_dir=project_dir,
            domain=concept.domain,
            lean_source=lean_source,
        )

        print(f"[Phase 4] Dispatching to Aristotle...")
        dispatch_start = time.time()
        result = await self.aristotle.submit_lean_project(
            prompt=prompt,
            project_dir=project_dir,
        )
        dispatch_elapsed = time.time() - dispatch_start
        print(f"[Phase 4] Aristotle: {result.status} ({dispatch_elapsed:.1f}s)")
        if result.error_message:
            print(f"[Phase 4] Error: {result.error_message}")

        self.state.total_experiments += 1

        # ---------------------------------------------------------------
        # Phase 5: EVALUATE — Pi-Agent assesses result quality
        # ---------------------------------------------------------------
        result_lean = result.lean_source or ""
        quality_assessment = {"quality": "unknown", "should_retry": False, "confidence": 0.0, "analysis": ""}

        if result_lean:
            print(f"[Phase 5] Pi-Agent evaluating result quality...")
            quality_assessment = self.pi_agent.evaluate_result_quality(
                result_lean=result_lean,
                concept=concept,
                prompt=prompt,
            )
            print(f"[Phase 5] Quality: {quality_assessment.get('quality', 'unknown')} "
                  f"(confidence: {quality_assessment.get('confidence', 0):.2f})")
            print(f"[Phase 5] Analysis: {quality_assessment.get('analysis', 'N/A')[:200]}")
        else:
            print(f"[Phase 5] No Lean source in result. Skipping quality evaluation.")

        # Retry logic
        proof_quality = quality_assessment.get("quality", "unknown")
        should_retry = quality_assessment.get("should_retry", False) and concept.research_mode != "sorry_fill"
        max_retries = self.global_settings.get("max_retries_per_cycle", 2)

        if should_retry and self.state.cycle_count <= max_retries + 1:
            print(f"[Phase 5] Quality insufficient. Requesting retry from Pi-Agent...")
            retry_result = self.pi_agent.suggest_retry_improvement(
                concept=concept,
                previous_prompt=prompt,
                result_lean=result_lean,
                quality_assessment=quality_assessment,
            )
            if retry_result.get("confidence", 0) >= 0.5:
                # Update concept with revised info
                concept.concept_description = retry_result.get(
                    "revised_concept_description", concept.concept_description
                )
                concept.research_mode = retry_result.get(
                    "revised_research_mode", concept.research_mode
                )
                concept.catalog_references = retry_result.get(
                    "revised_catalog_references", concept.catalog_references
                )
                prompt = retry_result.get("revised_prompt", prompt)
                print(f"[Phase 5] Retry with revised concept. Mode: {concept.research_mode}")
            else:
                print(f"[Phase 5] Retry confidence too low. Proceeding with original.")

        # ---------------------------------------------------------------
        # Phase 6: ORGANIZE — Place output files professionally
        # ---------------------------------------------------------------
        files_placed = []
        artifacts_placed = []

        if result.result_path and result.result_path.exists():
            print(f"[Phase 6] Organizing output files...")
            extract_dir = project_dir / "result_extracted"
            extract_dir.mkdir(exist_ok=True)
            import tarfile
            with tarfile.open(result.result_path, "r:gz") as tar:
                tar.extractall(path=extract_dir)

            decisions = self.output_organizer.organize_results(
                result_dir=extract_dir,
                exp_id=exp_id,
                concept=concept,
                dry_run=False,
            )

            # Summarize placement
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
            print(f"[Phase 6] Placed: {placed_count} theorems, {paper_count} papers, "
                  f"{demo_count} demos, {visual_count} visuals, {article_count} articles")

            manifest = self.output_organizer.generate_manifest(decisions, exp_id)
            manifest_path = self.workspace / f"manifest_{exp_id}.json"
            manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        else:
            print(f"[Phase 6] No result tarball. Status: {result.status}")

        # ---------------------------------------------------------------
        # Phase 7: RECORD — ResearchMemory, Telemetry, Autoresearch
        # ---------------------------------------------------------------
        print(f"[Phase 7] Recording experiment...")

        # Calculate quality score for autoresearch
        quality_score = self.autoresearch.evaluate_concept_quality(
            concept_title=concept.title,
            concept_domain=concept.domain,
            quality_assessment=quality_assessment,
            catalog_references=concept.catalog_references,
            research_mode=concept.research_mode,
            prompt_length=len(prompt),
        )

        # Record in ResearchMemory
        if self.memory:
            mem_record = MemoryExperimentRecord(
                exp_id=exp_id,
                domain=concept.domain,
                concept_title=concept.title,
                concept_description=concept.concept_description,
                status="success" if proof_quality == "substantial" else "partial" if proof_quality == "partial" else "failure",
                files_produced=len(files_placed),
                key_theorems=[str(p) for p in files_placed[:5]],
                prompt_text=prompt[:500],
                proof_quality=proof_quality,
                retry_of="",
                retry_count=0,
            )
            self.memory.record(mem_record)

        # Record in Autoresearch
        self.autoresearch.log_result(
            exp_id=exp_id,
            concept_title=concept.title,
            concept_domain=concept.domain,
            research_mode=concept.research_mode,
            quality=proof_quality,
            quality_score=quality_score,
            catalog_references=concept.catalog_references,
            prompt_length=len(prompt),
            files_placed=len(files_placed),
        )

        # Record in Telemetry
        record = ExperimentRecord(
            experiment_id=exp_id,
            arc_id=concept.domain,
            arc_name=concept.domain,
            domain=concept.domain,
            file_path=str(self.catalog_root / "Speculative" / "AutoResearch" / f"v3_{concept.domain}_{exp_id}.lean"),
            difficulty="phd",
            hypothesis_text=lean_source[:500],
            concept_combination=concept.key_references[:5],
            generation_latency_ms=int((time.time() - start_time) * 1000),
            aristotle_job_id=result.project_id or "",
            status="proven" if proof_quality == "substantial" else proof_quality,
            proof_length_lines=len(result_lean.splitlines()) if result_lean else 0,
            novelty_score=concept.novelty_estimate,
            epicness_score=concept.breakthrough_potential,
        )
        self.telemetry.log_experiment(record)

        # ---------------------------------------------------------------
        # Phase 8: GIT — Commit and push
        # ---------------------------------------------------------------
        success = proof_quality in ("substantial", "partial") and len(files_placed) > 0

        if success:
            print(f"[Phase 8] Git operations...")
            commit_ok = self.git.create_commit_for_cycle(
                cycle_num=cycle_n,
                domain=concept.domain,
                concept_title=concept.title,
                changed_files=files_placed,
                artifacts=artifacts_placed,
                version="v3",
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
                "concept": concept.title,
                "domain": concept.domain,
                "research_mode": concept.research_mode,
                "quality": proof_quality,
                "quality_score": quality_score,
                "files_placed": len(files_placed),
                "artifacts_placed": len(artifacts_placed),
            })
        else:
            print(f"[Phase 8] No changes to commit (quality={proof_quality}).")

        self.state.last_domain = concept.domain
        self._save_state()

        elapsed = time.time() - start_time
        print(f"\n{'='*70}")
        print(f"CYCLE #{cycle_n} COMPLETE ({elapsed:.1f}s)")
        print(f"  Concept: {concept.title}")
        print(f"  Domain: {concept.domain} | Mode: {concept.research_mode}")
        print(f"  Quality: {proof_quality} ({quality_score:.2f})")
        print(f"  Files: {len(files_placed)} placed, {len(artifacts_placed)} artifacts")
        print(f"{'='*70}")

        return proof_quality in ("substantial", "partial")

    async def run_continuous(self, parallel: bool = False, max_jobs: int = 3) -> None:
        """Run continuous cycles until shutdown."""
        interval = self.global_settings.get("cycle_interval_seconds", 300)

        print("=" * 70)
        print("AETHER v3: PI-AGENT CENTERED RESEARCH ENGINE")
        print(f"Workspace: {self.workspace}")
        print(f"Catalog: {self.catalog_root}")
        print(f"Model: {self.pi_agent.model}")
        print(f"Mode: {'PARALLEL' if parallel else 'SEQUENTIAL'}")
        print("Press Ctrl+C to shutdown.")
        print("=" * 70)

        while not self._shutdown_requested:
            try:
                await self.run_single_cycle()
            except KeyboardInterrupt:
                print("\n[SHUTDOWN] Ctrl+C received.")
                self._shutdown_requested = True
                break
            except Exception as e:
                print(f"[ERROR] Cycle failed: {e}")
                import traceback
                traceback.print_exc()

            if self._shutdown_requested:
                break

            print(f"[ORCHESTRATOR] Sleeping {interval}s before next cycle...")
            await asyncio.sleep(interval)

        print("[ORCHESTRATOR] Shutdown complete.")
        self._save_state()

    def _generate_lean_source(self, concept: ResearchConcept, exp_id: str) -> str:
        """Generate Lean source from concept."""
        header = f"""import Mathlib

/-! # CatalogBuild.Speculative.AutoResearch.{concept.title}

Auto-generated by Aether v3 (Pi-Agent + Aristotle).
Domain: {concept.domain}
Mode: {concept.research_mode}
Novelty: {concept.novelty_estimate:.2f}
Experiment: {exp_id}
Date: {datetime.now(timezone.utc).isoformat()}
-/

/-
{concept.concept_description}

Mathematical Framing: {concept.mathematical_framing}
-/
"""
        lean_body = concept.lean_guess.strip()
        if not lean_body or "theorem" not in lean_body:
            lean_body = f"""-- TODO: Aristotle — replace this stub with a genuine, non-trivial theorem.
-- Use concrete types (Nat, Real, Matrix, Finset) not True/Prop tautologies.
theorem {concept.title.lower().replace(' ', '_')}_breakthrough
    {{X : Type*}} [Inhabited X] :
    True := by
  sorry
"""
        if "sorry" not in lean_body and concept.research_mode != "sorry_fill":
            lean_body += "\n  sorry\n"
        return header + "\n" + lean_body

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


async def main():
    parser = argparse.ArgumentParser(description="Aether v3: Pi-Agent Centered Research Engine")
    parser.add_argument("--config", default="config.yaml", help="Path to config.yaml")
    parser.add_argument("--domains", default="research_domains.json", help="Path to research_domains.json")
    parser.add_argument("--workspace", default="../workspace", help="Workspace directory")
    parser.add_argument("--single-cycle", action="store_true", help="Run one cycle and exit")
    parser.add_argument("--domain", help="Force a specific domain")
    parser.add_argument("--dry-run", action="store_true", help="Generate but do not dispatch")
    parser.add_argument("--parallel", action="store_true", help="Run cycles in parallel (not yet implemented)")
    parser.add_argument("--max-jobs", type=int, default=3, help="Max concurrent Aristotle jobs")

    args = parser.parse_args()

    config_path = Path(args.config)
    config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}

    domains_path = Path(args.domains)
    domains_config = json.loads(domains_path.read_text(encoding="utf-8")) if domains_path.exists() else {}

    # Override paths
    config["catalog"] = config.get("catalog", {})
    config["catalog"]["root_dir"] = config["catalog"].get("root_dir", "../Catalog")

    orchestrator = PiAgentOrchestrator(
        config=config,
        domains_config=domains_config,
        workspace=Path(args.workspace).resolve(),
    )

    if args.single_cycle:
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
                parallel=args.parallel,
                max_jobs=args.max_jobs,
            )
        except asyncio.CancelledError:
            pass


if __name__ == "__main__":
    asyncio.run(main())
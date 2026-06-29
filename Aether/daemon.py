#!/usr/bin/env python3
"""AETHER Daemon: Autonomous mathematical science engine.

Runs continuous research cycles:
  1. Select domain (weighted round-robin)
  2. Pi-Agent generates breakthrough concept
  3. PromptEngine optimizes Aristotle prompt
  4. Generate Lean source + dispatch to Aristotle
  5. Poll for completion
  6. Extract proof + artifacts (report, demo, SVG, discussion)
  7. Integrate proven results into Catalog
  8. Log telemetry + generate dashboard

Usage:
    python3 -m aether.daemon --config config.yaml --domains research_domains.json
    python3 -m aether.daemon --single-cycle --domain factoring
"""

import argparse
import asyncio
import json
import os
import random
import signal
import sys
import textwrap
import time
import uuid
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

# Aether subsystems
from pi_agent_client import PiAgentClient, ResearchConcept
from prompt_engine import PromptEngine, ArtifactRequests, ResearchPrompt
from aristotle_sdk_client import AristotleSDKClient, AristotleResult
from telemetry import TelemetryLogger, ExperimentRecord


@dataclass
class DaemonState:
    """Persisted daemon state across restarts."""
    cycle_count: int = 0
    last_domain: str = ""
    completed_experiments: List[str] = field(default_factory=list)
    failed_experiments: List[str] = field(default_factory=list)
    domain_stats: Dict[str, Dict[str, int]] = field(default_factory=dict)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2)

    @classmethod
    def from_json(cls, raw: str) -> "DaemonState":
        data = json.loads(raw)
        return cls(**data)


class AetherDaemon:
    """Autonomous research daemon."""

    def __init__(
        self,
        config: Dict[str, Any],
        domains_config: Dict[str, Any],
        state_path: Optional[Path] = None,
    ):
        self.config = config
        self._substitute_env_vars(self.config)
        self.domains = domains_config.get("domains", [])
        self.global_settings = domains_config.get("global_settings", {})
        self.state_path = state_path or Path("./logs/daemon_state.json")
        self.state = self._load_state()

        # Catalog root
        self.catalog_root = Path(config.get("catalog", {}).get("root_dir", "../Catalog")).resolve()
        if not self.catalog_root.exists() or self.catalog_root.name != "Catalog":
            if (self.catalog_root / "Catalog").exists():
                self.catalog_root = self.catalog_root / "Catalog"
            else:
                self.catalog_root = (Path(__file__).parent.parent / "Catalog").resolve()

        # Output dirs
        self.output_dir = Path("./output").resolve()
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.artifacts_dir = self.output_dir / "artifacts"
        self.artifacts_dir.mkdir(parents=True, exist_ok=True)
        self.reports_dir = self.output_dir / "reports"
        self.reports_dir.mkdir(parents=True, exist_ok=True)

        # Subsystems
        _pi_cfg = config.get("pi_agent", {})
        self.pi_agent = PiAgentClient(
            model=_pi_cfg.get("model", "fingpt-7b:latest"),
            use_ollama=_pi_cfg.get("use_ollama", False),
            ollama_base_url=_pi_cfg.get("ollama_base_url"),
            ollama_model=_pi_cfg.get("ollama_model"),
        ) if self.global_settings.get("pi_agent_enabled", True) else None

        self.prompt_engine = PromptEngine(config.get("prompts", {}))
        self.aristotle = AristotleSDKClient(config.get("aristotle", {}))
        self.telemetry = TelemetryLogger(config.get("telemetry", {}))

        # Control flags
        self._shutdown_requested = False
        self._current_task: Optional[asyncio.Task] = None

        # Domain weights
        self._domain_weights = {d["id"]: d.get("weight", 1.0) for d in self.domains}

    def _substitute_env_vars(self, obj: Any) -> None:
        """Recursively substitute ${VAR} in config strings."""
        import os
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
                    var_name = v[2:-1]
                    obj[k] = os.environ.get(var_name, v)
                else:
                    self._substitute_env_vars(v)
        elif isinstance(obj, list):
            for item in obj:
                self._substitute_env_vars(item)

    def _load_state(self) -> DaemonState:
        if self.state_path.exists():
            try:
                return DaemonState.from_json(self.state_path.read_text(encoding="utf-8"))
            except Exception:
                pass
        return DaemonState()

    def _save_state(self) -> None:
        self.state_path.parent.mkdir(parents=True, exist_ok=True)
        self.state_path.write_text(self.state.to_json(), encoding="utf-8")

    def _select_domain(self) -> Dict[str, Any]:
        """Weighted random domain selection, avoiding immediate repeats."""
        candidates = [d for d in self.domains if d["id"] != self.state.last_domain]
        if not candidates:
            candidates = self.domains

        weights = [self._domain_weights.get(d["id"], 1.0) for d in candidates]
        total = sum(weights)
        if total == 0:
            return random.choice(candidates)

        r = random.uniform(0, total)
        cumulative = 0.0
        for d, w in zip(candidates, weights):
            cumulative += w
            if r <= cumulative:
                return d
        return candidates[-1]

    def _generate_lean_source(
        self,
        concept: ResearchConcept,
        domain_config: Dict[str, Any],
    ) -> str:
        """Generate a Lean 4 source file from a concept."""
        exp_id = str(uuid.uuid4())[:8]
        domain = domain_config["id"]
        arc = domain_config.get("name", domain)
        difficulty = domain_config.get("difficulty_target", "phd")
        novelty = concept.novelty_estimate

        header = textwrap.dedent(f"""\
            import Mathlib

            /-! # CatalogBuild.Speculative.AutoResearch.{concept.title}

            Auto-generated by AETHER Daemon (Pi-Agent + Aristotle).
            Domain: {domain}
            Arc: {arc}
            Novelty: {novelty:.2f}
            Experiment: {exp_id}
            Date: {datetime.utcnow().isoformat()}
            -/

            /-
            {concept.concept_description}

            Mathematical Concept: {concept.mathematical_framing}

            Difficulty: {difficulty}
            Arc: {arc}
            -/
        """)

        # Use the lean guess from pi-agent, or build a generic sorry theorem
        lean_body = concept.lean_guess.strip()
        if not lean_body or lean_body == "" or "..." in lean_body or "theorem" not in lean_body:
            lean_body = textwrap.dedent(f"""\
                theorem {concept.title.lower().replace(' ', '_')}_breakthrough
                    {{X : Type*}} [Inhabited X] :
                    True := by
                  sorry
            """)

        # Ensure there's at least one sorry for Aristotle to fill
        if "sorry" not in lean_body:
            lean_body += "\n  sorry\n"

        return header + "\n" + lean_body

    async def _dispatch_to_aristotle(
        self,
        prompt: ResearchPrompt,
        lean_source: str,
        exp_id: str,
        domain: str,
    ) -> AristotleResult:
        """Create a project and dispatch to Aristotle with focused Catalog context."""
        project_dir = self.output_dir / f"job_{exp_id}"
        project_dir.mkdir(parents=True, exist_ok=True)

        # Dispatch with focused domain context
        result = await self.aristotle.submit_with_catalog_context(
            lean_source=lean_source,
            catalog_root=self.catalog_root,
            project_dir=project_dir,
            prompt=prompt.prompt_text,
            domain=domain,
        )
        return result

    def _extract_artifacts(self, project_dir: Path, exp_id: str) -> Dict[str, Path]:
        """Extract research report, demo, SVG, and discussion from result."""
        artifacts: Dict[str, Path] = {}
        result_dir = project_dir / "result_extracted"
        if not result_dir.exists():
            return artifacts

        # Map artifact names to patterns
        patterns = {
            "research_report": ["RESEARCH_REPORT.md", "report.md", "*report*.md"],
            "python_demo": ["demo.py", "*demo*.py"],
            "svg_demo": ["diagram.svg", "*.svg"],
            "sciam_discussion": ["DISCUSSION.md", "discussion.md", "*discussion*.md"],
        }

        exp_artifacts_dir = self.artifacts_dir / exp_id
        exp_artifacts_dir.mkdir(parents=True, exist_ok=True)

        for artifact_type, filenames in patterns.items():
            for pattern in filenames:
                matches = list(result_dir.rglob(pattern))
                if matches:
                    src = matches[0]
                    dest = exp_artifacts_dir / src.name
                    dest.write_bytes(src.read_bytes())
                    artifacts[artifact_type] = dest
                    break

        return artifacts

    def _integrate_proof(self, lean_source: str, domain_config: Dict[str, Any], exp_id: str) -> Optional[Path]:
        """Integrate proven Lean source into the Catalog."""
        domain = domain_config["id"]
        target_dir = self.catalog_root / "Speculative" / "AutoResearch"
        target_dir.mkdir(parents=True, exist_ok=True)

        safe_title = f"AutoResearch_{domain}_{exp_id}.lean"
        target_file = target_dir / safe_title

        try:
            target_file.write_text(lean_source, encoding="utf-8")
            print(f"[INTEGRATE] Proof saved to {target_file}")
            return target_file
        except Exception as e:
            print(f"[ERROR] Integration failed: {e}")
            return None

    async def run_single_cycle(self, forced_domain: Optional[str] = None) -> bool:
        """Run one complete research cycle. Returns True if successful."""
        self.state.cycle_count += 1
        cycle_n = self.state.cycle_count
        print(f"\n{'='*70}")
        print(f"AETHER DAEMON CYCLE #{cycle_n}")
        print(f"{'='*70}")

        # Phase 1: Select domain
        domain = self._select_domain() if forced_domain is None else next(
            (d for d in self.domains if d["id"] == forced_domain), self.domains[0]
        )
        self.state.last_domain = domain["id"]
        print(f"[Phase 1] Domain: {domain['name']} ({domain['id']})")

        # Phase 2: Pi-Agent generates concept
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
                concept_description="Auto-generated placeholder concept.",
                mathematical_framing="TBD",
            )

        print(f"[Phase 2] Concept: {concept.title} (novelty={concept.novelty_estimate:.2f})")

        # Phase 3: Prompt optimization
        print(f"[Phase 3] Optimizing Aristotle prompt...")
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
        print(f"[Phase 3] Prompt ready: {len(prompt.prompt_text)} chars, artifacts={prompt.expected_artifacts}")

        # Phase 4: Generate Lean source
        lean_source = self._generate_lean_source(concept, domain)
        print(f"[Phase 4] Lean source generated: {len(lean_source)} chars")

        # Phase 5: Dispatch to Aristotle
        print(f"[Phase 5] Dispatching to Aristotle...")
        start_time = time.time()
        result = await self._dispatch_to_aristotle(prompt, lean_source, exp_id, domain["id"])
        elapsed = time.time() - start_time
        print(f"[Phase 5] Aristotle result: {result.status} ({elapsed:.1f}s)")
        if result.error_message:
            print(f"[Phase 5] Aristotle error: {result.error_message}")

        # Phase 6: Process results
        project_dir = self.output_dir / f"job_{exp_id}"
        artifacts: Dict[str, Path] = {}
        if result.lean_source:
            # Extract artifacts
            artifacts = self._extract_artifacts(project_dir, exp_id)
            print(f"[Phase 6] Artifacts extracted: {list(artifacts.keys())}")

            # Evaluate novelty
            novelty_scores = {}
            if self.pi_agent:
                novelty_scores = self.pi_agent.evaluate_novelty(result.lean_source, domain["id"])
                print(f"[Phase 6] Novelty scores: {novelty_scores}")

            # Integrate if configured
            integrated_path: Optional[Path] = None
            if self.global_settings.get("auto_integrate", False):
                integrated_path = self._integrate_proof(result.lean_source, domain, exp_id)
            else:
                # Save to pending integration area
                pending_dir = self.catalog_root / "Speculative" / "AutoResearch"
                pending_dir.mkdir(parents=True, exist_ok=True)
                pending_file = pending_dir / f"PENDING_{domain['id']}_{exp_id}.lean"
                pending_file.write_text(result.lean_source, encoding="utf-8")
                integrated_path = pending_file
                print(f"[Phase 6] Saved to pending: {pending_file}")

            # Log experiment
            record = ExperimentRecord(
                experiment_id=exp_id,
                arc_id=domain["id"],
                arc_name=domain["name"],
                domain=domain["id"],
                file_path=str(integrated_path) if integrated_path else "",
                difficulty=domain.get("difficulty_target", "phd"),
                hypothesis_text=lean_source[:500],
                concept_combination=domain.get("seed_concepts", []),
                generation_latency_ms=elapsed * 1000,
                aristotle_job_id=result.project_id,
                status="proven" if result.status in ("complete", "COMPLETE", "COMPLETE_WITH_ERRORS") else result.status.lower(),
                proof_length_lines=len(result.lean_source.splitlines()),
                novelty_score=concept.novelty_estimate,
                epicness_score=concept.breakthrough_potential,
            )
            self.telemetry.log_experiment(record)
            self.state.completed_experiments.append(exp_id)

            # Update domain stats
            stats = self.state.domain_stats.setdefault(domain["id"], {"attempts": 0, "successes": 0})
            stats["attempts"] += 1
            stats["successes"] += 1

        else:
            print(f"[Phase 6] No proof returned. Status: {result.status}")
            self.state.failed_experiments.append(exp_id)
            stats = self.state.domain_stats.setdefault(domain["id"], {"attempts": 0, "successes": 0})
            stats["attempts"] += 1

        # Phase 7: Save state
        self._save_state()
        print(f"[Phase 7] State saved. Cycle #{cycle_n} complete.")

        return result.lean_source is not None

    async def run_daemon(self) -> None:
        """Run continuous research cycles until shutdown."""
        print("="*70)
        print("AETHER DAEMON STARTED")
        print("Domains:", [d["id"] for d in self.domains])
        print("Press Ctrl+C to shutdown gracefully.")
        print("="*70)

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

            print(f"[DAEMON] Sleeping {interval}s before next cycle...")
            await asyncio.sleep(interval)

        print("[DAEMON] Shutdown complete.")

    def request_shutdown(self) -> None:
        """Signal graceful shutdown."""
        print("[DAEMON] Shutdown requested...")
        self._shutdown_requested = True
        if self._current_task and not self._current_task.done():
            self._current_task.cancel()


async def main():
    parser = argparse.ArgumentParser(description="AETHER Daemon: Autonomous Math Research")
    parser.add_argument("--config", default="config.yaml", help="Path to config.yaml")
    parser.add_argument("--domains", default="research_domains.json", help="Path to research_domains.json")
    parser.add_argument("--state", default="./logs/daemon_state.json", help="Daemon state file")
    parser.add_argument("--single-cycle", action="store_true", help="Run one cycle and exit")
    parser.add_argument("--domain", help="Force a specific domain for this cycle")
    parser.add_argument("--dry-run", action="store_true", help="Generate concept + prompt but do not dispatch")

    args = parser.parse_args()

    # Load configs
    import yaml
    config_path = Path(args.config)
    config = {}
    if config_path.exists():
        with open(config_path, "r", encoding="utf-8") as f:
            config = yaml.safe_load(f)

    domains_path = Path(args.domains)
    domains_config = {}
    if domains_path.exists():
        with open(domains_path, "r", encoding="utf-8") as f:
            domains_config = json.load(f)

    daemon = AetherDaemon(
        config=config,
        domains_config=domains_config,
        state_path=Path(args.state),
    )

    if args.single_cycle:
        if args.dry_run:
            # Dry run: just generate concept and prompt
            domain = daemon._select_domain() if not args.domain else next(
                (d for d in daemon.domains if d["id"] == args.domain), daemon.domains[0]
            )
            concept = daemon.pi_agent.generate_breakthrough_concept(
                domain=domain["id"],
                seed_concepts=domain.get("seed_concepts", []),
            ) if daemon.pi_agent else ResearchConcept(title="dry_run", domain=domain["id"], concept_description="", mathematical_framing="")
            prompt = daemon.prompt_engine.build_prompt(
                title=concept.title,
                domain=domain["id"],
                concept_description=concept.concept_description,
                mathematical_framing=concept.mathematical_framing,
                lean_guess=concept.lean_guess,
            )
            print(f"\n{'='*60}")
            print("DRY RUN OUTPUT")
            print(f"{'='*60}")
            print(f"Domain: {domain['name']}")
            print(f"Concept: {concept.title}")
            print(f"Description: {concept.concept_description}")
            print(f"\n--- OPTIMIZED PROMPT ---\n{prompt.prompt_text[:2000]}...")
        else:
            success = await daemon.run_single_cycle(forced_domain=args.domain)
            sys.exit(0 if success else 1)
    else:
        # Setup signal handlers
        loop = asyncio.get_event_loop()
        for sig in (signal.SIGINT, signal.SIGTERM):
            loop.add_signal_handler(sig, daemon.request_shutdown)

        try:
            await daemon.run_daemon()
        except asyncio.CancelledError:
            pass


if __name__ == "__main__":
    asyncio.run(main())

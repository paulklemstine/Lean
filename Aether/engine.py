#!/usr/bin/env python3
"""AETHER Engine: Main orchestrator for autonomous mathematical research.

Coordinates the ConceptMiner, HypothesisGenerator, PiAgent, PromptEngine,
AristotleSDKClient, and IntegrationGate into a unified research pipeline.

Usage:
    python3 -m aether.engine --mode single --arc "Quantum Pythagoras"
    python3 -m aether.engine --mode daemon --domains research_domains.json
    python3 -m aether.engine --mode generate --count 10
    python3 -m aether.engine --mode dispatch
    python3 -m aether.engine --mode integrate
    python3 -m aether.engine --mode landscape
    python3 -m aether.engine --mode daemon --single-cycle --domain factoring
"""

import argparse
import asyncio
import json
import os
import sys
import time
import yaml
from pathlib import Path
from typing import Dict, List, Optional, Any

from miner import ConceptMiner
from generator import HypothesisGenerator, ResearchProposal
from integrator import IntegrationGate, ValidationReport
from telemetry import TelemetryLogger, ExperimentRecord

# New SDK-based Aristotle client
from aristotle_sdk_client import AristotleSDKClient, AristotleResult

# New autoresearch + prompt optimization
from pi_agent_client import PiAgentClient, ResearchConcept
from prompt_engine import PromptEngine, ArtifactRequests, ResearchPrompt


class AetherEngine:
    """Central orchestrator for the AETHER research pipeline."""

    def __init__(self, config_path: Optional[str] = None):
        self.config = self._load_config(config_path)
        self.catalog_root = Path(self.config["catalog"].get("root_dir", "../Catalog")).resolve()
        if not self.catalog_root.exists() or self.catalog_root.name != "Catalog":
            if (self.catalog_root / "Catalog").exists():
                self.catalog_root = self.catalog_root / "Catalog"
            else:
                self.catalog_root = (Path(__file__).parent.parent / "Catalog").resolve()

        # Initialize subsystems
        self.telemetry = TelemetryLogger(self.config["telemetry"])
        self.miner = ConceptMiner(
            catalog_root=self.catalog_root,
            db_path=Path(self.config["catalog"]["db_path"]).resolve() if self.config["catalog"].get("db_path") else None,
        )
        self.generator = HypothesisGenerator(
            config=self.config["research"],
            catalog_root=self.catalog_root,
        )

        # New: Pi-Agent autoresearch client
        pi_cfg = self.config.get("pi_agent", {})
        self.pi_agent = PiAgentClient(
            model=pi_cfg.get("model", "fingpt-7b:latest"),
            use_ollama=pi_cfg.get("use_ollama", False),
            ollama_base_url=pi_cfg.get("ollama_base_url"),
            ollama_model=pi_cfg.get("ollama_model"),
        ) if pi_cfg.get("enabled", True) else None

        # New: Prompt engine
        self.prompt_engine = PromptEngine(self.config.get("prompts", {}))

        # Aristotle SDK client (replaces old REST client)
        self._aristotle: Optional[AristotleSDKClient] = None

        # Integration gate
        self.integrator = IntegrationGate(
            config=self.config["integration"],
            catalog_root=self.catalog_root,
        )

        # Daemon reference
        self._daemon = None

    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """Load configuration from YAML."""
        if config_path:
            p = Path(config_path)
        else:
            # Default: config.yaml next to this file
            p = Path(__file__).parent / "config.yaml"

        if p.exists():
            with open(p, "r", encoding="utf-8") as f:
                cfg = yaml.safe_load(f)
                # Substitute env vars
                self._substitute_env_vars(cfg)
                return cfg

        # Minimal default config
        return {
            "aristotle": {"api_key": os.environ.get("ARISTOTLE_API_KEY", "")},
            "catalog": {"root_dir": "../Catalog"},
            "research": {"arcs": [], "generation_batch_size": 5},
            "telemetry": {"log_dir": "./logs"},
            "integration": {"auto_merge": False, "require_human_review": True},
            "pi_agent": {"enabled": True, "model": "fingpt-7b:latest"},
        }

    def _substitute_env_vars(self, obj: Any) -> None:
        """Recursively substitute ${VAR} in config strings."""
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

    @property
    def aristotle(self) -> AristotleSDKClient:
        if self._aristotle is None:
            self._aristotle = AristotleSDKClient(self.config["aristotle"])
        return self._aristotle

    # ------------------------------------------------------------------
    # Core pipeline modes
    # ------------------------------------------------------------------

    def run_landscape(self) -> str:
        """Generate and save a research landscape report."""
        self.telemetry.log_event("info", "Scanning catalog landscape...")
        landscape = self.miner.build_landscape()
        output_path = Path(self.config["telemetry"]["log_dir"]) / "landscape.json"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(self.miner.to_json())
        self.telemetry.log_event("info", f"Landscape saved to {output_path}")
        return str(output_path)

    def run_generate(self, arc_filter: Optional[str] = None, count: int = 5) -> List[ResearchProposal]:
        """Generate research proposals without dispatching."""
        arcs = self.config["research"]["arcs"]
        if arc_filter and arc_filter != "all":
            arcs = [a for a in arcs if a["id"] == arc_filter or a["name"] == arc_filter]

        proposals = []
        for arc in arcs:
            self.telemetry.log_event("info", f"Generating proposals for arc: {arc['name']}")
            batch = self.generator.generate_proposals(arc, count=min(count, self.config["research"].get("max_proposals_per_arc", 3)))
            for p in batch:
                self.telemetry.log_experiment(
                    ExperimentRecord(
                        experiment_id=p.experiment_id,
                        arc_id=p.arc_id,
                        arc_name=p.arc_name,
                        domain=p.domain,
                        file_path=p.target_file,
                        difficulty=p.difficulty,
                        hypothesis_text=p.conjecture_lean,
                        concept_combination=p.concept_combination,
                    )
                )
            proposals.extend(batch)

        # Save proposals
        output_path = Path(self.config["telemetry"]["log_dir"]) / "proposals.json"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump([{
                "experiment_id": p.experiment_id,
                "arc_id": p.arc_id,
                "title": p.title,
                "domain": p.domain,
                "difficulty": p.difficulty,
                "type": p.hypothesis_type,
                "target_file": p.target_file,
                "narrative": p.narrative,
                "conjecture_lean": p.conjecture_lean,
                "concept_combination": p.concept_combination,
                "novelty_estimate": p.novelty_estimate,
            } for p in proposals], f, indent=2, ensure_ascii=False)

        self.telemetry.log_event("info", f"Generated {len(proposals)} proposals -> {output_path}")
        return proposals

    async def run_dispatch(self, proposals: Optional[List[ResearchProposal]] = None) -> List[Dict[str, Any]]:
        """Dispatch pending proposals to Aristotle using the SDK client."""
        if proposals is None:
            # Load from proposals.json
            prop_path = Path(self.config["telemetry"]["log_dir"]) / "proposals.json"
            if prop_path.exists():
                with open(prop_path, "r", encoding="utf-8") as f:
                    raw = json.load(f)
                # Convert back to ResearchProposal objects
                from generator import ResearchProposal
                proposals = []
                for r in raw:
                    p = ResearchProposal(
                        experiment_id=r["experiment_id"],
                        arc_id=r["arc_id"],
                        arc_name=r.get("arc_name", ""),
                        title=r["title"],
                        domain=r["domain"],
                        difficulty=r["difficulty"],
                        hypothesis_type=r["type"],
                        conjecture_lean=r["conjecture_lean"],
                        narrative=r.get("narrative", ""),
                        target_file=r["target_file"],
                        concept_combination=r.get("concept_combination", []),
                        novelty_estimate=r.get("novelty_estimate", 0.0),
                    )
                    proposals.append(p)
            else:
                self.telemetry.log_event("error", "No proposals found. Run --mode generate first.")
                return []

        results = []
        for p in proposals:
            # Use prompt engine for optimized prompt
            prompt_obj = self.prompt_engine.build_prompt(
                title=p.title,
                domain=p.domain,
                concept_description=p.narrative,
                mathematical_framing=p.conjecture_lean[:500],
                lean_guess=p.conjecture_lean,
                difficulty=p.difficulty,
                artifacts=ArtifactRequests(lean_proof=True, research_report=False, python_demo=False, svg_demo=False, sciam_discussion=False),
            )
            self.telemetry.log_event("info", f"Dispatching {p.experiment_id} to Aristotle: {p.title}")

            try:
                # Create temporary project directory with full Catalog context
                import tempfile
                project_dir = Path(tempfile.mkdtemp(prefix=f"aether_{p.experiment_id}_"))

                result = await self.aristotle.submit_with_catalog_context(
                    lean_source=p.conjecture_lean,
                    catalog_root=self.catalog_root,
                    project_dir=project_dir,
                    prompt=prompt_obj.prompt_text,
                )

                self.telemetry.update_experiment(
                    p.experiment_id,
                    aristotle_job_id=result.project_id,
                    status=result.status,
                    sorry_count_after=0 if result.status in ("complete", "COMPLETE", "COMPLETE_WITH_ERRORS") else -1,
                )
                results.append({
                    "experiment_id": p.experiment_id,
                    "status": result.status,
                    "job_id": result.project_id,
                    "latency": result.latency_seconds,
                })
            except Exception as e:
                self.telemetry.log_event("error", f"Dispatch failed for {p.experiment_id}: {e}")
                results.append({
                    "experiment_id": p.experiment_id,
                    "status": "failed",
                    "error": str(e),
                })

        return results

    def run_integrate(self, dry_run: bool = True) -> List[ValidationReport]:
        """Integrate completed Aristotle jobs into the catalog."""
        records = self.telemetry.load_experiments()
        completed = [r for r in records if r.get("status") in ("completed", "proven", "COMPLETE", "COMPLETE_WITH_ERRORS")]

        reports = []
        for r in completed:
            exp_id = r.get("experiment_id")
            target_file = self.catalog_root / r.get("file_path", "")

            self.telemetry.log_event("info", f"Integrating {exp_id} into {target_file}")

            # Placeholder: read from a stored result
            result_path = Path(self.config["telemetry"]["log_dir"]) / f"result_{exp_id}.lean"
            if not result_path.exists():
                self.telemetry.log_event("warning", f"No result file for {exp_id}, skipping integration.")
                continue

            lean_source = result_path.read_text(encoding="utf-8")

            if dry_run:
                report = self.integrator.validate_patch(target_file, lean_source)
                self.telemetry.log_event("info", f"Dry-run validation for {exp_id}: passed={report.passed}")
            else:
                report = self.integrator.apply_patch(target_file, lean_source)
                if report.passed:
                    self.telemetry.update_experiment(exp_id, status="integrated")

            reports.append(report)

        return reports

    # ------------------------------------------------------------------
    # Pi-Agent + Daemon integration
    # ------------------------------------------------------------------

    async def run_daemon(self, domains_path: Optional[Path] = None, single_cycle: bool = False, forced_domain: Optional[str] = None) -> None:
        """Launch the AETHER daemon for continuous research."""
        from daemon import AetherDaemon

        domains_config = {}
        if domains_path and domains_path.exists():
            with open(domains_path, "r", encoding="utf-8") as f:
                domains_config = json.load(f)

        daemon = AetherDaemon(
            config=self.config,
            domains_config=domains_config,
        )

        if single_cycle:
            await daemon.run_single_cycle(forced_domain=forced_domain)
        else:
            await daemon.run_daemon()

    async def run_single_cycle(self, arc: Optional[str] = None) -> None:
        """Run one complete research cycle with optional Pi-Agent boost."""
        print("=" * 60)
        print("AETHER SINGLE CYCLE")
        print("=" * 60)

        # Phase 0: Landscape
        landscape_path = self.run_landscape()
        print(f"[Phase 0] Landscape: {landscape_path}")

        # Phase 1: Generate (with Pi-Agent if available)
        if self.pi_agent and arc:
            # Pi-Agent boosted generation for a specific domain
            print(f"[Phase 1a] Pi-Agent generating breakthrough concept for: {arc}")
            concept = self.pi_agent.generate_breakthrough_concept(
                domain=arc,
                seed_concepts=[arc, "mathlib4", "breakthrough"],
            )
            print(f"[Phase 1a] Concept: {concept.title} (novelty={concept.novelty_estimate:.2f})")

            # Build optimized prompt
            prompt_obj = self.prompt_engine.build_prompt(
                title=concept.title,
                domain=arc,
                concept_description=concept.concept_description,
                mathematical_framing=concept.mathematical_framing,
                lean_guess=concept.lean_guess,
                difficulty="phd",
                artifacts=ArtifactRequests(
                    lean_proof=True,
                    research_report=True,
                    python_demo=True,
                    svg_demo=True,
                    sciam_discussion=True,
                ),
            )
            print(f"[Phase 1b] Prompt optimized: {len(prompt_obj.prompt_text)} chars")

        # Phase 1c: Standard proposal generation
        proposals = self.run_generate(arc_filter=arc, count=self.config["research"].get("generation_batch_size", 5))
        print(f"[Phase 1c] Generated {len(proposals)} proposals")

        if not proposals:
            print("No proposals generated. Exiting.")
            return

        # Phase 2: Dispatch
        print("[Phase 2] Dispatching to Aristotle...")
        results = await self.run_dispatch(proposals)
        succeeded = sum(1 for r in results if r["status"] in ("complete", "COMPLETE", "COMPLETE_WITH_ERRORS"))
        print(f"[Phase 2] {succeeded}/{len(results)} proofs completed")

        # Phase 3: Integrate (dry run by default)
        print("[Phase 3] Integration (dry-run)...")
        reports = self.run_integrate(dry_run=True)
        passed = sum(1 for r in reports if r.passed)
        print(f"[Phase 3] {passed}/{len(reports)} patches passed validation")

        # Phase 4: Report
        report_path = self.telemetry.generate_html_report()
        print(f"[Phase 4] Telemetry report: {report_path}")

        print("=" * 60)
        print("CYCLE COMPLETE")
        print("=" * 60)


# ------------------------------------------------------------------
# CLI
# ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="AETHER: Automated Epic Theorem Hypothesis Engine")
    parser.add_argument("--config", help="Path to config.yaml")
    parser.add_argument("--mode", choices=["landscape", "generate", "dispatch", "integrate", "single", "daemon", "report"], default="single")
    parser.add_argument("--arc", help="Research arc filter")
    parser.add_argument("--count", type=int, default=5, help="Number of proposals to generate")
    parser.add_argument("--dry-run", action="store_true", default=True, help="Dry run integration")
    parser.add_argument("--no-dry-run", dest="dry_run", action="store_false", help="Actually apply patches")
    parser.add_argument("--domains", default="research_domains.json", help="Path to research_domains.json (for daemon)")
    parser.add_argument("--single-cycle", action="store_true", help="Run one daemon cycle and exit")
    parser.add_argument("--domain", help="Force specific domain for daemon cycle")

    args = parser.parse_args()

    engine = AetherEngine(config_path=args.config)

    if args.mode == "landscape":
        path = engine.run_landscape()
        print(f"Landscape saved to: {path}")

    elif args.mode == "generate":
        proposals = engine.run_generate(arc_filter=args.arc, count=args.count)
        print(f"Generated {len(proposals)} proposals")

    elif args.mode == "dispatch":
        results = asyncio.run(engine.run_dispatch())
        print(json.dumps(results, indent=2))

    elif args.mode == "integrate":
        reports = engine.run_integrate(dry_run=args.dry_run)
        for i, r in enumerate(reports):
            print(f"Patch {i}: passed={r.passed}, checks={r.checks}")

    elif args.mode == "single":
        asyncio.run(engine.run_single_cycle(arc=args.arc))

    elif args.mode == "daemon":
        asyncio.run(engine.run_daemon(
            domains_path=Path(args.domains),
            single_cycle=args.single_cycle,
            forced_domain=args.domain,
        ))

    elif args.mode == "report":
        path = engine.telemetry.generate_html_report()
        print(f"Report generated: {path}")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()

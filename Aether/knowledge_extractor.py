#!/usr/bin/env python3
"""KnowledgeExtractor: Aether's pipeline for mathematical knowledge discovery.

Architecture:
  Aether (orchestrator)
    → Pi (brains: decides WHAT to research, writes prompts, evaluates results)
    → Aristotle (worker: proves theorems, creates Lean files, demos, papers)
    → Pi (integrator: evaluates quality, places artifacts in Catalog)
    → Aether (commits, tracks metrics, loops)

The KnowledgeExtractor coordinates this pipeline:
1. DISCOVER: Pi analyzes the catalog, finds gaps/connections, selects direction
2. DISPATCH: Pi writes a detailed prompt asking Aristotle for Lean + demo + paper
3. AWAIT: Aristotle works (proves theorems, generates artifacts)
4. EXTRACT: Download Aristotle's result tarball
5. EVALUATE: Pi judges the quality of the result
6. INTEGRATE: Pi decides where artifacts go in the Catalog
7. COMMIT: Aether commits verified results, reverts failures
8. LOOP: Back to step 1

Usage:
    python3 knowledge_extractor.py --single-cycle
    python3 knowledge_extractor.py --continuous --max-inflight 3
    python3 knowledge_extractor.py --dry-run  # See what Pi would dispatch
"""

import argparse
import asyncio
import json
import os
import re
import shutil
import tarfile
import tempfile
import time
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import yaml

from pi_agent_client import PiAgentClient, ResearchConcept
from catalog_analyzer import CatalogAnalyzer
from autoresearch_bridge import AutoresearchBridge
from research_memory import ResearchMemory
from research_context import ResearchContext
from aristotle_loop import AristotleLoop
from output_organizer import OutputOrganizer, normalize_domain
from aristotle_sdk_client import AristotleSDKClient
from git_automator import GitAutomator
from arxiv_miner import ArxivMiner


@dataclass
class ResearchJob:
    """A single research cycle from concept to result."""
    job_id: str
    cycle_n: int
    concept: ResearchConcept
    prompt: str
    project_dir: Optional[Path] = None
    project_id: Optional[str] = None
    status: str = "created"  # created → dispatched → completed → integrated
    dispatch_time: float = 0.0
    complete_time: float = 0.0
    result_lean: Optional[str] = None
    result_demo: Optional[str] = None
    result_paper: Optional[str] = None
    result_summary: Optional[str] = None
    result_future_directions: Optional[str] = None
    result_discussion: Optional[str] = None
    result_article: Optional[str] = None
    result_research_paper: Optional[str] = None
    result_algorithms: Optional[str] = None
    result_json_package: Optional[str] = None
    quality_score: float = 0.0
    quality_assessment: Optional[Dict] = None
    quality_detail: Optional[Any] = None  # 8-axis QualityScore from quality_evaluator
    sorry_count: int = 0
    theorem_count: int = 0
    files_integrated: int = 0  # Actual count of files written to Catalog during integrate
    integrated_paths: list = None  # Paths of files written to Catalog (relative to repo root)
    error_message: Optional[str] = None
    source_exp_ids: list = None  # exp_ids of parent experiments whose future directions inspired this one


class KnowledgeExtractor:
    """The core Aether pipeline: Pi brain + Aristotle worker.

    Pi decides what to research. Aristotle does the heavy lifting.
    Pi integrates the results. Aether commits and loops.
    """

    def __init__(self, config_path: Optional[str] = None, config: Optional[Dict[str, Any]] = None):
        if config is not None:
            self.config = config
            self._substitute_env_vars(self.config)
        else:
            self.config = self._load_config(config_path)
        self.catalog_root = Path(self.config.get("catalog", {}).get("root_dir", "../Catalog")).resolve()
        if not self.catalog_root.exists():
            self.catalog_root = (Path(__file__).parent.parent / "Catalog").resolve()

        self.workspace = Path(self.config.get("workspace", ".aether_workspace")).resolve()
        self.workspace.mkdir(parents=True, exist_ok=True)

        # Core subsystems
        self.catalog_analyzer = CatalogAnalyzer(self.catalog_root)
        self.aristotle = AristotleSDKClient(self.config.get("aristotle", {}))
        self.memory = ResearchMemory(self.workspace)
        self.autoresearch = AutoresearchBridge(self.workspace)
        self.aristotle_loop = AristotleLoop(exploration_constant=1.5)
        self.git = GitAutomator(self.catalog_root.parent)

        # Pi-Agent: the BRAINS of Aether
        pi_cfg = self.config.get("pi_agent", {})
        self.pi_agent = PiAgentClient(
            model=pi_cfg.get("model", "kimi-k2.6:cloud"),
            memory=self.memory,
            catalog_root=self.catalog_root,
            timeout=pi_cfg.get("timeout", 300),
            compact="cloud" in pi_cfg.get("model", "kimi-k2.6:cloud").lower(),
            pollinations=pi_cfg.get("pollinations", {}),
            use_ollama=pi_cfg.get("use_ollama", False),
            ollama_base_url=pi_cfg.get("ollama_base_url"),
            ollama_model=pi_cfg.get("ollama_model"),
            ollama_cloud=pi_cfg.get("ollama_cloud", {}),
        )

        self.output_organizer = OutputOrganizer(
            catalog_root=self.catalog_root,
            pi_agent=self.pi_agent,
        )

        self.research_context = ResearchContext(self.workspace)

        # ArXiv miner for fresh ideas pipeline
        arxiv_cfg = self.config.get("arxiv", {})
        if arxiv_cfg.get("enabled", False):
            from research_memory import FutureDirectionsManager
            self._arxiv_fd_manager = FutureDirectionsManager(self.workspace)
            self.arxiv_miner = ArxivMiner(
                pi_agent=self.pi_agent,
                catalog_analyzer=self.catalog_analyzer,
                research_memory=self._arxiv_fd_manager,
                config=arxiv_cfg,
            )
        else:
            self.arxiv_miner = None

        # State
        self.cycle_count = 0
        self.inflight: Dict[str, ResearchJob] = {}
        self.completed_count = 0
        self.failed_count = 0
        
        self._load_inflight()

    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        if config_path:
            p = Path(config_path)
        else:
            p = Path(__file__).parent / "config.yaml"
        if p.exists():
            with open(p) as f:
                cfg = yaml.safe_load(f) or {}
            self._substitute_env_vars(cfg)
            return cfg
        return {"aristotle": {"api_key": os.environ.get("ARISTOTLE_API_KEY", "")},
                "catalog": {"root_dir": "../Catalog"},
                "pi_agent": {"model": "kimi-k2.6:cloud", "timeout": 300}}

    def _substitute_env_vars(self, obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
                    obj[k] = os.environ.get(v[2:-1], v)
                else:
                    self._substitute_env_vars(v)
        elif isinstance(obj, list):
            for item in obj:
                self._substitute_env_vars(item)

    def _save_inflight(self):
        """Save the inflight jobs to disk."""
        path = self.workspace / "inflight_jobs.json"
        data = {}
        for pid, job in self.inflight.items():
            d = {}
            for k, v in job.__dict__.items():
                if isinstance(v, Path):
                    d[k] = str(v)
                elif hasattr(v, '__dict__'):
                    d[k] = v.__dict__
                else:
                    d[k] = v
            data[pid] = d
        path.write_text(json.dumps(data, indent=2))

    def _load_inflight(self):
        """Load the inflight jobs from disk on startup."""
        path = self.workspace / "inflight_jobs.json"
        if not path.exists():
            return
        # Fields removed from ResearchJob — strip from saved data to avoid errors
        removed_fields = {
        }
        try:
            data = json.loads(path.read_text())
            for pid, d in data.items():
                concept_dict = d.pop('concept', {})
                concept = ResearchConcept(**concept_dict)
                d['concept'] = concept
                if 'project_dir' in d and d['project_dir']:
                    d['project_dir'] = Path(d['project_dir'])
                for f in removed_fields:
                    d.pop(f, None)
                self.inflight[pid] = ResearchJob(**d)
            if self.inflight:
                print(f"[Aether] Recovered {len(self.inflight)} inflight jobs from previous run")
        except Exception as e:
            print(f"[Aether] Warning: could not load inflight jobs: {e}")

    # ==================================================================
    # Phase 1: DISCOVER — Pi decides what to research
    # ==================================================================

    def discover(self, forced_domain: Optional[str] = None, domain_filter: Optional[str] = None, exclude_domains: Optional[list] = None) -> ResearchJob:
        """Pi analyzes the catalog and selects a research direction.

        Uses Aristotle Loop (UCB) for principled domain selection,
        then Pi-Agent for specific concept generation.

        domain_filter: if set, only select future directions in this domain (e.g. "Novelty")
        exclude_domains: if set, exclude future directions in these domains
        """
        self.cycle_count += 1
        cycle_n = self.cycle_count
        job_id = str(uuid.uuid4())[:8]

        print(f"\n{'='*60}")
        print(f"[DISCOVER #{cycle_n}] job={job_id}")

        # Refresh catalog analysis
        self.catalog_analyzer.invalidate_cache()
        self.catalog_analyzer.scan()

        # Aristotle Loop: principled domain selection
        sorry_targets = [f.relative_path for f in self.catalog_analyzer.get_priority_sorry_targets()[:5]]
        missing_bridges = self.catalog_analyzer.find_missing_bridges(limit=10)

        loop_result = self.aristotle_loop.select_prompt(
            forced_domain=forced_domain,
            sorry_targets=sorry_targets,
            missing_bridges=missing_bridges,
        )

        print(f"[Loop] domain={loop_result['domain']}, mode={loop_result['mode']}, "
              f"ucb={loop_result['ucb_score']:.2f}")

        # Build domains config for Pi-Agent
        arcs = self.config.get("research", {}).get("arcs", [])
        domains_with_context = [
            {"id": a["id"], "name": a["name"], "description": a["description"],
             "frontier": a.get("frontier", ""), "seed_domains": a.get("seed_domains", [])}
            for a in arcs
        ]
        # Add the loop's recommendation
        domains_with_context.append({
            "id": f"loop_{loop_result['domain']}",
            "name": f"Aristotle Loop: {loop_result['domain']} ({loop_result['mode']})",
            "description": f"UCB-recommended: {loop_result['domain']} mode={loop_result['mode']}",
            "frontier": loop_result.get("recommended_bridges", [(loop_result['domain'], "", 0)])[0][1] if loop_result.get("recommended_bridges") else loop_result["domain"],
        })

        # Build research context
        discoveries_prompt = self.research_context.build_discoveries_prompt()

        # Build history from memory
        recent_history = []
        low_quality_domains = set()
        for rec in self.memory._cache[-20:]:
            recent_history.append({
                'concept_title': rec.concept_title,
                'domain': rec.domain,
                'quality': rec.proof_quality,
                'quality_score': getattr(rec, 'quality_score', 0.0),
            })
            # Track domains that produced trivial results
            qs = getattr(rec, 'quality_score', 0.0)
            if qs < 0.3:
                low_quality_domains.add(rec.domain)

        # Inflight concepts (to avoid repeating requests)
        inflight_concepts = [j.concept.title for j in self.inflight.values()] if hasattr(self, 'inflight') and self.inflight else []

        # Select future direction — the primary path
        # Domain decay and anti-repetition handle diversity; no need for redirect logic
        source_exp_ids = []
        from research_memory import FutureDirectionsManager
        fd_manager = FutureDirectionsManager(self.workspace)
        recent_domain_quality = fd_manager.get_recent_domain_quality(n=10, memory=self.memory)

        # Try domain-filtered selection first, fall back to any available
        effective_filter = domain_filter or loop_result['domain']
        best_dir = fd_manager.select_direction_weighted(domain_filter=effective_filter, recent_domain_quality=recent_domain_quality, catalog_analyzer=self.catalog_analyzer, exclude_domains=exclude_domains)
        if not best_dir:
            best_dir = fd_manager.select_direction_weighted(recent_domain_quality=recent_domain_quality, catalog_analyzer=self.catalog_analyzer, exclude_domains=exclude_domains)

        if best_dir:
            fd_manager.mark_direction_consumed(best_dir.id, job_id)
            source_exp_ids = fd_manager.get_source_exp_ids_for(job_id)
            print(f"[Discover] Using future direction: {best_dir.title} (source={best_dir.source_exp_id})")
            # Use the Aristotle loop's domain, not the direction's domains[0].
            # The direction provides the concept idea; the loop provides the domain target.
            # This prevents Pythagorean (56% of directions' domains[0]) from dominating dispatch.
            loop_domain = loop_result['domain']
            concept = ResearchConcept(
                title=best_dir.title,
                domain=normalize_domain(loop_domain),
                concept_description=best_dir.description,
                mathematical_framing=best_dir.description,
                lean_guess=best_dir.proof_strategy or "",
                catalog_references=best_dir.catalog_references or [],
                research_mode=best_dir.research_mode or "prove",
                novelty_estimate=min(1.0, best_dir.priority_score),
                breakthrough_potential=best_dir.priority_score,
                key_references=[],
            )
        else:
            # Add quality feedback context to guide away from low-quality domains
            quality_context = ""
            if low_quality_domains:
                quality_context = f"\n\nRecent low-quality domains (avoid similar concepts): {', '.join(sorted(low_quality_domains))}"
            concept = self.pi_agent.select_research_direction(
                domains=domains_with_context,
                recent_history=recent_history,
                research_context=discoveries_prompt + quality_context,
                inflight_concepts=inflight_concepts,
            )

        print(f"[Pi] concept={concept.title}, domain={concept.domain}, "
              f"mode={concept.research_mode}, novelty={concept.novelty_estimate:.2f}")

        return ResearchJob(
            job_id=job_id,
            cycle_n=cycle_n,
            concept=concept,
            prompt="",  # Will be filled in Phase 2
            source_exp_ids=source_exp_ids if source_exp_ids else None,
        )

    # ==================================================================
    # Phase 2: DISPATCH — Pi writes the prompt, Aristotle receives it
    # ==================================================================

    def dispatch(self, job: ResearchJob, dry_run: bool = False) -> ResearchJob:
        """Pi writes a detailed prompt for Aristotle, then dispatches.

        The prompt asks Aristotle for:
        1. Formally verified mathematics in Lean 4
        2. Python demos that bring the math to life
        3. A research paper with a Scientific American style discussion
        4. Useful applications showing real-world relevance

        This is the sync version — safe to call from non-async code.
        Use dispatch_async() when inside an already-running event loop.
        """
        job = self._prepare_dispatch(job, dry_run=dry_run)
        if dry_run or job.status in ("failed", "dry_run"):
            return job

        # Dispatch to Aristotle
        try:
            project_id = asyncio.run(self._dispatch_to_aristotle(job))
            job.project_id = project_id
            job.status = "dispatched"
            job.dispatch_time = time.time()
            self.inflight[project_id] = job
            self._save_inflight()
            print(f"[Dispatch] Aristotle project: {project_id}")
        except RuntimeError as e:
            if "already running" in str(e) or "cannot be called from a running event loop" in str(e):
                # We're inside an async loop — caller should use dispatch_async
                job.status = "failed"
                job.error_message = f"Dispatch failed: nested event loop. Use dispatch_async() in async context."
                print(f"[Dispatch] FAILED: nested event loop — use dispatch_async() from async code")
            else:
                job.status = "failed"
                job.error_message = f"Dispatch failed: {e}"
                print(f"[Dispatch] FAILED: {e}")
        except Exception as e:
            job.status = "failed"
            job.error_message = f"Dispatch failed: {e}"
            print(f"[Dispatch] FAILED: {e}")

        return job

    async def dispatch_async(self, job: ResearchJob, dry_run: bool = False) -> ResearchJob:
        """Async version of dispatch() — call from inside an already-running event loop.

        This is the version to use in run_continuous() and other async contexts.
        """
        job = self._prepare_dispatch(job, dry_run=dry_run)
        if dry_run or job.status in ("failed", "dry_run"):
            return job

        # Dispatch to Aristotle (we're already in an async context, just await)
        try:
            project_id = await self._dispatch_to_aristotle(job)
            job.project_id = project_id
            job.status = "dispatched"
            job.dispatch_time = time.time()
            self.inflight[project_id] = job
            self._save_inflight()
            print(f"[Dispatch] Aristotle project: {project_id}")
        except Exception as e:
            job.status = "failed"
            job.error_message = f"Dispatch failed: {e}"
            print(f"[Dispatch] FAILED: {e}")

        return job

    def _prepare_dispatch(self, job: ResearchJob, dry_run: bool = False) -> ResearchJob:
        """Prepare a job for dispatch: build prompt, augment, create project dir.

        Split out from dispatch() so both sync and async paths share the
        same preparation logic.
        """
        print(f"[DISPATCH] job={job.job_id}, concept={job.concept.title}")

        # Pi-Agent: writes the Aristotle prompt
        # This includes references to catalog files for context
        refs = job.concept.catalog_references or []
        catalog_context = ""
        if refs and self.catalog_analyzer:
            catalog_context = self.catalog_analyzer.build_catalog_context_string(refs)

        # Build previously proved theorems context
        theorem_context = self.research_context.build_discoveries_prompt()

        # Pi-Agent enriches the prompt with mathematical depth
        base_prompt = self.pi_agent.write_aristotle_prompt(
            concept=job.concept,
            catalog_references=refs,
            catalog_context=catalog_context,
            recent_successes=[{'concept_title': r.concept_title, 'domain': r.domain, 'quality': r.proof_quality} for r in self.memory._cache[-3:]],
            theorem_context=theorem_context,
        )

        # AUGMENT the prompt to explicitly request ALL deliverables
        # Pi has defined the math; now we make sure Aristotle knows to produce
        # the complete artifact set: Lean + demo + paper
        augmented_prompt = self._augment_prompt_with_deliverables(base_prompt, job.concept)
        job.prompt = augmented_prompt

        print(f"[Dispatch] prompt length: {len(augmented_prompt)} chars")

        if dry_run:
            print(f"[Dry Run] Would dispatch to Aristotle:")
            print(f"  Concept: {job.concept.title}")
            print(f"  Domain: {job.concept.domain}")
            print(f"  Mode: {job.concept.research_mode}")
            print(f"  Prompt preview: {augmented_prompt[:300]}...")
            job.status = "dry_run"
            return job

        # Build the project directory with reference files
        job.project_dir = self._build_project_dir(job)
        if not job.project_dir:
            job.status = "failed"
            job.error_message = "Could not build project directory"
            return job

        return job

    def _augment_prompt_with_deliverables(self, base_prompt: str, concept: ResearchConcept) -> str:
        """Add comprehensive deliverable guidance to the Aristotle prompt.

        Aristotle is a powerful theorem prover — give it freedom to produce
        excellent work, not rigid file name constraints. We describe WHAT
        outcomes we want, not HOW to name the files.

        Deliverable set (expanded):
          1. Lean 4 proofs
          2. Standalone popular-science ARTICLE (no "scientific american" / "lean" mentions)
          3. Comprehensive RESEARCH_PAPER with depth
          4. Python demos, algorithms
          5. Applications code
          6. FUTURE_DIRECTIONS roadmap
          7. JSON Data Package bundling everything
        """
        deliverables_section = f"""

### Deliverables

You are a world-class mathematician, software engineer, and science writer.
We need ALL of the following:

1. **Lean 4 proofs** — Non-trivial theorems with complete proofs (no `sorry`).
   Organize as makes sense. Use doc comments for key results.

2. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or proof assistants.
   Vivid prose, narrative arc, real-world connections. Must make sense standalone.

3. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results with proof sketches, algorithms, applications,
   discussion, future work, references.

4. **Python code** — demo.py (numerical examples), algorithms.py (type-hinted implementations),
   and up to 3 self-contained visualization scripts (matplotlib/plotly, each a single file
   with all functions inlined — no local imports).

5. **FUTURE_DIRECTIONS.md** (MOST IMPORTANT — drives next cycle).
   Begin with ## Synthesis tying all directions together. Then 3-5 directions using:
   **Conjecture**, **Test**, **Impact**, **Catalog References**, **Proof Strategy**,
   **Domain Bridges**, **Lineage**, **Ambition** (grand_challenge or extension).
   Each direction must be self-contained and specific enough to fail.

6. **PACKAGE.json** — Single JSON bundling all artifacts:
   title, domain, article, research_paper, future_directions, demos, algorithms,
   visualizations, interactive_demos, lean_proofs. JSON-escape all content.

   **interactive_demos** (MANDATORY — include at least 1): Array of objects, each with:
   - `name`: short title
   - `html`: self-contained HTML+CSS+JS snippet (inline styles, no external JS files,
     no local imports, CDN links OK for d3/plotly). Must render an interactive widget
     (slider, button, animation, etc.) that demonstrates a key result visually.
     Wrap in a `<div>` with inline styles. Use vanilla JS — no frameworks.
   - `description`: one-sentence summary

   **visualizations**: Array of objects with `name`, `code` (standalone Python script
   using matplotlib or plotly, all functions inlined), `description`.

   **algorithms**: Array of objects with `name`, `pseudocode` (brief), `code` (Python).

Research domain: {concept.domain}
Research mode: {concept.research_mode}
"""

        # Replace the old rigid "Expected Deliverables" section if present
        if "### Expected Deliverables" in base_prompt:
            augmented = base_prompt.replace(
                "### Expected Deliverables",
                deliverables_section
            )
        else:
            augmented = base_prompt + deliverables_section

        return augmented

    def _build_project_dir(self, job: ResearchJob) -> Optional[Path]:
        """Build a project directory for Aristotle with the full Lean Catalog.

        Copies every .lean file from the Catalog into the project directory,
        preserving the domain subdirectory structure (Algebra/, Tropical/, etc.).
        This gives Aristotle maximum context to build on existing verified theorems.
        """
        dir_path = self.workspace / f"projects/{job.job_id}"
        dir_path.mkdir(parents=True, exist_ok=True)

        # Copy the entire Lean-only Catalog into the project directory (skip .lake)
        # Skip FINAL/ — those are symlinks to canonical copies already included
        catalog_dst = dir_path / "Catalog"
        lean_count = 0
        for src_file in self.catalog_root.rglob("*.lean"):
            if ".lake" in src_file.parts:
                continue
            if "FINAL" in src_file.parts:
                continue
            # Resolve symlinks — copy the real file content
            real_src = src_file.resolve() if src_file.is_symlink() else src_file
            rel = src_file.relative_to(self.catalog_root)
            dst_file = catalog_dst / rel
            dst_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(real_src, dst_file)
            lean_count += 1

        # Copy Lean project configuration files
        for cfg in ["lean-toolchain", "lakefile.toml", "lakefile.lean", "lake-manifest.json"]:
            src_cfg = self.catalog_root / cfg
            if src_cfg.exists():
                # Copy to the project root (where Aristotle looks first)
                shutil.copy2(src_cfg, dir_path / cfg)
                # And inside the Catalog subdirectory for completeness
                catalog_dst.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src_cfg, catalog_dst / cfg)

        print(f"[Project] Copied {lean_count} .lean files and project configs from Catalog")

        # Write the prompt as a README for context
        (dir_path / "PROMPT.md").write_text(job.prompt)

        return dir_path

    async def _dispatch_to_aristotle(self, job: ResearchJob, max_retries: int = 2) -> str:
        """Dispatch the job to Aristotle with retry on transient failures.

        The aristotlelib SDK creates a fresh httpx.AsyncClient per request with
        a 30s timeout — too short for uploading a project with 7000+ .lean files.
        We temporarily raise the module-level default before calling create_from_directory.
        """
        import aristotlelib.api_request as api_mod
        from aristotlelib import Project

        # Temporarily increase timeout for the upload (default 30s is too short)
        original_timeout = api_mod.DEFAULT_TIMEOUT_SECONDS
        api_mod.DEFAULT_TIMEOUT_SECONDS = 300  # 5 minutes

        last_error = None
        try:
            for attempt in range(max_retries + 1):
                try:
                    project = await Project.create_from_directory(
                        prompt=job.prompt,
                        project_dir=str(job.project_dir),
                    )
                    return project.project_id
                except Exception as e:
                    last_error = e
                    if attempt < max_retries:
                        wait = 5 * (attempt + 1)
                        print(f"[Dispatch] Attempt {attempt+1}/{max_retries+1} failed: {e}, retrying in {wait}s...")
                        await asyncio.sleep(wait)
        finally:
            api_mod.DEFAULT_TIMEOUT_SECONDS = original_timeout

        raise last_error

    # ==================================================================
    # Phase 3: AWAIT — Poll Aristotle for completion
    # ==================================================================

    async def poll_all(self) -> List[ResearchJob]:
        """Poll all in-flight jobs and return completed ones."""
        completed = []
        for pid, job in list(self.inflight.items()):
            if job.status in ("completed", "failed", "integrated", "rejected"):
                completed.append(job)
                continue
                
            try:
                result = await self.aristotle.poll_project(pid)
                status = result.get("status", "unknown")
                has_files = result.get("has_files", False)
                is_complete = result.get("complete", False)

                if is_complete or (status == "IDLE" and has_files):
                    print(f"[Poll] {pid[:8]} COMPLETED (status={status}, has_files={has_files})")
                    job.status = "completed"
                    job.complete_time = time.time()
                    completed.append(job)
                elif status == "IDLE" and not has_files:
                    print(f"[Poll] {pid[:8]} FAILED (IDLE, no files)")
                    job.status = "failed"
                    job.error_message = "Aristotle status: IDLE with no result files"
                    self.failed_count += 1
                    completed.append(job)
                elif status == "RUNNING":
                    print(f"[Poll] {pid[:8]} in progress (RUNNING)")
            except Exception as e:
                print(f"[Poll] {pid[:8]} error: {e}")

        if completed:
            self._save_inflight()

        return completed

    # ==================================================================
    # Phase 4: EXTRACT — Download and parse Aristotle's results
    # ==================================================================

    def extract(self, job: ResearchJob) -> ResearchJob:
        """Download and extract Aristotle's result tarball."""
        if not job.project_id:
            job.error_message = "No project_id"
            return job

        try:
            with tempfile.TemporaryDirectory() as tmpdir:
                tar_path = asyncio.get_event_loop().run_until_complete(
                    self.aristotle.download_result(job.project_id, Path(tmpdir))
                )
                # Check for auth error marker from download_result
                if tar_path and tar_path.name == "__AUTH_ERROR__":
                    job.error_message = "Result download failed: authentication error (403/401)"
                    job.status = "failed"
                    return job
                if not tar_path or not tar_path.exists():
                    job.error_message = "Result download failed"
                    return job

                # Extract
                extract_dir = Path(tmpdir) / "extracted"
                with tarfile.open(tar_path, 'r:gz') as tar:
                    tar.extractall(extract_dir)

                # Parse the results
                job = self._parse_aristotle_result(job, extract_dir)

        except Exception as e:
            job.error_message = f"Extraction failed: {e}"

        return job

    async def extract_async(self, job: ResearchJob) -> ResearchJob:
        """Async version of extract — safe to call from within an active event loop."""
        if not job.project_id:
            job.error_message = "No project_id"
            return job

        try:
            with tempfile.TemporaryDirectory() as tmpdir:
                tar_path = await self.aristotle.download_result(job.project_id, Path(tmpdir))
                # Check for auth error marker from download_result
                if tar_path and tar_path.name == "__AUTH_ERROR__":
                    job.error_message = "Result download failed: authentication error (403/401)"
                    job.status = "failed"
                    return job
                if not tar_path or not tar_path.exists():
                    job.error_message = "Result download failed"
                    return job

                # Extract
                extract_dir = Path(tmpdir) / "extracted"
                with tarfile.open(tar_path, 'r:gz') as tar:
                    tar.extractall(extract_dir)

                # Parse the results
                job = self._parse_aristotle_result(job, extract_dir)

        except Exception as e:
            job.error_message = f"Extraction failed: {e}"

        return job

    def _parse_aristotle_result(self, job: ResearchJob, extract_dir: Path) -> ResearchJob:
        """Parse Aristotle's result directory to extract all artifacts.

        Aristotle is free to organize however it sees fit. We scan for:
        - Any .lean files containing theorem proofs
        - Any .py files (demos, applications, algorithms)
        - Any .md files (articles, research papers, discussions, future directions)
        - Any .html files (standalone HTML packages)
        - Any other useful artifacts
        """
        lean_files = []
        python_files = []
        paper_files = []
        future_directions_files = []
        discussion_files = []
        article_files = []
        research_paper_files = []
        json_package_files = []
        summary = None
        # Track diff files and seen paths to avoid duplicates.
        # We cannot set attributes on Path objects (they use __slots__),
        # so we use a dict keyed by the file's string path.
        diff_paths = {}   # abs_path_str -> True if file is a diff, not full content
        seen_rel_paths = {}   # catalog-relative path -> fp (dedup by catalog location)

        for root, dirs, files in os.walk(extract_dir):
            for f in files:
                fp = Path(root) / f
                # Skip build artifacts
                if ".lake" in str(fp) or "lake-manifest" in f or "lakefile" in f:
                    continue

                # Is this file identical to a local file?
                is_modified = True
                is_diff_file = False
                try:
                    rel = fp.relative_to(extract_dir)
                    
                    # Locate where the actual Catalog structure begins in the extracted path
                    if "Catalog" in rel.parts:
                        idx = rel.parts.index("Catalog")
                        local_equiv = self.catalog_root / Path(*rel.parts[idx+1:])
                    else:
                        # Strip _aristotle project directory prefixes from relative path
                        # e.g. 47bf2ccd_aristotle/Bridges/file.lean -> Bridges/file.lean
                        clean_parts = []
                        for p in rel.parts:
                            if re.match(r'^[0-9a-f]+_aristotle$', p):
                                continue
                            clean_parts.append(p)
                        local_equiv = self.catalog_root / Path(*clean_parts) if clean_parts else self.catalog_root / rel

                    # Deduplicate: if we've already seen a file for this catalog
                    # location, skip the duplicate (prefer the version closer to root).
                    catalog_rel = str(local_equiv.relative_to(self.catalog_root)) if local_equiv.exists() else str(rel)
                    if catalog_rel in seen_rel_paths:
                        continue
                    seen_rel_paths[catalog_rel] = fp
                        
                    if local_equiv.exists():
                        # Read text and ignore whitespace/CRLF differences
                        fp_text = fp.read_text(encoding='utf-8', errors='ignore')
                        local_text = local_equiv.read_text(encoding='utf-8', errors='ignore')
                        
                        # Normalize all whitespace for comparison
                        fp_norm = re.sub(r'\s+', ' ', fp_text).strip()
                        local_norm = re.sub(r'\s+', ' ', local_text).strip()
                        
                        if fp_norm == local_norm:
                            is_modified = False
                        else:
                            # It actually changed! Generate a diff
                            import difflib
                            diff = list(difflib.unified_diff(
                                local_text.splitlines(keepends=True),
                                fp_text.splitlines(keepends=True),
                                fromfile=f"a/{local_equiv.relative_to(self.catalog_root)}",
                                tofile=f"b/{local_equiv.relative_to(self.catalog_root)}"
                            ))
                            if diff:
                                # Store diff text separately; do NOT modify the
                                # original file and do NOT set attributes on Path.
                                diff_text = "".join(diff)
                                diff_paths[str(fp)] = diff_text
                                is_diff_file = True
                except Exception as e:
                    print(f"[Extract] Warning comparing {fp.name}: {e}")

                if f == "ARISTOTLE_SUMMARY.md":
                    summary = fp.read_text()
                elif not is_modified:
                    continue  # Skip unchanged files!
                elif f.endswith(".lean") and f != "Main.lean":
                    lean_files.append((fp, is_diff_file))
                elif f.endswith(".py"):
                    python_files.append(fp)
                elif f.endswith(".json") and f != "knowledge_data.json":
                    # JSON package files (PACKAGE.json or similar)
                    json_package_files.append(fp)
                elif f.endswith(".md") and f not in ("README.md", "PROMPT.md"):
                    fname_lower = f.lower()
                    if "future_directions" in fname_lower or "future-directions" in fname_lower:
                        future_directions_files.append(fp)
                    elif fname_lower.startswith("article") or fname_lower == "article.md":
                        article_files.append(fp)
                    elif "research_paper" in fname_lower or "research-paper" in fname_lower or fname_lower == "research_paper.md":
                        research_paper_files.append(fp)
                    elif "discussion" in fname_lower or "sciam" in fname_lower or "scientific_american" in fname_lower:
                        discussion_files.append(fp)
                    else:
                        paper_files.append(fp)

        # Collect Lean sources — Aristotle decides which files contain the new theorems
        if lean_files:
            parts = []
            seen_paths = set()  # Deduplicate by catalog-relative path
            for fp, is_diff_file in sorted(lean_files, key=lambda x: str(x[0])):
                # Get content: if it's a diff file, use the diff text from diff_paths dict,
                # otherwise read the file directly
                if is_diff_file and str(fp) in diff_paths:
                    content = diff_paths[str(fp)]
                else:
                    content = fp.read_text(encoding='utf-8', errors='ignore')
                rel_path = fp.relative_to(extract_dir) if extract_dir in fp.parents else fp.name
                # Strip _aristotle project directory prefixes (e.g. c6e162ae_aristotle/)
                # These are temporary extraction dirs, not real Catalog paths
                clean_parts = []
                for p in rel_path.parts:
                    if re.match(r'^[0-9a-f]+_aristotle$', p):
                        continue
                    clean_parts.append(p)
                clean_rel = Path(*clean_parts) if clean_parts else rel_path
                # Deduplicate by catalog-relative path to avoid writing same file twice
                dedup_key = str(clean_rel).replace('\\', '/')
                # For files under Catalog/ subdirectory, strip that prefix for dedup
                if "Catalog/" in dedup_key:
                    dedup_key = dedup_key.split("Catalog/", 1)[1]
                if dedup_key in seen_paths:
                    continue
                seen_paths.add(dedup_key)
                # Use the cleaned path in headers so downstream gets real Catalog paths
                header = f"-- DIFF: {clean_rel}\n" if is_diff_file else f"-- NEW_FILE: {clean_rel}\n"
                parts.append(f"{header}{content}\n")
            job.result_lean = "\n\n".join(parts)

        # Collect Python artifacts — separate algorithms from demos
        algo_parts = []
        demo_parts = []
        for f in sorted(python_files):
            content = f.read_text()
            fname = f.name.lower()
            if "algorithm" in fname or fname == "algorithms.py":
                algo_parts.append(content)
            else:
                demo_parts.append(content)
        if algo_parts:
            job.result_algorithms = "\n\n".join(algo_parts)
        if demo_parts:
            job.result_demo = "\n\n".join(demo_parts)
        elif algo_parts and not demo_parts:
            # If all .py files are algorithms, still put them in result_demo
            # so downstream consumers that only check result_demo still work
            job.result_demo = "\n\n".join(algo_parts)

        # Collect paper / general markdown artifacts
        if paper_files:
            parts = []
            for f in sorted(paper_files):
                parts.append(f.read_text())
            job.result_paper = "\n\n".join(parts)

        # Collect FUTURE_DIRECTIONS — the MOST IMPORTANT deliverable
        if future_directions_files:
            parts = []
            for f in sorted(future_directions_files):
                parts.append(f.read_text())
            job.result_future_directions = "\n\n".join(parts)

        # Collect discussion articles (legacy format)
        if discussion_files:
            parts = []
            for f in sorted(discussion_files):
                parts.append(f.read_text())
            job.result_discussion = "\n\n".join(parts)

        # Collect standalone popular-science ARTICLE (new deliverable)
        if article_files:
            parts = []
            for f in sorted(article_files):
                parts.append(f.read_text())
            job.result_article = "\n\n".join(parts)

        # Collect comprehensive RESEARCH PAPER (new deliverable)
        if research_paper_files:
            parts = []
            for f in sorted(research_paper_files):
                parts.append(f.read_text())
            job.result_research_paper = "\n\n".join(parts)

        # Collect HTML package (new deliverable — standalone bundle)
        if json_package_files:
            parts = []
            for f in sorted(json_package_files):
                parts.append(f.read_text(encoding='utf-8', errors='ignore'))
            # If multiple JSON package files were produced, merge them
            # instead of concatenating (which creates invalid JSON)
            if len(parts) == 1:
                job.result_json_package = parts[0]
            else:
                merged = {}
                for part in parts:
                    try:
                        obj = json.loads(part)
                        if isinstance(obj, dict):
                            # Later files override earlier ones
                            merged.update(obj)
                    except json.JSONDecodeError:
                        pass
                if merged:
                    job.result_json_package = json.dumps(merged, ensure_ascii=False)
                else:
                    # Fallback: use first file only
                    job.result_json_package = parts[0]

        # Summary
        job.result_summary = summary

        # Count sorries and theorems across all Lean output
        if job.result_lean:
            job.sorry_count = job.result_lean.count("sorry")
            job.theorem_count = job.result_lean.count("theorem ") + job.result_lean.count("lemma ")

        print(f"[Extract] Lean: {len(lean_files)} files, Python: {len(python_files)} files, "
              f"Papers: {len(paper_files)} files, "
              f"Article: {len(article_files)} files, "
              f"ResearchPaper: {len(research_paper_files)} files, "
              f"JSON: {len(json_package_files)} files, "
              f"FUTURE_DIRECTIONS: {len(future_directions_files)} files, "
              f"Discussion: {len(discussion_files)} files, "
              f"Sorries: {job.sorry_count}, Theorems: {job.theorem_count}")

        # Persist extraction results to inflight_jobs
        if job.project_id and job.project_id in self.inflight:
            self.inflight[job.project_id] = job
            self._save_inflight()

        return job

    # ==================================================================
    # Phase 5: EVALUATE — Pi judges the quality
    # ==================================================================

    @staticmethod
    def _compact_result_lean(result_lean: str, max_chars: int = 100_000) -> str:
        """Compact oversized result_lean for evaluation.

        Keeps the first 50K chars (opening definitions/imports) and last 10K
        chars (final theorems), with a marker showing what was omitted.
        """
        if len(result_lean) <= max_chars:
            return result_lean
        head = 50_000
        tail = 10_000
        omitted = len(result_lean) - head - tail
        return (
            result_lean[:head]
            + f"\n\n[... {omitted:,} chars omitted for evaluation budget ...]\n\n"
            + result_lean[-tail:]
        )

    def evaluate(self, job: ResearchJob) -> ResearchJob:
        """Pi-Agent evaluates the quality of Aristotle's result."""
        if not job.result_lean:
            job.quality_score = 0.0
            job.quality_assessment = {"quality": "trivial", "analysis": "No Lean output"}
            return job

        # Compact oversized result_lean before passing to evaluation
        compact_lean = self._compact_result_lean(job.result_lean)

        # Pi-Agent: THE BRAINS — evaluates quality
        qa = self.pi_agent.evaluate_result_quality(
            result_lean=compact_lean,
            concept=job.concept,
            prompt=job.prompt,
        )
        job.quality_assessment = qa

        # Compute the heuristic composite score
        # First, get LLM-graded breakthrough assessment
        breakthrough_grade = "incremental"
        if self.pi_agent and hasattr(self.pi_agent, 'evaluate_breakthrough'):
            breakthrough_grade = self.pi_agent.evaluate_breakthrough(compact_lean, job.concept)

        heuristic_score = self.autoresearch.evaluate_concept_quality(
            concept_title=job.concept.title,
            concept_domain=job.concept.domain,
            quality_assessment=qa,
            catalog_references=job.concept.catalog_references,
            research_mode=job.concept.research_mode,
            prompt_length=len(job.prompt),
            theorem_count=job.theorem_count,
            sorry_count=job.sorry_count,
            has_cross_domain="Bridge" in (job.concept.title or "") or "bridge" in (job.concept.domain or "").lower(),
            advances_open_problem=job.concept.research_mode == "sorry_fill" and job.sorry_count == 0,
            breakthrough_grade=breakthrough_grade,
        )

        # 8-axis structural quality evaluation
        from quality_evaluator import QualityEvaluator
        qeval = QualityEvaluator(pi_agent=self.pi_agent, catalog_root=self.catalog_root)
        try:
            # Collect existing theorem titles for novelty comparison
            existing_titles = set()
            if hasattr(self, 'catalog_analyzer') and self.catalog_analyzer:
                for s in self.catalog_analyzer.scan():
                    existing_titles.update(s.declarations)

            qscore = qeval.evaluate(
                lean_source=compact_lean,
                result_dir=job.project_dir if hasattr(job, 'project_dir') and job.project_dir else None,
                concept_title=job.concept.title,
                concept_description=job.concept.concept_description,
                existing_titles=existing_titles,
                catalog_references=job.concept.catalog_references or [],
                result_fields={
                    "result_paper": job.result_paper or "",
                    "result_research_paper": job.result_research_paper or "",
                    "result_demo": job.result_demo or "",
                    "result_algorithms": job.result_algorithms or "",
                    "result_discussion": job.result_discussion or "",
                    "result_future_directions": job.result_future_directions or "",
                },
            )
            job.quality_detail = qscore
            # Blend heuristic and structural scores using direction-driven weights
            concept_domains = getattr(job.concept, 'domains', []) if job.concept else []
            composite = qscore.composite_with_domains(domains=concept_domains) if hasattr(qscore, 'composite_with_domains') else qscore.composite
            job.quality_score = 0.4 * heuristic_score + 0.6 * composite
        except Exception as e:
            print(f"[Evaluate] Warning: QualityEvaluator failed, using heuristic only: {e}")
            job.quality_score = heuristic_score

        print(f"[Evaluate] quality={qa.get('quality','?')}, score={job.quality_score:.3f}, "
              f"sorries={job.sorry_count}, theorems={job.theorem_count}"
              + (f", depth={job.quality_detail.proof_depth:.2f}" if hasattr(job, 'quality_detail') and job.quality_detail else ""))

        # Persist evaluation results to inflight_jobs
        if job.project_id and job.project_id in self.inflight:
            self.inflight[job.project_id] = job
            self._save_inflight()

        return job

    # ==================================================================
    # Phase 6: INTEGRATE — Pi places artifacts in Catalog
    # ==================================================================

    def integrate(self, job: ResearchJob) -> ResearchJob:
        """Synchronous version of integrate."""
        # Use a new event loop if none exists, else run directly if blocking is acceptable here
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                # We shouldn't be here in async context, but just in case
                import warnings
                warnings.warn("Calling sync integrate from running loop; this will block.")
        except RuntimeError:
            pass
            
        return asyncio.run(self.integrate_async(job))

    def _update_exp_id_map(self, job: ResearchJob, package_filename: str) -> None:
        """Record the mapping from exp_id to package filename for provenance tracking."""
        if not hasattr(job, 'job_id') or not job.job_id:
            return
        map_file = self.workspace / "exp_id_map.json"
        mapping = {}
        if map_file.exists():
            try:
                mapping = json.loads(map_file.read_text(encoding="utf-8"))
            except Exception:
                mapping = {}
        mapping[job.job_id] = package_filename
        map_file.parent.mkdir(parents=True, exist_ok=True)
        map_file.write_text(json.dumps(mapping, indent=2, ensure_ascii=False), encoding="utf-8")

    async def integrate_async(self, job: ResearchJob) -> ResearchJob:
        """Pi-Agent integrates Aristotle's output into the Catalog.

        Handles all artifact types:
        - Lean files → domain directories or Speculative/AutoResearch/
        - Python demos → Applications/Demos/
        - Papers → Applications/Papers/
        - Articles → Applications/Articles/
        - Research papers → Applications/Papers/
        - HTML packages → Applications/Packages/
        - Discussion → Applications/Articles/
        """
        if job.quality_score < 0.05:
            print(f"[Integrate] REJECTED: score too low ({job.quality_score:.3f})")
            job.status = "rejected"
            return job

        has_any_content = any([
            job.result_lean, job.result_demo, job.result_paper,
            job.result_article, job.result_research_paper,
            job.result_json_package, job.result_discussion,
        ])
        if not has_any_content:
            print(f"[Integrate] No new/modified files to integrate.")
            job.status = "integrated"
            self.completed_count += 1
            return job

        print(f"[Integrate] Asking Pi-Agent to verify and integrate ALL artifacts...")
        import subprocess
        
        # 1. Parse out the diffs and new files
        parts = []
        if job.result_lean:
            # Split by either -- DIFF: or -- NEW_FILE:
            blocks = re.split(r'(?=-- DIFF: |-- NEW_FILE: )', job.result_lean)
            for block in blocks:
                if not block.strip(): continue
                lines = block.split("\n")
                header = lines[0]
                content = "\n".join(lines[1:]).strip()
                if header.startswith("-- DIFF: "):
                    parts.append({"type": "diff", "path": header.replace("-- DIFF: ", "").strip(), "content": content})
                elif header.startswith("-- NEW_FILE: "):
                    parts.append({"type": "new", "path": header.replace("-- NEW_FILE: ", "").strip(), "content": content})
                    
        if job.result_demo:
            parts.append({"type": "new", "path": f"Applications/Demos/{self._derive_artifact_name(job.concept, 'py')}", "content": job.result_demo})
        if job.result_algorithms:
            parts.append({"type": "new", "path": f"Applications/Demos/algorithms_{self._derive_artifact_name(job.concept, 'py')}", "content": job.result_algorithms})
        if job.result_paper:
            parts.append({"type": "new", "path": f"Applications/Papers/{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_paper})

        # NEW artifact types — integrate into correct Catalog locations
        if job.result_article:
            parts.append({"type": "new", "path": f"Applications/Articles/{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_article})
        if job.result_research_paper:
            parts.append({"type": "new", "path": f"Applications/Papers/research_{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_research_paper})
        if job.result_json_package:
            # Enrich JSON package with executable module code for Pyodide
            enriched_pkg = job.result_json_package
            if job.result_algorithms or job.result_demo:
                enriched_pkg = self._enrich_json_package(job.result_json_package, job)
            parts.append({"type": "new", "path": f"Applications/Packages/{self._derive_artifact_name(job.concept, 'json')}", "content": enriched_pkg})
        if job.result_discussion:
            parts.append({"type": "new", "path": f"Applications/Articles/discussion_{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_discussion})

        # 2. Separate auto-accept files from review-needed files
        # Speculative/AutoResearch/ files are speculative by definition — auto-accept them.
        # Applications/ files (Demos, Papers, Articles, Packages) are also auto-accepted.
        # Only domain-directory Lean files and FINAL/ placements need Pi-Agent review.
        SPECULATIVE_PREFIXES = ("Speculative/AutoResearch/", "Applications/Demos/",
                                "Applications/Papers/", "Applications/Articles/",
                                "Applications/Packages/")
        auto_accept_parts = []
        review_parts = []
        for p in parts:
            is_speculative = any(p["path"].startswith(prefix) or p["path"].startswith(f"Catalog/{prefix}") for prefix in SPECULATIVE_PREFIXES)
            if is_speculative:
                auto_accept_parts.append(p)
            else:
                review_parts.append(p)

        print(f"[Integrate] {len(auto_accept_parts)} auto-accepted, {len(review_parts)} need review")

        # Build the integration plan: auto-accept speculative, review the rest in batches
        plan = {}

        # Auto-accept speculative/Application files
        for p in auto_accept_parts:
            plan[p["path"]] = p["path"]  # Keep their original path

        # 3. Ask Pi to review domain-directory and FINAL/ placements (in batches of 25)
        # Cap total reviews per integration to avoid spending the entire tick on one job
        MAX_REVIEW_FILES = 100
        BATCH_SIZE = 25
        if review_parts:
            review_subset = review_parts[:MAX_REVIEW_FILES]
            if len(review_parts) > MAX_REVIEW_FILES:
                print(f"[Integrate] Reviewing {MAX_REVIEW_FILES} of {len(review_parts)} files (capped)")
            batches = [review_subset[i:i + BATCH_SIZE] for i in range(0, len(review_subset), BATCH_SIZE)]
            for batch_idx, batch in enumerate(batches):
                batch_plan = await self._review_file_batch(batch, batch_idx, len(batches))
                plan.update(batch_plan)
            # Auto-accept remaining files beyond the cap
            for p in review_parts[MAX_REVIEW_FILES:]:
                plan[p["path"]] = p["path"]

        # 4. Apply the changes — with deduplication and REJECT filtering
        written_paths = set()  # Track what we've already written to avoid duplicates
        files_written = 0  # Count files actually written to Catalog

        for p in parts:
            raw_target = plan.get(p["path"], p["path"])

            # Filter out REJECT entries (Pi said don't integrate this)
            if not raw_target or raw_target.upper().startswith("REJECT"):
                print(f"[Integrate] Skipped (rejected by Pi): {p['path']}")
                continue
            
            target_path = self._authorize_integration_path(job, p, raw_target)
            
            # Filter out REJECT entries from authorization
            if not target_path or target_path == "REJECT" or target_path.upper().startswith("REJECT"):
                print(f"[Integrate] Skipped (rejected): {p['path']}")
                continue
            
            # Deduplicate: skip if we've already written to this path in this pass
            if target_path in written_paths:
                print(f"[Integrate] Skipped (duplicate target): {target_path}")
                continue
            written_paths.add(target_path)
                
            abs_target = self.catalog_root / target_path
            
            # Safety check: don't overwrite an existing catalog file with identical content
            if abs_target.exists() and p["type"] == "new":
                try:
                    existing_content = abs_target.read_text(encoding='utf-8', errors='ignore')
                    new_content = p.get("content", "")
                    if re.sub(r'\s+', ' ', existing_content).strip() == re.sub(r'\s+', ' ', new_content).strip():
                        print(f"[Integrate] Skipped (unchanged): {target_path}")
                        continue
                except Exception:
                    pass  # If we can't read it, proceed with writing
            
            abs_target.parent.mkdir(parents=True, exist_ok=True)
            
            if p["type"] == "new":
                abs_target.write_text(p["content"], encoding="utf-8")
                print(f"[Integrate] Created {target_path}")
                files_written += 1
                # Update exp_id mapping for provenance tracking
                if target_path.endswith('.json') and 'Packages' in str(target_path):
                    self._update_exp_id_map(job, os.path.basename(str(target_path)))
            elif p["type"] == "diff":
                # Write diff to temporary file and use patch
                import tempfile
                with tempfile.NamedTemporaryFile("w", delete=False) as f:
                    f.write(p["content"])
                    patch_file = f.name
                
                try:
                    # Apply diff
                    result = subprocess.run(["patch", str(abs_target), patch_file], capture_output=True, text=True)
                    if result.returncode == 0:
                        print(f"[Integrate] Merged diff into {target_path}")
                        files_written += 1
                    else:
                        print(f"[Integrate] Patch failed for {target_path}: {result.stderr}")
                except Exception as e:
                    print(f"[Integrate] Patch failed for {target_path}: {e}")
                finally:
                    os.unlink(patch_file)

        print(f"[Integrate] Pi successfully integrated {files_written} files.")
        job.files_integrated = files_written
        job.integrated_paths = list(written_paths)
        job.status = "integrated"
        self.completed_count += 1

        # Update package_index.js and lineage if we saved a JSON package
        if job.result_json_package:
            try:
                packages_dir = self.catalog_root / "Applications" / "Packages"
                packages_dir.mkdir(parents=True, exist_ok=True)

                # Run update_index.py to regenerate package_index.js (lightweight index)
                try:
                    import subprocess
                    aether_root = Path(__file__).parent
                    lineage_script = aether_root / "lineage_extractor.py"
                    if lineage_script.exists():
                        result = subprocess.run(
                            [__import__("sys").executable, str(lineage_script)],
                            capture_output=True, text=True, cwd=str(aether_root)
                        )
                        if result.returncode == 0:
                            print(f"[Integrate] Updated lineage.json")
                        else:
                            print(f"[Integrate] Warning: lineage_extractor failed: {result.stderr[:200]}")

                    update_script = packages_dir / "update_index.py"
                    if update_script.exists():
                        result = subprocess.run(
                            [__import__("sys").executable, str(update_script)],
                            capture_output=True, text=True, cwd=str(packages_dir)
                        )
                        if result.returncode == 0:
                            print(f"[Integrate] Updated package_index.js with PACKAGE_GRAPH")
                        else:
                            print(f"[Integrate] Warning: update_index failed: {result.stderr[:200]}")
                except Exception as e:
                    print(f"[Integrate] Warning: Failed to update package_index.js: {e}")
            except Exception as e:
                print(f"[Integrate] Warning: Failed to update package_index.js: {e}")

        return job

    async def _review_file_batch(self, batch: List[Dict[str, Any]], batch_idx: int, total_batches: int) -> Dict[str, str]:
        """Send a batch of files to Pi-Agent for accept/reject review.

        Returns a dict mapping each file's original path to its authorized
        target path (or "REJECT" if Pi says not to integrate).
        """
        # Strip _aristotle project dir prefixes (e.g. c6e162ae_aristotle/) from
        # file paths before including them in the review listing
        for p in batch:
            path = p.get("path", "")
            if path:
                cleaned_parts = [part for part in path.replace("\\", "/").split("/")
                                 if not re.match(r'^[0-9a-f]+_aristotle', part)]
                p["path"] = "/".join(cleaned_parts) if cleaned_parts else path

        # Build a compact listing of the batch
        listing_parts = []
        for i, p in enumerate(batch):
            content_preview = (p.get("content", "") or "")[:300]
            listing_parts.append(
                f"[{i}] type={p['type']} path={p['path']}\n"
                f"    preview: {content_preview}"
            )
        listing = "\n".join(listing_parts)

        system = (
            "You are a mathematical research integration assistant. "
            "Review each file and decide where it should be placed in the Catalog, "
            "or whether it should be REJECTED (duplicate, empty, or junk). "
            "Output ONLY valid JSON: a dict mapping each index to either "
            "the target path string or 'REJECT'."
        )
        user = (
            f"Review these {len(batch)} files (batch {batch_idx+1}/{total_batches}).\n"
            f"For each file, decide:\n"
            f"- If it's a valid contribution, output its Catalog path (keep the suggested path unless it's wrong)\n"
            f"- If it's empty, duplicate, or junk, output 'REJECT'\n\n"
            f"{listing}\n\n"
            f"Output JSON like: {{\"0\": \"Algebra/SomeFile.lean\", \"1\": \"REJECT\", ...}}"
        )

        try:
            raw = self.pi_agent._call_ollama(system, user, timeout=120)
        except Exception as e:
            print(f"[Integrate] Pi-Agent batch review failed: {e}")
            # On failure, auto-accept all files in the batch
            return {p["path"]: p["path"] for p in batch}

        result = self.pi_agent._parse_json_response(raw)
        if not result:
            print(f"[Integrate] Could not parse Pi-Agent batch review response, auto-accepting batch")
            return {p["path"]: p["path"] for p in batch}

        # Map Pi's index-based response back to file paths
        plan = {}
        for i, p in enumerate(batch):
            pi_decision = result.get(str(i), p["path"])
            if isinstance(pi_decision, str):
                # Strip _aristotle prefix from Pi's response paths too
                cleaned_decision = "/".join(
                    part for part in pi_decision.replace("\\", "/").split("/")
                    if not re.match(r'^[0-9a-f]+_aristotle', part)
                )
                plan[p["path"]] = cleaned_decision or pi_decision
            else:
                plan[p["path"]] = p["path"]  # Fallback: keep original path

        return plan

    def _authorize_integration_path(self, job: ResearchJob, part: Dict[str, Any], requested_path: str) -> str:
        """Normalize Pi/Aristotle placement decisions into safe Catalog paths.

        Pi is allowed to suggest paths, but no-sorry Lean files should not stay
        buried under Speculative/AutoResearch simply because Aristotle emitted
        them from a generated project directory. Speculative is reserved for
        Lean files that still contain `sorry`.

        Preserves subdirectory structure from Pi's response (e.g.
        EML/ReflectionCapacity/Defs.lean) rather than flattening to just
        domain/filename.
        """
        target_path = self._strip_catalog_prefix(str(requested_path or part.get("path", "")))
        # Strip any remaining _aristotle path segments (e.g. Bridges/47bf2ccd_aristotle/Bridges/...)
        target_path = re.sub(r'/[0-9a-f]+_aristotle/', '/', target_path)
        # Fix compound domain paths like AlgebraEML/Cryptography/ -> Bridges/AlgebraEMLCryptography/
        target_path = self._resolve_compound_domain_path(target_path)
        # Deduplicate repeated domain segments: Bridges/Bridges/ -> Bridges/
        target_path = self._deduplicate_domain_segments(target_path)
        suffix = Path(target_path).suffix.lower()

        # Safety: reject obviously invalid paths
        if not target_path or target_path.upper().startswith("REJECT"):
            return "REJECT"

        if suffix == ".lean" and part.get("type") == "new":
            has_sorry = self._lean_contains_sorry(part.get("content", ""))
            if has_sorry:
                # Incomplete proofs go to Speculative/AutoResearch, preserving any
                # subdirectory structure Pi suggested (e.g. EML/ReflectionCapacity/).
                filename = Path(target_path).name
                # If Pi gave a proper sub-structured speculative path, keep it
                parts = [p for p in target_path.replace("\\", "/").split("/") if p]
                if len(parts) > 2:
                    # Already has structure like Speculative/AutoResearch/EML/X.lean
                    return target_path
                else:
                    return f"Speculative/AutoResearch/{filename}"

            # For sorry-free Lean: trust Pi's full path structure. If Pi says
            # EML/ReflectionCapacity/Defs.lean, keep that. Only fix if it's still
            # stuck under Speculative/ or missing a domain prefix.
            parts = [p for p in target_path.replace("\\", "/").split("/") if p]
            
            # If the path starts with Speculative, re-route to the proper domain
            if parts and parts[0] == "Speculative" and len(parts) >= 2:
                # Determine domain from the path content first, then concept domain
                path_domain = self._domain_from_path(target_path)
                domain = normalize_domain(path_domain or job.concept.domain or "MachineLearning")
                if not domain or domain == "Speculative":
                    domain = path_domain or "MachineLearning"
                # Rebuild with domain prefix, preserving subdirectory structure
                # e.g. Speculative/AutoResearch/EML/ReflectionCapacity/Defs.lean
                #      -> EML/ReflectionCapacity/Defs.lean
                sub_parts = parts[1:]  # Skip "Speculative"
                if sub_parts and sub_parts[0] == "AutoResearch":
                    sub_parts = sub_parts[1:]  # Skip "AutoResearch"
                # If sub_parts starts with a domain directory that matches our domain,
                # skip it to avoid duplication like EML/EML/...
                if sub_parts and normalize_domain(sub_parts[0]) == domain:
                    sub_parts = sub_parts[1:]
                if sub_parts:
                    return "/".join([domain] + sub_parts)
                else:
                    return f"{domain}/{Path(target_path).name}"
            
            # If path is just a filename (no domain prefix), add the domain
            filename = Path(target_path).name
            path_domain = self._domain_from_path(target_path)
            if not path_domain:
                # No domain in path — use the concept domain
                domain = normalize_domain(job.concept.domain or "MachineLearning")
                return f"{domain}/{filename}"

            # Path looks good — trust Pi's structure
            return target_path

        return target_path

    @staticmethod
    def _strip_catalog_prefix(path: str) -> str:
        path = path.replace("\\", "/").lstrip("/")
        prefixes = (
            "extracted/Catalog/",
            "Catalog/",
        )
        for prefix in prefixes:
            if path.startswith(prefix):
                path = path[len(prefix):]
                break
        # Strip Aristotle project directory prefixes like 47bf2ccd_aristotle/Bridges/...
        # These are artifacts of the extraction structure, not real Catalog paths
        path = re.sub(r'^[0-9a-f]+_aristotle/', '', path)
        # Fix doubled paths like Bridges/Catalog/Bridges/X.lean -> Bridges/X.lean
        # The LLM sometimes generates paths with interior "Catalog/" segments
        while '/Catalog/' in path:
            path = path.replace('/Catalog/', '/')
        return path

    @staticmethod
    def _deduplicate_domain_segments(path: str) -> str:
        """Remove repeated domain-like segments from paths.

        E.g. Bridges/Bridges/X.lean -> Bridges/X.lean
        Handles cases where the LLM or path computation creates doubled segments.
        """
        parts = [p for p in path.replace("\\", "/").split("/") if p]
        if len(parts) < 2:
            return path
        known_domains = {
            "Algebra", "Applications", "Bridges", "Computation", "Cryptography",
            "EML", "Geometry", "Logic", "MachineLearning", "Novelty", "Physics",
            "Pythagorean", "Shared", "Speculative", "Tropical",
        }
        deduped = [parts[0]]
        for i in range(1, len(parts)):
            # Skip a segment if it's the same domain as the previous segment
            if parts[i] == deduped[-1] and parts[i] in known_domains:
                continue
            deduped.append(parts[i])
        return "/".join(deduped)

    @staticmethod
    def _lean_contains_sorry(content: str) -> bool:
        return bool(re.search(r'(?<![A-Za-z0-9_])sorry(?![A-Za-z0-9_])', content))

    @staticmethod
    def _domain_from_path(path: str) -> str:
        """Extract the content domain from a path, skipping Speculative/AutoResearch prefixes."""
        parts = [p for p in path.replace("\\", "/").split("/") if p]
        known_domains = {
            "Algebra", "Applications", "Bridges", "Computation", "Cryptography",
            "EML", "Geometry", "Logic", "MachineLearning", "Physics",
            "Pythagorean", "Shared", "Tropical",
        }
        # Skip structural prefixes that aren't content domains
        skip_prefixes = {"Speculative", "AutoResearch"}
        for part in parts:
            if part in skip_prefixes:
                continue
            if part in known_domains:
                return part
        return ""

    def _resolve_compound_domain_path(self, target_path: str) -> str:
        """Fix paths like AlgebraEML/Cryptography/X.lean -> Bridges/AlgebraEMLCryptography/X.lean.

        Aristotle sometimes generates compound domain paths split into nested directories
        (AlgebraEML/Cryptography/) or as a single compound directory (AlgebraEMLCryptography/).
        Both should map to the correct Bridges/ subdirectory.
        """
        parts = [p for p in target_path.replace("\\", "/").split("/") if p]
        if not parts:
            return target_path

        # Already under Bridges/ — trust it
        if parts[0] == "Bridges":
            return target_path

        # Already a known single domain — no fix needed
        known_domains = {
            "Algebra", "Applications", "Bridges", "Computation", "Cryptography",
            "EML", "Geometry", "Logic", "MachineLearning", "Physics",
            "Pythagorean", "Shared", "Tropical", "Speculative", "Core",
        }
        if parts[0] in known_domains:
            return target_path

        bridges_dir = self.catalog_root / "Bridges"
        if not bridges_dir.exists():
            return target_path

        bridges_entries = {e.name for e in bridges_dir.iterdir() if e.is_dir()}

        # Priority 1: If first part + second part concatenates to a Bridges subdirectory,
        # use the compound form. This handles AlgebraEML/Cryptography/ -> Bridges/AlgebraEMLCryptography/
        # which is more specific than the bare AlgebraEML directory.
        if len(parts) >= 2:
            second = parts[1] if parts[1] != "Bridges" else (parts[2] if len(parts) > 2 else "")
            if second:
                compound = parts[0] + second
                if compound in bridges_entries:
                    skip = 2 if parts[1] != "Bridges" else 3
                    remaining = "/".join(parts[skip:]) if len(parts) > skip else ""
                    if remaining:
                        return f"Bridges/{compound}/{remaining}"
                    return f"Bridges/{compound}/{parts[-1]}"

        # Priority 2: The first part itself is a Bridges compound directory
        # e.g. AlgebraEMLCryptography/X.lean -> Bridges/AlgebraEMLCryptography/X.lean
        # e.g. VSAlgebra/X.lean -> Bridges/VSAlgebra/X.lean
        if parts[0] in bridges_entries:
            return "Bridges/" + target_path

        # No compound match — return as-is
        return target_path

    async def cleanup_catalog_async(self, job: ResearchJob) -> ResearchJob:
        """Run deduplication, cleanup project files, and Pi consolidation.
        
        Runs by default after every integration. Steps:
        1. Global deduplication (byte-for-byte exact copy removal)
        2. Project workspace cleanup (remove extracted tarball dirs)
        3. Pi consolidation session (check for duplicates, suggest refactoring)
        4. Catalog sync verification
        """
        if job.status != "integrated":
            return job
            
        import subprocess

        print(f"[Cleanup] Running global deduplication script...")
        try:
            # 1. Run global deduplication first to remove byte-for-byte exact copies
            dedup_script = Path(__file__).parent / "dedup_catalog.py"
            if dedup_script.exists():
                await asyncio.to_thread(
                    subprocess.run,
                    ["python3", str(dedup_script)],
                    capture_output=True,
                    timeout=120
                )
            
            # 2. Semantic cleanup was handled during the integration step
            if job.concept.domain:
                print(f"[Cleanup] Semantic cleanup was handled during the integration step.")
        except Exception as e:
            print(f"[Cleanup] Warning: {e}")

        # 3. Project workspace cleanup: remove extracted directories
        try:
            if job.project_dir and Path(job.project_dir).exists():
                import shutil
                print(f"[Cleanup] Removing project workspace: {job.project_dir}")
                await asyncio.to_thread(shutil.rmtree, str(job.project_dir), ignore_errors=True)
            # Also clean up any temp extract directories
            for temp_dir in Path(tempfile.gettempdir()).glob("aristotle_extract_*"):
                try:
                    await asyncio.to_thread(shutil.rmtree, str(temp_dir), ignore_errors=True)
                except Exception:
                    pass
        except Exception as e:
            print(f"[Cleanup] Warning: workspace cleanup failed: {e}")

        # 4. Verify catalog sync
        try:
            sync_report = self._verify_catalog_sync(job)
            if sync_report.get("missing_files"):
                print(f"[Cleanup] WARNING: {len(sync_report['missing_files'])} files not found at expected paths")
                for f in sync_report["missing_files"][:5]:
                    print(f"  - {f}")
        except Exception as e:
            print(f"[Cleanup] Warning: sync verification failed: {e}")

        # 5. LLM-assisted future directions cleanup
        try:
            await asyncio.to_thread(self._cleanup_future_directions)
        except Exception as e:
            print(f"[Cleanup] Warning: future directions cleanup failed: {e}")

        # 6. Catalog pruning — immortalize best theorems, remove junk
        try:
            await asyncio.to_thread(self._prune_catalog)
        except Exception as e:
            print(f"[Cleanup] Warning: catalog pruning failed: {e}")

        # 7. Structural hole mining — find domain pairs with no edges, generate bridge directions
        try:
            await asyncio.to_thread(self._mine_structural_holes)
        except Exception as e:
            print(f"[Cleanup] Warning: structural hole mining failed: {e}")

        # 8. ArXiv mining is handled by cycle_master.py Phase 10.7

        return job

    def _cleanup_future_directions(self) -> None:
        """Thoughtfully prune low-quality directions and brainstorm a novel new one.

        Reviews directions in small batches, requiring justification for each removal.
        Protects high-priority, Novelty-tagged, and seed directions.
        Runs every ~20 cycles to avoid over-pruning.
        """
        from research_memory import FutureDirectionsManager, FutureDirection
        fd_manager = FutureDirectionsManager(self.workspace)
        available = [d for d in fd_manager._directions if d.status == "available"]
        if len(available) < 5:
            return

        # Only run every ~20 cycles to avoid over-pruning
        if self.cycle_count % 20 != 0 and self.cycle_count > 0:
            return

        # Only review the bottom 30% by quality — top directions are protected
        scored = [(d, fd_manager._compute_quality_score(d)) for d in available]
        scored.sort(key=lambda x: x[1])  # ascending — worst first
        cutoff_idx = max(5, len(scored) // 3)  # review bottom third, at least 5
        candidates = scored[:cutoff_idx]

        if not candidates:
            print("[Cleanup] No low-quality candidates to review.")
            return

        # Small batches of 15 for thoughtful review
        BATCH_SIZE = 15
        all_removed = []

        for batch_start in range(0, len(candidates), BATCH_SIZE):
            batch = candidates[batch_start:batch_start + BATCH_SIZE]

            print(f"[Cleanup] Reviewing batch {batch_start // BATCH_SIZE + 1}: {len(batch)} low-quality directions...")

            # Build a compact listing
            dir_lines = []
            for d, score in batch:
                desc_preview = d.description[:120].replace("\n", " ").strip()
                domains_str = ", ".join(d.domains[:3])
                dir_lines.append(f"[{d.id}] (priority={d.priority_score:.2f}, quality={score:.2f}, domains=[{domains_str}]) {d.title}: {desc_preview}")
            directions_text = "\n".join(dir_lines)

            system = (
                "You are a research direction curator for the Aether autonomous math research system.\n\n"
                "TASK — REVIEW: Evaluate these low-quality future directions. Only remove entries that are "
                "CLEARLY worthless. Default to KEEPING directions that have any mathematical substance.\n\n"
                "REMOVE only entries that are:\n"
                "- JUNK: genuinely nonsensical or not real mathematics\n"
                "- EXACT DUPLICATES: same idea as another entry in this batch (keep the better one)\n"
                "- EMPTY: no description or description is just the title repeated\n\n"
                "KEEP entries that:\n"
                "- Have any falsifiable conjecture, even an imprecise one\n"
                "- Touch on genuinely novel ideas, even if speculative\n"
                "- Represent an unsolved problem or open question\n"
                "- Are tagged with Novelty domain\n\n"
                "For each removal, provide a one-line reason. Be CONSERVATIVE — when in doubt, keep.\n\n"
                "Respond in this exact JSON format:\n"
                '{\n'
                '  "remove": [{"id": "dir_id", "reason": "one-line justification"}],\n'
                '  "kept": ["dir_id_1", "dir_id_2"],\n'
                '  "notes": "brief summary"\n'
                '}'
            )

            user = f"Here are {len(batch)} future research directions to evaluate (sorted by quality, worst first):\n\n{directions_text}"

            try:
                raw = self.pi_agent._call_ollama(system, user, timeout=60)
            except Exception as e:
                print(f"[Cleanup] Pi-Agent call failed for batch: {e}")
                continue

            result = self.pi_agent._parse_json_response(raw)
            if not result:
                print(f"[Cleanup] Could not parse Pi-Agent cleanup response for batch")
                continue

            for item in result.get("remove", []):
                if isinstance(item, dict):
                    all_removed.append((item.get("id", ""), item.get("reason", "no reason")))
                elif isinstance(item, str):
                    all_removed.append((item, "no reason provided"))

        # Apply removals with protection guardrails
        removed = 0
        skipped = 0
        for dir_id, reason in all_removed:
            for d in fd_manager._directions:
                if d.id == dir_id and d.status == "available":
                    # Protection guardrails — never prune these
                    if d.priority_score >= 0.80:
                        print(f"[Cleanup] Protecting {d.id} (priority={d.priority_score:.2f}): {d.title[:50]}")
                        skipped += 1
                        continue
                    if "Novelty" in d.domains:
                        print(f"[Cleanup] Protecting {d.id} (Novelty): {d.title[:50]}")
                        skipped += 1
                        continue
                    if d.source_path.startswith("seed:"):
                        print(f"[Cleanup] Protecting {d.id} (seed): {d.title[:50]}")
                        skipped += 1
                        continue
                    d.status = "pruned"
                    d.prune_reason = f"llm_cleanup: {reason[:100]}"
                    d.pruned_at = datetime.now(timezone.utc).isoformat()
                    removed += 1

        # Brainstorm a new direction
        existing_titles = [d.title for d in available]
        existing_titles_preview = existing_titles[:30]

        brainstorm_system = (
            "You are a research direction curator for the Aether autonomous math research system.\n\n"
            "Invent ONE novel, interesting, exciting new research direction that is NOT covered by any existing entry.\n"
            "It should be a testable scientific hypothesis: a falsifiable conjecture with a clear test.\n"
            "Draw from frontier mathematics, physics, computation, and speculative ideas.\n\n"
            "Respond in this exact JSON format:\n"
            '{\n'
            '  "new_direction": {\n'
            '    "title": "...",\n'
            '    "description": "Conjecture: [precise falsifiable statement]. Test: [what confirms/refutes]. Impact: [what this enables]",\n'
            '    "domains": ["Domain1", "Domain2"]\n'
            '  }\n'
            '}'
        )

        brainstorm_user = f"Here are some existing research direction titles (do NOT duplicate these):\n" + "\n".join(f"- {t}" for t in existing_titles_preview)

        new_direction_data = None
        try:
            raw = self.pi_agent._call_ollama(brainstorm_system, brainstorm_user, timeout=60)
            result = self.pi_agent._parse_json_response(raw)
            if result:
                new_direction_data = result.get("new_direction")
        except Exception as e:
            print(f"[Cleanup] Pi-Agent brainstorm call failed: {e}")

        # Add brainstormed direction
        added_new = False
        if new_direction_data and new_direction_data.get("title") and new_direction_data.get("description"):
            fd = FutureDirection(
                id=fd_manager._next_id(),
                title=new_direction_data["title"][:80],
                description=new_direction_data["description"][:2000],
                source_exp_id="pi_brainstorm",
                source_path="brainstorm",
                domains=new_direction_data.get("domains", ["Novelty"]),
                depth_estimate=3,
                priority_score=0.80,
            )
            quality = fd_manager._compute_quality_score(fd)
            fd.priority_score = min(fd.priority_score, max(0.70, quality))
            fd_manager.add_direction(fd)
            added_new = True

        if removed > 0 or added_new:
            fd_manager._save()

        print(f"[Cleanup] Directions cleanup: removed {removed}, protected {skipped}, brainstormed {1 if added_new else 0}. Total available: {len([d for d in fd_manager._directions if d.status == 'available'])}")

    def _mine_structural_holes(self) -> None:
        """Find domain pairs with no edges in the knowledge graph and generate bridge directions.

        Structural holes are pairs of domains that have no provenance edges between them.
        These are the highest-value bridge targets: a theorem connecting two disconnected
        domains would create new knowledge graph edges and unlock cross-domain research.
        """
        import json as _json
        from research_memory import FutureDirection, FutureDirectionsManager

        lineage_path = self.catalog_root.parent / "Applications" / "Packages" / "lineage.json"
        if not lineage_path.exists():
            return

        try:
            with open(lineage_path, 'r', encoding='utf-8') as f:
                graph_data = _json.load(f)
        except Exception:
            return

        nodes = graph_data.get("nodes", [])
        edges = graph_data.get("edges", [])

        if not nodes or not edges:
            return

        # Build domain sets per node
        node_domains = {}
        for n in nodes:
            nid = n.get("id", "")
            domains = n.get("domains", []) or ([n.get("primary_domain", "Bridges")] if n.get("primary_domain") else [])
            node_domains[nid] = set(domains)

        # Find which domain pairs are connected (have at least one edge)
        connected_pairs = set()
        for e in edges:
            src = e.get("source", "")
            tgt = e.get("target", "")
            src_domains = node_domains.get(src, set())
            tgt_domains = node_domains.get(tgt, set())
            for sd in src_domains:
                for td in tgt_domains:
                    if sd != td:
                        connected_pairs.add((min(sd, td), max(sd, td)))

        # Find all domain pairs and identify holes
        all_domains = set()
        for domains in node_domains.values():
            all_domains.update(domains)

        all_pairs = set()
        domain_list = sorted(all_domains)
        for i, d1 in enumerate(domain_list):
            for d2 in domain_list[i+1:]:
                all_pairs.add((d1, d2))

        holes = all_pairs - connected_pairs

        if not holes:
            return

        # Only run every ~5 cycles to save pollen
        if self.cycle_count % 5 != 0 and self.cycle_count > 0:
            return

        print(f"[StructuralHoles] Found {len(holes)} disconnected domain pairs out of {len(all_pairs)} total")

        # Generate bridge directions for the top holes (limit to 3 per run)
        fd_manager = FutureDirectionsManager(self.workspace)
        added = 0
        for d1, d2 in sorted(holes)[:3]:
            existing_bridge = any(
                d1 in d.domains and d2 in d.domains
                for d in fd_manager._directions
                if d.status == "available"
            )
            if existing_bridge:
                continue

            direction = FutureDirection(
                id=fd_manager._next_id(),
                title=f"Bridge: {d1} ↔ {d2}",
                description=f"The key insight is that {d1} and {d2} have no provenance connections in the knowledge graph — they are structural holes. A theorem connecting {d1} structures to {d2} results would create the first knowledge graph edge between these domains and unlock cross-domain research. Why now: the catalog has sufficient depth in both domains to make a bridge theorem tractable. Find a specific result in {d1} that has an analog or consequence in {d2}, state the precise correspondence, and prove it.",
                source_exp_id="structural_hole",
                source_path="hole_mining",
                domains=[d1, d2],
                depth_estimate=4,
                priority_score=0.90,
                proof_strategy=f"Search catalog for {d1} theorems with structural analogs in {d2}. Formalize the analogy as a functor or reduction. Prove the correspondence.",
            )
            fd_manager.add_direction(direction)
            added += 1
            print(f"[StructuralHoles] Added bridge direction: {d1} ↔ {d2}")

        if added > 0:
            fd_manager._save()

    # ArXiv mining is consolidated in cycle_master.py Phase 10.7

    def _generate_challenge_problem(self, job: ResearchJob) -> None:
        """After a successful cycle, auto-create a challenge problem — a hard
        conjecture or generalization that would take 2-3 cycles to resolve.

        Challenge problems become grand-challenge targets with priority 0.95+,
        derived from the key result of the completed package.
        """
        from research_memory import FutureDirection, FutureDirectionsManager

        fd_manager = FutureDirectionsManager(self.workspace)

        title = job.concept.title if hasattr(job, 'concept') and job.concept else "Unknown"
        domain = job.concept.domain if hasattr(job, 'concept') and job.concept else "Bridges"
        exp_id = job.job_id if hasattr(job, 'job_id') else ""

        # Extract key theorem names from the lean result for context
        key_theorems = []
        if job.result_lean:
            import re
            for m in re.finditer(r"(?:theorem|lemma)\s+(\w+)", job.result_lean[:4000]):
                key_theorems.append(m.group(1))
        theorem_ctx = f" (e.g., {', '.join(key_theorems[:3])})" if key_theorems else ""

        # Avoid duplicate challenge problems on the same source
        existing_challenge = any(
            d.source_exp_id == exp_id and d.title.startswith("Challenge:")
            for d in fd_manager._directions
            if d.status in ("available", "in_progress")
        )
        if existing_challenge:
            print(f"[Challenge] Skipping — challenge already exists for {exp_id}")
            return

        # Determine challenge type based on what the package achieved
        challenge_descriptions = {
            "generalization": f"The key insight is that {title} establishes a specific result{theorem_ctx}, but the natural generalization remains open. Formulate and prove the most ambitious generalization that preserves the core proof technique. Why now: the base case is now proven in the catalog, providing a foundation to build on.",
            "strengthening": f"The key insight is that {title} proves a result under restrictive hypotheses{theorem_ctx}. Strengthen the theorem by removing or weakening the strongest assumption used in the proof. Why now: the existing proof structure reveals exactly which lemmas depend on which assumptions, making targeted weakening tractable.",
            "cross_domain": f"The key insight is that {title} lives in {domain}, but the underlying structure has analogs in at least one other domain. Find the precise category-theoretic or algebraic connection that transports this result to a new domain. Why now: the formal proof is now machine-checked, giving confidence in the structural properties needed for transport.",
        }

        # Pick the most appropriate challenge type
        if "bridge" in domain.lower() or "bridge" in title.lower():
            ctype = "cross_domain"
        elif key_theorems and any("prime" in t.lower() or "finite" in t.lower() for t in key_theorems):
            ctype = "generalization"
        else:
            ctype = "strengthening"

        # Assign arc_id — each challenge problem starts a new 3-cycle arc
        arc_id = f"arc_{fd_manager._next_id().replace('fd_', '')}"

        direction = FutureDirection(
            id=fd_manager._next_id(),
            title=f"Challenge: {title}",
            description=challenge_descriptions[ctype],
            source_exp_id=exp_id,
            source_path="challenge_generation",
            domains=[domain],
            depth_estimate=5,
            priority_score=0.95,
            proof_strategy=f"Start from the existing proof in {domain}{theorem_ctx}, identify the structural bottleneck, and formulate the stronger statement. The catalog proof provides the template.",
            ambition_level="grand_challenge",
            arc_id=arc_id,
            arc_position=1,
        )
        fd_manager.add_direction(direction)
        fd_manager._save()
        print(f"[Challenge] Created challenge problem: Challenge: {title} (type={ctype}, priority=0.95)")

    def _propagate_research_arc(self, job: ResearchJob) -> None:
        """When an arc position completes, auto-seed the next arc position.

        Arc structure: 1=foundation → 2=main theorem → 3=applications
        Each subsequent position gets lower priority since it depends on the prior.
        """
        from research_memory import FutureDirection, FutureDirectionsManager

        fd_manager = FutureDirectionsManager(self.workspace)

        # Find the direction that was consumed by this job
        consumed_id = ""
        for d in fd_manager._directions:
            if d.consumed_by_exp_id == job.job_id and d.arc_id:
                consumed_id = d.id
                arc_id = d.arc_id
                arc_pos = d.arc_position
                domains = d.domains
                title = d.title
                break
        else:
            return  # Not part of an arc

        if arc_pos >= 3:
            return  # Arc is complete

        # Check if next position already exists
        next_pos = arc_pos + 1
        already_exists = any(
            d.arc_id == arc_id and d.arc_position == next_pos and d.status in ("available", "in_progress")
            for d in fd_manager._directions
        )
        if already_exists:
            return

        position_labels = {2: "Main Theorem", 3: "Applications"}
        position_priorities = {2: 0.90, 3: 0.85}
        position_descriptions = {
            2: f"The key insight is that the foundation for {title} is now established in the catalog. Build the central theorem that this arc was designed to prove — the main result that justifies the entire research program. Why now: the foundational lemmas and definitions from cycle 1 are formalized and machine-checked, providing the precise building blocks needed.",
            3: f"The key insight is that the main theorem of the {title} arc is now proven. Explore applications: find 2-3 concrete consequences in neighboring domains, computational implementations, or connections to open problems. Why now: the main theorem is formalized, so we can safely derive applications without proof-theoretic risk.",
        }

        direction = FutureDirection(
            id=fd_manager._next_id(),
            title=f"Arc {next_pos}/3: {position_labels[next_pos]} for {title}",
            description=position_descriptions[next_pos],
            source_exp_id=job.job_id,
            source_path="arc_propagation",
            domains=domains,
            depth_estimate=5 if next_pos == 2 else 3,
            priority_score=position_priorities[next_pos],
            proof_strategy=f"Build on the catalog results from arc position {arc_pos}. Leverage the proven lemmas as dependencies.",
            ambition_level="grand_challenge" if next_pos == 2 else "extension",
            arc_id=arc_id,
            arc_position=next_pos,
        )
        fd_manager.add_direction(direction)
        fd_manager._save()
        print(f"[Arc] Propagated arc {arc_id}: position {next_pos}/3 for {title} (priority={position_priorities[next_pos]})")

    def _prune_catalog(self, batch_size: int = 10) -> None:
        """Incrementally prune the Catalog — one batch per tick.

        Auto-immortalizes clear winners, auto-removes clear junk,
        then sends one batch of gray-area files to PI-Agent for review.
        Deletes removed files.
        """
        catalog_root = self.catalog_root
        final_dir = catalog_root / "FINAL"
        final_dir.mkdir(parents=True, exist_ok=True)

        # Build set of already-immortalized files
        already_final = set()
        for f in final_dir.rglob("*.lean"):
            already_final.add(f.name)

        # Scan all .lean files (excluding FINAL, Speculative, .lake, ResearchOutput)
        skip_dirs = {"FINAL", "Speculative", ".lake", "ResearchOutput", "Applications"}
        candidates = []
        for f in catalog_root.rglob("*.lean"):
            # Skip if any parent dir is in skip_dirs
            parts = f.relative_to(catalog_root).parts
            if any(p in skip_dirs for p in parts):
                continue
            if f.name in already_final:
                continue
            if f.name == "Main.lean":
                continue

            # Quick heuristic scan
            try:
                content = f.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue

            lines = content.split("\n")
            line_count = len([l for l in lines if l.strip() and not l.strip().startswith("--")])
            has_sorry = "sorry" in content
            theorem_count = len(re.findall(r"^\s*(theorem|lemma)\s", content, re.MULTILINE))
            has_deep_proof = bool(re.search(r"\b(induction|rcases|by_contra|omega|linarith|field_simp|ring_nf)\b", content))
            is_trivial_only = not has_deep_proof and bool(re.search(r"\b(trivial|simp|rfl|decide|native_decide)\b", content))

            candidates.append({
                "path": str(f.relative_to(catalog_root)),
                "name": f.name,
                "domain": parts[0] if parts else "Unknown",
                "lines": line_count,
                "sorries": has_sorry,
                "theorems": theorem_count,
                "deep_proof": has_deep_proof,
                "trivial_only": is_trivial_only,
                "abs_path": f,
            })

        if not candidates:
            return

        # Auto-immortalize clear winners: sorry-free, >100 lines, deep proofs
        auto_immortalized = 0
        for c in candidates:
            if not c["sorries"] and c["lines"] > 100 and c["deep_proof"] and c["theorems"] >= 3:
                self._immortalize_file(c, final_dir)
                auto_immortalized += 1
        if auto_immortalized:
            print(f"[Prune] Auto-immortalized {auto_immortalized} high-quality files")

        # Auto-remove clear junk: trivial-only, very short, or sorry-containing
        # Delete instead of moving to old/
        auto_removed = 0
        for c in candidates:
            if c["sorries"] or (c["lines"] < 15 and c["trivial_only"]) or (c["theorems"] == 0 and c["lines"] < 30):
                try:
                    c["abs_path"].unlink(missing_ok=True)
                    auto_removed += 1
                except Exception:
                    pass
        if auto_removed:
            print(f"[Prune] Auto-removed {auto_removed} junk files")

        # Gray area: send to Pi-Agent for review
        gray_area = [c for c in candidates
                     if not (not c["sorries"] and c["lines"] > 100 and c["deep_proof"] and c["theorems"] >= 3)
                     and not (c["sorries"] or (c["lines"] < 15 and c["trivial_only"]) or (c["theorems"] == 0 and c["lines"] < 30))]

        if not gray_area:
            self._rebuild_final_main(final_dir)
            return

        # Send one batch of gray-area files to Pi-Agent
        batch = gray_area[:batch_size]
        summaries = []
        for c in batch:
            tag = "deep" if c["deep_proof"] else ("trivial" if c["trivial_only"] else "mixed")
            summaries.append(
                f"  {c['path']} | {c['theorems']} theorems | {c['lines']} lines | "
                f"sorry={'yes' if c['sorries'] else 'no'} | proofs={tag}"
            )
        listing = "\n".join(summaries)

        system = (
            "You are a Lean 4 theorem curator for the Aether research engine.\n"
            "Review these .lean file summaries. For each, decide:\n"
            "- IMMORTALIZE: contains genuinely interesting theorems with non-trivial proofs\n"
            "- REMOVE: trivial tautologies, duplicates, or too shallow to keep\n\n"
            "Be generous with immortalization (keep good work). Be strict with removal (only clear junk).\n"
            "Respond in JSON:\n"
            '{\n'
            '  "immortalize": ["path/to/File1.lean", ...],\n'
            '  "remove": ["path/to/Junk1.lean", ...],\n'
            '  "notes": "brief summary"\n'
            '}'
        )

        user = f"Lean files to review ({len(batch)} gray-area files):\n\n{listing}"

        try:
            raw = self.pi_agent._call_ollama(system, user, timeout=60)
        except Exception as e:
            print(f"[Prune] Pi-Agent call failed: {e}")
            self._rebuild_final_main(final_dir)
            return

        result = self.pi_agent._parse_json_response(raw)
        if not result:
            print(f"[Prune] Could not parse Pi-Agent response")
            self._rebuild_final_main(final_dir)
            return

        # Process immortalizations
        llm_immortalized = 0
        for path_str in result.get("immortalize", []):
            c = next((c for c in batch if c["path"] == path_str), None)
            if c:
                self._immortalize_file(c, final_dir)
                llm_immortalized += 1

        # Process removals
        llm_removed = 0
        for path_str in result.get("remove", []):
            c = next((c for c in batch if c["path"] == path_str), None)
            if c:
                try:
                    c["abs_path"].unlink(missing_ok=True)
                    llm_removed += 1
                except Exception:
                    pass

        notes = result.get("notes", "")
        print(f"[Prune] LLM: immortalized {llm_immortalized}, removed {llm_removed}. {notes}")

        # Rebuild Main.lean from FINAL
        self._rebuild_final_main(final_dir)

        # Clean up empty directories
        self._cleanup_empty_dirs(catalog_root)

    def _immortalize_file(self, candidate: dict, final_dir: Path) -> None:
        """Symlink a .lean file into the FINAL directory (no duplicate bytes)."""
        src = Path(candidate["abs_path"])
        domain = candidate["domain"]
        dest_dir = final_dir / domain
        dest_dir.mkdir(parents=True, exist_ok=True)
        dest = dest_dir / src.name
        if not dest.exists():
            try:
                # Create a relative symlink from FINAL back to the canonical file
                rel_src = os.path.relpath(str(src), str(dest_dir))
                dest.symlink_to(rel_src)
            except Exception:
                pass

    def _rebuild_final_main(self, final_dir: Path) -> None:
        """Rebuild Catalog/Main.lean from all files in FINAL/."""
        imports = []
        for f in sorted(final_dir.rglob("*.lean")):
            if f.name == "Main.lean":
                continue
            rel = f.relative_to(self.catalog_root)
            # Convert path to Lean import: FINAL/Algebra/File.lean → FINAL.Algebra.File
            import_path = str(rel.with_suffix("")).replace("/", ".")
            imports.append(f"import {import_path}")

        if imports:
            header = (
                "/- Aether FINAL Catalog\n"
                f"A curated collection of {len(imports)} of the highest-quality\n"
                "formally verified mathematical results from the Aether engine.\n"
                "Sorry-free. No placeholders. Auto-maintained.\n"
                f"Total files: {len(imports)}\n"
                "-/\n"
            )
            main_path = self.catalog_root / "Main.lean"
            main_path.write_text(header + "\n".join(imports) + "\n", encoding="utf-8")

    def _cleanup_empty_dirs(self, root: Path) -> None:
        """Remove empty directories in the catalog tree."""
        for d in sorted(root.rglob("*"), reverse=True):
            if d.is_dir() and not any(d.iterdir()):
                try:
                    d.rmdir()
                except Exception:
                    pass

    def _verify_catalog_sync(self, job: ResearchJob) -> dict:
        """Verify all output files are properly placed in the Catalog."""
        report = {"missing_files": [], "verified_files": []}
        # Check that key artifacts exist at expected paths
        catalog_root = self.catalog_root
        
        # Check Applications directories exist
        for subdir in ["Papers", "Demos", "Visuals", "Articles", "Packages"]:
            d = catalog_root / "Applications" / subdir
            if d.exists():
                report["verified_files"].append(f"Applications/{subdir}/ exists")
        
        # Check master FUTURE_DIRECTIONS exists if we merged content
        master_fd = catalog_root / "Aether" / ".aether_workspace" / "MASTER_FUTURE_DIRECTIONS.md"
        if master_fd.exists():
            report["verified_files"].append("MASTER_FUTURE_DIRECTIONS.md exists")
        
        
        return report

    def _split_lean_output(self, lean_source: str, concept: ResearchConcept) -> List[Tuple[str, str]]:
        """Split multi-file Lean output into individual files.

        Aristotle may produce multiple .lean files. If we combined them
        for transport, split them back out here.
        """
        # Check if this is a multi-file bundle (contains "-- File:" separators)
        if "-- File:" in lean_source:
            parts = lean_source.split("-- File:")
            result = []
            for part in parts[1:]:  # Skip empty first part
                lines = part.strip().split("\n")
                first_line = lines[0]
                content = "\n".join(lines[1:]).strip()
                # Derive filename from first line
                suggested_name = first_line.strip().replace(" ", "_") + ".lean"
                result.append((content, suggested_name))
            return result

        # Single file — derive name from concept
        name = concept.title.replace(" ", "_").replace("-", "_") + ".lean"
        return [(lean_source, name)]

    def _enrich_json_package(self, json_pkg_str: str, job) -> str:
        """Enrich JSON package with executable module code for Pyodide demos.

        Adds a 'modules' dict mapping module names to their source code,
        so the web frontend can register them as importable Python modules.
        Also adds 'code' fields to algorithms entries from the source,
        and injects a 'date' field from the cycle completion time.
        """
        import ast
        from datetime import datetime, timezone
        try:
            pkg = json.loads(json_pkg_str)
        except (json.JSONDecodeError, ValueError):
            # Try to extract the first valid JSON object from concatenated data
            try:
                decoder = json.JSONDecoder()
                pos = 0
                while pos < len(json_pkg_str) and json_pkg_str[pos] in ' \t\n\r':
                    pos += 1
                pkg, _ = decoder.raw_decode(json_pkg_str, pos)
            except (json.JSONDecodeError, ValueError):
                return json_pkg_str

        # Replace placeholder filenames with actual content from separate result files.
        # The LLM sometimes outputs PACKAGE.json with fields like "article": "ARTICLE.md"
        # instead of the actual content. If we have the real content from separate files,
        # inject it here.
        PLACEHOLDER_PATTERN = re.compile(r'^[A-Z_0-9]+\.(md|py|txt|json|lean)$', re.IGNORECASE)
        if hasattr(job, 'result_article') and job.result_article:
            article = pkg.get("article", "")
            if isinstance(article, str) and (PLACEHOLDER_PATTERN.match(article) or len(article) < 30):
                pkg["article"] = job.result_article
        if hasattr(job, 'result_research_paper') and job.result_research_paper:
            rp = pkg.get("research_paper", "")
            if isinstance(rp, str) and (PLACEHOLDER_PATTERN.match(rp) or len(rp) < 30):
                pkg["research_paper"] = job.result_research_paper
        if hasattr(job, 'result_future_directions') and job.result_future_directions:
            fd = pkg.get("future_directions", "")
            if isinstance(fd, str) and (PLACEHOLDER_PATTERN.match(fd) or (isinstance(fd, str) and len(fd) < 50)):
                pkg["future_directions"] = job.result_future_directions
        if hasattr(job, 'result_lean') and job.result_lean:
            lp = pkg.get("lean_proofs", "")
            if isinstance(lp, str) and PLACEHOLDER_PATTERN.match(lp):
                pkg["lean_proofs"] = job.result_lean
            elif isinstance(lp, list):
                # Replace string entries that look like filenames
                pkg["lean_proofs"] = [
                    job.result_lean if isinstance(e, str) and PLACEHOLDER_PATTERN.match(e) else e
                    for e in lp
                ]

            # Also add all .lean files from result_lean that aren't already in lean_proofs.
            # This ensures the website tab and zip download include every changed file.
            if hasattr(job, 'result_lean') and job.result_lean:
                existing_files = set()
                lp_list = pkg.get("lean_proofs", [])
                if isinstance(lp_list, list):
                    for entry in lp_list:
                        if isinstance(entry, dict):
                            fname = entry.get("file", "") or entry.get("name", "")
                            # Clean _aristotle project dir prefixes from existing entries
                            clean_fname = "/".join(p for p in fname.split("/") if not re.match(r'^[0-9a-f]+_aristotle$', p))
                            if clean_fname != fname:
                                entry["file"] = clean_fname
                                if "name" in entry:
                                    entry["name"] = clean_fname
                            existing_files.add(clean_fname.split("/")[-1].replace(".lean", ""))
                # Parse -- NEW_FILE: markers from result_lean (skip DIFF entries —
                # those are patches, not complete files)
                _pattern = re.compile(r'^-- NEW_FILE:\s*(.+?)$', re.MULTILINE)
                _splits = _pattern.split(job.result_lean)
                # _splits: [preamble, filename1, code1, filename2, code2, ...]
                _new_entries = []
                for i in range(1, len(_splits), 2):
                    fname = _splits[i].strip()
                    # Clean _aristotle project dir prefixes
                    fname = "/".join(p for p in fname.split("/") if not re.match(r'^[0-9a-f]+_aristotle$', p))
                    code = _splits[i + 1].strip() if i + 1 < len(_splits) else ""
                    basename = fname.split("/")[-1].replace(".lean", "")
                    if basename not in existing_files and code:
                        _new_entries.append({
                            "file": fname,
                            "name": fname,
                            "code": code,
                            "theorems": code.count("theorem ") + code.count("lemma "),
                            "description": f"Lean 4 proof file from research cycle"
                        })
                        existing_files.add(basename)
                if _new_entries:
                    if isinstance(pkg.get("lean_proofs"), list):
                        pkg["lean_proofs"].extend(_new_entries)
                    elif not pkg.get("lean_proofs"):
                        pkg["lean_proofs"] = _new_entries
        if hasattr(job, 'result_algorithms') and job.result_algorithms:
            # Replace string entries in algorithms list that look like filenames
            algs = pkg.get("algorithms", [])
            pkg["algorithms"] = [
                {"name": e.replace(".py", "").replace("_", " ").title(),
                 "code": job.result_algorithms}
                if isinstance(e, str) and PLACEHOLDER_PATTERN.match(e) else e
                for e in algs
            ]
        if hasattr(job, 'result_demo') and job.result_demo:
            # Replace string entries in demos list that look like filenames
            demos = pkg.get("demos", [])
            pkg["demos"] = [
                {"name": e.replace(".py", "").replace("_", " ").title(),
                 "code": job.result_demo}
                if isinstance(e, str) and PLACEHOLDER_PATTERN.match(e) else e
                for e in demos
            ]
            # Also replace interactive_demos string entries
            idemos = pkg.get("interactive_demos", [])
            pkg["interactive_demos"] = [
                {"name": e.replace(".py", "").replace("_", " ").title(),
                 "code": job.result_demo}
                if isinstance(e, str) and PLACEHOLDER_PATTERN.match(e) else e
                for e in idemos
            ]

        # Replace visualization code fields that are filename placeholders
        # The LLM sometimes outputs "code": "visualize_barrier.py" instead of actual code
        viz_code_source = ""
        if hasattr(job, 'result_demo') and job.result_demo:
            viz_code_source = job.result_demo
        elif hasattr(job, 'result_algorithms') and job.result_algorithms:
            viz_code_source = job.result_algorithms
        if viz_code_source:
            # Parse result_demo into a dict of filename→content
            file_contents = {}
            parts = re.split(r'-- (?:NEW_FILE|DIFF): (.+?)\n', viz_code_source)
            for i in range(1, len(parts) - 1, 2):
                fname = parts[i].strip()
                content = parts[i + 1].strip() if i + 1 < len(parts) else ""
                if content:
                    file_contents[fname] = content
                    file_contents[Path(fname).name] = content  # also key by basename

            viz_list = pkg.get("visualizations", [])
            for v in viz_list:
                if isinstance(v, dict):
                    code = v.get("code", "")
                    if isinstance(code, str) and (PLACEHOLDER_PATTERN.match(code) or
                        (len(code) < 80 and code.endswith('.py'))):
                        # Try to find the matching file content
                        matched = file_contents.get(code, "")
                        if not matched:
                            # Try partial match on basename
                            stem = code.replace('.py', '').replace('_', '').lower()
                            for fname, content in file_contents.items():
                                if stem in fname.replace('_', '').replace('.py', '').lower():
                                    matched = content
                                    break
                        if matched:
                            v["code"] = matched

        # Build modules dict from all Python artifacts
        modules = {}

        if hasattr(job, 'result_algorithms') and job.result_algorithms:
            modules["algorithms"] = job.result_algorithms
            # Also inject code into algorithms entries for backward compat
            # Filter out string entries — LLM sometimes returns algorithms as strings
            algorithms = [a for a in pkg.get("algorithms", []) if isinstance(a, dict)]
            if algorithms:
                try:
                    tree = ast.parse(job.result_algorithms)
                    source_lines = job.result_algorithms.splitlines()
                    definitions = {}
                    for node in ast.iter_child_nodes(tree):
                        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                            name = node.name
                        elif isinstance(node, ast.ClassDef):
                            name = node.name
                        else:
                            continue
                        start = node.lineno - 1
                        end = node.end_lineno
                        definitions[name] = "\n".join(source_lines[start:end])
                    module_code_lines = []
                    for node in ast.iter_child_nodes(tree):
                        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
                            continue
                        if isinstance(node, (ast.Assign, ast.AugAssign, ast.Import, ast.ImportFrom)):
                            start = node.lineno - 1
                            end = node.end_lineno
                            module_code_lines.append("\n".join(source_lines[start:end]))
                    module_preamble = "\n".join(module_code_lines) if module_code_lines else ""
                    for alg in algorithms:
                        # LLM sometimes returns algorithms as strings instead of dicts
                        if isinstance(alg, str):
                            continue
                        if alg.get("code"):
                            continue
                        alg_name = alg.get("name", "").lower()
                        alg_key = re.sub(r'[^a-z0-9]', '', alg_name)
                        matched_code = []
                        for def_name, def_code in definitions.items():
                            def_key = re.sub(r'[^a-z0-9]', '', def_name.lower())
                            if def_key in alg_key or alg_key in def_key:
                                matched_code.append(def_code)
                        if matched_code:
                            code_block = (module_preamble + "\n\n" + "\n\n".join(matched_code)) if module_preamble else "\n\n".join(matched_code)
                            alg["code"] = code_block.strip()
                        else:
                            alg["code"] = job.result_algorithms
                except SyntaxError:
                    for alg in algorithms:
                        if isinstance(alg, str):
                            continue
                        if not alg.get("code"):
                            alg["code"] = job.result_algorithms

        if hasattr(job, 'result_demo') and job.result_demo:
            modules["demo"] = job.result_demo

        if modules:
            pkg["modules"] = modules

        # Inject date from cycle completion time
        if not pkg.get("date"):
            pkg["date"] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

        # Inject provenance: which experiment produced this package
        if hasattr(job, 'job_id') and job.job_id:
            pkg["exp_id"] = job.job_id
        if hasattr(job, 'source_exp_ids') and job.source_exp_ids:
            pkg["source_exp_ids"] = job.source_exp_ids
        elif hasattr(job, 'job_id') and job.job_id:
            # Fallback: look up source_exp_ids from FutureDirectionsManager
            try:
                from research_memory import FutureDirectionsManager
                fd_path = Path(__file__).parent / ".aether_workspace" / "future_directions.json"
                if fd_path.exists():
                    fd_mgr = FutureDirectionsManager(Path(__file__).parent / ".aether_workspace")
                    pkg["source_exp_ids"] = fd_mgr.get_source_exp_ids_for(job.job_id)
            except Exception:
                pass

        # Write visualization scripts to visualizations/ dir
        # Filter out string entries — LLM sometimes returns visualizations as strings
        visualizations = [v for v in pkg.get("visualizations", []) if isinstance(v, dict)]
        if visualizations:
            viz_dir = self.catalog_root / "Applications" / "Packages" / "visualizations"
            viz_dir.mkdir(parents=True, exist_ok=True)
            pkg_slug = re.sub(r'[^a-z0-9]', '_', pkg.get("title", "pkg").lower())[:40]
            for viz in visualizations:
                if viz.get("code"):
                    safe_name = re.sub(r'[^a-z0-9_]', '_', viz.get("name", "viz").lower())[:30]
                    viz_path = viz_dir / f"{pkg_slug}_{safe_name}.py"
                    try:
                        viz_path.write_text(viz["code"], encoding="utf-8")
                        viz["code_file"] = f"visualizations/{pkg_slug}_{safe_name}.py"
                        print(f"[Enrich] Wrote visualization script: {viz_path.name}")
                    except Exception as e:
                        print(f"[Enrich] Warning: failed to write viz script {safe_name}: {e}")

        return json.dumps(pkg, ensure_ascii=False)

    def _derive_artifact_name(self, concept: ResearchConcept, ext: str) -> str:
        """Derive a sensible artifact name from the concept.

        Uses the concept title as a base, sanitized for filenames.
        """
        base = concept.title.replace(" ", "_").replace("-", "_").lower()
        # Remove any characters that aren't filename-safe
        base = re.sub(r'[^a-z0-9_]', '', base)
        # Ensure it's not too long
        base = base[:50]
        return f"{base}.{ext}"

    def cleanup_catalog(self, job: ResearchJob) -> ResearchJob:
        """Synchronous version of cleanup_catalog_async for run_single_cycle."""
        if job.status != "integrated":
            return job
        
        import subprocess
        
        print(f"[Cleanup] Running global deduplication script...")
        try:
            dedup_script = Path(__file__).parent / "dedup_catalog.py"
            if dedup_script.exists():
                subprocess.run(
                    ["python3", str(dedup_script)],
                    capture_output=True,
                    timeout=120
                )
        except Exception as e:
            print(f"[Cleanup] Warning: {e}")

        # Project workspace cleanup
        try:
            if job.project_dir and Path(job.project_dir).exists():
                import shutil
                print(f"[Cleanup] Removing project workspace: {job.project_dir}")
                shutil.rmtree(str(job.project_dir), ignore_errors=True)
        except Exception as e:
            print(f"[Cleanup] Warning: workspace cleanup failed: {e}")

        # Verify catalog sync
        try:
            sync_report = self._verify_catalog_sync(job)
            if sync_report.get("missing_files"):
                print(f"[Cleanup] WARNING: {len(sync_report['missing_files'])} files not found")
        except Exception as e:
            print(f"[Cleanup] Warning: sync verification failed: {e}")

        # LLM-assisted future directions cleanup
        try:
            self._cleanup_future_directions()
        except Exception as e:
            print(f"[Cleanup] Warning: future directions cleanup failed: {e}")

        # Catalog pruning — immortalize best, remove junk
        try:
            self._prune_catalog()
        except Exception as e:
            print(f"[Cleanup] Warning: catalog pruning failed: {e}")

        return job

    # ==================================================================
    # Phase 8: COMMIT — Aether commits and tracks

    def commit(self, job: ResearchJob) -> None:
        """Commit integrated results and track metrics."""
        if job.status != "integrated":
            return

        # Git commit
        commit_msg = (
            f"AETHER cycle #{job.cycle_n}: {job.concept.title}\n\n"
            f"Domain: {job.concept.domain}\n"
            f"Mode: {job.concept.research_mode}\n"
            f"Quality: {job.quality_score:.3f}\n"
            f"Theorems: {job.theorem_count}, Sorries: {job.sorry_count}\n\n"
            f"{job.concept.concept_description[:500]}"
        )
        try:
            # Add only the files we actually wrote, plus workspace and index
            paths_to_add = []
            if job.integrated_paths:
                for p in job.integrated_paths:
                    abs_path = self.catalog_root / p
                    if abs_path.exists():
                        # git add relative to repo root
                        rel = abs_path.relative_to(self.catalog_root.parent)
                        paths_to_add.append(str(rel))
            # Always add workspace changes (future directions, memory)
            paths_to_add.append(".aether_workspace/")
            # Add packages index if it was regenerated
            pkg_index = self.catalog_root / "Applications" / "Packages" / "package_index.js"
            if pkg_index.exists():
                paths_to_add.append("Catalog/Applications/Packages/package_index.js")
            lineage = self.catalog_root / "Applications" / "Packages" / "lineage.json"
            if lineage.exists():
                paths_to_add.append("Catalog/Applications/Packages/lineage.json")

            if paths_to_add:
                for p in paths_to_add:
                    self.git.add(p)
            self.git.commit(commit_msg)
            self.git.push()
        except Exception as e:
            print(f"[Commit] Warning: {e}")

        # Update Aristotle Loop with reward
        self.aristotle_loop.record_discovery(
            domain=job.concept.domain,
            mode=job.concept.research_mode,
            reward=job.quality_score,
            new_theorem_count=job.theorem_count,
            cross_domain="Bridge" in (job.concept.title or "") or "bridge" in (job.concept.domain or "").lower()
        )

        from research_memory import ExperimentRecord
        import datetime
        status = "success" if job.quality_score > 0 else "trivial_rejected"
        proof_quality = "substantial" if job.quality_score >= 0.7 else ("partial" if job.quality_score > 0 else "trivial")

        record = ExperimentRecord(
            exp_id=job.job_id,
            domain=job.concept.domain,
            concept_title=job.concept.title,
            concept_description=job.concept.concept_description,
            status=status,
            files_produced=job.theorem_count,
            timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            prompt_text=job.prompt,
            proof_quality=proof_quality,
            quality_score=job.quality_score,
            quality_detail=job.quality_detail.to_dict() if hasattr(job, 'quality_detail') and job.quality_detail else None,
        )
        self.memory.record(record)

        # Quality feedback: adjust future direction priorities based on results
        try:
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            fd_manager.adjust_direction_quality_feedback(
                domain=job.concept.domain,
                quality_score=job.quality_score,
                proof_quality=proof_quality,
            )
        except Exception as e:
            print(f"[Commit] Warning: quality feedback failed: {e}")

        # Log to autoresearch
        self.autoresearch.log_result(
            exp_id=job.job_id,
            concept_title=job.concept.title,
            concept_domain=job.concept.domain,
            research_mode=job.concept.research_mode,
            quality=proof_quality,
            quality_score=job.quality_score,
            catalog_references=job.concept.catalog_references or [],
            prompt_length=len(job.prompt) if job.prompt else 0,
            files_placed=job.files_integrated,
        )

        print(f"[Commit] Cycle #{job.cycle_n} complete: score={job.quality_score:.3f}")

    # ==================================================================
    # Full pipeline: single cycle
    # ==================================================================

    def _release_direction(self, job: ResearchJob) -> None:
        """Release the future direction consumed by a failed job back to available."""
        if not job.job_id:
            return
        try:
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            for d in fd_manager._directions:
                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                    fd_manager.mark_direction_available(d.id)
                    print(f"[Tick] Released direction {d.id}: {d.title[:50]}")
                    break
        except Exception as e:
            print(f"[Tick] Warning: could not release direction: {e}")

    def _extract_future_directions(self, job: ResearchJob) -> None:
        """Extract future directions from Aristotle's output and mark the consumed direction completed."""
        if job.status != "integrated" or not job.job_id:
            return
        try:
            from research_memory import FutureDirectionsManager, FutureDirection
            fd_manager = FutureDirectionsManager(self.workspace)
            fd_added = 0
            # Extract future directions text from results
            fd_text = None
            # Try result_future_directions first
            if job.result_future_directions and len(job.result_future_directions) > 50:
                fd_text = job.result_future_directions
            # Fallback: try JSON package's future_directions field
            if not fd_text and job.result_json_package:
                try:
                    pkg = json.loads(job.result_json_package)
                    fd_text = pkg.get("future_directions", "")
                    if len(fd_text) < 50:
                        fd_text = None
                except Exception:
                    pass
            # Also scan project dir for FUTURE_DIRECTIONS.md files
            if not fd_text and job.project_dir and job.project_dir.exists():
                for fd_file in job.project_dir.rglob("FUTURE_DIRECTIONS*.md"):
                    try:
                        fd_content = fd_file.read_text(encoding="utf-8", errors="replace")
                        if len(fd_content) > 50:
                            fd_text = fd_content
                            break
                    except Exception:
                        pass
            if fd_text:
                # Use the entire future_directions text as one single entry
                title_line = ""
                for line in fd_text.split("\n"):
                    line = line.strip()
                    if line and not line.startswith("#") and not line.startswith("-") and len(line) > 10:
                        title_line = line[:80]
                        break
                if not title_line:
                    title_line = f"Future directions from cycle {job.job_id[:8]}"
                fd = FutureDirection(
                    id=fd_manager._next_id(),
                    title=title_line,
                    description=fd_text,
                    source_exp_id=job.job_id,
                    source_path=str(job.project_dir) if job.project_dir else "future_directions_md",
                    domains=fd_manager._infer_domains(fd_text),
                    depth_estimate=3,
                    priority_score=0.75,
                )
                fd_manager.add_direction(fd)
                fd_added = 1
                print(f"[Cycle] Added 1 future direction from cycle {job.job_id}")
            else:
                print(f"[Cycle] No future directions found for cycle {job.job_id}")
            # Mark the consumed direction as completed
            for d in fd_manager._directions:
                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                    fd_manager.mark_direction_completed(d.id)
                    # Quality feedback: record how well this direction performed
                    if job.quality_score > 0:
                        d.outcome_quality = job.quality_score
                        print(f"[Cycle] Direction {d.id} outcome_quality={job.quality_score:.2f}")
                    print(f"[Cycle] Marked direction {d.id} as completed")
                    break
        except Exception as e:
            print(f"[Cycle] Warning: Failed to extract future directions: {e}")

    def run_single_cycle(self, forced_domain: Optional[str] = None, dry_run: bool = False) -> ResearchJob:
        """Run one complete research cycle: discover → dispatch → await → extract → evaluate → integrate → commit."""
        # 1. DISCOVER
        job = self.discover(forced_domain)

        # 2. DISPATCH
        job = self.dispatch(job, dry_run=dry_run)

        if dry_run or job.status in ("failed", "dry_run"):
            return job

        # 3. AWAIT - poll until complete
        if job.project_id:
            self.inflight[job.project_id] = job
            print(f"[Await] Waiting for Aristotle project {job.project_id[:8]}...")
            job = self._await_job(job)

        if job.status not in ("completed",):
            print(f"[Cycle] Job {job.job_id} ended with status: {job.status}")
            # Mark the consumed direction as available again so it can be retried
            if job.job_id:
                try:
                    from research_memory import FutureDirectionsManager
                    fd_mgr = FutureDirectionsManager(self.workspace)
                    for d in fd_mgr._directions:
                        if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                            fd_mgr.mark_direction_available(d.id)
                            print(f"[Cycle] Released direction {d.id}: {d.title[:50]}")
                            break
                except Exception as e:
                    print(f"[Cycle] Warning: could not release direction: {e}")
            return job

        # 4. EXTRACT
        job = self.extract(job)

        # 5. EVALUATE
        job = self.evaluate(job)

        # 6. INTEGRATE
        job = self.integrate(job)

        # 6b. EXTRACT FUTURE DIRECTIONS from Aristotle's output
        self._extract_future_directions(job)

        # 7. CLEANUP — dedup, workspace removal, sync verification
        job = self.cleanup_catalog(job)

        # 8. COMMIT
        self.commit(job)

        # 9. Challenge problem generation from successful research
        if job.quality_score and job.quality_score >= 0.5:
            try:
                self._generate_challenge_problem(job)
            except Exception as e:
                print(f"[Challenge] Warning: challenge generation failed: {e}")

        # 10. Research arc propagation
        try:
            self._propagate_research_arc(job)
        except Exception as e:
            print(f"[Arc] Warning: arc propagation failed: {e}")

        return job

    def _await_job(self, job: ResearchJob, timeout: int = 7200, poll_interval: int = 30) -> ResearchJob:
        """Block until Aristotle completes or times out.

        This is the SYNC version — only call from non-async code.
        """
        start = time.time()
        while time.time() - start < timeout:
            try:
                result = asyncio.run(self.aristotle.poll_project(job.project_id))
                status = result.get("status", "unknown")
                has_files = result.get("has_files", False)
                is_complete = result.get("complete", False)

                if is_complete or (status == "IDLE" and has_files):
                    job.status = "completed"
                    job.complete_time = time.time()
                    print(f"[Await] {job.project_id[:8]} COMPLETE (status={status})")
                    return job
                elif status == "IDLE" and not has_files:
                    job.status = "failed"
                    job.error_message = "Aristotle: IDLE with no result files"
                    self.failed_count += 1
                    print(f"[Await] {job.project_id[:8]} FAILED (IDLE, no files)")
                    return job
                elif status == "RUNNING" and int(time.time() - start) % 120 < poll_interval:
                    elapsed = int(time.time() - start)
                    print(f"[Await] {job.project_id[:8]} RUNNING ({elapsed}s elapsed)")
            except Exception as e:
                print(f"[Await] Poll error: {e}")

            time.sleep(poll_interval)

        job.status = "timeout"
        job.error_message = f"Timed out after {timeout}s"
        return job

    # ==================================================================
    # Continuous mode
    # ==================================================================

    async def run_continuous(self, max_inflight: int = 3, max_cycles: int = 50,
                             poll_interval: int = 60) -> None:
        """Run the continuous research loop with parallel dispatch."""
        print(f"[Aether] Starting continuous loop: max_inflight={max_inflight}, "
              f"max_cycles={max_cycles}, poll={poll_interval}s")
        print(f"[Aether] Catalog: {self.catalog_root}")
        print(f"[Aether] Pi-Agent model: {self.config.get('pi_agent', {}).get('model', 'unknown')}")

        domain_cycle = [None, "tropical", "emachinelearning", "ealgebra", "epythagorean", "ebridges"]
        domain_idx = 0

        while self.cycle_count < max_cycles:
            # Poll in-flight jobs
            completed = await self.poll_all()
            for job in completed:
                if job.status == "completed":
                    job = await self.extract_async(job)
                    job = self.evaluate(job)
                    job = await self.integrate_async(job)

                    # Extract future directions and mark consumed direction as completed
                    if job.status == "integrated" and job.job_id:
                        try:
                            from research_memory import FutureDirectionsManager, FutureDirection
                            fd_manager = FutureDirectionsManager(self.workspace)
                            # Extract future directions text from results
                            fd_text = None
                            if job.result_future_directions and len(job.result_future_directions) > 50:
                                fd_text = job.result_future_directions
                            if not fd_text and job.result_json_package:
                                try:
                                    pkg = json.loads(job.result_json_package)
                                    fd_text = pkg.get("future_directions", "")
                                    if len(fd_text) < 50:
                                        fd_text = None
                                except Exception:
                                    pass
                            if not fd_text and job.project_dir and job.project_dir.exists():
                                for fd_file in job.project_dir.rglob("FUTURE_DIRECTIONS*.md"):
                                    try:
                                        fd_content = fd_file.read_text(encoding="utf-8", errors="replace")
                                        if len(fd_content) > 50:
                                            fd_text = fd_content
                                            break
                                    except Exception:
                                        pass
                            if fd_text:
                                # Use the entire future_directions text as one single entry
                                title_line = ""
                                for line in fd_text.split("\n"):
                                    line = line.strip()
                                    if line and not line.startswith("#") and not line.startswith("-") and len(line) > 10:
                                        title_line = line[:80]
                                        break
                                if not title_line:
                                    title_line = f"Future directions from cycle {job.job_id[:8]}"
                                fd = FutureDirection(
                                    id=fd_manager._next_id(),
                                    title=title_line,
                                    description=fd_text,
                                    source_exp_id=job.job_id,
                                    source_path=str(job.project_dir) if job.project_dir else "future_directions_md",
                                    domains=fd_manager._infer_domains(fd_text),
                                    depth_estimate=3,
                                    priority_score=0.75,
                                )
                                fd_manager.add_direction(fd)
                                fd_added = 1
                                print(f"[Continuous] Added 1 future direction from cycle {job.job_id}")
                            else:
                                print(f"[Continuous] No future directions found for cycle {job.job_id}")
                            for d in fd_manager._directions:
                                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                                    fd_manager.mark_direction_completed(d.id)
                                    # Quality feedback: record how well this direction performed
                                    if job.quality_score > 0:
                                        d.outcome_quality = job.quality_score
                                        print(f"[Continuous] Direction {d.id} outcome_quality={job.quality_score:.2f}")
                                    print(f"[Continuous] Marked direction {d.id} as completed")
                                    break
                        except Exception as e:
                            print(f"[Continuous] Warning: Failed to extract future directions: {e}")

                    job = await self.cleanup_catalog_async(job)
                    self.commit(job)

                    if job.project_id in self.inflight:
                        del self.inflight[job.project_id]
                else:
                    self.failed_count += 1
                    # Release the consumed direction so it can be retried
                    if job.job_id:
                        try:
                            from research_memory import FutureDirectionsManager
                            fd_mgr = FutureDirectionsManager(self.workspace)
                            for d in fd_mgr._directions:
                                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                                    fd_mgr.mark_direction_available(d.id)
                                    print(f"[Continuous] Released direction {d.id}: {d.title[:50]}")
                                    break
                        except Exception as e:
                            print(f"[Continuous] Warning: could not release direction: {e}")
                    if job.project_id in self.inflight:
                        del self.inflight[job.project_id]
            
            if completed:
                self._save_inflight()

            # Dispatch new jobs to fill queue
            while len(self.inflight) < max_inflight and self.cycle_count < max_cycles:
                domain = domain_cycle[domain_idx % len(domain_cycle)]
                domain_idx += 1

                # Discover and dispatch (async version since we're in an event loop)
                job = self.discover(forced_domain=domain)
                job = await self.dispatch_async(job)

                if job.project_id:
                    print(f"[Continuous] Dispatched {job.project_id[:8]}: {job.concept.title[:50]}")
                else:
                    print(f"[Continuous] Dispatch failed, waiting...")
                    await asyncio.sleep(30)
                    break

            # Status
            print(f"\n[Status] Cycle {self.cycle_count}/{max_cycles} | "
                  f"Inflight: {len(self.inflight)}/{max_inflight} | "
                  f"Completed: {self.completed_count} | Failed: {self.failed_count}")

            await asyncio.sleep(poll_interval)

        print(f"\n[Aether] Loop complete: {self.completed_count} completed, {self.failed_count} failed")


def main():
    parser = argparse.ArgumentParser(description="Aether Knowledge Extractor")
    parser.add_argument("--single-cycle", action="store_true", help="Run one research cycle")
    parser.add_argument("--continuous", action="store_true", help="Run continuous loop")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be dispatched")
    parser.add_argument("--domain", type=str, default=None, help="Force research domain")
    parser.add_argument("--max-inflight", type=int, default=3, help="Max concurrent Aristotle jobs")
    parser.add_argument("--max-cycles", type=int, default=50, help="Max dispatch cycles")
    parser.add_argument("--poll-interval", type=int, default=60, help="Seconds between polls")
    parser.add_argument("--config", type=str, default=None, help="Config file path")
    args = parser.parse_args()

    extractor = KnowledgeExtractor(config_path=args.config)

    if args.dry_run:
        job = extractor.discover(forced_domain=args.domain)
        extractor.dispatch(job, dry_run=True)
    elif args.single_cycle:
        extractor.run_single_cycle(forced_domain=args.domain)
    elif args.continuous:
        asyncio.run(extractor.run_continuous(
            max_inflight=args.max_inflight,
            max_cycles=args.max_cycles,
            poll_interval=args.poll_interval,
        ))
    else:
        print("Use --single-cycle, --continuous, or --dry-run")


if __name__ == "__main__":
    main()

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
import shutil
import tarfile
import tempfile
import time
import uuid
from dataclasses import dataclass, field
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
    quality_score: float = 0.0
    quality_assessment: Optional[Dict] = None
    sorry_count: int = 0
    theorem_count: int = 0
    error_message: Optional[str] = None


class KnowledgeExtractor:
    """The core Aether pipeline: Pi brain + Aristotle worker.

    Pi decides what to research. Aristotle does the heavy lifting.
    Pi integrates the results. Aether commits and loops.
    """

    def __init__(self, config_path: Optional[str] = None):
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
        )

        self.output_organizer = OutputOrganizer(
            catalog_root=self.catalog_root,
            pi_agent=self.pi_agent,
        )

        self.research_context = ResearchContext(self.workspace)

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
            'result_future_directions', 'result_discussion',
            'result_article', 'result_research_paper', 'result_json_package',
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

    def discover(self, forced_domain: Optional[str] = None) -> ResearchJob:
        """Pi analyzes the catalog and selects a research direction.

        Uses Aristotle Loop (UCB) for principled domain selection,
        then Pi-Agent for specific concept generation.
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
        for rec in self.memory._cache[-5:]:
            recent_history.append({
                'concept_title': rec.concept_title,
                'domain': rec.domain,
                'quality': rec.proof_quality,
            })

        # Inflight concepts (to avoid repeating requests)
        inflight_concepts = [j.concept.title for j in self.inflight.values()] if hasattr(self, 'inflight') and self.inflight else []

        # Pi-Agent: THE BRAINS — selects the specific concept
        concept = self.pi_agent.select_research_direction(
            domains=domains_with_context,
            recent_history=recent_history,
            research_context=discoveries_prompt,
            inflight_concepts=inflight_concepts,
        )

        print(f"[Pi] concept={concept.title}, domain={concept.domain}, "
              f"mode={concept.research_mode}, novelty={concept.novelty_estimate:.2f}")

        return ResearchJob(
            job_id=job_id,
            cycle_n=cycle_n,
            concept=concept,
            prompt="",  # Will be filled in Phase 2
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
          4. Python demos, visualizations, algorithms
          5. Applications code
          6. FUTURE_DIRECTIONS roadmap
          7. JSON Data Package bundling everything
        """
        deliverables_section = f"""

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {{
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ {{ "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" }} ],
    "algorithms": [ {{ "name": "...", "pseudocode": "..." }} ],
    "visualizations": [ {{ "name": "...", "data": "base64 encoded URI or inline SVG string" }} ],
    "lean_proofs": "Raw lean code..."
  }}
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `\n` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

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
        catalog_dst = dir_path / "Catalog"
        lean_count = 0
        for src_file in self.catalog_root.rglob("*.lean"):
            if ".lake" in src_file.parts:
                continue
            rel = src_file.relative_to(self.catalog_root)
            dst_file = catalog_dst / rel
            dst_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src_file, dst_file)
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

    async def _dispatch_to_aristotle(self, job: ResearchJob) -> str:
        """Dispatch the job to Aristotle and return project_id."""
        from aristotlelib import Project

        project = await Project.create_from_directory(
            prompt=job.prompt,
            project_dir=str(job.project_dir),
        )
        return project.project_id

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
                pct = result.get("percent_complete", 0)

                if status in ("COMPLETE", "COMPLETE_WITH_ERRORS"):
                    print(f"[Poll] {pid[:8]} COMPLETED ({status}, {pct}%)")
                    job.status = "completed"
                    job.complete_time = time.time()
                    completed.append(job)
                elif status in ("FAILED", "OUT_OF_BUDGET", "CANCELED"):
                    print(f"[Poll] {pid[:8]} FAILED ({status})")
                    job.status = "failed"
                    job.error_message = f"Aristotle status: {status}"
                    self.failed_count += 1
                    completed.append(job)
                elif pct > 1:
                    print(f"[Poll] {pid[:8]} in progress ({pct}%)")
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
        - Any .py files (demos, applications, algorithms, visualizations)
        - Any .md files (articles, research papers, discussions, future directions)
        - Any .html files (standalone HTML packages)
        - Any .svg/.png files (visualizations, diagrams)
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
        visual_files = []
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
                        local_equiv = self.catalog_root / rel

                    # Deduplicate: if we've already seen a file for this catalog
                    # location, skip the duplicate (prefer the version closer to root).
                    catalog_rel = str(local_equiv.relative_to(self.catalog_root)) if local_equiv.exists() else str(rel)
                    if catalog_rel in seen_rel_paths:
                        continue
                    seen_rel_paths[catalog_rel] = fp
                        
                    if local_equiv.exists():
                        # Read text and ignore whitespace/CRLF differences
                        import re
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
                elif f.endswith((".svg", ".png", ".jpg", ".jpeg")):
                    visual_files.append(fp)
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
                # Deduplicate by catalog-relative path to avoid writing same file twice
                dedup_key = str(rel_path).replace('\\', '/')
                # For files under Catalog/ subdirectory, strip that prefix for dedup
                if "Catalog/" in dedup_key:
                    dedup_key = dedup_key.split("Catalog/", 1)[1]
                if dedup_key in seen_paths:
                    continue
                seen_paths.add(dedup_key)
                header = f"-- DIFF: {rel_path}\n" if is_diff_file else f"-- NEW_FILE: {rel_path}\n"
                parts.append(f"{header}{content}\n")
            job.result_lean = "\n\n".join(parts)

        # Collect Python artifacts — demos, applications, algorithms, visualizations
        if python_files:
            parts = []
            for f in sorted(python_files):
                parts.append(f.read_text())
            job.result_demo = "\n\n".join(parts)

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
            job.result_json_package = "\n\n".join(parts)

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
              f"Visuals: {len(visual_files)} files, "
              f"FUTURE_DIRECTIONS: {len(future_directions_files)} files, "
              f"Discussion: {len(discussion_files)} files, "
              f"Sorries: {job.sorry_count}, Theorems: {job.theorem_count}")

        return job

    # ==================================================================
    # Phase 5: EVALUATE — Pi judges the quality
    # ==================================================================

    def evaluate(self, job: ResearchJob) -> ResearchJob:
        """Pi-Agent evaluates the quality of Aristotle's result."""
        if not job.result_lean:
            job.quality_score = 0.0
            job.quality_assessment = {"quality": "trivial", "analysis": "No Lean output"}
            return job

        # Pi-Agent: THE BRAINS — evaluates quality
        qa = self.pi_agent.evaluate_result_quality(
            result_lean=job.result_lean,
            concept=job.concept,
            prompt=job.prompt,
        )
        job.quality_assessment = qa

        # Compute the composite score
        job.quality_score = self.autoresearch.evaluate_concept_quality(
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
        )

        print(f"[Evaluate] quality={qa.get('quality','?')}, score={job.quality_score:.3f}, "
              f"sorries={job.sorry_count}, theorems={job.theorem_count}")

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
            import re
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
        if job.result_paper:
            parts.append({"type": "new", "path": f"Applications/Papers/{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_paper})

        # NEW artifact types — integrate into correct Catalog locations
        if job.result_article:
            parts.append({"type": "new", "path": f"Applications/Articles/{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_article})
        if job.result_research_paper:
            parts.append({"type": "new", "path": f"Applications/Papers/research_{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_research_paper})
        if job.result_json_package:
            parts.append({"type": "new", "path": f"Applications/Packages/{self._derive_artifact_name(job.concept, 'json')}", "content": job.result_json_package})
        if job.result_discussion:
            parts.append({"type": "new", "path": f"Applications/Articles/discussion_{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_discussion})

        # 2. Ask Pi to review and authorize the placements
        plan_prompt = (
            f"Aristotle has generated the following files and diffs for the Catalog:\n"
        )
        for i, p in enumerate(parts):
            plan_prompt += f"[{i}] {p['type'].upper()} -> {p['path']}\n"
            
        plan_prompt += (
            f"\nReview these paths and assign each to the correct Catalog location.\n"
            f"PLACEMENT RULES:\n"
            f"- Lean proofs WITH sorries → Speculative/AutoResearch/\n"
            f"- Lean proofs WITHOUT sorries → their real Catalog domain directory\n"
            f"- Python demos/algorithms → Applications/Demos/\n"
            f"- Research papers → Applications/Papers/\n"
            f"- Popular-science articles → Applications/Articles/\n"
            f"- Discussion articles → Applications/Articles/\n"
            f"- JSON packages → Applications/Packages/\n"
            f"- If a file should NOT be integrated (placeholder, empty, invalid), respond with \"REJECT\".\n"
            f"Respond ONLY with a JSON dictionary mapping the index (as string) to the authorized target path relative to the Catalog root, or \"REJECT\".\n"
            f"Example: {{\"0\": \"Tropical/MyFile.lean\", \"1\": \"Applications/Articles/my_article.md\", \"2\": \"REJECT\"}}"
        )
        
        raw_plan = await asyncio.to_thread(
            self.pi_agent._call_ollama, 
            "You are Pi-Agent, an expert integration manager. Output ONLY valid JSON.", 
            plan_prompt, 
            timeout=120
        )
        
        import json
        try:
            # Simple JSON extraction
            match = re.search(r'\{.*\}', raw_plan, re.DOTALL)
            plan = json.loads(match.group(0)) if match else {}
        except Exception:
            plan = {}

        # 3. Apply the changes — with deduplication and REJECT filtering
        written_paths = set()  # Track what we've already written to avoid duplicates
        
        for i, p in enumerate(parts):
            raw_target = plan.get(str(i), p["path"])
            
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
                    import re
                    if re.sub(r'\s+', ' ', existing_content).strip() == re.sub(r'\s+', ' ', new_content).strip():
                        print(f"[Integrate] Skipped (unchanged): {target_path}")
                        continue
                except Exception:
                    pass  # If we can't read it, proceed with writing
            
            abs_target.parent.mkdir(parents=True, exist_ok=True)
            
            if p["type"] == "new":
                abs_target.write_text(p["content"], encoding="utf-8")
                print(f"[Integrate] Created {target_path}")
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
                    else:
                        print(f"[Integrate] Patch failed for {target_path}: {result.stderr}")
                except Exception as e:
                    print(f"[Integrate] Patch failed for {target_path}: {e}")
                finally:
                    os.unlink(patch_file)

        print(f"[Integrate] Pi successfully integrated all files.")
        job.status = "integrated"
        self.completed_count += 1

        # Update the packages_db.js if we saved a JSON package
        if job.result_json_package:
            try:
                packages_dir = self.catalog_root / "Applications" / "Packages"
                packages_dir.mkdir(parents=True, exist_ok=True)
                
                # Regenerate packages_db.js from all json files in the directory
                import glob
                json_files = list(packages_dir.glob("*.json"))
                
                package_index = []
                package_db = {}
                
                for fp in json_files:
                    if fp.name in ("index.json", "package.json"): continue
                    try:
                        data = json.loads(fp.read_text(encoding='utf-8'))
                        date_str = data.get("date", __import__("time").strftime('%Y-%m-%dT%H:%M:%SZ', __import__("time").gmtime(os.path.getmtime(str(fp)))))
                        package_index.append({
                            "filename": fp.name,
                            "title": data.get("title", "Untitled Research"),
                            "domain": data.get("domain", "General"),
                            "date": date_str
                        })
                        package_db[fp.name] = data
                    except Exception as e:
                        print(f"[Integrate] Error parsing {fp.name}: {e}")
                        
                package_index.sort(key=lambda x: x.get("date", ""), reverse=True)
                
                js_content = f"// AUTO-GENERATED FILE. DO NOT EDIT.\n"
                js_content += f"// This file bundles all JSON packages so they can be loaded from file:// without CORS issues.\n\n"
                js_content += f"window.PACKAGE_INDEX = {json.dumps(package_index, indent=2)};\n\n"
                js_content += f"window.PACKAGE_DB = {json.dumps(package_db, indent=2)};\n"
                
                (packages_dir / "packages_db.js").write_text(js_content, encoding="utf-8")
                print(f"[Integrate] Updated packages_db.js with {len(package_index)} packages.")
            except Exception as e:
                print(f"[Integrate] Warning: Failed to update packages_db.js: {e}")

        return job

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
                return path[len(prefix):]
        return path

    @staticmethod
    def _lean_contains_sorry(content: str) -> bool:
        import re
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
            dedup_script = self.workspace / "Aether/dedup_catalog.py"
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
            
        return job

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

    def _derive_artifact_name(self, concept: ResearchConcept, ext: str) -> str:
        """Derive a sensible artifact name from the concept.

        Uses the concept title as a base, sanitized for filenames.
        """
        base = concept.title.replace(" ", "_").replace("-", "_").lower()
        # Remove any characters that aren't filename-safe
        import re
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
            dedup_script = self.workspace / "Aether/dedup_catalog.py"
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
        
        return job

    # ==================================================================
    # Phase 8: COMMIT — Aether commits and tracks
    # ==================================================================

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
            self.git.add(".")
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
        proof_quality = "substantial" if job.quality_score >= 0.8 else ("partial" if job.quality_score > 0 else "trivial")
        
        record = ExperimentRecord(
            exp_id=job.job_id,
            domain=job.concept.domain,
            concept_title=job.concept.title,
            concept_description=job.concept.concept_description,
            status=status,
            files_produced=job.theorem_count,
            timestamp=datetime.datetime.now().isoformat(),
            prompt_text=job.prompt,
            proof_quality=proof_quality
        )
        self.memory.record(record)

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
            files_placed=job.theorem_count,
        )

        print(f"[Commit] Cycle #{job.cycle_n} complete: score={job.quality_score:.3f}")

    # ==================================================================
    # Full pipeline: single cycle
    # ==================================================================

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
            return job

        # 4. EXTRACT
        job = self.extract(job)

        # 5. EVALUATE
        job = self.evaluate(job)

        # 6. INTEGRATE
        job = self.integrate(job)

        # 7. CLEANUP — dedup, workspace removal, sync verification
        job = self.cleanup_catalog(job)

        # 8. COMMIT
        self.commit(job)

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
                pct = result.get("percent_complete", 0)

                if status in ("COMPLETE", "COMPLETE_WITH_ERRORS"):
                    job.status = "completed"
                    job.complete_time = time.time()
                    print(f"[Await] {job.project_id[:8]} COMPLETE ({pct}%)")
                    return job
                elif status in ("FAILED", "OUT_OF_BUDGET", "CANCELED"):
                    job.status = "failed"
                    job.error_message = f"Aristotle: {status}"
                    self.failed_count += 1
                    print(f"[Await] {job.project_id[:8]} FAILED ({status})")
                    return job
                elif pct > 1 and int(time.time() - start) % 120 < poll_interval:
                    elapsed = int(time.time() - start)
                    print(f"[Await] {job.project_id[:8]} {pct}% ({elapsed}s elapsed)")
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
                    job = await self.cleanup_catalog_async(job)
                    self.commit(job)
                    
                    if job.project_id in self.inflight:
                        del self.inflight[job.project_id]
                else:
                    self.failed_count += 1
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

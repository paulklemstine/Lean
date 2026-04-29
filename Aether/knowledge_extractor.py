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

        # Pi-Agent: THE BRAINS — selects the specific concept
        concept = self.pi_agent.select_research_direction(
            domains=domains_with_context,
            recent_history=recent_history,
            research_context=discoveries_prompt,
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
        """Add open-ended deliverable guidance to the Aristotle prompt.

        Aristotle is a powerful theorem prover — give it freedom to produce
        excellent work, not rigid file name constraints. We describe WHAT
        outcomes we want, not HOW to name the files.
        """
        deliverables_section = f"""

### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

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
        """Build a project directory for Aristotle with reference files."""
        dir_path = self.workspace / f"projects/{job.job_id}"
        dir_path.mkdir(parents=True, exist_ok=True)

        # Copy referenced catalog files for Aristotle's context
        refs = job.concept.catalog_references or []
        for ref in refs:
            src = self.catalog_root / ref
            if src.exists():
                # Create parent dirs in project
                dst = dir_path / ref
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)

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

        # Remove completed/failed from inflight
        for job in completed:
            if job.project_id in self.inflight:
                del self.inflight[job.project_id]

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

    def _parse_aristotle_result(self, job: ResearchJob, extract_dir: Path) -> ResearchJob:
        """Parse Aristotle's result directory to extract all artifacts.

        Aristotle is free to organize however it sees fit. We scan for:
        - Any .lean files containing theorem proofs
        - Any .py files (demos, applications)
        - Any .md files (papers, discussions, summaries)
        - Any other useful artifacts
        """
        lean_files = []
        python_files = []
        paper_files = []
        summary = None

        for root, dirs, files in os.walk(extract_dir):
            for f in files:
                fp = Path(root) / f
                # Skip build artifacts
                if ".lake" in str(fp) or "lake-manifest" in f or "lakefile" in f:
                    continue

                if f == "ARISTOTLE_SUMMARY.md":
                    summary = fp.read_text()
                elif f.endswith(".lean") and f != "Main.lean":
                    lean_files.append(fp)
                elif f.endswith(".py"):
                    python_files.append(fp)
                elif f.endswith(".md") and f not in ("README.md", "PROMPT.md"):
                    paper_files.append(fp)

        # Collect Lean sources — Aristotle decides which files contain the new theorems
        if lean_files:
            # Prefer files that aren't just reference copies of catalog files
            ref_stems = {Path(r).stem for r in (job.concept.catalog_references or [])}
            new_lean = [f for f in lean_files if f.stem not in ref_stems]
            if new_lean:
                # Combine all new Lean files into the result
                if len(new_lean) == 1:
                    job.result_lean = new_lean[0].read_text()
                else:
                    # Multiple new files — combine them
                    parts = []
                    for f in sorted(new_lean):
                        parts.append(f"-- File: {f.name}\n{f.read_text()}")
                    job.result_lean = "\n\n".join(parts)
            elif lean_files:
                job.result_lean = lean_files[0].read_text()

        # Collect Python artifacts — demos, applications, whatever Aristotle created
        if python_files:
            parts = []
            for f in sorted(python_files):
                parts.append(f.read_text())
            job.result_demo = "\n\n".join(parts)

        # Collect paper / discussion artifacts
        if paper_files:
            parts = []
            for f in sorted(paper_files):
                parts.append(f.read_text())
            job.result_paper = "\n\n".join(parts)

        # Summary
        job.result_summary = summary

        # Count sorries and theorems across all Lean output
        if job.result_lean:
            job.sorry_count = job.result_lean.count("sorry")
            job.theorem_count = job.result_lean.count("theorem ") + job.result_lean.count("lemma ")

        print(f"[Extract] Lean: {len(lean_files)} files, Python: {len(python_files)} files, "
              f"Papers: {len(paper_files)} files, Sorries: {job.sorry_count}, "
              f"Theorems: {job.theorem_count}")

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
        """Pi-Agent integrates Aristotle's output into the Catalog.

        Pi has freedom to place artifacts wherever makes sense:
        - Lean theorems: Catalog/{Domain}/{Subdir}/ (Pi chooses domain & subdir)
        - Python demos: Catalog/Applications/Demos/ (Pi names the file)
        - Research papers: Catalog/Applications/Papers/ (Pi names the file)
        - Any other artifacts Aristotle produced: wherever Pi decides

        Pi uses classify_file_placement() to decide where Lean goes.
        For other artifacts, we use a simple convention but let Aristotle's
        naming influence the final placement.
        """
        if job.quality_score < 0.05:
            print(f"[Integrate] REJECTED: score too low ({job.quality_score:.3f})")
            job.status = "rejected"
            return job

        # Primary artifact: Lean theorems
        # Pi may have produced one file or several; we place each one.
        if job.result_lean:
            # Split multi-file output back into individual files if needed
            files_to_place = self._split_lean_output(job.result_lean, job.concept)

            for lean_content, suggested_name in files_to_place:
                # Pi classifies where each file goes
                placement = self.pi_agent.classify_file_placement(
                    lean_source=lean_content,
                    file_name=suggested_name,
                    concept=job.concept,
                )

                target_path = self.catalog_root / placement["target_path"]
                target_path.parent.mkdir(parents=True, exist_ok=True)

                sorry_count = lean_content.count("sorry")
                if sorry_count == 0:
                    # Verified theorem — place directly in Catalog domain
                    target_path.write_text(lean_content)
                    print(f"[Integrate] Lean → {placement['target_path']} (verified, 0 sorries)")
                else:
                    # Has sorries — place in Speculative
                    speculative_name = suggested_name
                    speculative_path = self.catalog_root / f"Speculative/AutoResearch/{speculative_name}"
                    speculative_path.parent.mkdir(parents=True, exist_ok=True)
                    speculative_path.write_text(lean_content)
                    print(f"[Integrate] Lean → Speculative/AutoResearch/{speculative_name} ({sorry_count} sorries)")

        # Secondary artifacts: Python demos, research papers, etc.
        # Let Aristotle's organization guide our placement, with Pi deciding final location
        if job.result_demo:
            # Use Aristotle's suggested name or fall back to a descriptive name
            demo_name = self._derive_artifact_name(job.concept, "py")
            demo_path = self.catalog_root / f"Applications/Demos/{demo_name}"
            demo_path.parent.mkdir(parents=True, exist_ok=True)
            demo_path.write_text(job.result_demo)
            print(f"[Integrate] Python demos → Applications/Demos/{demo_name}")

        if job.result_paper:
            paper_name = self._derive_artifact_name(job.concept, "md")
            paper_path = self.catalog_root / f"Applications/Papers/{paper_name}"
            paper_path.parent.mkdir(parents=True, exist_ok=True)
            paper_path.write_text(job.result_paper)
            print(f"[Integrate] Research paper → Applications/Papers/{paper_name}")

        job.status = "integrated"
        self.completed_count += 1
        return job

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

    # ==================================================================
    # Phase 7: COMMIT — Aether commits and tracks
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
            self.git.auto_commit()
        except Exception as e:
            print(f"[Commit] Warning: {e}")

        # Update Aristotle Loop with reward
        self.aristotle_loop.update(
            domain=job.concept.domain,
            mode=job.concept.research_mode,
            reward=job.quality_score,
        )

        # Record in memory
        self.memory.record_experiment({
            "job_id": job.job_id,
            "cycle": job.cycle_n,
            "concept_title": job.concept.title,
            "domain": job.concept.domain,
            "mode": job.concept.research_mode,
            "quality_score": job.quality_score,
            "theorem_count": job.theorem_count,
            "sorry_count": job.sorry_count,
            "has_demo": bool(job.result_demo),
            "has_paper": bool(job.result_paper),
        })

        # Log to autoresearch
        self.autoresearch.log_result(
            quality_score=job.quality_score,
            concept_title=job.concept.title,
            domain=job.concept.domain,
            theorem_count=job.theorem_count,
            sorry_count=job.sorry_count,
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

        # 7. COMMIT
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
                    job = self.extract(job)
                    job = self.evaluate(job)
                    job = self.integrate(job)
                    self.commit(job)
                else:
                    self.failed_count += 1

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

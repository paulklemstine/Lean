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
from pi_agent_client import (
    PiAgentClient,
    ResearchConcept,
    select_phase_a_prompt_version,
    DEFAULT_PHASE_A_PROMPT_WEIGHTS,
    select_phase_b_prompt_version,
    DEFAULT_PHASE_B_PROMPT_WEIGHTS,
)
from archive_manager import ArchiveManager
from catalog_analyzer import CatalogAnalyzer
from autoresearch_bridge import AutoresearchBridge
from research_memory import ResearchMemory
from research_threads import ResearchThreadManager, ResearchThread
from specialized_critics import SpecializedCritic
from external_signal import ExternalSignalFeed
from computational_stage import ComputationalStage
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
    specialized_critic_scores: Optional[Dict[str, Any]] = None  # 4-axis critic scores
    sorry_count: int = 0
    theorem_count: int = 0
    theorem_novelty: Optional[Dict[str, int]] = None  # new/strengthening/duplicate/disproof/unknown counts
    files_integrated: int = 0  # Actual count of files written to Catalog during integrate
    integrated_paths: list = None  # Paths of files written to Catalog (relative to repo root)
    error_message: Optional[str] = None
    source_exp_ids: list = None  # exp_ids of parent experiments whose future directions inspired this one
    adversarial_result: Optional[Dict] = None  # Adversarial judging metadata
    decomposition_depth: int = 0
    prompt_version: str = "v1"  # Which prompt version was used: v1, v2, v3
    prod_count: int = 0  # How many times Aristotle was explicitly prodded to continue
    # Two-phase fields (Phase A: math, Phase B: packaging)
    phase: str = "A"  # "A" | "B" | "complete" | "A_only"
    phase_a_result: Optional[Dict] = None  # {"lean_files": [...], "theorem_count": N, "sorry_count": M, "self_grade": "world_class|substantial|partial"}
    phase_b_result: Optional[Dict] = None  # {"article_path": ..., "demo_path": ..., "widgets": [...]}
    phase_a_prompt_version: Optional[str] = None  # "v3" | "v4"
    phase_b_prompt_version: Optional[str] = None  # currently only "v1" packaging
    phase_a_quality_score: Optional[float] = None  # saved before phase B so we can re-evaluate after B
    phase_b_skipped_reason: Optional[str] = None  # "low_quality" | "threshold_not_met" | "phase_a_failed"
    retry_count: int = 0
    retry_of: Optional[str] = None
    resume_count: int = 0  # times an OUT_OF_BUDGET task was resumed via project.ask()
    retry_queued_time: float = 0.0
    # Reliable job↔direction link. Set when the direction is consumed (discover
    # path, line ~693). Retries mutate the same job, so they retain this. The
    # tick-end reconcile uses it to re-establish in_progress even if
    # consumed_by_exp_id was cleared (retry-queued dispatches skip
    # mark_direction_consumed).
    direction_id: Optional[str] = None
    # Wall-clock timestamp set whenever status -> "preparing". Lets poll_all
    # force-fail jobs that never made it to "dispatched" (e.g. process killed
    # mid-dispatch), so they don't occupy a slot forever.
    preparing_started: float = 0.0
    # Multi-cycle research threads
    thread_id: Optional[str] = None
    cycle_index: int = 0
    # GitHub injection tracking
    github_issue: int = 0



# Max times to resume an OUT_OF_BUDGET (truncated) Phase A task via project.ask()
# before falling back to integrating the partial result.
MAX_RESUME_BUDGET = 2


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

        ws_config = self.config.get("workspace")
        if ws_config:
            self.workspace = Path(ws_config)
            if not self.workspace.is_absolute():
                self.workspace = (Path(__file__).parent / self.workspace).resolve()
            else:
                self.workspace = self.workspace.resolve()
        else:
            self.workspace = (Path(__file__).parent / ".aether_workspace").resolve()
        self.workspace.mkdir(parents=True, exist_ok=True)

        # Core subsystems
        self.catalog_analyzer = CatalogAnalyzer(self.catalog_root)
        self.aristotle = AristotleSDKClient(self.config.get("aristotle", {}))
        self.memory = ResearchMemory(self.workspace)
        self.autoresearch = AutoresearchBridge(self.workspace)
        self.aristotle_loop = AristotleLoop(exploration_constant=1.5)
        self.git = GitAutomator(self.catalog_root.parent)

        # Novelty/duplicate detection no longer uses a SQLite index: it corrupted
        # on SIGTERM mid-rebuild and produced a 142MB file that blocked pushes.
        # _classify_theorem_novelty now counts every theorem as "new" (disproofs
        # still detected by keyword). self.theorem_db is intentionally absent.

        # Content-addressable archive of every Aristotle project input/output
        archive_root = self.config.get("archive", {}).get("root_dir", "../Archive")
        self.archive_manager = ArchiveManager(self.catalog_root.parent / archive_root)

        # Pi-Agent: the BRAINS of Aether
        pi_cfg = self.config.get("pi_agent", {})
        self.pi_agent = PiAgentClient(
            model=pi_cfg.get("model", "kimi-k2.6:cloud"),
            memory=self.memory,
            catalog_root=self.catalog_root,
            timeout=pi_cfg.get("timeout", 300),
            compact="cloud" in pi_cfg.get("model", "kimi-k2.6:cloud").lower(),
            use_ollama=pi_cfg.get("use_ollama", False),
            ollama_base_url=pi_cfg.get("ollama_base_url"),
            ollama_model=pi_cfg.get("ollama_model"),
            ollama_cloud=pi_cfg.get("ollama_cloud", {}),
            openrouter=pi_cfg.get("openrouter", {}),
        )

        self.output_organizer = OutputOrganizer(
            catalog_root=self.catalog_root,
            pi_agent=self.pi_agent,
        )

        self.research_context = ResearchContext(self.workspace)

        # Multi-cycle research thread manager
        self.thread_manager = ResearchThreadManager(self.workspace)

        # External signal feed: arXiv, OEIS, LMFDB
        from research_memory import FutureDirectionsManager
        self.external_signal = ExternalSignalFeed(
            pi_agent=self.pi_agent,
            fd_manager=FutureDirectionsManager(self.workspace),
            workspace=self.workspace,
        )

        # Computational evidence stage: optional pre-proof Python experimentation
        self.computational_stage = ComputationalStage(timeout=60)

        # Insight extractor: meta-feedback loop from Aether's own theorems
        from insight_extractor import InsightExtractor
        self.insight_extractor = InsightExtractor(
            workspace=self.workspace,
            pi_agent=self.pi_agent,
            catalog_analyzer=self.catalog_analyzer,
        )

        # Research journal: cross-cycle memory
        from research_journal import ResearchJournal
        self.research_journal = ResearchJournal(self.workspace)

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
        self.locked_titles = set()
        self.completed_count = 0
        self.failed_count = 0
        self.inflight_path = self.workspace / "inflight_jobs.json"
        self.max_retries = self.config.get("autoresearch", {}).get("max_retries", 2)
        self.phase_b_min_score = self.config.get("phase_b", {}).get("min_score", 0.25)

        
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
    # Two-phase dispatch: Phase A (math) + Phase B (packaging)
    # ==================================================================

    def _adaptive_phase_b_threshold(self) -> float:
        """Rank-based Phase B promotion gate.

        Promotes roughly the **top 30%** of recent Phase A cycles to
        packaging: the threshold is the 70th percentile of recent Phase A
        quality scores, clamped to [0.25, 0.70]. A cycle scoring at or
        above this value gets a Phase B package; the rest stay A_only.

        Phase A scores are extracted from cycle_analytics records:
        - For records that went on to Phase B, ``phase_a_quality_score``
          is the pre-packaging score and is preferred.
        - For A_only / Phase A records, ``quality_score`` IS the Phase A
          score and is used.
        - Phase B records without a ``phase_a_quality_score`` are skipped,
          so packaged-quality doesn't contaminate the Phase A rank.

        Cold start (no usable records): return 0.25 so early cycles can
        bootstrap packaging instead of stalling behind a high fixed bar.

        Cached; recompute every 10 records. The cache carries a version
        key so changes to this formula invalidate stale entries.
        """
        cache_path = self.workspace / "phase_b_threshold_cache.json"
        analytics_path = self.workspace / "cycle_analytics.json"
        if not analytics_path.exists():
            return 0.25
        try:
            import json as _json
            data = _json.loads(analytics_path.read_text())
            records = data.get("records", [])
        except Exception:
            return 0.25

        # Collect Phase A scores (see docstring).
        scores = []
        for r in records:
            pa = r.get("phase_a_quality_score")
            if pa is not None:
                scores.append(float(pa))
            elif r.get("phase") in (None, "A", "A_only"):
                q = r.get("quality_score")
                if q is not None:
                    scores.append(float(q))
        if not scores:
            return 0.25

        n = len(records)
        cache_bucket = n // 10
        cache_version = 2  # bump when the formula/clamp changes
        try:
            if cache_path.exists():
                cache = _json.loads(cache_path.read_text())
                if (cache.get("bucket") == cache_bucket
                        and cache.get("v") == cache_version
                        and "threshold" in cache):
                    return float(cache["threshold"])
        except Exception:
            pass

        # p70 of the most recent Phase A scores (up to 50) -> top 30% gate.
        recent = sorted(scores[-50:])
        p70_idx = int(0.70 * (len(recent) - 1))
        threshold = recent[p70_idx]
        # Clamp to [0.25, 0.70] — never gate so low we package junk, nor
        # so high we stall when scores cluster high.
        threshold = max(0.25, min(0.70, threshold))

        try:
            cache_path.write_text(_json.dumps({
                "v": cache_version,
                "bucket": cache_bucket,
                "threshold": threshold,
                "n_records": n,
                "computed_at": time.time(),
            }))
        except Exception:
            pass

        return threshold

    def _a_only_integration_floor(self) -> float:
        """Quality floor for integrating A_only Lean into the Catalog.

        Decoupled from the promotion percentile: near-miss A_only cycles
        (those below the top-30% cutoff but at or above this floor) still
        get their Lean files integrated as Lean-only, so the Catalog keeps
        near-miss results. Below this floor, A_only Lean is skipped (and
        the direction is quarantined by the caller).
        """
        phase_b_cfg = self.config.get("phase_b", {}) if hasattr(self, "config") and self.config else {}
        return float(phase_b_cfg.get("a_only_integration_floor", 0.30))

    def _dispatch_phase_b(self, job: "ResearchJob") -> "ResearchJob":
        """Build a Phase B prompt on a job, in-place. Does NOT submit to Aristotle.

        The caller (tick loop) is responsible for invoking the Aristotle
        submission after this method returns. We rebuild the prompt with
        Phase A's Lean content as input and update the job's phase metadata.

        This split lets the tick loop reuse the standard dispatch path
        (which calls _dispatch_to_aristotle) without bypassing project
        directory setup.
        """
        # Save the Phase A quality score so we can re-evaluate after Phase B
        if not hasattr(job, 'phase_a_quality_score') or job.phase_a_quality_score is None:
            job.phase_a_quality_score = job.quality_score

        # Snapshot the Phase A result
        job.phase_a_result = {
            "lean_files": [str(p) for p in (job.integrated_paths or []) if str(p).endswith('.lean')],
            "theorem_count": job.theorem_count,
            "sorry_count": job.sorry_count,
            "self_grade": "world_class" if (job.quality_assessment or {}).get("quality") == "world_class" else "substantial",
            "quality_score": job.quality_score,
        }

        # Select Phase B prompt version (A/B weights from config or env)
        prompt_weights = DEFAULT_PHASE_B_PROMPT_WEIGHTS.copy()
        config_weights = self.config.get("pi_agent", {}).get("phase_b_prompt_weights")
        if config_weights and isinstance(config_weights, dict):
            prompt_weights.update(config_weights)
        env_weights = os.environ.get("AETHER_PHASE_B_PROMPT_WEIGHTS")
        if env_weights:
            try:
                prompt_weights.update(json.loads(env_weights))
            except Exception as e:
                print(f"[Dispatch-B] Ignoring invalid AETHER_PHASE_B_PROMPT_WEIGHTS: {e}")
        phase_b_version = select_phase_b_prompt_version(prompt_weights)
        job.phase_b_prompt_version = phase_b_version
        print(f"[Dispatch-B] Phase B prompt version: {phase_b_version}")

        # Build Phase B prompt with Phase A's Lean content as input
        job.phase = "B"
        phase_a_lean = job.result_lean or ""
        # Pass Phase A's Lean file paths so Phase B can @reference them
        phase_a_lean_file_paths = job.phase_a_result.get("lean_files", []) if job.phase_a_result else []
        # Pass Phase A's future directions so Phase B includes them in PACKAGE.json
        phase_a_future_dirs = getattr(job, 'result_future_directions', None) or ""
        job.prompt = self.pi_agent.write_aristotle_prompt(
            concept=job.concept,
            phase="B_package_only",
            phase_a_lean_content=phase_a_lean,
            phase_a_lean_files=phase_a_lean_file_paths,
            phase_a_future_directions=phase_a_future_dirs,
            phase_b_prompt_version=phase_b_version,
        )

        # Phase B does NOT need a fresh project_dir — reuse Phase A's
        # (the Lean files are already there as inputs)
        return job

    async def dispatch_phase_b_async(self, job: "ResearchJob") -> "ResearchJob":
        """Dispatch Phase B to Aristotle using the Phase B prompt.

        Builds a new Aristotle project with the Phase B prompt and submits
        it. The new project_id replaces job.project_id so the next tick
        can poll for Phase B's results.
        """
        # Build the Phase B prompt
        self._dispatch_phase_b(job)

        # Build a fresh project dir for Phase B (since it's a new Aristotle call)
        # But keep the old project_dir as the source of the Phase A Lean
        phase_a_project_dir = job.project_dir
        job.project_dir = self._build_project_dir(job)
        if not job.project_dir:
            job.status = "failed"
            job.error_message = "Could not build Phase B project directory"
            return job

        try:
            old_project_id = job.project_id
            project_id = await self._dispatch_to_aristotle(job)
            if old_project_id and old_project_id in self.inflight:
                del self.inflight[old_project_id]
            # Note: we replace the project_id, but also remember Phase A's
            # (Phase A's lean files should be in the same project_dir as before)
            job.project_id = project_id
            job.status = "B_dispatched"
            job.dispatch_time = time.time()
            self.inflight[project_id] = job
            self._save_inflight()
            print(f"[Dispatch-B] Aristotle project: {project_id} (Phase B for {phase_a_project_dir.name if phase_a_project_dir else '?'})")
        except Exception as e:
            job.status = "failed"
            job.error_message = f"Phase B dispatch failed: {e}"
            print(f"[Dispatch-B] FAILED: {e}")
        return job

    def _count_inflight_dispatched(self) -> int:
        """Count jobs currently occupying Aristotle slots."""
        return len([
            j for j in self.inflight.values()
            if j.status not in ("completed", "failed", "integrated", "rejected")
        ])

    async def dispatch_retry_async(self, job: "ResearchJob", retry_suggestion: Dict[str, Any], max_inflight: int = 9) -> "ResearchJob":
        """Queue or dispatch a proof repair retry, respecting the parallel limit.

        If Aristotle's queue is full or we are already at max_inflight, the job is
        marked as `retry_queued` and left in `inflight`. The main dispatch loop
        will retry it once a slot opens up, instead of immediately hammering the
        Aristotle API and failing.
        """
        old_project_id = job.project_id

        # Update concept and prompt with retry suggestions
        job.concept.concept_description = retry_suggestion.get("revised_concept_description", job.concept.concept_description)
        job.prompt = retry_suggestion.get("revised_prompt", job.prompt)
        job.concept.catalog_references = retry_suggestion.get("revised_catalog_references", job.concept.catalog_references)
        job.concept.research_mode = retry_suggestion.get("revised_research_mode", job.concept.research_mode)

        # Set retry fields
        job.retry_count += 1
        if not job.retry_of:
            job.retry_of = job.job_id

        # Re-build project directory with the new suffix
        job.project_dir = self._build_project_dir(job)
        if not job.project_dir:
            job.status = "failed"
            job.error_message = f"Could not build retry project directory for job {job.job_id}"
            return job

        # Write prompt.md for context
        (job.project_dir / "PROMPT.md").write_text(job.prompt)

        # If there is no capacity, queue the retry instead of dispatching.
        if self._count_inflight_dispatched() >= max_inflight:
            print(f"[Retry-Dispatch] Queueing retry for {job.job_id[:8]}: at max_inflight ({self._count_inflight_dispatched()}/{max_inflight})")
            job.status = "retry_queued"
            job.retry_queued_time = time.time()
            job.project_id = old_project_id  # keep old id placeholder; will dispatch from queued state
            if old_project_id and old_project_id in self.inflight:
                del self.inflight[old_project_id]
            self.inflight[job.job_id] = job
            self._save_inflight()
            return job

        # Prepare dispatch
        job.status = "preparing"
        job.preparing_started = time.time()

        try:
            project_id = await self._dispatch_to_aristotle(job)
            if old_project_id and old_project_id in self.inflight:
                del self.inflight[old_project_id]
            job.project_id = project_id
            job.status = "dispatched"
            job.dispatch_time = time.time()
            self.inflight[project_id] = job
            self._save_inflight()
            print(f"[Retry-Dispatch] Aristotle project: {project_id} (Retry {job.retry_count} for job {job.job_id})")
        except Exception as e:
            if self._is_queue_full_error(e):
                print(f"[Retry-Dispatch] Aristotle queue full for {job.job_id[:8]}; queuing retry")
                job.status = "retry_queued"
                job.retry_queued_time = time.time()
                job.project_id = old_project_id
                if old_project_id and old_project_id in self.inflight:
                    del self.inflight[old_project_id]
                self.inflight[job.job_id] = job
                self._save_inflight()
            else:
                job.status = "failed"
                job.error_message = f"Retry dispatch failed: {e}"
                print(f"[Retry-Dispatch] FAILED: {e}")

        return job

    def dispatch_retry(self, job: "ResearchJob", retry_suggestion: Dict[str, Any], max_inflight: int = 9) -> "ResearchJob":
        """Synchronous version of dispatch_retry_async."""
        return asyncio.run(self.dispatch_retry_async(job, retry_suggestion, max_inflight=max_inflight))

    # ==================================================================
    # Phase 1: DISCOVER — Pi decides what to research
    # ==================================================================

    def discover(self, forced_domain: Optional[str] = None, domain_filter: Optional[str] = None, exclude_domains: Optional[list] = None, forced_direction=None) -> ResearchJob:
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
        if hasattr(self, 'locked_titles'):
            inflight_concepts.extend(self.locked_titles)

        # Select future direction — the primary path
        # Domain decay and anti-repetition handle diversity; no need for redirect logic
        source_exp_ids = []
        from research_memory import FutureDirectionsManager
        fd_manager = FutureDirectionsManager(self.workspace)
        recent_domain_quality = fd_manager.get_recent_domain_quality(n=10, memory=self.memory)

        # Merge cycle_analytics quality data for adaptive domain weighting
        try:
            from cycle_analytics import CycleAnalytics
            ca = CycleAnalytics(self.workspace)
            domain_stats = ca.get_domain_stats()
            for domain, stats in domain_stats.items():
                if stats.get("avg_quality", 0) > 0:
                    # Blend analytics quality with memory quality
                    # Analytics gets 50% weight if both exist, 100% if only analytics
                    if domain in recent_domain_quality:
                        recent_domain_quality[domain] = 0.5 * recent_domain_quality[domain] + 0.5 * stats["avg_quality"]
                    else:
                        recent_domain_quality[domain] = stats["avg_quality"]
        except Exception:
            pass  # cycle_analytics not available, use memory-only quality

        # Try domain-filtered selection first, fall back to any available
        # Skip directions whose title matches an already-inflight concept to prevent duplicate dispatch
        if forced_direction:
            best_dir = forced_direction
        else:
            effective_filter = domain_filter or loop_result['domain']
            best_dir = fd_manager.select_direction_weighted(domain_filter=effective_filter, recent_domain_quality=recent_domain_quality, catalog_analyzer=self.catalog_analyzer, exclude_domains=exclude_domains, exclude_titles=inflight_concepts)
            if not best_dir:
                best_dir = fd_manager.select_direction_weighted(recent_domain_quality=recent_domain_quality, catalog_analyzer=self.catalog_analyzer, exclude_domains=exclude_domains, exclude_titles=inflight_concepts)

        thread_id = None
        cycle_index = 0
        if best_dir:
            fd_manager.mark_direction_consumed(best_dir.id, job_id)
            source_exp_ids = fd_manager.get_source_exp_ids_for(job_id)
            print(f"[Discover] Using future direction: {best_dir.title} (source={best_dir.source_exp_id})")

            # Link to an active research thread, or start a new one.
            if best_dir.thread_id:
                existing_thread = self.thread_manager.get_thread(best_dir.thread_id)
                if existing_thread and existing_thread.status == "active":
                    thread_id = existing_thread.thread_id
                    cycle_index = len(existing_thread.cycles)
                    print(f"[Discover] Continuing thread {thread_id} (cycle {cycle_index})")
                else:
                    # Thread is no longer active; treat this direction as ordinary.
                    best_dir.thread_id = ""
            else:
                new_thread = self.thread_manager.start_thread(best_dir.id, job_id, concept_title=best_dir.title)
                thread_id = new_thread.thread_id
                cycle_index = 0

            # Use the Aristotle loop's domain, not the direction's domains[0].
            # The direction provides the concept idea; the loop provides the domain target.
            # This prevents Pythagorean (56% of directions' domains[0]) from dominating dispatch.
            loop_domain = loop_result['domain']

            # Cost-aware direction weighting: adjust breakthrough potential by domain cost
            # High-cost domains get slightly reduced weight (0.8x max penalty)
            # Low-cost domains get slight boost (1.2x)
            cost_score = self.insight_extractor.get_cost_estimate(normalize_domain(loop_domain))
            cost_factor = 1.2 - cost_score * 0.4  # ranges from 0.8 (expensive) to 1.2 (cheap)
            adjusted_breakthrough = best_dir.priority_score * cost_factor

            concept = ResearchConcept(
                title=best_dir.title,
                domain=normalize_domain(loop_domain),
                concept_description=best_dir.description,
                mathematical_framing=best_dir.description,
                lean_guess=best_dir.proof_strategy or "",
                catalog_references=best_dir.catalog_references or [],
                research_mode=best_dir.research_mode or "prove",
                novelty_estimate=min(1.0, max(best_dir.priority_score, fd_manager._compute_quality_score(best_dir))),
                breakthrough_potential=adjusted_breakthrough,
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

        # For continuing threads, record the new cycle's concept title now.
        # The Lean result will be backfilled by _update_thread_after_job.
        if thread_id and cycle_index > 0:
            self.thread_manager.append_cycle(
                thread_id, job_id, "", concept_title=concept.title
            )

        if hasattr(self, 'locked_titles') and concept.title:
            self.locked_titles.add(concept.title)

        print(f"[Pi] concept={concept.title}, domain={concept.domain}, "
              f"mode={concept.research_mode}, novelty={concept.novelty_estimate:.2f}")

        job = ResearchJob(
            job_id=job_id,
            cycle_n=cycle_n,
            concept=concept,
            prompt="",
            direction_id=best_dir.id if best_dir else None,
            source_exp_ids=source_exp_ids if source_exp_ids else None,
            thread_id=thread_id,
            cycle_index=cycle_index,
            github_issue=getattr(best_dir, 'github_issue', 0) if best_dir else 0,
        )
        job.decomposition_depth = getattr(best_dir, 'decomposition_depth', 0) if best_dir else 0
        job.direction_id = best_dir.id if best_dir else None
        return job

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
            if hasattr(self, 'locked_titles') and job.concept:
                self.locked_titles.discard(job.concept.title)
            return job

        # Pre-register in inflight to avoid race conditions during the network call
        job.status = "preparing"
        job.preparing_started = time.time()
        self.inflight[job.job_id] = job
        self._save_inflight()

        # Dispatch to Aristotle
        try:
            project_id = asyncio.run(self._dispatch_to_aristotle(job))
            self.inflight.pop(job.job_id, None)
            if hasattr(self, 'locked_titles') and job.concept:
                self.locked_titles.discard(job.concept.title)

            job.project_id = project_id
            job.status = "dispatched"
            job.dispatch_time = time.time()
            self.inflight[project_id] = job
            self._save_inflight()
            print(f"[Dispatch] Aristotle project: {project_id}")
        except RuntimeError as e:
            self.inflight.pop(job.job_id, None)
            if hasattr(self, 'locked_titles') and job.concept:
                self.locked_titles.discard(job.concept.title)
            self._save_inflight()
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
            self.inflight.pop(job.job_id, None)
            self._save_inflight()
            if self._is_queue_full_error(e):
                job.status = "dispatch_queued"
                job.error_message = f"Queue full: {e}"
                print(f"[Dispatch] QUEUE FULL: {e}")
            else:
                if hasattr(self, 'locked_titles') and job.concept:
                    self.locked_titles.discard(job.concept.title)
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
            if hasattr(self, 'locked_titles') and job.concept:
                self.locked_titles.discard(job.concept.title)
            return job

        # Pre-register in inflight to avoid race conditions during the network call
        job.status = "preparing"
        job.preparing_started = time.time()
        self.inflight[job.job_id] = job
        self._save_inflight()

        # Dispatch to Aristotle (we're already in an async context, just await)
        try:
            project_id = await self._dispatch_to_aristotle(job)
            self.inflight.pop(job.job_id, None)
            if hasattr(self, 'locked_titles') and job.concept:
                self.locked_titles.discard(job.concept.title)

            job.project_id = project_id
            job.status = "dispatched"
            job.dispatch_time = time.time()
            self.inflight[project_id] = job
            self._save_inflight()
            print(f"[Dispatch] Aristotle project: {project_id}")
            # Capture reasoning log: submission event
            try:
                from reasoning_log import ReasoningLog
                rlog = ReasoningLog(self.workspace, project_id, job.job_id)
                rlog.record_submission(
                    prompt=job.prompt or "",
                    domain=job.concept.domain if job.concept else "",
                )
            except Exception as e:
                pass  # Don't break dispatch on log errors
        except Exception as e:
            self.inflight.pop(job.job_id, None)
            self._save_inflight()
            if self._is_queue_full_error(e):
                # Leave the job in a recoverable state so the caller can release
                # the direction back to available and retry later.
                job.status = "dispatch_queued"
                job.error_message = f"Queue full: {e}"
                print(f"[Dispatch] QUEUE FULL: {e}")
            else:
                if hasattr(self, 'locked_titles') and job.concept:
                    self.locked_titles.discard(job.concept.title)
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

        # Phase A prompt version selection. v15 is the stable baseline.
        # Weights can be overridden via config (pi_agent.phase_a_prompt_weights)
        # or environment variable AETHER_PHASE_A_PROMPT_WEIGHTS as JSON.
        prompt_weights = DEFAULT_PHASE_A_PROMPT_WEIGHTS.copy()
        config_weights = self.config.get("pi_agent", {}).get("phase_a_prompt_weights")
        if config_weights and isinstance(config_weights, dict):
            prompt_weights.update(config_weights)
        env_weights = os.environ.get("AETHER_PHASE_A_PROMPT_WEIGHTS")
        if env_weights:
            try:
                prompt_weights.update(json.loads(env_weights))
            except Exception as e:
                print(f"[Dispatch] Ignoring invalid AETHER_PHASE_A_PROMPT_WEIGHTS: {e}")
        phase_a_version = select_phase_a_prompt_version(prompt_weights)
        job.prompt_version = phase_a_version  # legacy field
        job.phase = "A"  # Two-phase: this is Phase A (math)
        job.phase_a_prompt_version = phase_a_version
        print(f"[Dispatch] Phase A prompt version: {phase_a_version}")
        # Default to Phase A lean-only prompt; full A_full is legacy
        phase_arg = "A_lean_only"
        # Build the prompt with the chosen version
        base_prompt = self.pi_agent.write_aristotle_prompt(
            concept=job.concept,
            catalog_references=refs,
            catalog_context=catalog_context,
            recent_successes=[{'concept_title': r.concept_title, 'domain': r.domain, 'quality': r.proof_quality} for r in self.memory._cache[-3:]],
            theorem_context=theorem_context,
            insight_extractor=self.insight_extractor,
            research_journal=self.research_journal if hasattr(self, 'research_journal') else None,
            prompt_version=job.phase_a_prompt_version,
            phase=phase_arg,
        )

        # For continuing research threads, append cumulative context.
        if job.thread_id and job.cycle_index > 0:
            thread_context = self._build_thread_context(job)
            if thread_context:
                base_prompt += "\n\n" + thread_context

        # Optional computational evidence stage
        if self.config.get("features", {}).get("enable_computational_stage", False):
            base_prompt = self.computational_stage.augment_prompt(base_prompt)

        # AUGMENT the prompt to explicitly request ALL deliverables
        # For Phase A (lean_only), the prompt already excludes packaging —
        # the augmentation is skipped because the prompt is intentionally narrow.
        # For A_full (legacy), the augmentation adds the full deliverable list.
        if phase_arg == "A_lean_only":
            job.prompt = base_prompt
        else:
            job.prompt = self._augment_prompt_with_deliverables(base_prompt, job.concept)

        print(f"[Dispatch] prompt length: {len(job.prompt)} chars ({job.prompt_version})")

        if dry_run:
            print(f"[Dry Run] Would dispatch to Aristotle:")
            print(f"  Concept: {job.concept.title}")
            print(f"  Domain: {job.concept.domain}")
            print(f"  Mode: {job.concept.research_mode}")
            print(f"  Phase: {phase_arg}")
            print(f"  Prompt preview: {job.prompt[:300]}...")
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

    def _build_thread_context(self, job: ResearchJob) -> str:
        """Build a cumulative context section for a continuing research thread."""
        if not job.thread_id:
            return ""
        thread = self.thread_manager.get_thread(job.thread_id)
        if not thread:
            return ""

        lines = [
            "## Research Thread Context",
            f"Thread: {thread.thread_id} | Cycle: {job.cycle_index}",
            f"Root direction: {thread.root_direction_id}",
            "",
            "Previous cycles (do not repeat these results; build on them):",
        ]
        # Show cycles before the current one
        for idx in range(min(job.cycle_index, len(thread.cycles))):
            title = thread.cycle_concepts[idx] if idx < len(thread.cycle_concepts) else ""
            score = thread.cycle_quality_scores[idx] if idx < len(thread.cycle_quality_scores) else 0.0
            jid = thread.cycles[idx]
            lines.append(f"  Cycle {idx}: {title} (job {jid[:8]}, Q={score:.2f})")
            # Include a sample of identifiers proved in that cycle
            idents = thread.cycle_idents[idx] if idx < len(thread.cycle_idents) else []
            if idents:
                lines.append(f"    New identifiers: {', '.join(idents[:10])}")

        lines.append("")
        lines.append(
            "Your task is the next step of this research thread. "
            "Advance the inquiry with a new theorem, lemma, definition, or counterexample. "
            "If the previous cycles reveal an obstacle, pivot to a closely related but fresh angle."
        )
        return "\n".join(lines)

    def _build_project_dir(self, job: ResearchJob) -> Optional[Path]:
        """Build a project directory for Aristotle with the full Lean Catalog.

        Copies every .lean file from the Catalog into the project directory,
        preserving the domain subdirectory structure (Algebra/, Tropical/, etc.).
        This gives Aristotle maximum context to build on existing verified theorems.
        """
        suffix = f"_retry{job.retry_count}" if getattr(job, "retry_count", 0) > 0 else ""
        dir_path = self.workspace / f"projects/{job.job_id}{suffix}"
        if dir_path.exists():
            shutil.rmtree(dir_path)
        dir_path.mkdir(parents=True, exist_ok=True)


        # Determine files to copy: Phase B gets a pruned workspace of only Phase A outputs, Phase A gets full catalog
        is_phase_b = getattr(job, 'phase', '') == 'B'
        files_to_copy = []
        if is_phase_b:
            phase_a_files = []
            if hasattr(job, 'phase_a_result') and job.phase_a_result:
                phase_a_files = job.phase_a_result.get("lean_files", [])
            for fpath in phase_a_files:
                p = Path(fpath)
                if not p.is_absolute():
                    # integrated_paths are relative to repo root (e.g., "Catalog/Algebra/Foo.lean")
                    p = self.catalog_root.parent / p
                if p.exists():
                    files_to_copy.append(p)
            print(f"[Project] Phase B detected: pruning workspace to {len(files_to_copy)} files from Phase A")

            # Fallback if no files resolved
            if not files_to_copy:
                print("[Project] Warning: Phase B has no files in phase_a_result['lean_files']. Falling back to full catalog.")
                for src_file in self.catalog_root.rglob("*.lean"):
                    if ".lake" in src_file.parts or "FINAL" in src_file.parts:
                        continue
                    if src_file.is_symlink() and not src_file.resolve().exists():
                        continue
                    files_to_copy.append(src_file)
        else:
            # Phase A: send the full Catalog of .lean files as context so
            # Aristotle can build on every existing verified theorem.
            for src_file in self.catalog_root.rglob("*.lean"):
                if ".lake" in src_file.parts or "FINAL" in src_file.parts:
                    continue
                if src_file.is_symlink() and not src_file.resolve().exists():
                    continue
                files_to_copy.append(src_file)

        catalog_dst = dir_path / "Catalog"
        lean_count = 0
        for src_file in files_to_copy:
            # Resolve symlinks — copy the real file content
            real_src = src_file.resolve() if src_file.is_symlink() else src_file
            try:
                rel = src_file.relative_to(self.catalog_root)
            except ValueError:
                rel = Path(src_file.name)
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

        # Create empty .lake folders to silence the SDK dependency warnings
        (dir_path / ".lake").mkdir(exist_ok=True)
        (catalog_dst / ".lake").mkdir(exist_ok=True)

        print(f"[Project] Copied {lean_count} .lean files and project configs from Catalog")

        # Write the prompt as a README for context
        (dir_path / "PROMPT.md").write_text(job.prompt)

        return dir_path


    def _is_queue_full_error(self, error: Exception) -> bool:
        """Return True if the error indicates Aristotle's queue is full."""
        err_str = str(error).lower()
        return any(kw in err_str for kw in [
            "too many requests in progress",
            "too many requests",
            "rate limit",
            "429",
            "queue is full",
        ])

    async def _dispatch_to_aristotle(self, job: ResearchJob, max_retries: int = 2) -> str:
        """Dispatch the job to Aristotle with retry on transient failures.

        Queue-full errors are reported immediately without burning retries,
        so the caller can requeue the job and wait for capacity. Other transient
        errors still retry with escalating backoff.
        """
        import aristotlelib.api_request as api_mod
        from aristotlelib import Project

        # Temporarily increase timeout for the upload (default 30s is too short)
        original_timeout = api_mod.DEFAULT_TIMEOUT_SECONDS
        api_mod.DEFAULT_TIMEOUT_SECONDS = 300  # 5 minutes

        # Strip .lake build-cache dirs from the project before upload — they are
        # not source and must not be sent to Aristotle (the Catalog .lake alone
        # is ~600 MB; even per-project .lake dirs add dead weight to the tarball).
        try:
            for lake_dir in Path(job.project_dir).rglob(".lake"):
                if lake_dir.is_dir():
                    shutil.rmtree(lake_dir, ignore_errors=True)
        except Exception:
            pass

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
                    if self._is_queue_full_error(e):
                        # Don't burn retries or sleep here; let the caller requeue.
                        raise
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
        """Poll all in-flight jobs and return completed ones.

        Also captures reasoning log checkpoints for each project: status,
        percent_complete, and elapsed time. Saved to .aether_workspace/
        reasoning_logs/{job_id}.json for later analysis.
        """
        from reasoning_log import ReasoningLog

        # Stall / timeout configuration — WALL-CLOCK based. Checkpoint elapsed
        # is unreliable: it freezes when Aristotle stops emitting checkpoints,
        # leaving zombie jobs that never hit a checkpoint-based cap. dispatch_time
        # age is the authoritative signal and covers no-checkpoint jobs too.
        stall_cfg = self.config.get("stall", {}) if hasattr(self, "config") and self.config else {}
        max_cycle_seconds = stall_cfg.get("hard_cap_seconds", 24 * 3600)       # 24h wall-clock cap
        preparing_timeout = stall_cfg.get("preparing_timeout_seconds", 1800)   # 30min in preparing
        warn_seconds = stall_cfg.get("warn_seconds", 5400)                     # 90min warn
        # No-progress zombie cap (seconds). A dispatched job whose last
        # Aristotle reasoning checkpoint is older than this has hung
        # server-side. Set > the healthy checkpoint gap (observed ~44min) so
        # legitimately-progressing jobs aren't killed. Default 60min.
        no_progress_seconds = stall_cfg.get("no_progress_seconds", 3600)

        completed = []
        now = time.time()
        for pid, job in list(self.inflight.items()):
            if job.status in ("completed", "failed", "integrated", "rejected"):
                continue

            # Preparing timeout: a job still in 'preparing' past the bound was
            # never submitted to Aristotle (e.g. process killed mid-dispatch).
            # Release its direction and fail it so the slot frees up.
            if job.status == "preparing" and job.preparing_started:
                p_age = now - job.preparing_started
                if p_age > preparing_timeout:
                    print(f"[Poll] {pid[:8]} PREPARING TIMEOUT: stuck for {p_age/60:.0f}min, failing")
                    job.status = "failed"
                    job.error_message = f"Stuck in preparing > {p_age/60:.0f}min"
                    self.failed_count += 1
                    self._release_direction(job)
                    completed.append(job)
                    continue

            # Wall-clock hard cap — the authoritative kill signal. Runs FIRST so
            # a job over the hard cap is quarantined (presumed a bad concept)
            # rather than soft-released by the no-progress cap below. Covers jobs
            # with no reasoning checkpoints (the checkpoint branch can't see those).
            if job.dispatch_time and (now - job.dispatch_time) > max_cycle_seconds:
                age_min = (now - job.dispatch_time) / 60
                print(f"[Poll] {pid[:8]} HARD CAP: {age_min:.0f}min wall-clock, "
                      f"failing ({max_cycle_seconds/3600:.0f}h cap)")
                job.status = "failed"
                job.error_message = (f"Cancelled after {age_min:.0f}min "
                                     f"({max_cycle_seconds/3600:.0f}h wall-clock cap)")
                self.failed_count += 1
                self._quarantine_direction_for_job(job, days=7)
                try:
                    rlog = ReasoningLog(self.workspace, pid, job.job_id)
                    rlog.record_completion(
                        status="TIMEOUT", percent=0, has_files=False,
                        error=job.error_message,
                    )
                except Exception:
                    pass
                completed.append(job)
                continue

            # No-progress zombie cap: a dispatched job that HAD reasoning
            # checkpoints then went silent for > `no_progress_seconds` has hung
            # server-side. Aristotle exposes no project-cancel API (POST
            # /project/{id}/cancel -> 404, DELETE /project/{id} -> 405), so the
            # dead project lingers remotely — but we free the local slot and
            # return the direction to available so a fresh dispatch can retry
            # it, instead of pinning max_inflight on a dead project forever.
            # Only fires when checkpoints exist (a never-checkpointed job is
            # left to the hard cap / preparing timeout — it may just be slow to
            # emit its first checkpoint). Distinct from the hard cap: a
            # no-progress hang is presumed a server glitch, not a bad concept.
            if job.status == "dispatched" and job.dispatch_time:
                _last_progress = None
                try:
                    _rlog = ReasoningLog(self.workspace, pid, job.job_id)
                    _cps = _rlog._data.get("checkpoints", [])
                    if _cps:
                        _ts = _cps[-1].get("timestamp")
                        if _ts:
                            _dt = datetime.fromisoformat(_ts)
                            if _dt.tzinfo is None:
                                _dt = _dt.replace(tzinfo=timezone.utc)
                            _last_progress = _dt.timestamp()
                except Exception:
                    pass
                if _last_progress is not None and (now - _last_progress) > no_progress_seconds:
                    _idle_min = (now - _last_progress) / 60
                    print(f"[Poll] {pid[:8]} NO-PROGRESS ZOMBIE: idle {_idle_min:.0f}min, "
                          f"releasing direction to available")
                    job.status = "failed"
                    job.error_message = (f"No Aristotle progress for {_idle_min:.0f}min "
                                         f"(no_progress cap)")
                    self.failed_count += 1
                    self._release_direction_back_to_available(job)
                    try:
                        ReasoningLog(self.workspace, pid, job.job_id).record_completion(
                            status="ZOMBIE", percent=0, has_files=False,
                            error=job.error_message,
                        )
                    except Exception:
                        pass
                    completed.append(job)
                    continue

            # Wall-clock stall warning (independent of checkpoints).
            if job.status == "dispatched" and job.dispatch_time \
                    and (now - job.dispatch_time) > warn_seconds:
                age_min = (now - job.dispatch_time) / 60
                print(f"[Poll] {pid[:8]} STALL WARNING: RUNNING for {age_min:.0f}min (wall-clock)")

        for pid, job in list(self.inflight.items()):
            # Skip jobs already in terminal status — they were returned in a
            # previous poll and either processed or about to be pruned.
            # Including them again causes duplicate integration.
            if job.status in ("completed", "failed", "integrated", "rejected"):
                continue

            try:
                result = await self.aristotle.poll_project(pid)
                status = result.get("status", "unknown")
                has_files = result.get("has_files", False)
                is_complete = result.get("complete", False)
                percent = result.get("percent_complete", 0) or 0

                # Capture reasoning checkpoint
                try:
                    rlog = ReasoningLog(self.workspace, pid, job.job_id)
                    # Only add a checkpoint if the state has changed
                    last_pct = rlog._data["checkpoints"][-1]["percent_complete"] if rlog._data["checkpoints"] else -1
                    last_status = rlog._data["checkpoints"][-1]["status"] if rlog._data["checkpoints"] else None
                    if percent != last_pct or status != last_status:
                        rlog.add_checkpoint(status=status, percent=percent)
                except Exception:
                    pass  # Don't break polling on log errors

                if is_complete or (status == "IDLE" and has_files):
                    needs_resume = bool(result.get("needs_resume", False))
                    # Content-based gate: COMPLETE jobs (no task-status signal)
                    # can still be truncated (Aristotle finished but the Lean
                    # cuts off mid-proof). Download + check; resume if truncated.
                    if (not needs_resume and job.phase == "A"
                            and getattr(job, "resume_count", 0) < MAX_RESUME_BUDGET
                            and job.project_id):
                        try:
                            if await self._result_looks_truncated(pid):
                                needs_resume = True
                                print(f"[Poll] {pid[:8]} COMPLETE but content truncated "
                                      f"— will resume via ask()")
                        except Exception:
                            pass
                    # Resume incomplete Phase A jobs (OUT_OF_BUDGET or
                    # COMPLETE_WITH_ERRORS — truncated/non-compiling Lean) by
                    # asking Aristotle to continue, instead of integrating a
                    # partial result. The project re-enters RUNNING; re-poll
                    # next tick.
                    if (needs_resume and job.phase == "A"
                            and getattr(job, "resume_count", 0) < MAX_RESUME_BUDGET):
                        try:
                            _resume_prompt = (
                                "Continue and complete the truncated/incomplete work. "
                                "Finish every theorem with a full proof — no `sorry`, "
                                "no stubbed signatures, no mid-proof cutoffs. Complete "
                                "all Lean 4 files so they compile end-to-end, then "
                                "finalize FUTURE_DIRECTIONS.md."
                            )
                            _tid = await self.aristotle.resume_project(pid, _resume_prompt)
                            job.resume_count = getattr(job, "resume_count", 0) + 1
                            job.status = "dispatched"  # re-poll for the new task
                            job.dispatch_time = time.time()  # reset wall-clock caps
                            print(f"[Poll] {pid[:8]} INCOMPLETE ({result.get('task_status','?')}) "
                                  f"— resuming via ask() "
                                  f"(attempt {job.resume_count}/{MAX_RESUME_BUDGET}), "
                                  f"new task {_tid[:8]}; deferring integration")
                            continue  # do NOT append to completed; re-poll next tick
                        except Exception as _re:
                            print(f"[Poll] {pid[:8]} resume failed: {_re}; "
                                  f"integrating partial result")
                            # fall through to complete with the partial result
                    print(f"[Poll] {pid[:8]} COMPLETED (status={status}, has_files={has_files})"
                          f"{(' [INCOMPLETE]' if needs_resume else '')}")
                    job.status = "completed"
                    job.complete_time = time.time()
                    # Final reasoning log entry
                    try:
                        rlog = ReasoningLog(self.workspace, pid, job.job_id)
                        rlog.record_completion(
                            status=status, percent=percent, has_files=has_files,
                        )
                    except Exception:
                        pass
                    completed.append(job)
                elif status == "IDLE" and not has_files:
                    print(f"[Poll] {pid[:8]} FAILED (IDLE, no files)")
                    job.status = "failed"
                    job.error_message = "Aristotle status: IDLE with no result files"
                    self.failed_count += 1
                    # Final reasoning log entry
                    try:
                        rlog = ReasoningLog(self.workspace, pid, job.job_id)
                        rlog.record_completion(
                            status="FAILED", percent=percent, has_files=False,
                            error="IDLE with no result files",
                        )
                    except Exception:
                        pass
                    completed.append(job)
                elif status == "RUNNING":
                    # Secondary checkpoint-based stall signal. The authoritative
                    # wall-clock cap is applied above (before polling), so this
                    # branch only emits a diagnostic warning. Aristotle's SDK
                    # doesn't expose percent_complete (always 0), so checkpoint
                    # elapsed is the only signal available here.
                    try:
                        rlog = ReasoningLog(self.workspace, pid, job.job_id)
                        summary = rlog.get_summary()
                        if summary.get("n_checkpoints", 0) >= 2:
                            checkpoints = rlog._data["checkpoints"]
                            elapsed = (checkpoints[-1]["elapsed_seconds"]
                                       - checkpoints[0]["elapsed_seconds"])
                            if elapsed > 5400:  # 90 minutes of checkpoint time
                                print(f"[Poll] {pid[:8]} STALL WARNING: RUNNING for {elapsed/60:.0f}min (checkpoint)")
                    except Exception:
                        pass
                    print(f"[Poll] {pid[:8]} in progress (RUNNING, {percent:.0f}%)")
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
                # Check for error markers from download_result
                if tar_path and tar_path.name in ("__AUTH_ERROR__", "__SERVER_ERROR__", "__NOT_FOUND__"):
                    reasons = {"__AUTH_ERROR__": "authentication error (403/401)",
                               "__SERVER_ERROR__": "server error (500) — project may have been garbage-collected",
                               "__NOT_FOUND__": "project not found (404)"}
                    job.error_message = f"Result download failed: {reasons[tar_path.name]}"
                    job.status = "failed"
                    return job
                if not tar_path or not tar_path.exists():
                    # Retry once: Aristotle sometimes reports has_files=True
                    # but the download fails on first try
                    print(f"[Extract] First download attempt failed for {job.project_id[:8]}, retrying...")
                    time.sleep(5)
                    tar_path = asyncio.get_event_loop().run_until_complete(
                        self.aristotle.download_result(job.project_id, Path(tmpdir))
                    )
                if tar_path and tar_path.name in ("__AUTH_ERROR__", "__SERVER_ERROR__", "__NOT_FOUND__"):
                    reasons = {"__AUTH_ERROR__": "authentication error (403/401)",
                               "__SERVER_ERROR__": "server error (500) — project may have been garbage-collected",
                               "__NOT_FOUND__": "project not found (404)"}
                    job.error_message = f"Result download failed: {reasons[tar_path.name]}"
                    job.status = "failed"
                    return job
                if not tar_path or not tar_path.exists():
                    job.error_message = "Result download failed (2 attempts)"
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
                # Check for error markers from download_result
                if tar_path and tar_path.name in ("__AUTH_ERROR__", "__SERVER_ERROR__", "__NOT_FOUND__"):
                    reasons = {"__AUTH_ERROR__": "authentication error (403/401)",
                               "__SERVER_ERROR__": "server error (500) — project may have been garbage-collected",
                               "__NOT_FOUND__": "project not found (404)"}
                    job.error_message = f"Result download failed: {reasons[tar_path.name]}"
                    job.status = "failed"
                    return job
                if not tar_path or not tar_path.exists():
                    # Retry once: Aristotle sometimes reports has_files=True
                    # but the download fails on first try
                    print(f"[Extract] First download attempt failed for {job.project_id[:8]}, retrying...")
                    await asyncio.sleep(5)
                    tar_path = await self.aristotle.download_result(job.project_id, Path(tmpdir))
                if tar_path and tar_path.name in ("__AUTH_ERROR__", "__SERVER_ERROR__", "__NOT_FOUND__"):
                    reasons = {"__AUTH_ERROR__": "authentication error (403/401)",
                               "__SERVER_ERROR__": "server error (500) — project may have been garbage-collected",
                               "__NOT_FOUND__": "project not found (404)"}
                    job.error_message = f"Result download failed: {reasons[tar_path.name]}"
                    job.status = "failed"
                    return job
                if not tar_path or not tar_path.exists():
                    job.error_message = "Result download failed (2 attempts)"
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

    async def _result_looks_truncated(self, project_id: str) -> bool:
        """Download a project's result and check whether the Lean content is
        truncated/incomplete — used to resume COMPLETE-but-truncated Phase A
        jobs that slip past the task-status gate (OUT_OF_BUDGET /
        COMPLETE_WITH_ERRORS). Signals: any `sorry`, an unclosed comment
        block, or a declaration line cut off before its proof body.
        """
        import tempfile, tarfile
        try:
            with tempfile.TemporaryDirectory() as tmp:
                tar_path = await self.aristotle.download_result(project_id, Path(tmp))
                if (not tar_path or not tar_path.exists()
                        or tar_path.name in ("__AUTH_ERROR__", "__SERVER_ERROR__", "__NOT_FOUND__")):
                    return False
                ed = Path(tmp) / "ex"
                with tarfile.open(tar_path, "r:gz") as tar:
                    tar.extractall(ed)
                leans = []
                for f in ed.rglob("*.lean"):
                    if ".lake" in f.parts:
                        continue
                    try:
                        leans.append(f.read_text(encoding="utf-8", errors="ignore"))
                    except Exception:
                        pass
                content = "\n".join(leans)
                if not content.strip():
                    return False
                if re.findall(r'\bsorry\b', content):
                    return True
                if content.count("/-") > content.count("-/"):
                    return True
                lines = [l for l in content.splitlines() if l.strip()]
                if lines:
                    last = lines[-1].strip()
                    if (re.match(r'^(theorem|lemma|def|structure|instance|abbrev)\b', last)
                            and ':=' not in last and 'sorry' not in last
                            and not last.endswith(('.', ':'))):
                        return True
                return False
        except Exception:
            return False

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
                        # also retry dirs: 47bf2ccd_retry2_aristotle/Bridges/file.lean
                        clean_parts = []
                        for p in rel.parts:
                            if re.match(r'^[0-9a-f]+(_retry[0-9]+)?_aristotle$', p):
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

        # Count sorries and theorems across all Lean output.
        # Use regex on top-level `theorem`/`lemma` declarations only.
        # Naive `.count("theorem ")` inflated counts by 5-10x because it caught
        # doc-comments, string literals, and nested lemmas inside def bodies.
        # (re is imported at module level — no local re-import here to avoid
        # shadowing the module-level re used elsewhere in this function.)
        if job.result_lean:
            job.sorry_count = len(re.findall(r'\bsorry\b', job.result_lean))
            # Match `theorem name`, `lemma name`, `example :` at start of line
            # (zero indentation, allowing tabs/spaces at the file's top level).
            # Excludes nested declarations inside def/class bodies.
            theorem_pattern = re.compile(r'^(?:theorem|lemma|nonrec theorem|protected theorem|private theorem|example)\s+\w', re.MULTILINE)
            matches = theorem_pattern.findall(job.result_lean)
            job.theorem_count = len(matches)

        print(f"[Extract] Lean: {len(lean_files)} files, Python: {len(python_files)} files, "
              f"Papers: {len(paper_files)} files, "
              f"Article: {len(article_files)} files, "
              f"ResearchPaper: {len(research_paper_files)} files, "
              f"JSON: {len(json_package_files)} files, "
              f"FUTURE_DIRECTIONS: {len(future_directions_files)} files, "
              f"Discussion: {len(discussion_files)} files, "
              f"Sorries: {job.sorry_count}, Theorems: {job.theorem_count}")

        # Theorem-level novelty classification
        if job.result_lean and hasattr(self, "catalog_root") and self.catalog_root:
            novelty = self._classify_theorem_novelty(job.result_lean, lean_files)
            job.theorem_novelty = novelty
            print(f"[Novelty] Theorems: {novelty.get('new', 0)} new, "
                  f"{novelty.get('strengthening', 0)} strengthening, "
                  f"{novelty.get('duplicate', 0)} duplicate, "
                  f"{novelty.get('disproof', 0)} disproof, "
                  f"{novelty.get('unknown', 0)} unknown")

        # Persist extraction results to inflight_jobs
        if job.project_id and job.project_id in self.inflight:
            self.inflight[job.project_id] = job
            self._save_inflight()

        return job

    def _classify_theorem_novelty(self, result_lean: str, lean_files: List[str]) -> Dict[str, int]:
        """Classify each theorem in result_lean.

        Novelty/duplicate detection against the catalog was removed: the SQLite
        theorem index corrupted on SIGTERM mid-rebuild and produced a 142MB file
        that blocked pushes, and the per-theorem file-scan fallback was too slow
        on a large catalog. Every theorem now counts as "new"; disproofs are
        still detected by keyword. The dict shape is preserved so downstream
        callers ([Novelty] metrics, quality scoring) keep working — the novelty
        input simply no longer differentiates duplicate vs genuinely-new work.
        """
        import re as _re
        counts = {"new": 0, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}
        theorem_decl_pattern = _re.compile(
            r"^(?:theorem|lemma|nonrec theorem|protected theorem|private theorem|example)\s+(\w+)",
            _re.MULTILINE,
        )
        for m in theorem_decl_pattern.finditer(result_lean):
            start = m.end()
            statement = result_lean[start:start + 400].strip()
            lower_stmt = statement.lower()
            is_disproof = any(
                kw in lower_stmt for kw in ("not exists", "no such", "false", "disprove", "counterexample")
            )
            if is_disproof:
                counts["disproof"] += 1
            else:
                counts["new"] += 1
        return counts

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

        # Shared config for LLM-reduction levers (Phases 1-4).
        _red_cfg = self.config.get("llm_reduction", {}) if hasattr(self, "config") and self.config else {}

        # Phase 3 (Lever B): content-hash eval cache. If we've already
        # evaluated identical (content + concept + prompt_version) content,
        # restore the cached result and skip the LLM eval + critic entirely.
        # Safe because the eval is deterministic given those inputs (novelty
        # is computed in extract(), before eval). Disable via llm_reduction.eval_cache="off".
        _ec = None
        _ec_key = None
        if _red_cfg.get("eval_cache", "on") == "on":
            try:
                from eval_cache import EvalCache
                _ec = EvalCache(self.workspace)
                _ec_key = _ec.key_for(job.result_lean, job.concept,
                                      getattr(job, "prompt_version", None))
                _cached = _ec.get(_ec_key)
                if _cached is not None:
                    job.quality_score = float(_cached.get("quality_score", 0.0))
                    job.quality_assessment = _cached.get("quality_assessment", {})
                    job.adversarial_result = _cached.get("adversarial_result")
                    _qd = _cached.get("quality_detail")
                    if _qd:
                        try:
                            from quality_evaluator import QualityScore
                            job.quality_detail = QualityScore.from_dict(_qd)
                        except Exception:
                            job.quality_detail = None
                    if self.pi_agent is not None:
                        self.pi_agent.record_llm_skip("eval")
                        self.pi_agent.record_llm_skip("critic")
                    print(f"[Cache] eval hit (hash={_ec_key[:8]}) for {job.job_id[:8]} "
                          f"-> score={job.quality_score:.3f}")
                    return job
            except Exception as _e:
                print(f"[Cache] eval cache read failed: {_e}")

        # Compact oversized result_lean before passing to evaluation
        compact_lean = self._compact_result_lean(job.result_lean)

        # Pi-Agent: THE BRAINS — evaluates quality.
        # (The count-based static quality gate was removed for v1.0 — it was
        # proven non-viable; see Aether/CLAUDE.md "LLM Usage Reduction".)
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
            theorem_novelty_new=job.theorem_novelty.get("new", 0) if job.theorem_novelty else 0,
            theorem_novelty_strengthening=job.theorem_novelty.get("strengthening", 0) if job.theorem_novelty else 0,
            theorem_novelty_duplicate=job.theorem_novelty.get("duplicate", 0) if job.theorem_novelty else 0,
            theorem_novelty_disproof=job.theorem_novelty.get("disproof", 0) if job.theorem_novelty else 0,
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
                phase=getattr(job, 'phase', 'A'),
            )
            job.quality_detail = qscore
            # Blend heuristic and structural scores using direction-driven weights
            concept_domains = getattr(job.concept, 'domains', []) if job.concept else []
            composite = qscore.composite_with_domains(domains=concept_domains) if hasattr(qscore, 'composite_with_domains') else qscore.composite
            job.quality_score = 0.3 * heuristic_score + 0.7 * composite

            # ── Adversarial quality judging ──
            # Second LLM evaluates as a skeptical critic; if they disagree,
            # a third tiebreaker adjudicates.
            if self.pi_agent and hasattr(qeval, 'adversarial_evaluate'):
                # Phase 2 (Lever E): critic skip-gate. When the structural
                # composite is decisive (>0.85 clearly good, <0.15 clearly
                # bad) the adversarial critic is unlikely to change the
                # outcome, so skip it. Modes: shadow (default) / enabled / off.
                _critic_gate = _red_cfg.get("critic_gate", "shadow")
                _critic_decisive = (composite > 0.85) or (composite < 0.15)
                adversarial_result = None
                if _critic_gate == "enabled" and _critic_decisive:
                    if self.pi_agent is not None:
                        self.pi_agent.record_llm_skip("critic")
                    print(f"[Gate] critic skipped (composite={composite:.3f} decisive) "
                          f"for {job.job_id[:8]}")
                else:
                    try:
                        adversarial_result = qeval.adversarial_evaluate(
                            lean_source=compact_lean,
                            concept_title=job.concept.title,
                            concept_description=job.concept.concept_description,
                            primary_score=qscore,
                            disagreement_threshold=0.2,
                            domains=concept_domains,
                        )
                        adj_score = adversarial_result.get("adjudicated_score", composite)
                        agreement = adversarial_result.get("agreement", "unknown")
                        adv_composite = adversarial_result.get("adversarial_composite")
                        delta = adversarial_result.get("delta", 0.0)

                        if agreement == "agree":
                            # Judges agree — blend adjudicated score with heuristic
                            job.quality_score = 0.3 * heuristic_score + 0.7 * adj_score
                        elif agreement in ("tiebreak", "disagree"):
                            # Disagreement resolved — but cap the adversarial override.
                            # When the structural composite is 0.7+ but the adversarial
                            # judge scores 0.1, a delta of 0.6 is too extreme.  Limit the
                            # adjudicated score to no less than composite * 0.5 so the
                            # final blend stays reasonable.
                            floor = composite * 0.5
                            adj_score = max(adj_score, floor)
                            job.quality_score = 0.2 * heuristic_score + 0.8 * adj_score

                        # Store adversarial metadata
                        job.adversarial_result = adversarial_result
                        primary_val = adversarial_result.get("primary_composite", composite)
                        primary_str = f"{primary_val:.3f}" if primary_val is not None else "?"
                        critic_str = f"{adv_composite:.3f}" if adv_composite is not None else "?"
                        print(f"[Adversarial] {agreement}: primary={primary_str} critic={critic_str} "
                              f"adjudicated={adj_score:.3f} delta={delta:.3f}")
                        if _critic_gate == "shadow" and _critic_decisive:
                            print(f"[Gate] critic shadow: composite={composite:.3f} "
                                  f"agreement={agreement} for {job.job_id[:8]}")
                    except Exception as ae:
                        print(f"[Adversarial] Failed (using primary only): {ae}")
        except Exception as e:
            print(f"[Evaluate] Warning: QualityEvaluator failed, using heuristic only: {e}")
            job.quality_score = heuristic_score

        # Log should_retry flag for monitoring, but don't cap score —
        # the quality evaluator already factors partiality into its score.
        if qa.get("should_retry"):
            print(f"[Evaluate] should_retry=true (quality={qa.get('quality','?')}), score={job.quality_score:.3f} — keeping computed score")

        if self.pi_agent and hasattr(self.pi_agent, '_log_pi_agent_eval'):
            self.pi_agent._log_pi_agent_eval(
                job_id=job.job_id,
                score=job.quality_score,
                grade=qa.get("quality", "?"),
                rationale=qa
            )
        else:
            print(f"[Evaluate] quality={qa.get('quality','?')}, score={job.quality_score:.3f}, "
                  f"sorries={job.sorry_count}, theorems={job.theorem_count}"
                  + (f", depth={job.quality_detail.proof_depth:.2f}" if hasattr(job, 'quality_detail') and job.quality_detail else ""))

        # v8-v15 output quality metrics: track research team protocol compliance
        phase_ver = getattr(job, 'phase_a_prompt_version', '')
        if phase_ver in ('v8', 'v9', 'v10', 'v11', 'v12', 'v13', 'v14', 'v15') and job.result_lean:
            import re as _re
            lean_content = job.result_lean
            lab_notebook_count = lean_content.count("Lab Notebook") + lean_content.count("Lab Notes")
            hypothesis_count = lean_content.lower().count("hypothesis")
            # Track disproved theorems: count theorem declarations with status disproved
            disproved_pattern = _re.compile(r'status.*disproved|disproved.*status', _re.IGNORECASE)
            disproved_theorem_count = len(disproved_pattern.findall(lean_content))
            disproved_keyword_count = lean_content.lower().count("disproved")
            has_synthesis = "## Synthesis" in lean_content
            has_results_summary = "Results Summary" in lean_content or "## Results Summary" in lean_content
            has_if_true = "**If true**" in lean_content or "**If false**" in lean_content
            critic_present = lean_content.lower().count("critic") + lean_content.lower().count("critique")
            # Count Lab Notebook detail fields
            ln_insight = lean_content.count("Insight:")
            ln_failure = lean_content.count("Failure analysis:")
            print(f"[{phase_ver} Metrics] Lab_Notebooks={lab_notebook_count} hypotheses={hypothesis_count} "
                  f"disproved_theorems={disproved_theorem_count} disproved_keywords={disproved_keyword_count} "
                  f"Synthesis={'Y' if has_synthesis else 'N'} "
                  f"Results_Summary={'Y' if has_results_summary else 'N'} "
                  f"If_true={'Y' if has_if_true else 'N'} "
                  f"Critic_refs={critic_present} "
                  f"LN_Insights={ln_insight} LN_Failures={ln_failure}")

        # Persist evaluation results to inflight_jobs
        if job.project_id and job.project_id in self.inflight:
            self.inflight[job.project_id] = job
            self._save_inflight()

        # Optional specialized critics (feature-flagged; default off).
        if self.config.get("features", {}).get("enable_specialized_critics", False):
            try:
                critic = SpecializedCritic(self.pi_agent, timeout=120)
                scores = critic.evaluate(
                    lean_source=compact_lean,
                    concept_title=job.concept.title if job.concept else "",
                    concept_description=job.concept.concept_description if job.concept else "",
                    existing_titles=existing_titles,
                )
                job.specialized_critic_scores = {
                    "correctness": scores.correctness,
                    "novelty": scores.novelty,
                    "depth": scores.depth,
                    "presentation": scores.presentation,
                    "rationale": scores.rationale,
                    "aggregate": scores.aggregate(),
                }
                # Blend with existing heuristic/structural score so the pipeline
                # still benefits from local signal, but specialized critics dominate.
                aggregate = scores.aggregate()
                if aggregate > 0:
                    job.quality_score = 0.3 * job.quality_score + 0.7 * aggregate
                print(f"[SpecializedCritics] correctness={scores.correctness:.2f} novelty={scores.novelty:.2f} "
                      f"depth={scores.depth:.2f} presentation={scores.presentation:.2f} "
                      f"aggregate={aggregate:.2f} final_q={job.quality_score:.3f}")
            except Exception as e:
                print(f"[SpecializedCritics] Warning: failed to run: {e}")

        # Phase 3 (Lever B): store the fully-evaluated result so future cycles
        # with identical content+concept+prompt skip the LLM eval + critic.
        if _ec is not None and _ec_key is not None:
            try:
                _qd = (job.quality_detail.to_dict()
                       if hasattr(job, "quality_detail") and job.quality_detail else None)
                _ec.put(_ec_key, {
                    "quality_score": job.quality_score,
                    "quality_assessment": job.quality_assessment,
                    "adversarial_result": job.adversarial_result,
                    "quality_detail": _qd,
                })
            except Exception:
                pass

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
        - Python demos → Demos/
        - Papers → Papers/
        - Articles → Articles/
        - Research papers → Papers/
        - HTML packages → Packages/
        - Discussion → Articles/
        """
        if job.quality_score < 0.15:
            print(f"[Integrate] REJECTED: score too low ({job.quality_score:.3f})")
            # Quarantine the direction for 30 days — don't retry this one
            self._quarantine_direction_for_job(job, days=30)
            job.status = "rejected"
            return job

        # A_only jobs (Phase B skipped for low quality) don't produce deliverables
        # for human consumption. Skip Catalog integration for their Lean files —
        # only high-quality results (Phase B packaged) deserve a spot in the Catalog.
        is_a_only = getattr(job, 'phase', '') == 'A_only' or getattr(job, 'phase_b_skipped_reason', None)
        if is_a_only and job.quality_score < self._a_only_integration_floor():
            print(f"[Integrate] A_only Q={job.quality_score:.3f} below integration floor — skipping Catalog integration")
            # Still quarantine low-quality directions to avoid wasting compute
            if job.quality_score < 0.3:
                self._quarantine_direction_for_job(job, days=30)
            job.status = "integrated"
            self.completed_count += 1
            return job

        # Quarantine: Q<0.3 means the direction itself is producing near-junk
        # Don't waste compute retrying the same direction for 30 days
        if job.quality_score < 0.3:
            self._quarantine_direction_for_job(job, days=30)

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
            parts.append({"type": "new", "path": f"Demos/{self._derive_artifact_name(job.concept, 'py')}", "content": job.result_demo})
        if job.result_algorithms:
            parts.append({"type": "new", "path": f"Demos/algorithms_{self._derive_artifact_name(job.concept, 'py')}", "content": job.result_algorithms})
        if job.result_paper:
            parts.append({"type": "new", "path": f"Papers/{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_paper})

        # NEW artifact types — integrate into correct Catalog locations
        if job.result_article:
            parts.append({"type": "new", "path": f"Articles/{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_article})
        if job.result_research_paper:
            parts.append({"type": "new", "path": f"Papers/research_{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_research_paper})
        if job.result_json_package:
            # Enrich JSON package with executable module code for Pyodide
            enriched_pkg = job.result_json_package
            if job.result_algorithms or job.result_demo:
                enriched_pkg = self._enrich_json_package(job.result_json_package, job)

            # If sorry_fill research mode, check if there is an existing package JSON that tracks these Lean files
            target_pkg_path = f"Packages/{self._derive_artifact_name(job.concept, 'json')}"
            if job.concept.research_mode == "sorry_fill":
                updated_lean_files = []
                for p in parts:
                    if p["path"].endswith(".lean"):
                        # normalize path
                        fname = p["path"].replace("Catalog/", "")
                        updated_lean_files.append(fname)
                        updated_lean_files.append(fname.split("/")[-1]) # also add basename
                
                # Search Packages directory for a matching package
                pkg_dir = self.catalog_root.parent / "Packages"
                matched_pkg_file = None
                if pkg_dir.exists():
                    for f in pkg_dir.glob("*.json"):
                        if f.name in ("index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json"):
                            continue
                        try:
                            pkg_data = json.loads(f.read_text(encoding="utf-8"))
                            pkg_lean_files = []
                            for lf in pkg_data.get("lean_files", []) or []:
                                pkg_lean_files.append(lf.replace("Catalog/", ""))
                                pkg_lean_files.append(lf.split("/")[-1])
                            lp_field = pkg_data.get("lean_proofs", [])
                            if isinstance(lp_field, list):
                                for lp in lp_field:
                                    if isinstance(lp, dict):
                                        f_val = lp.get("file") or lp.get("name", "")
                                        pkg_lean_files.append(f_val.replace("Catalog/", ""))
                                        pkg_lean_files.append(f_val.split("/")[-1])
                                    elif isinstance(lp, str):
                                        pkg_lean_files.append(lp.replace("Catalog/", ""))
                                        pkg_lean_files.append(lp.split("/")[-1])
                                    
                            if any(lf in pkg_lean_files for lf in updated_lean_files if lf):
                                matched_pkg_file = f
                                break
                        except Exception:
                            pass
                            
                if matched_pkg_file:
                    print(f"[Integrate] sorry_fill cycle: found existing parent package {matched_pkg_file.name}")
                    target_pkg_path = f"Packages/{matched_pkg_file.name}"
                    try:
                        old_pkg = json.loads(matched_pkg_file.read_text(encoding="utf-8"))
                        new_pkg = json.loads(enriched_pkg)
                        
                        # Merge metadata
                        old_pkg["date"] = new_pkg.get("date", old_pkg.get("date"))
                        old_pkg["exp_id"] = new_pkg.get("exp_id", old_pkg.get("exp_id"))
                        if "source_exp_ids" in new_pkg:
                            old_pkg["source_exp_ids"] = list(set(old_pkg.get("source_exp_ids", []) + new_pkg["source_exp_ids"]))
                            
                        # Update lean_proofs: merge matching files
                        old_lp = old_pkg.get("lean_proofs", [])
                        new_lp = new_pkg.get("lean_proofs", [])
                        if isinstance(old_lp, list) and isinstance(new_lp, list):
                            old_lp_dict = {}
                            for e in old_lp:
                                if isinstance(e, dict):
                                    old_lp_dict[e.get("file", "").split("/")[-1]] = e
                            for e in new_lp:
                                if isinstance(e, dict):
                                    base = e.get("file", "").split("/")[-1]
                                    if base in old_lp_dict:
                                        old_lp_dict[base]["code"] = e.get("code", old_lp_dict[base].get("code"))
                                        old_lp_dict[base]["theorems"] = e.get("theorems", old_lp_dict[base].get("theorems"))
                                        old_lp_dict[base]["description"] = "Lean 4 proof file (repaired and sorry-free)"
                                    else:
                                        old_lp.append(e)
                            old_pkg["lean_proofs"] = old_lp
                            
                        # Update key_results and keywords
                        old_pkg["key_results"] = list(set(old_pkg.get("key_results", []) + new_pkg.get("key_results", [])))
                        old_pkg["keywords"] = list(set(old_pkg.get("keywords", []) + new_pkg.get("keywords", [])))
                        
                        # Merge modules
                        if "modules" in new_pkg:
                            old_modules = old_pkg.get("modules", {})
                            old_modules.update(new_pkg["modules"])
                            old_pkg["modules"] = old_modules
                            
                        enriched_pkg = json.dumps(old_pkg, indent=2, ensure_ascii=False)
                    except Exception as e:
                        print(f"[Integrate] Error merging into existing package JSON: {e}")
                        
            parts.append({"type": "new", "path": target_pkg_path, "content": enriched_pkg})

        if job.result_discussion:
            parts.append({"type": "new", "path": f"Articles/discussion_{self._derive_artifact_name(job.concept, 'md')}", "content": job.result_discussion})

        # 2. Separate auto-accept files from review-needed files
        # Speculative/AutoResearch/ files are speculative by definition — auto-accept them.
        # Applications/ files (Demos, Papers, Articles, Packages) are also auto-accepted.
        # Only domain-directory Lean files and FINAL/ placements need Pi-Agent review.
        SPECULATIVE_PREFIXES = ("Speculative/AutoResearch/", "Demos/",
                                "Papers/", "Articles/",
                                "Packages/")
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
                
            abs_target = self._resolve_target(target_path)
            
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
                
                patched = False
                try:
                    # Apply diff
                    result = subprocess.run(["patch", str(abs_target), patch_file], capture_output=True, text=True)
                    if result.returncode == 0:
                        print(f"[Integrate] Merged diff into {target_path}")
                        files_written += 1
                        patched = True
                    else:
                        print(f"[Integrate] Patch failed for {target_path}: {result.stderr}")
                except Exception as e:
                    print(f"[Integrate] Patch failed for {target_path}: {e}")
                finally:
                    os.unlink(patch_file)

                # Fallback: if patch failed, try to copy the full file from project directory
                if not patched:
                    if hasattr(job, "project_dir") and job.project_dir:
                        proj_dir = Path(job.project_dir)
                        candidates = [
                            proj_dir / "Catalog" / target_path,
                            proj_dir / target_path,
                        ]
                        if target_path.startswith("Catalog/"):
                            clean_target_path = target_path[len("Catalog/"):]
                            candidates.append(proj_dir / "Catalog" / clean_target_path)
                            candidates.append(proj_dir / clean_target_path)
                        
                        for cand in candidates:
                            if cand.exists() and cand.is_file():
                                try:
                                    content = cand.read_text(encoding="utf-8", errors="ignore")
                                    abs_target.write_text(content, encoding="utf-8")
                                    print(f"[Integrate] Fallback success: copied full file from project dir to {target_path}")
                                    files_written += 1
                                    patched = True
                                    break
                                except Exception as fe:
                                    print(f"[Integrate] Fallback read/write failed for {cand}: {fe}")

        print(f"[Integrate] Pi successfully integrated {files_written} files.")
        job.files_integrated = files_written
        job.integrated_paths = list(written_paths)
        job.status = "integrated"
        self.completed_count += 1

        # Update package_index.js and lineage if we saved a JSON package
        if job.result_json_package:
            try:
                packages_dir = self.catalog_root.parent / "Packages"
                packages_dir.mkdir(parents=True, exist_ok=True)

                # Run update_index.py to regenerate package_index.js (lightweight index)
                try:
                    import subprocess
                    aether_root = Path(__file__).parent
                    lineage_script = aether_root / "lineage_extractor.py"
                    if lineage_script.exists() and "pytest" not in __import__("sys").modules:
                        result = subprocess.run(
                            [__import__("sys").executable, str(lineage_script)],
                            capture_output=True, text=True, cwd=str(aether_root)
                        )
                        if result.returncode == 0:
                            print(f"[Integrate] Updated lineage.json")
                        else:
                            print(f"[Integrate] Warning: lineage_extractor failed: {result.stderr[:200]}")

                    update_script = packages_dir / "update_index.py"
                    if update_script.exists() and "pytest" not in __import__("sys").modules:
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
        # Phase 2 (Lever F): lint batch skip-gate. If every file in the batch
        # is a non-empty .lean file with a theorem/lemma declaration, the batch
        # is clearly a real contribution -> auto-accept with suggested paths,
        # skipping the LLM review. Modes: shadow (default) / enabled / off.
        _lint_cfg = self.config.get("llm_reduction", {}) if hasattr(self, "config") and self.config else {}
        _lint_gate = _lint_cfg.get("lint_gate", "shadow")

        def _all_good_lean(b: List[Dict[str, Any]]) -> bool:
            for p in b:
                content = p.get("content", "") or ""
                path = p.get("path", "") or ""
                if not path.endswith(".lean"):
                    return False
                if not content.strip():
                    return False
                if not re.search(r'\b(theorem|lemma)\b', content):
                    return False
            return True

        _lint_decisive = _all_good_lean(batch) if batch else False
        if _lint_gate == "enabled" and _lint_decisive:
            if self.pi_agent is not None:
                self.pi_agent.record_llm_skip("lint")
            print(f"[Gate] lint batch {batch_idx+1}/{total_batches} skipped "
                  f"(all non-empty .lean with theorems)")
            return {p["path"]: p["path"] for p in batch}
        if _lint_gate == "shadow" and _lint_decisive:
            print(f"[Gate] lint shadow: batch {batch_idx+1}/{total_batches} "
                  f"would skip (all good .lean)")

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
            raw = self.pi_agent._call_ollama(system, user, timeout=120,
                                             category="lint")
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

        # Reject SalvagedBest.lean — this convention is dead. Low-quality output
        # is no longer salvaged; it's skipped entirely at the integration gate.
        if Path(target_path).name == "SalvagedBest.lean":
            print(f"[Integrate] Rejecting SalvagedBest.lean: {target_path}")
            return "REJECT"

        if suffix == ".lean" and part.get("type") == "new":
            content = part.get("content", "")
            has_sorry = self._lean_contains_sorry(content)
            # Reject sorry-dense trivial files (>50% sorry, <3 theorems)
            theorem_count = content.count("theorem ") + content.count("lemma ")
            sorry_count = content.count("sorry")
            lines = content.count("\n") + 1
            if has_sorry and sorry_count > 0:
                sorry_density = sorry_count / max(1, lines)
                if sorry_density > 0.5 and theorem_count < 3:
                    print(f"[Integrate] Rejecting sorry-dense trivial file: {target_path} "
                          f"(sorry_density={sorry_density:.2f}, theorems={theorem_count})")
                    return "REJECT"

            # v7 linting gate: reject Lean files from v7 prompts with basic syntax issues
            # v7 uses structured theorem declarations — verify they're well-formed
            phase_ver = getattr(job, 'phase_a_prompt_version', '')
            if phase_ver in ('v8', 'v9', 'v10', 'v11', 'v12', 'v13', 'v14', 'v15', 'v16', 'v16a', 'v16b', 'v17', 'v18', 'v19', 'v19a', 'v19b', 'v19c', 'v19d', 'v20', 'v21', 'v22', 'v23'):
                # Check 1: unclosed block comments (/- ... -/)
                open_blocks = content.count("/-") - content.count("/-!")
                close_blocks = content.count("-/")
                if open_blocks > close_blocks:
                    print(f"[Integrate] {phase_ver} lint: rejecting {target_path} — unclosed block comments "
                          f"(open={open_blocks}, close={close_blocks})")
                    return "REJECT"
                # Check 2: bare 'sorry' in theorem statements (not in proof bodies)
                # Pattern: "theorem foo ... := sorry" or "| sorry" at definition level
                for line_no, line in enumerate(content.split("\n"), 1):
                    stripped = line.strip()
                    if stripped.startswith("theorem ") and stripped.endswith(":= sorry"):
                        print(f"[Integrate] {phase_ver} lint: rejecting {target_path} — "
                              f"trivial sorry-define on line {line_no}")
                        return "REJECT"
                # Check 3: minimum theorem density (≥1 theorem per 100 lines)
                if lines > 50 and theorem_count / max(1, lines) < 0.01:
                    print(f"[Integrate] {phase_ver} lint: rejecting {target_path} — theorem density too low "
                          f"({theorem_count} theorems in {lines} lines)")
                    return "REJECT"
            # v8-v18 lint gate: check for research team protocol markers
            if phase_ver in ('v8', 'v9', 'v10', 'v11', 'v12', 'v13', 'v14', 'v16', 'v16a', 'v16b', 'v17', 'v18', 'v19', 'v19a', 'v19b', 'v19c', 'v19d', 'v20', 'v21', 'v22', 'v23'):
                has_lab_notebook = "Lab Notebook" in content or "lab notebook" in content.lower()
                has_lab_notes = "Lab Notes" in content or "lab notes" in content.lower()
                has_hypothesis = "hypothesis" in content.lower()
                critic_count = content.lower().count("critic") + content.lower().count("critique")
                if not has_lab_notebook and not has_lab_notes and not has_hypothesis:
                    print(f"[Integrate] {phase_ver} lint: {target_path} has no Lab Notebook, Lab Notes, or "
                          f"hypothesis markers (expected from {phase_ver} research team protocol)")
                if critic_count == 0:
                    print(f"[Integrate] {phase_ver} lint: {target_path} has zero critic/critique references — "
                          f"the Critic step is MANDATORY in {phase_ver}. This suggests the LLM "
                          f"skipped the critique step.")
            # v15 lint gate: check for research team lab notes markers
            if phase_ver == 'v15':
                has_lab_notes = "Lab Notes" in content or "lab notes" in content.lower()
                has_hypothesis = "hypothesis" in content.lower()
                if not has_lab_notes and not has_hypothesis:
                    print(f"[Integrate] {phase_ver} lint: {target_path} has no Lab Notes or "
                          f"hypothesis markers (expected from {phase_ver} research team protocol)")
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

            # If domain is "Applications" with NO subdirectory (e.g.
            # "Applications/Foo.lean"), re-route to the concept's actual
            # domain. "Applications" is a catch-all that dumps .lean files
            # at the root — they should go to a proper domain directory.
            parts_list = [p for p in target_path.replace("\\", "/").split("/") if p]
            if path_domain == "Applications" and len(parts_list) <= 2:
                domain = normalize_domain(job.concept.domain or "Algebra")
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
            
            dedup_packages_script = Path(__file__).parent / "dedup_packages.py"
            if dedup_packages_script.exists():
                await asyncio.to_thread(
                    subprocess.run,
                    ["python3", str(dedup_packages_script)],
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

        # 8. Cross-domain bridge directions from this cycle's result
        try:
            await asyncio.to_thread(self._generate_bridge_directions_from_cycle, job)
        except Exception as e:
            print(f"[Cleanup] Warning: bridge direction generation failed: {e}")

        # 9. ArXiv mining is handled by cycle_master.py Phase 10.7

        return job

    @staticmethod
    def _rule_prunable(d, score: float) -> bool:
        """Phase 4 (Lever F): rule-based prune predicate. True if a direction
        is clearly worthless and can be auto-pruned without an LLM review:
        very low quality (<0.20) + empty/junk description + no protection
        (priority <0.80, not Novelty, not seed)."""
        _protected = (getattr(d, "priority_score", 0) >= 0.80
                      or "Novelty" in (getattr(d, "domains", None) or [])
                      or (getattr(d, "source_path", "") or "").startswith("seed:"))
        if _protected:
            return False
        if score >= 0.20:
            return False
        _desc = (getattr(d, "description", "") or "").strip()
        _title = (getattr(d, "title", "") or "").strip()
        _junk = (not _desc or _desc == _title or len(_desc) < 15)
        return _junk

    def _cleanup_future_directions(self) -> None:
        """Thoughtfully prune low-quality directions and brainstorm a novel new one.

        Reviews directions in small batches, requiring justification for each removal.
        Protects high-priority, Novelty-tagged, and seed directions.
        Runs every ~20 cycles to avoid over-pruning.
        """
        from research_memory import FutureDirectionsManager, FutureDirection
        fd_manager = FutureDirectionsManager(self.workspace)

        # Fix auto-generated titles before cleanup review
        fixed = fd_manager.fix_existing_auto_titles()
        if fixed:
            print(f"[Cleanup] Fixed {fixed} auto-generated cycle-summary titles")

        available = [d for d in fd_manager._directions if d.status == "available"]
        if len(available) < 5:
            return

        # Only run every ~20 cycles to avoid over-pruning
        if self.cycle_count % 20 != 0 and self.cycle_count > 0:
            return

        # Only review the bottom 30% by quality — top directions are protected
        # Skip directions that were reviewed and kept in the last 2 cleanup cycles
        # (they survived Pi-Agent review already — no point re-evaluating unchanged directions)
        reviewed_cutoff_cycles = 2  # skip if reviewed in last 2 cleanup cycles (every ~40 normal cycles)
        reviewed_ids = set()
        for d in available:
            if d.cleanup_review_count >= reviewed_cutoff_cycles:
                reviewed_ids.add(d.id)

        scored = [(d, fd_manager._compute_quality_score(d)) for d in available if d.id not in reviewed_ids]
        scored.sort(key=lambda x: x[1])  # ascending — worst first
        cutoff_idx = max(5, len(scored) // 3)  # review bottom third, at least 5
        candidates = scored[:cutoff_idx]

        # Phase 4 (Lever F): rules-first pre-filter. Auto-prune the clearly
        # worthless candidates by rule (very low quality + empty/junk
        # description + no protection) so only the ambiguous middle goes to the
        # LLM batch. Disable via llm_reduction.pruning_rules="off".
        _prune_rules = ((self.config.get("llm_reduction", {}) if hasattr(self, "config") and self.config else {})
                        .get("pruning_rules", "on"))
        if _prune_rules == "on" and candidates:
            _survivors = []
            _rule_removed = 0
            for d, score in candidates:
                if self._rule_prunable(d, score):
                    d.status = "pruned"
                    d.prune_reason = f"rule_cleanup: low quality ({score:.2f}) + empty/junk"
                    d.pruned_at = datetime.now(timezone.utc).isoformat()
                    _rule_removed += 1
                else:
                    _survivors.append((d, score))
            candidates = _survivors
            if _rule_removed:
                print(f"[Cleanup] Rules-first auto-pruned {_rule_removed} direction(s); "
                      f"{len(candidates)} remain for LLM review")

        if reviewed_ids:
            print(f"[Cleanup] Skipping {len(reviewed_ids)} directions already reviewed and kept")

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
                raw = self.pi_agent._call_ollama(system, user, timeout=60,
                                                 category="pruning")
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

            # Mark kept directions as reviewed — they survived Pi-Agent review
            kept_ids = result.get("kept", [])
            now_iso = datetime.now(timezone.utc).isoformat()
            kept_count = 0
            for d in fd_manager._directions:
                if d.id in kept_ids and d.status == "available":
                    d.last_reviewed_at = now_iso
                    d.cleanup_review_count = getattr(d, 'cleanup_review_count', 0) + 1
                    kept_count += 1
            if kept_count > 0:
                print(f"[Cleanup] Marked {kept_count} directions as reviewed and kept")

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
            raw = self.pi_agent._call_ollama(brainstorm_system, brainstorm_user, timeout=60,
                                             category="pruning")
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
    def refresh_external_signals(self, domain: str = "", count_per_source: int = 2) -> int:
        """Refresh external signal feed if the feature is enabled."""
        if not self.config.get("features", {}).get("enable_external_signal", False):
            return 0
        try:
            added = self.external_signal.refresh(domain=domain, count_per_source=count_per_source)
            if added:
                print(f"[ExternalSignal] Added {added} direction(s) from external feeds")
            return added
        except Exception as e:
            print(f"[ExternalSignal] Warning: refresh failed: {e}")
            return 0

    def _mine_structural_holes(self) -> None:
        """Find domain pairs with no edges in the knowledge graph and generate bridge directions.

        Structural holes are pairs of domains that have no provenance edges between them.
        These are the highest-value bridge targets: a theorem connecting two disconnected
        domains would create new knowledge graph edges and unlock cross-domain research.
        """
        import json as _json
        from research_memory import FutureDirection, FutureDirectionsManager

        lineage_path = self.catalog_root.parent / "Packages" / "lineage.json"
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

        Groups Lean 4 files by semantic similarity, round-robins similarity
        groups, and queries Pi-Agent to select canonical file and prune duplicates.
        """
        from catalog_pruner import CatalogPruner
        pruner = CatalogPruner(self.catalog_root, self.pi_agent, self.workspace)
        try:
            pruner.prune(target_remove_count=batch_size)
        except Exception as e:
            print(f"[Prune] CatalogPruner execution failed: {e}")


    def _generate_bridge_directions_from_cycle(self, job: ResearchJob) -> None:
        """Generate 2-3 cross-domain future directions implied by this cycle's result.

        Uses a lightweight LLM call to identify how the proven theorems could
        connect to other catalog domains. These become high-priority future
        directions that build bridges between isolated packages.
        """
        from research_memory import FutureDirection, FutureDirectionsManager

        if not job.result_lean or not job.concept:
            return

        title = job.concept.title
        domain = job.concept.domain
        exp_id = job.job_id if hasattr(job, 'job_id') else ""

        # Avoid duplicate bridge generation for the same cycle
        fd_manager = FutureDirectionsManager(self.workspace)
        existing = any(
            d.source_exp_id == exp_id and d.source_path == "cycle_bridge"
            for d in fd_manager._directions
            if d.status in ("available", "in_progress")
        )
        if existing:
            return

        # Extract key theorems and a short summary of the result
        key_theorems = []
        if job.result_lean:
            for m in re.finditer(r"(?:theorem|lemma)\s+(\w+)", job.result_lean[:2000]):
                key_theorems.append(m.group(1))

        lean_summary = job.result_lean[:1500].strip()
        theorem_ctx = f" Key theorems: {', '.join(key_theorems[:5])}." if key_theorems else ""

        system = (
            "You are a cross-domain mathematics strategist for an autonomous research engine.\n\n"
            "Given a proven result, identify 2-3 specific ways it could connect to OTHER mathematical domains. "
            "Each bridge must be a falsifiable conjecture that extends the result into a new domain, not just a vague analogy.\n\n"
            "For each bridge direction provide:\n"
            "- A precise conjecture\n"
            "- The target domain (different from the result's domain)\n"
            "- Why the connection is plausible given the existing proof\n\n"
            "Respond in this exact JSON format:\n"
            '{\n'
            '  "bridges": [\n'
            '    {\n'
            '      "title": "Short, compelling title",\n'
            '      "target_domain": "DomainName",\n'
            '      "description": "Conjecture: [precise statement]. Test: [what confirms/refutes]. Impact: [why it matters]",\n'
            '      "proof_strategy": "How to build on the existing result"\n'
            '    }\n'
            '  ]\n'
            '}'
        )

        user = (
            f"Proven result: {title}\n"
            f"Source domain: {domain}\n"
            f"Result excerpt:\n```\n{lean_summary}\n```\n"
            f"{theorem_ctx}\n\n"
            f"Suggest 2-3 bridge directions to other mathematical domains."
        )

        added = 0
        try:
            raw = self.pi_agent._call_ollama(system, user, timeout=60)
            result = self.pi_agent._parse_json_response(raw)
            if not result:
                return
            bridges = result.get("bridges", [])
            for b in bridges:
                target = b.get("target_domain", "Bridges")
                direction = FutureDirection(
                    id=fd_manager._next_id(),
                    title=b.get("title", f"Bridge: {domain} → {target}")[:80],
                    description=b.get("description", "")[:2000],
                    source_exp_id=exp_id,
                    source_path="cycle_bridge",
                    domains=list(set([domain, target])),
                    depth_estimate=4,
                    priority_score=0.88,
                    proof_strategy=b.get("proof_strategy", f"Extend {title} into {target}.")[:1000],
                )
                fd_manager.add_direction(direction)
                added += 1
            if added > 0:
                fd_manager._save()
                print(f"[BridgeDirs] Generated {added} cross-domain bridge directions from {title}")
        except Exception as e:
            print(f"[BridgeDirs] LLM bridge generation failed: {e}")

    _TOP_LEVEL_OUTPUT_DIRS = ("Papers", "Demos", "Visuals", "Articles", "Packages")

    def _resolve_target(self, target_path: str) -> Path:
        """Resolve a part/integrated path to an absolute filesystem path.

        Papers/Demos/Visuals/Articles/Packages moved to top-level (siblings of
        Catalog, i.e. under catalog_root.parent). Everything else (e.g.
        Algebra/foo.lean, Speculative/...) stays under catalog_root.
        """
        first = target_path.split("/", 1)[0]
        base = self.catalog_root.parent if first in self._TOP_LEVEL_OUTPUT_DIRS else self.catalog_root
        return base / target_path

    def _verify_catalog_sync(self, job: ResearchJob) -> dict:
        """Verify all output files are properly placed in the Catalog."""
        report = {"missing_files": [], "verified_files": []}
        # Check that key artifacts exist at expected paths
        catalog_root = self.catalog_root

        # Check top-level output directories exist (moved out of Catalog/Applications/)
        for subdir in ["Papers", "Demos", "Visuals", "Articles", "Packages"]:
            d = self.catalog_root.parent / subdir
            if d.exists():
                report["verified_files"].append(f"{subdir}/ exists")
        
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
                    # Replace SalvagedBest.lean with a meaningful name derived from the concept title
                    if Path(fname).name == "SalvagedBest.lean" and hasattr(job, 'concept') and job.concept:
                        slug = re.sub(r'[^a-zA-Z0-9]+', '', job.concept.title[:40])
                        if not slug:
                            slug = "Proofs"
                        fname = str(Path(fname).parent / f"{slug}.lean") if Path(fname).parent.name else f"{slug}.lean"
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

        # Always set date to when this package was created for the website,
        # not whatever Aristotle may have put in the JSON. This ensures the
        # displayed date reflects when the research was packaged, not some
        # arbitrary timestamp from the LLM output.
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
            viz_dir = self.catalog_root.parent / "Packages" / "visualizations"
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
        # Auto-align domain based on actual proof files
        resolved_domains = set()
        lp_list = pkg.get("lean_proofs", []) or pkg.get("lean_files", [])
        from output_organizer import DOMAIN_DIRS
        if isinstance(lp_list, list):
            for entry in lp_list:
                fname = ""
                if isinstance(entry, dict):
                    fname = entry.get("file", "") or entry.get("name", "")
                elif isinstance(entry, str):
                    fname = entry
                
                parts = fname.replace("\\", "/").split("/")
                # If path contains 'Catalog/{Domain}', extract it
                if "Catalog" in parts:
                    idx = parts.index("Catalog")
                    if idx + 1 < len(parts):
                        resolved_domains.add(parts[idx + 1])
                elif len(parts) > 1 and parts[0] in DOMAIN_DIRS:
                    resolved_domains.add(parts[0])
         
        # Also fall back to job's actual integrated paths
        if not resolved_domains and hasattr(job, 'integrated_paths') and job.integrated_paths:
            for path in job.integrated_paths:
                parts = str(path).replace("\\", "/").split("/")
                if len(parts) > 1 and parts[0] == "Catalog" and parts[1] in DOMAIN_DIRS:
                    resolved_domains.add(parts[1])
                elif len(parts) > 0 and parts[0] in DOMAIN_DIRS:
                    resolved_domains.add(parts[0])
                     
        if resolved_domains:
            # Count frequency of each resolved domain
            counts = {}
            for rd in resolved_domains:
                counts[rd] = counts.get(rd, 0) + 1
            most_common = sorted(counts.items(), key=lambda x: -x[1])[0][0]
            pkg["domain"] = most_common
            print(f"[Enrich] Domain auto-aligned to Catalog folder: {most_common}")
        elif pkg.get("domain") not in DOMAIN_DIRS:
            # Fall back to concept domain normalized
            norm_domain = normalize_domain(pkg.get("domain", "Novelty"))
            pkg["domain"] = norm_domain
            print(f"[Enrich] Domain normalized to: {norm_domain}")

        # Backfill core metadata if still missing or empty after the prompt
        if not pkg.get("title") and hasattr(job, 'concept') and job.concept:
            pkg["title"] = job.concept.title
            print(f"[Enrich] Title backfilled from concept")
        if not pkg.get("description") and hasattr(job, 'concept') and job.concept:
            pkg["description"] = f"Research package for {job.concept.title}."
        if not pkg.get("authors"):
            pkg["authors"] = ["Aristotle"]
        if not pkg.get("date"):
            pkg["date"] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        if not pkg.get("key_results") and hasattr(job, 'result_lean') and job.result_lean:
            # Extract theorem/lemma names as a best-effort key_results list
            _names = re.findall(r'(?:theorem|lemma)\s+([a-zA-Z_][a-zA-Z0-9_\']*)', job.result_lean)
            if _names:
                pkg["key_results"] = _names[:6]
                print(f"[Enrich] key_results backfilled from Lean theorems")
        if not pkg.get("keywords") and hasattr(job, 'concept') and job.concept:
            # Derive keywords from concept title + domain
            _title_words = re.findall(r'[a-zA-Z]+', job.concept.title)
            _keywords = [w for w in _title_words if len(w) > 3][:5]
            if job.concept.domain:
                _keywords.insert(0, job.concept.domain)
            if _keywords:
                pkg["keywords"] = _keywords
                print(f"[Enrich] keywords backfilled from concept")

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

            dedup_packages_script = Path(__file__).parent / "dedup_packages.py"
            if dedup_packages_script.exists():
                subprocess.run(
                    ["python3", str(dedup_packages_script)],
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

        # Archive project input/output for durable master catalog
        try:
            self._archive_job(job)
        except Exception as e:
            print(f"[Cleanup] Warning: project archive failed: {e}")

        return job

    def _archive_job(self, job: "ResearchJob") -> None:
        """Archive this job's input and output files to the CAS archive."""
        if not job.project_id:
            return
        if self.archive_manager.project_exists(job.project_id):
            return
        input_dir: Optional[Path] = None
        output_dir: Optional[Path] = None
        if job.project_dir and Path(job.project_dir).exists():
            input_dir = Path(job.project_dir)
            extracted = input_dir / "result_extracted"
            if extracted.exists():
                output_dir = extracted
        if not input_dir:
            return
        self.archive_manager.archive_project(
            project_id=job.project_id,
            description=getattr(job.concept, "title", "")[:100],
            status=job.status or "integrated",
            created_at=datetime.now(timezone.utc).isoformat(),
            last_updated=datetime.now(timezone.utc).isoformat(),
            input_dir=input_dir,
            output_dir=output_dir,
        )
        print(f"[Archive] Archived project {job.project_id[:8]} to master catalog")

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
                    abs_path = self._resolve_target(p)
                    if abs_path.exists():
                        # git add relative to repo root
                        rel = abs_path.relative_to(self.catalog_root.parent)
                        paths_to_add.append(str(rel))
            # Always add workspace changes (future directions, memory)
            state_files = [
                "Aether/.aether_workspace/future_directions.json",
                "Aether/.aether_workspace/cycle_analytics.json",
                "Aether/.aether_workspace/research_journal.json",
                "Aether/.aether_workspace/research_threads.json",
                "Aether/.aether_workspace/inflight_jobs.json",
                "Aether/.aether_workspace/insights.json",
                "Aether/.aether_workspace/tick_counter.json",
                "Aether/.aether_workspace/exp_id_map.json",
                "Aether/.aether_workspace/prune_state.json",
                "Aether/.aether_workspace/phase_b_threshold_cache.json",
                "Aether/.aether_workspace/research_memory.jsonl",
                "Aether/.aether_workspace/autoresearch/autoresearch.jsonl",
            ]
            for sf in state_files:
                abs_sf = self.catalog_root.parent / sf
                if abs_sf.exists():
                    paths_to_add.append(sf)
            # Add packages index if it was regenerated
            pkg_index = self.catalog_root.parent / "Packages" / "package_index.js"
            if pkg_index.exists():
                paths_to_add.append("Catalog/Packages/package_index.js")
            lineage = self.catalog_root.parent / "Packages" / "lineage.json"
            if lineage.exists():
                paths_to_add.append("Catalog/Packages/lineage.json")

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
        """Mark the future direction consumed by a failed job as terminal failed.

        Directions are no longer retried; a failed job consumes the direction once.
        """
        if not job.job_id:
            return
        if hasattr(self, 'locked_titles') and job.concept:
            self.locked_titles.discard(job.concept.title)
        try:
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            for d in fd_manager._directions:
                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                    fd_manager.mark_direction_failed(d.id)
                    print(f"[Tick] Direction {d.id} marked failed (no retry): {d.title[:50]}")
                    break
            self._terminate_thread_for_job(job, "job_failed")
        except Exception as e:
            print(f"[Tick] Warning: could not mark direction failed: {e}")

    def _release_direction_back_to_available(self, job: ResearchJob) -> None:
        """Release the direction consumed by this job back to the available pool.

        Use this when the job could not be dispatched for operational reasons
        (e.g., Aristotle queue full), not because the concept itself failed.
        """
        if not job.job_id:
            return
        if hasattr(self, 'locked_titles') and job.concept:
            self.locked_titles.discard(job.concept.title)
        try:
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            fd_manager.release_consumed_direction(job.job_id)
            print(f"[Tick] Released direction back to available for job {job.job_id[:8]}")
            self._terminate_thread_for_job(job, "dispatch_released")
        except Exception as e:
            print(f"[Tick] Warning: could not release direction back to available: {e}")

    def _quarantine_direction_for_job(self, job: ResearchJob, days: int = 30) -> None:
        """Quarantine the direction consumed by this job after a low-quality cycle.

        Prevents the same failing direction from being retried for `days` days.
        """
        if not job.job_id:
            return
        try:
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            for d in fd_manager._directions:
                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                    fd_manager.quarantine_direction(d.id, days=days)
                    print(f"[Quarantine] {d.id} for {days} days (Q={job.quality_score:.3f}): {d.title[:50]}")
                    break
            self._terminate_thread_for_job(job, "quarantined")
        except Exception as e:
            print(f"[Quarantine] Warning: could not quarantine: {e}")

    def _terminate_thread_for_job(self, job: ResearchJob, reason: str) -> None:
        """Terminate the research thread associated with a job and fail its directions."""
        if not job.thread_id:
            return
        thread = self.thread_manager.get_thread(job.thread_id)
        if not thread or thread.status != "active":
            return
        self.thread_manager.terminate_thread(thread.thread_id, reason)
        try:
            from research_memory import FutureDirectionsManager
            fd_manager = FutureDirectionsManager(self.workspace)
            cycle_job_ids = set(thread.cycles)
            marked = 0
            for d in fd_manager._directions:
                if d.status != "in_progress":
                    continue
                if d.thread_id == thread.thread_id or d.id == thread.root_direction_id or d.consumed_by_exp_id in cycle_job_ids:
                    fd_manager.mark_direction_failed(d.id)
                    marked += 1
            if marked:
                print(f"[Thread] {thread.thread_id}: marked {marked} in-progress direction(s) failed ({reason})")
        except Exception as e:
            print(f"[Thread] Warning: could not mark thread directions failed: {e}")

    def _update_thread_after_job(self, job: ResearchJob) -> None:
        """Update the research thread after a job finishes integrating.

        Appends the cycle, checks for knowledge delta / stagnation, and terminates
        threads whose jobs failed or were rejected.
        """
        if not job.thread_id:
            return
        thread = self.thread_manager.get_thread(job.thread_id)
        if not thread or thread.status != "active":
            return

        # Failure/rejection kills the thread.
        if job.status not in ("integrated", "completed", "B_dispatched"):
            self._terminate_thread_for_job(job, f"job_status_{job.status}")
            return
        if job.status == "integrated" and job.quality_score < 0.15:
            self._terminate_thread_for_job(job, "quality_rejected")
            return

        concept_title = job.concept.title if job.concept else ""
        still_active = self.thread_manager.append_cycle(
            thread.thread_id, job.job_id, job.result_lean or "", quality_score=job.quality_score,
            concept_title=concept_title,
        )
        if not still_active:
            self._terminate_thread_for_job(job, "stagnation")
            return

        # Thread promise critic: on longer threads, ask whether the trajectory is worth continuing.
        if len(thread.cycles) >= 2 and self.config.get("features", {}).get("enable_thread_promise_critic", False):
            try:
                from specialized_critics import ThreadPromiseCritic
                promise_critic = ThreadPromiseCritic(self.pi_agent, timeout=180)
                verdict = promise_critic.evaluate(thread)
                print(f"[ThreadPromise] {thread.thread_id} score={verdict['promise_score']:.2f} "
                      f"recommendation={verdict['recommendation']} rationale={verdict.get('rationale', '')[:120]}")
                if verdict.get("recommendation") in ("terminate", "pivot"):
                    self._terminate_thread_for_job(job, f"promise_{verdict['recommendation']}")
                    return
            except Exception as e:
                print(f"[ThreadPromise] Warning: failed to evaluate thread: {e}")

        # Counterexample or strong disproof closes the thread as a positive result.
        if self._is_counterexample_result(job):
            self.thread_manager.complete_thread(thread.thread_id)
            print(f"[Thread] {thread.thread_id} completed (counterexample/disproof)")
            return

        # Otherwise the thread stays active; a follow-up direction was already
        # extracted with thread_id in _extract_future_directions.
        if self.config.get("features", {}).get("enable_abduction_loop", False):
            self._ensure_thread_followup(thread, job)

    def _ensure_thread_followup(self, thread: ResearchThread, job: ResearchJob) -> None:
        """If the thread has no pending follow-up direction, generate one from thread context."""
        try:
            from research_memory import FutureDirectionsManager, FutureDirection
            fd_manager = FutureDirectionsManager(self.workspace)
            has_followup = any(
                d.thread_id == thread.thread_id and d.status == "available"
                for d in fd_manager._directions
            )
            if has_followup:
                return

            system = (
                "You are a mathematical research director. Given a research thread's history, "
                "propose a single focused next direction. Respond with valid JSON only:\n"
                "{\"title\": string, \"description\": string, \"proof_strategy\": string}."
            )
            context = self._build_thread_context(job)
            raw = self.pi_agent._call_ollama(system, context, timeout=120)
            import json as _json
            data = _json.loads(raw)
            if not isinstance(data, dict):
                return
            fd = FutureDirection(
                id=fd_manager._next_id(),
                title=str(data.get("title", "Thread follow-up"))[:200],
                description=str(data.get("description", ""))[:3000],
                source_exp_id=job.job_id,
                source_path=str(job.project_dir) if job.project_dir else "abduction_followup",
                domains=fd_manager._infer_domains(str(data.get("title", "")) + " " + str(data.get("description", ""))),
                proof_strategy=str(data.get("proof_strategy", ""))[:1000],
                depth_estimate=3,
                priority_score=0.85,
                thread_id=thread.thread_id,
            )
            fd_manager.add_direction(fd)
            print(f"[Abduction] Generated follow-up direction {fd.id} for thread {thread.thread_id}")
        except Exception as e:
            print(f"[Abduction] Warning: could not generate thread follow-up: {e}")

    def _is_counterexample_result(self, job: ResearchJob) -> bool:
        """Heuristic: does the job output contain a counterexample or disproof?"""
        text = (job.result_lean or "") + " " + (job.result_future_directions or "")
        text_lower = text.lower()
        if "counterexample" in text_lower or "disproof" in text_lower or "disproved" in text_lower:
            return True
        novelty = getattr(job, "theorem_novelty", None)
        if novelty and novelty.get("disproof", 0) > 0:
            return True
        return False

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
            # Fallback: extract FUTURE DIRECTIONS comment blocks from Phase A's Lean output.
            # Phase A produces these as trailing comment blocks in .lean files
            # (e.g., "-- FUTURE DIRECTIONS ..." or "/-! FUTURE DIRECTIONS ... -/")
            if not fd_text and job.result_lean:
                fd_blocks = []
                # Match line-style FUTURE DIRECTIONS blocks: "-- FUTURE DIRECTIONS" and subsequent "--" lines
                import re as _re
                # Block-style: /-! FUTURE DIRECTIONS ... -/
                for m in _re.finditer(
                    r'/-!?[\s]*FUTURE\s+DIRECTIONS.*?-/',
                    job.result_lean, _re.DOTALL | _re.IGNORECASE
                ):
                    block = m.group(0)
                    # Strip comment delimiters
                    content = _re.sub(r'^/-!?[\s]*FUTURE\s+DIRECTIONS[\s]*\n?', '', block)
                    content = _re.sub(r'-/\s*$', '', content)
                    if len(content.strip()) > 30:
                        fd_blocks.append(content.strip())
                # Line-style: "-- FUTURE DIRECTIONS" and collect subsequent "--" lines
                lines = job.result_lean.split('\n')
                in_fd_block = False
                current_block = []
                for line in lines:
                    stripped = line.strip()
                    if _re.match(r'^--\s*FUTURE\s+DIRECTIONS', stripped, _re.IGNORECASE):
                        in_fd_block = True
                        # Skip the header line itself
                        continue
                    if in_fd_block:
                        if stripped.startswith('--'):
                            current_block.append(stripped.lstrip('-').strip())
                        else:
                            if current_block:
                                fd_blocks.append('\n'.join(current_block))
                            current_block = []
                            in_fd_block = False
                if current_block:
                    fd_blocks.append('\n'.join(current_block))
                if fd_blocks:
                    fd_text = '\n\n'.join(fd_blocks)
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
                    thread_id=getattr(job, "thread_id", "") or "",
                )
                fd_manager.add_direction(fd)
                fd_added = 1
                print(f"[Cycle] Added 1 future direction from cycle {job.job_id}")
            else:
                print(f"[Cycle] No future directions found for cycle {job.job_id}")
            # Mark the consumed direction as completed. Use a robust lookup that
            # handles the case where stale-recovery already cleared the direction's
            # consumed_by_exp_id or changed its status.
            marked = False
            for d in fd_manager._directions:
                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                    if job.quality_score > 0:
                        d.outcome_quality = job.quality_score
                        print(f"[Cycle] Direction {d.id} outcome_quality={job.quality_score:.2f}")
                    fd_manager.mark_direction_completed(d.id)
                    print(f"[Cycle] Marked direction {d.id} as completed (quality={d.outcome_quality:.2f})")
                    marked = True
                    break
            if not marked:
                # Fallback: look for any in_progress direction this job might have consumed
                # (in case the stale-recovery already touched it). Check attempt_count
                # to ensure we don't re-dispatch immediately.
                for d in fd_manager._directions:
                    if d.status == "in_progress" and d.last_attempt_time:
                        # The direction was probably ours if its last_attempt_time is recent
                        import datetime
                        try:
                            last_attempt = datetime.datetime.fromisoformat(d.last_attempt_time)
                            now = datetime.datetime.now(datetime.timezone.utc)
                            if (now - last_attempt).total_seconds() < 3600:  # within last hour
                                if job.quality_score > 0:
                                    d.outcome_quality = job.quality_score
                                fd_manager.mark_direction_completed(d.id)
                                print(f"[Cycle] Recovered: marked direction {d.id} as completed "
                                      f"(consumed_by_exp_id was reset, matched by recency)")
                                marked = True
                                break
                        except (ValueError, TypeError):
                            pass
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
            # Directions are no longer retried. Mark the consumed direction failed.
            self._release_direction(job)
            return job

        # 4. EXTRACT
        job = self.extract(job)

        # 5. EVALUATE & RETRY
        job = self.evaluate(job)
        while job.quality_assessment and job.quality_assessment.get("should_retry") and job.retry_count < self.max_retries:
            print(f"[Cycle] Job {job.job_id[:8]} quality check failed (Q={job.quality_score:.3f}, quality={job.quality_assessment.get('quality')}). "
                  f"Initiating proof repair retry {job.retry_count + 1}/{self.max_retries}...")

            suggestion = self.pi_agent.suggest_retry_improvement(
                concept=job.concept,
                previous_prompt=job.prompt,
                result_lean=job.result_lean or "",
                quality_assessment=job.quality_assessment,
            )

            job = self.dispatch_retry(job, suggestion, max_inflight=self.config.get("autoresearch", {}).get("max_inflight", 3))
            if job.status == "retry_queued":
                print(f"[Cycle] Retry for {job.job_id[:8]} queued due to capacity; exiting synchronous retry loop")
                break
            if job.project_id:
                job = self._await_job(job)
                job = self.extract(job)
                job = self.evaluate(job)
            else:
                break

        # 6. INTEGRATE
        job = self.integrate(job)


        # 6b. EXTRACT FUTURE DIRECTIONS from Aristotle's output
        self._extract_future_directions(job)

        # 6b. UPDATE RESEARCH THREAD: track knowledge delta / stagnation
        self._update_thread_after_job(job)

        # 6c. INSIGHT EXTRACTION: scan new theorems for meta-insights
        # (guardrails, strategies, cost estimates for future cycles)
        try:
            self.insight_extractor.scan_new_theorems(job)
            istats = self.insight_extractor.stats()
            if any(v > 0 for v in istats.values()):
                print(f"[Insights] barriers={istats['barriers']}, strategies={istats['strategies']}, "
                      f"bridges={istats['cross_domain_bridges']}, costs={istats['cost_estimates']}")
        except Exception as e:
            print(f"[Insights] Warning: insight extraction failed: {e}")

        # 6d. NOVELTY AUDIT: evaluate whether cycle results are genuinely novel
        try:
            novelty_score = self.insight_extractor.audit_novelty(job, self.catalog_analyzer)
            if novelty_score is not None:
                print(f"[Insights] Novelty audit: score={novelty_score:.2f}")
                # Feed back into direction quality: adjust the consumed direction
                from research_memory import FutureDirectionsManager
                fd_mgr = FutureDirectionsManager(self.workspace)
                direction = fd_mgr.get_direction_for_exp(job.job_id)
                if direction and direction.outcome_quality == 0:
                    direction.outcome_quality = novelty_score
                    fd_mgr._save()
        except Exception as e:
            print(f"[Insights] Warning: novelty audit failed: {e}")

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

    def _await_job(self, job: ResearchJob, timeout: int = 172800, poll_interval: int = 30) -> ResearchJob:
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

                    # Intercept for Dialogue-Based Proof Repair Loop
                    is_phase_b_completion = (job.phase == "B" or job.phase == "B_dispatched")
                    if not is_phase_b_completion and job.quality_assessment and job.quality_assessment.get("should_retry"):
                        if job.retry_count < self.max_retries:
                            print(f"[Continuous] Job {job.job_id[:8]} quality check failed (Q={job.quality_score:.3f}, quality={job.quality_assessment.get('quality')}). "
                                  f"Initiating proof repair retry {job.retry_count + 1}/{self.max_retries}...")

                            suggestion = self.pi_agent.suggest_retry_improvement(
                                concept=job.concept,
                                previous_prompt=job.prompt,
                                result_lean=job.result_lean or "",
                                quality_assessment=job.quality_assessment,
                            )

                            current_max_inflight = max_inflight
                            job = await self.dispatch_retry_async(job, suggestion, max_inflight=current_max_inflight)
                            self._save_inflight()
                            continue

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
                                    thread_id=getattr(job, "thread_id", "") or "",
                                )
                                fd_manager.add_direction(fd)
                                fd_added = 1
                                print(f"[Continuous] Added 1 future direction from cycle {job.job_id}")
                            else:
                                print(f"[Continuous] No future directions found for cycle {job.job_id}")
                            for d in fd_manager._directions:
                                if d.consumed_by_exp_id == job.job_id and d.status == "in_progress":
                                    # Quality feedback: BEFORE saving to persist the score
                                    if job.quality_score > 0:
                                        d.outcome_quality = job.quality_score
                                        print(f"[Continuous] Direction {d.id} outcome_quality={job.quality_score:.2f}")
                                    fd_manager.mark_direction_completed(d.id)
                                    print(f"[Continuous] Marked direction {d.id} as completed (quality={d.outcome_quality:.2f})")
                                    break
                        except Exception as e:
                            print(f"[Continuous] Warning: Failed to extract future directions: {e}")

                        # Update research thread for this job
                        self._update_thread_after_job(job)

                    job = await self.cleanup_catalog_async(job)
                    self.commit(job)

                    if job.project_id in self.inflight:
                        del self.inflight[job.project_id]
                else:
                    self.failed_count += 1
                    # Directions are no longer retried. Mark consumed direction failed.
                    self._release_direction(job)
                    if job.project_id in self.inflight:
                        del self.inflight[job.project_id]
            
            if completed:
                self._save_inflight()

            # Dispatch new jobs to fill queue
            active_inflight = len([j for j in self.inflight.values()
                                   if j.status not in ("completed", "failed", "integrated", "rejected")])
            while active_inflight < max_inflight and self.cycle_count < max_cycles:
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

                active_inflight = len([j for j in self.inflight.values()
                                       if j.status not in ("completed", "failed", "integrated", "rejected")])

            # Status
            active_inflight = len([j for j in self.inflight.values()
                                   if j.status not in ("completed", "failed", "integrated", "rejected")])
            print(f"\n[Status] Cycle {self.cycle_count}/{max_cycles} | "
                  f"Inflight: {active_inflight}/{max_inflight} | "
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

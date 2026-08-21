#!/usr/bin/env python3
"""ResearchMemory: Persistent memory of what has been explored.

Tracks completed experiments, concepts, and outcomes to avoid repetition
and guide future research toward novel ground.
"""

import json
import os
import re
import shutil
import subprocess
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Set

# Default maximum number of available non-seed directions to keep
DEFAULT_DIRECTION_CAP = 2000  # Soft ceiling; quality decay handles the real pruning


@dataclass
class ExperimentRecord:
    """Record of a single experiment."""
    exp_id: str
    domain: str
    concept_title: str
    concept_description: str
    status: str  # "success", "failure", "timeout", "trivial_rejected"
    files_produced: int = 0
    timestamp: str = ""
    key_theorems: List[str] = field(default_factory=list)
    # v2: quality tracking fields
    prompt_text: str = ""
    proof_quality: str = ""  # "trivial", "substantial", "partial"
    retry_of: str = ""       # parent exp_id if this is a retry
    retry_count: int = 0     # how many retries for this concept
    quality_score: float = 0.0  # composite quality from evaluate()
    quality_detail: Optional[Dict] = None  # 8-axis QualityScore breakdown


class ResearchMemory:
    """Persistent memory to avoid repetitive research."""

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        self.memory_file = self.workspace / "research_memory.jsonl"
        self._cache: List[ExperimentRecord] = []
        self._titles: Set[str] = set()
        self._descriptions: Set[str] = set()
        self._load()

    def _load(self) -> None:
        """Load memory from disk."""
        if not self.memory_file.exists():
            return
        with open(self.memory_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                    record = ExperimentRecord(
                        exp_id=data.get("exp_id", ""),
                        domain=data.get("domain", ""),
                        concept_title=data.get("concept_title", ""),
                        concept_description=data.get("concept_description", ""),
                        status=data.get("status", ""),
                        files_produced=data.get("files_produced", 0),
                        timestamp=data.get("timestamp", ""),
                        key_theorems=data.get("key_theorems", []),
                        prompt_text=data.get("prompt_text", ""),
                        proof_quality=data.get("proof_quality", ""),
                        retry_of=data.get("retry_of", ""),
                        retry_count=data.get("retry_count", 0),
                        quality_score=data.get("quality_score", 0.0),
                        quality_detail=data.get("quality_detail"),
                    )
                    self._cache.append(record)
                    self._titles.add(record.concept_title.lower())
                    self._descriptions.add(record.concept_description.lower()[:100])
                except Exception:
                    pass
        # Auto-prune if file is too large (> 5 MB or > 500 records)
        if self.memory_file.exists() and (self.memory_file.stat().st_size > 5_000_000 or len(self._cache) > 500):
            self.prune_memory_file(max_records=500)

    def prune_memory_file(self, max_records: int = 500) -> int:
        """Prune research_memory.jsonl to keep only the most recent max_records."""
        if not self.memory_file.exists():
            return 0
        original_count = len(self._cache)
        if original_count > max_records:
            self._cache = self._cache[-max_records:]
        tmp_file = self.memory_file.with_suffix(".tmp")
        with open(tmp_file, "w", encoding="utf-8") as f:
            for record in self._cache:
                f.write(json.dumps({
                    "exp_id": record.exp_id,
                    "domain": record.domain,
                    "concept_title": record.concept_title,
                    "concept_description": record.concept_description,
                    "status": record.status,
                    "files_produced": record.files_produced,
                    "timestamp": record.timestamp,
                    "key_theorems": record.key_theorems,
                    "prompt_text": (record.prompt_text[:1000] if record.prompt_text else ""),
                    "proof_quality": record.proof_quality,
                    "retry_of": record.retry_of,
                    "retry_count": record.retry_count,
                    "quality_score": record.quality_score,
                    "quality_detail": record.quality_detail,
                }) + "\n")
        tmp_file.replace(self.memory_file)
        pruned_count = max(0, original_count - len(self._cache))
        print(f"[ResearchMemory] Pruned memory file. New size: {self.memory_file.stat().st_size / 1e6:.2f} MB ({len(self._cache)} records retained)")
        return pruned_count

    def record(self, record: ExperimentRecord) -> None:
        """Record an experiment."""
        if not record.timestamp:
            record.timestamp = datetime.now(timezone.utc).isoformat()
        self._cache.append(record)
        self._titles.add(record.concept_title.lower())
        self._descriptions.add(record.concept_description.lower()[:100])
        with open(self.memory_file, "a", encoding="utf-8") as f:
            f.write(json.dumps({
                "exp_id": record.exp_id,
                "domain": record.domain,
                "concept_title": record.concept_title,
                "concept_description": record.concept_description,
                "status": record.status,
                "files_produced": record.files_produced,
                "timestamp": record.timestamp,
                "key_theorems": record.key_theorems,
                "prompt_text": record.prompt_text,
                "proof_quality": record.proof_quality,
                "retry_of": record.retry_of,
                "retry_count": record.retry_count,
                "quality_score": record.quality_score,
                "quality_detail": record.quality_detail,
            }) + "\n")

    def has_been_explored(self, title: str, description: str) -> bool:
        """Check if a concept has already been explored (exact match)."""
        title_lower = title.lower()
        desc_snippet = description.lower()[:100]
        return title_lower in self._titles or desc_snippet in self._descriptions

    def get_domain_history(self, domain: str, limit: int = 50) -> List[ExperimentRecord]:
        """Get recent experiments in a domain."""
        return [r for r in self._cache if r.domain == domain][-limit:]

    def get_successful_titles(self, domain: str = "") -> Set[str]:
        """Get titles of successful experiments."""
        return {
            r.concept_title.lower()
            for r in self._cache
            if r.status == "success" and (not domain or r.domain == domain)
        }

    def get_all_titles(self) -> Set[str]:
        """Get all explored titles."""
        return self._titles.copy()

    def suggest_novel_direction(self, domain: str) -> str:
        """Suggest a research direction based on history."""
        history = self.get_domain_history(domain)
        if not history:
            return "Explore foundational theorems in this domain."

        # Identify gaps: what hasn't been tried?
        successful = [r for r in history if r.status == "success"]
        failed = [r for r in history if r.status != "success"]

        if len(successful) > len(failed):
            return (
                f"Domain {domain} has {len(successful)} successes. "
                "Try pushing into adjacent domains or harder theorems."
            )
        elif len(failed) > len(successful):
            return (
                f"Domain {domain} has many failures. "
                "Try simpler, more concrete theorems with stronger lemmas."
            )
        else:
            return (
                f"Domain {domain} is balanced. "
                "Explore connections to other domains for cross-pollination."
            )

    def build_exclusion_prompt(self) -> str:
        """Build a prompt fragment listing explored concepts to avoid."""
        recent = self._cache[-20:] if len(self._cache) > 20 else self._cache
        if not recent:
            return ""

        lines = ["Previously explored concepts (AVOID these exact ideas):"]
        for r in recent:
            lines.append(f"  - {r.concept_title} ({r.domain}): {r.concept_description[:80]}...")

        return "\n".join(lines)

    def build_success_patterns(self) -> str:
        """Analyze successful experiments and extract patterns."""
        successes = [r for r in self._cache if r.status == "success"][-10:]
        if not successes:
            return ""
        lines = ["Successful concept patterns (EMULATE these):"]
        for r in successes:
            lines.append(f"  - {r.concept_title}: {r.concept_description[:80]}...")
        return "\n".join(lines)

    def get_trivial_count(self, domain: str = "") -> int:
        """Count how many trivial proofs were produced."""
        return sum(
            1 for r in self._cache
            if r.proof_quality == "trivial" and (not domain or r.domain == domain)
        )

    def get_best_prompts(self, domain: str, min_quality: str = "substantial") -> List[ExperimentRecord]:
        """Return prompts that produced good results for a domain."""
        quality_order = {"trivial": 0, "partial": 1, "substantial": 2}
        min_score = quality_order.get(min_quality, 2)
        results = []
        for r in self._cache:
            if r.domain == domain and r.prompt_text:
                score = quality_order.get(r.proof_quality, 0)
                if score >= min_score:
                    results.append(r)
        return results[-20:]  # most recent 20

    def suggest_improved_prompt(self, failed_exp_id: str) -> str:
        """Analyze a failed experiment and suggest prompt improvements."""
        failed = next((r for r in self._cache if r.exp_id == failed_exp_id), None)
        if not failed:
            return ""
        # Find successful experiments in the same domain
        successes = [r for r in self._cache
                     if r.domain == failed.domain
                     and r.proof_quality in ("substantial", "partial")
                     and r.prompt_text]
        if not successes:
            return ""
        best = successes[-1]
        lines = [
            "PROMPT AUTORESEARCH ANALYSIS:",
            f"Failed experiment: {failed.concept_title} ({failed.exp_id})",
            f"Proof quality: {failed.proof_quality}",
            f"Status: {failed.status}",
            "",
            "Best successful prompt in this domain:",
            f"  Concept: {best.concept_title}",
            f"  Quality: {best.proof_quality}",
            f"  Prompt excerpt (first 500 chars): {best.prompt_text[:500]}...",
            "",
            "SUGGESTED IMPROVEMENTS:",
            "1. Make the theorem statement more concrete — avoid True/Prop tautologies.",
            "2. Reference specific mathlib lemmas or catalog theorems in the prompt.",
            "3. Add a concrete numerical or structural constraint to the theorem.",
            "4. Use the creativity directives to force a non-obvious proof strategy.",
        ]
        return "\n".join(lines)

    def get_retry_history(self, original_exp_id: str) -> List[ExperimentRecord]:
        """Get all retries for an original experiment."""
        return [r for r in self._cache if r.retry_of == original_exp_id]


@dataclass
class FutureDirection:
    """A research direction extracted from Aristotle's FUTURE_DIRECTIONS.md output."""
    id: str
    title: str
    description: str
    source_exp_id: str
    source_path: str
    domains: List[str] = field(default_factory=list)
    proof_strategy: str = ""
    research_mode: str = "team"
    depth_estimate: int = 3
    priority_score: float = 0.5
    status: str = "available"  # available, in_progress, completed, failed, pruned
    consumed_by_exp_id: str = ""
    timestamp: str = ""
    prune_reason: str = ""
    pruned_at: str = ""
    # --- New fields for hybrid FUTURE_DIRECTIONS format ---
    catalog_references: List[str] = field(default_factory=list)    # e.g. ["Bridges.Basic.lean", "Algebra.Advanced.berggren_isogeny"]
    ambition_level: str = "extension"                             # "grand_challenge" or "extension"
    lineage_refs: List[str] = field(default_factory=list)          # e.g. ["fd_0003", "exp_20250517_001"]
    domain_bridges: List[str] = field(default_factory=list)        # e.g. ["NumberTheory <-> Tropical", "Algebra <-> Physics"]
    # --- Multi-cycle research arcs ---
    arc_id: str = ""                                              # groups related directions (e.g. "arc_001")
    arc_position: int = 0                                         # 1=foundation, 2=main theorem, 3=applications
    # --- Quality feedback ---
    outcome_quality: float = 0.0                                  # 0-1 score from cycle result (0=untested, 1=excellent)
    domain_quality_penalty: float = 0.0                            # accumulated feedback penalty/bonus (-1.0 to +1.0)
    # --- Retry tracking ---
    attempt_count: int = 0                                         # number of times this direction was dispatched
    last_attempt_time: str = ""                                    # ISO timestamp of last dispatch attempt
    # --- Decomposition ---
    parent_direction: str = ""
    decomposed_from_job: str = ""
    decomposition_depth: int = 0
    quarantined_until: str = ""                                    # ISO timestamp; if set, exclude from dispatch until then
    # --- Cleanup tracking ---
    last_reviewed_at: str = ""                                     # ISO timestamp of last Pi-Agent cleanup review
    cleanup_review_count: int = 0                                  # number of times reviewed by Pi-Agent (kept each time)
    # --- Syntactic proof stubs ---
    lean_theorem_stub: str = ""                                    # tentative Lean 4 theorem stub for early syntax validation
    # --- Multi-cycle research threads ---
    thread_id: str = ""                                            # if set, this direction is a follow-up in a research thread
    # --- 50/50 research menu categories ---
    category: str = ""                                             # famous_subtask | cross_domain_bridge | abduction_followup
    # --- GitHub Injection ---
    source: str = ""                                               # e.g., "github_injection"
    github_issue: int = 0                                          # Issue number to close when processed

    def get_category(self) -> str:
        """Return explicit category if set, else infer from other fields."""
        if self.category:
            return self.category
        if self.thread_id:
            return "abduction_followup"
        if self.domain_bridges:
            return "cross_domain_bridge"
        if self.ambition_level == "grand_challenge":
            return "famous_subtask"
        return ""

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "source_exp_id": self.source_exp_id,
            "source_path": self.source_path,
            "domains": self.domains,
            "proof_strategy": self.proof_strategy,
            "research_mode": self.research_mode,
            "depth_estimate": self.depth_estimate,
            "priority_score": self.priority_score,
            "status": self.status,
            "consumed_by_exp_id": self.consumed_by_exp_id,
            "timestamp": self.timestamp,
            "catalog_references": self.catalog_references,
            "ambition_level": self.ambition_level,
            "lineage_refs": self.lineage_refs,
            "domain_bridges": self.domain_bridges,
            "arc_id": self.arc_id,
            "arc_position": self.arc_position,
            "outcome_quality": self.outcome_quality,
            "domain_quality_penalty": self.domain_quality_penalty,
            "prune_reason": self.prune_reason,
            "pruned_at": self.pruned_at,
            "attempt_count": self.attempt_count,
            "last_attempt_time": self.last_attempt_time,
            "quarantined_until": self.quarantined_until,
            "last_reviewed_at": self.last_reviewed_at,
            "cleanup_review_count": self.cleanup_review_count,
            "lean_theorem_stub": self.lean_theorem_stub,
            "thread_id": self.thread_id,
            "category": self.category,
            "parent_direction": self.parent_direction,
            "decomposed_from_job": self.decomposed_from_job,
            "decomposition_depth": self.decomposition_depth,
            "source": self.source,
            "github_issue": self.github_issue,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "FutureDirection":
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})


class FutureDirectionsManager:
    """Manages a persistent list of future research directions extracted from
    Aristotle's outputs. Tracks consumption status so directions are removed
    from the available list when they're being researched."""

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        # Single source of truth: the persisted Packages/ copy (git-tracked).
        # The workspace copy was eliminated to avoid duplication — docs/ rsyncs
        # straight from Packages/, so this is the only file that matters.
        repo_root = self.workspace.parent.parent
        pkg_file = repo_root / "Packages" / "future_directions.json"
        ws_pkg_file = self.workspace / "Packages" / "future_directions.json"
        ws_parent_pkg = self.workspace.parent / "Packages" / "future_directions.json"
        ws_file = self.workspace / "future_directions.json"
        ws_pkg_file = self.workspace / "Packages" / "future_directions.json"
        ws_parent_pkg = self.workspace.parent / "Packages" / "future_directions.json"
        if ws_file.exists():
            self._file = ws_file
        elif ws_pkg_file.exists():
            self._file = ws_pkg_file
        elif ws_parent_pkg.exists():
            self._file = ws_parent_pkg
        elif self.workspace.name == ".aether_workspace" or (self.workspace.parent / "Catalog").exists():
            self._file = pkg_file
        else:
            self._file = ws_file
        self._directions: List[FutureDirection] = []
        self._pruned: List[FutureDirection] = []
        self._cycle_syntheses: Dict[str, str] = {}  # exp_id -> synthesis text
        self._recent_domain_counts: Dict[str, int] = {}  # domain -> count in recent completions
        self._recent_theme_keywords: Dict[str, int] = {}  # keyword -> count in recent completions
        self._selection_log: List[str] = []  # recent selected direction categories for 50/50 balancing
        self._restoring_from_git = False  # guards the corrupt-file git-HEAD fallback
        self._load()

    def _load_from_git_head(self) -> bool:
        """Best-effort pool restore from the last committed copy of the file.

        Used only when the on-disk pool JSON is corrupt: the git-tracked
        Packages/future_directions.json at HEAD is the last known-good state.
        """
        try:
            root = subprocess.run(
                ["git", "-C", str(self._file.parent), "rev-parse", "--show-toplevel"],
                capture_output=True, text=True, timeout=30, check=True,
            ).stdout.strip()
            if not root:
                return False
            rel = self._file.resolve().relative_to(Path(root)).as_posix()
            blob = subprocess.run(
                ["git", "-C", root, "show", f"HEAD:{rel}"],
                capture_output=True, text=True, timeout=30, check=True,
            ).stdout
            if not blob.strip():
                return False
            backup = self._file.with_name(self._file.name + ".githead-restore")
            backup.write_text(blob, encoding="utf-8")
            original_file = self._file
            self._file = backup
            try:
                self._load()
            finally:
                self._file = original_file
                try:
                    backup.unlink()
                except Exception:
                    pass
            return bool(self._directions)
        except Exception as e:
            print(f"[FutureDirections] git-HEAD pool restore failed: {e}")
            return False

    def _next_id(self) -> str:
        """Generate a unique direction ID by finding the max existing fd_NNNN and incrementing."""
        max_num = -1
        for d in self._directions:
            if d.id.startswith("fd_"):
                try:
                    num = int(d.id[3:])
                    if num > max_num:
                        max_num = num
                except ValueError:
                    pass
        for d in self._pruned:
            if d.id.startswith("fd_"):
                try:
                    num = int(d.id[3:])
                    if num > max_num:
                        max_num = num
                except ValueError:
                    pass
        return f"fd_{max_num + 1:04d}"

    def _dedup_ids(self) -> None:
        """Fix duplicate IDs by re-assigning colliding ones with new unique IDs."""
        seen = set()
        dupes = []
        for d in self._directions:
            if d.id in seen:
                dupes.append(d)
            else:
                seen.add(d.id)
        for d in dupes:
            old_id = d.id
            d.id = self._next_id()
            # Update any consumed_by_exp_id references to the old ID
            for other in self._directions:
                if other.consumed_by_exp_id == old_id:
                    other.consumed_by_exp_id = d.id
            seen.add(d.id)
        if dupes:
            print(f"[FutureDirections] Fixed {len(dupes)} duplicate IDs")

    def _load(self) -> None:
        if not self._file.exists():
            return
        try:
            data = json.loads(self._file.read_text(encoding="utf-8"))
            if isinstance(data, list):
                # Legacy format: flat list of directions
                self._directions = [FutureDirection.from_dict(d) for d in data]
                self._pruned = []
            elif isinstance(data, dict):
                self._directions = [FutureDirection.from_dict(d) for d in data.get("directions", [])]
                raw_pruned = [FutureDirection.from_dict(d) for d in data.get("pruned", [])]
                if raw_pruned:
                    for pd in raw_pruned:
                        pd.status = "available"
                        pd.prune_reason = ""
                        pd.pruned_at = ""
                        pd.consumed_by_exp_id = ""
                        self._directions.append(pd)
                self._pruned = []
                
                raw_syntheses = data.get("cycle_syntheses", {})
                self._cycle_syntheses = raw_syntheses if isinstance(raw_syntheses, dict) else {}
                
                raw_domain_counts = data.get("recent_domain_counts", {})
                self._recent_domain_counts = raw_domain_counts if isinstance(raw_domain_counts, dict) else {}
                
                raw_keywords = data.get("recent_theme_keywords", {})
                self._recent_theme_keywords = raw_keywords if isinstance(raw_keywords, dict) else {}

                raw_selection_log = data.get("selection_log", [])
                self._selection_log = raw_selection_log if isinstance(raw_selection_log, list) else []
        except Exception as e:
            # One corrupt read must NEVER silently wipe the ~2000-direction pool:
            # preserve the corrupt bytes for forensics, restore the last committed
            # copy when possible, and fail loudly either way.
            print(f"[FutureDirections] ERROR: failed to parse {self._file}: {e}")
            try:
                stamp = time.strftime("%Y%m%dT%H%M%SZ")
                shutil.copy2(self._file,
                             self._file.with_name(self._file.name + f".corrupt-{stamp}"))
                print(f"[FutureDirections] Corrupt pool preserved as "
                      f"{self._file.name}.corrupt-{stamp}")
            except Exception:
                pass
            self._directions = []
            self._pruned = []
            self._cycle_syntheses = {}
            self._recent_domain_counts = {}
            self._recent_theme_keywords = {}
            self._selection_log = []
            if not self._restoring_from_git:
                self._restoring_from_git = True
                try:
                    if self._load_from_git_head():
                        print(f"[FutureDirections] Pool restored from git HEAD "
                              f"({len(self._directions)} directions)")
                        return
                finally:
                    self._restoring_from_git = False
            print("[FutureDirections] WARNING: proceeding with an EMPTY pool; "
                  "the next save will overwrite the corrupt file")
            return
        self._dedup_ids()

        # Recover stale in_progress directions whose jobs no longer exist
        self._recover_stale_directions()

    def _recover_stale_directions(self) -> None:
        """Release in_progress directions whose consumed_by_exp_id references a job
        that no longer exists in inflight_jobs.json.

        Three states for a consumed direction's job:
          1. Job is currently in inflight_jobs.json (still running) — KEEP in_progress
          2. Job was completed (analytics has the record) — mark COMPLETED.
             This was the Sonic cycle bug where completed directions were reset
             to available and re-dispatched.
          3. Job was abandoned (no analytics record, no inflight) — truly stale,
             reset to available.
        """
        inflight_path = self.workspace / "inflight_jobs.json"
        if not inflight_path.exists():
            active_job_ids = set()
        else:
            try:
                inflight_data = json.loads(inflight_path.read_text(encoding="utf-8"))
                if isinstance(inflight_data, dict):
                    active_job_ids = {
                        v.get("job_id", "") for v in inflight_data.values()
                        if isinstance(v, dict) and v.get("job_id")
                    }
                elif isinstance(inflight_data, list):
                    active_job_ids = {
                        j.get("job_id", "") for j in inflight_data
                        if isinstance(j, dict) and j.get("job_id")
                    }
                else:
                    active_job_ids = set()
            except Exception:
                active_job_ids = set()

        # Analytics is the source of truth for "completed" jobs.
        # Failed/rejected jobs are NOT completions: a direction whose job failed
        # must fall through to the stale branch and return to the pool, not be
        # marked completed (which silently consumes its research slot).
        completed_job_ids = set()
        analytics_path = self.workspace / "cycle_analytics.json"
        if analytics_path.exists():
            try:
                analytics = json.loads(analytics_path.read_text(encoding="utf-8"))
                completed_job_ids = {
                    r.get("job_id", "") for r in analytics.get("records", [])
                    if r.get("job_id") and not r.get("failed")
                }
            except Exception:
                pass

        recovered = 0
        completed_via_recovery = 0
        for d in self._directions:
            if d.status == "in_progress" and d.consumed_by_exp_id:
                if d.consumed_by_exp_id in active_job_ids:
                    continue  # Job is still running
                if d.consumed_by_exp_id in completed_job_ids:
                    # Job was completed but never marked completed on this direction
                    d.status = "completed"
                    recovered += 1
                    completed_via_recovery += 1
                else:
                    # Truly stale — no record anywhere.
                    # But wait! If it was attempted very recently (e.g. in the last 15 minutes),
                    # it might be in the middle of being prepared/dispatched. Do not recover it yet!
                    if d.last_attempt_time:
                        try:
                            from datetime import datetime, timezone
                            attempt_ts = datetime.fromisoformat(d.last_attempt_time)
                            if attempt_ts.tzinfo is None:
                                attempt_ts = attempt_ts.replace(tzinfo=timezone.utc)
                            now = datetime.now(timezone.utc)
                            if (now - attempt_ts).total_seconds() < 900:  # 15 minutes grace period
                                continue
                        except Exception:
                            pass
                    d.status = "available"
                    d.consumed_by_exp_id = ""
                    recovered += 1
        if recovered:
            self._save()
            if completed_via_recovery:
                print(f"[FutureDirections] Recovered {recovered} direction(s): "
                      f"{completed_via_recovery} marked completed, "
                      f"{recovered - completed_via_recovery} reset to available")
            else:
                print(f"Recovered {recovered} stale direction(s) back to available")

    def _save(self) -> None:
        self.workspace.mkdir(parents=True, exist_ok=True)
        self._file.parent.mkdir(parents=True, exist_ok=True)
        # Auto-archive completed directions if they exceed retention limit (50).
        # An archiver failure must never block state persistence — the pool write
        # below is the critical operation (audit 2026-08-21: an archive crash
        # escaping _save left every direction stuck in_progress forever).
        completed_count = len([d for d in self._directions if d.status == "completed"])
        if completed_count > 50:
            try:
                self.archive_completed_directions(keep_recent=50, max_per_file=200)
            except Exception as e:
                print(f"[FutureDirections] WARNING: auto-archive failed (pool save "
                      f"continues): {e}")

        payload = json.dumps({
            "directions": sorted([d.to_dict() for d in self._directions], key=lambda d: d.get("id", "")),
            "pruned": sorted([d.to_dict() for d in self._pruned], key=lambda d: d.get("id", "")),
            "cycle_syntheses": self._cycle_syntheses,
            "recent_domain_counts": self._recent_domain_counts,
            "recent_theme_keywords": self._recent_theme_keywords,
            "selection_log": self._selection_log,
        }, indent=2, ensure_ascii=False, sort_keys=True)
        # Atomic write: a crash mid-write must never leave a truncated pool file
        # behind (the next _load would otherwise face corrupt JSON).
        tmp_file = self._file.with_name(self._file.name + ".tmp")
        tmp_file.write_text(payload, encoding="utf-8")
        os.replace(tmp_file, self._file)
        self._update_snapshot()

    def store_synthesis(self, exp_id: str, synthesis_text: str) -> None:
        """Store a cycle synthesis (from FUTURE_DIRECTIONS.md ## Synthesis section)."""
        if synthesis_text and len(synthesis_text) > 20:
            self._cycle_syntheses[exp_id] = synthesis_text
            self._save()

    def _update_snapshot(self) -> None:
        """Write a display-friendly snapshot for CI/GitHub Pages consumption."""
        repo_root = self.workspace.parent
        if not (repo_root / "Catalog").exists() and (repo_root.parent / "Catalog").exists():
            repo_root = repo_root.parent
        snapshot_path = repo_root / "Packages" / "future_directions_snapshot.json"
        if not snapshot_path.parent.exists():
            return
        active = [d for d in self._directions if d.status not in ("completed", "pruned")]
        display = []
        for d in active:
            display.append({
                "id": d.id,
                "title": d.title,
                "description": d.description,
                "domains": d.domains,
                "priority_score": d.priority_score,
                "status": d.status,
                "research_mode": d.research_mode,
                "source_exp_id": d.source_exp_id,
                "consumed_by_exp_id": d.consumed_by_exp_id,
                "timestamp": d.timestamp,
                "catalog_references": d.catalog_references,
                "ambition_level": d.ambition_level,
                "lineage_refs": d.lineage_refs,
                "domain_bridges": d.domain_bridges,
                "proof_strategy": d.proof_strategy,
            })
        display.sort(key=lambda x: (-x["priority_score"], x.get("id", "")))
        snapshot_path.write_text(
            json.dumps(display, indent=2, ensure_ascii=False, sort_keys=True),
            encoding="utf-8",
        )

    def add_direction(self, direction: FutureDirection) -> bool:
        """Add a new future direction. Skips if a very similar title already exists.

        Returns True when the direction was actually inserted, False when dedup
        dropped it — so callers can count real adds instead of attempts."""
        # Fix auto-generated cycle-summary titles at ingestion time
        if direction.title.startswith("This research cycle") or direction.title.startswith("This cycle") or direction.title.startswith("This work"):
            direction.title = self._fix_auto_title(direction.title, direction.description)
        title_lower = direction.title.lower().strip()
        title_tokens = set(re.findall(r'[a-z0-9]+', title_lower))
        for existing in self._directions:
            if existing.title.lower().strip() == title_lower:
                return False
            # Title token-overlap dedup: catches template families whose titles
            # differ only in a word or two (audit 2026-08-21: 499 such pairs).
            existing_tokens = set(re.findall(r'[a-z0-9]+', existing.title.lower()))
            if title_tokens and existing_tokens:
                overlap = len(title_tokens & existing_tokens) / max(
                    1, min(len(title_tokens), len(existing_tokens)))
                if overlap > 0.7:
                    return False
            # Also skip if descriptions are very similar (>80% word overlap)
            existing_words = set(existing.description.lower().split())
            new_words = set(direction.description.lower().split())
            if existing_words and new_words:
                overlap = len(existing_words & new_words) / max(len(existing_words), len(new_words))
                if overlap > 0.8:
                    return False
        if not direction.timestamp:
            direction.timestamp = datetime.now(timezone.utc).isoformat()
        # Cap domains at 2 to prevent domain count inflation
        if len(direction.domains) > 2:
            direction.domains = direction.domains[:2]
        # Normalize domain names to valid Catalog directories
        try:
            from output_organizer import normalize_domain
            direction.domains = [normalize_domain(d) for d in direction.domains]
            # Deduplicate after normalization (e.g. "NumberTheory" and "Algebra" both → "Algebra")
            seen = set()
            unique = []
            for d in direction.domains:
                if d not in seen:
                    seen.add(d)
                    unique.append(d)
            direction.domains = unique[:2]
        except ImportError:
            pass
        self._directions.append(direction)
        self._save()
        return True

    def _is_quality_direction(self, fd: FutureDirection) -> bool:
        """Quality gate for extracted directions.

        Rejects:
        - generic titles (e.g. "Further Research", "Conjecture 4:")
        - descriptions with no directional signal (future-oriented verbs or
          conjecture markers) — a terse real conjecture passes, a padded recap
          without direction does not (the old 80-char rule did the opposite)
        - directions that map only to Bridges with no proof strategy
        """
        from pi_agent_client import PiAgentClient
        desc = fd.description or ""
        if PiAgentClient._is_generic_title(fd.title):
            return False
        # Bridges-only directions need a concrete proof strategy
        if set(fd.domains) == {"Bridges"} and not fd.proof_strategy.strip():
            return False
        direction_signals = (
            "prove", "show", "extend", "formalize", "conjecture", "theorem",
            "establish", "derive", "construct", "generalize", "resolve",
            "develop", "investigate", "study", "open problem", "open question",
            "hypothesis", "if true", "if false", "test",
            "remains open", "remain open", "open.", "open)",
            "future work", "next step", "classify", "compute",
        )
        has_signal = any(k in desc.lower() for k in direction_signals)
        if len(desc) >= 120 and has_signal:
            return True
        if len(desc) >= 30 and has_signal and len(desc) < 120:
            # Terse but genuinely directional (e.g. a one-sentence conjecture)
            return True
        return False

    def add_directions_from_text(
        self, text: str, source_exp_id: str, source_path: str
    ) -> tuple:
        """Parse a FUTURE_DIRECTIONS.md text and add structured directions.

        Delegates to fd_splitter.split_directions_from_text — the validated
        section-aware cascade.  Returns (count_of_directions_added, synthesis_text).
        """
        from fd_splitter import split_directions_from_text
        return split_directions_from_text(self, text, source_exp_id, source_path)

    @staticmethod
    def _fix_auto_title(title: str, description: str = "") -> str:
        """Extract a proper research topic title from auto-generated cycle-summary titles.

        Titles like "This research cycle established a rigorous formal framework for the
        entropy power inequality" describe what the PREVIOUS cycle did, not what to research.
        Extract the actual mathematical topic from the tail of such titles.

        Returns a cleaned title, or the original if it doesn't match the pattern.
        """
        import re
        bad_prefixes = [
            r"^This research cycle (established|demonstrated|showed|proved|introduced|developed|created|built|extended|advanced|explored|investigated|initiated|provided|produced)\s+",
            r"^This cycle (established|demonstrated|showed|proved|introduced|developed|created|built|extended|advanced|explored|investigated|initiated|provided|produced)\s+",
            r"^This work (established|demonstrated|showed|proved|introduced|developed|created|built|extended|advanced|explored|investigated|initiated|provided|produced)\s+",
        ]
        # Remove articles after the verb phrase ("a ", "an ", "the ")
        article_re = r"(?:a |an |the )?"
        for prefix in bad_prefixes:
            m = re.match(prefix + article_re, title, re.IGNORECASE)
            if m:
                remainder = title[m.end():].strip()
                # Capitalize first letter
                if remainder:
                    remainder = remainder[0].upper() + remainder[1:]
                # Truncate at a reasonable length for a title
                if len(remainder) > 120:
                    # Try to cut at a natural boundary (comma, period, colon, or "and")
                    cut = re.search(r'[,.;:]\s', remainder[:120])
                    if cut:
                        remainder = remainder[:cut.start()]
                    else:
                        remainder = remainder[:117] + "..."
                return remainder if remainder else title
        return title

    def fix_existing_auto_titles(self) -> int:
        """Fix all existing directions with auto-generated cycle-summary titles.

        Returns the number of titles fixed.
        """
        fixed = 0
        for d in self._directions:
            if d.title.startswith("This research cycle") or d.title.startswith("This cycle") or d.title.startswith("This work"):
                new_title = self._fix_auto_title(d.title, d.description)
                if new_title != d.title:
                    print(f"[TitleFix] \"{d.title[:60]}...\" → \"{new_title[:60]}\"")
                    d.title = new_title
                    fixed += 1
        if fixed:
            self._save()
        return fixed

    @staticmethod
    def _extract_bold_field(body: str, field_name: str) -> str:
        """Extract value after **Field Name**: from a direction body."""
        import re
        pattern = rf'\*\*{field_name}\*\*\s*:\s*(.*?)(?=\n\*\*|\Z)'
        m = re.search(pattern, body, re.DOTALL)
        return m.group(1).strip() if m else ""

    @staticmethod
    def _infer_domains(text: str) -> List[str]:
        """Infer likely Catalog domains from text content.

        Returns domain names that match valid Catalog directory names,
        so they survive normalize_domain() without collapsing to Speculative.
        """
        text_lower = text.lower()
        domain_keywords = {
            "Pythagorean": ["diophantine", "goldbach", "riemann",
                            "zeta", "perfect number", "collatz", "twin prime", "modular form",
                            "euler-mascheroni", "fermat", "sieve", "lehmer", "beal"],
            "NumberTheory": ["number theory", "prime", "coprime", "divisibility", "totient",
                             "congruence", "legendre", "carmichael", "pseudoprime"],
            "Algebra": ["algebra", "ring", "group", "field", "galois", "module",
                        "representation", "homomorphism", "ideal", "jacobian",
                        "quadratic form", "algebraic", "differentiable",
                        "variational", "integral", "banach", "hilbert space", "functional analysis"],
            "Combinatorics": ["combinatorial", "extremal", "ramsey", "graph coloring",
                             "hadamard", "frankl", "union-closed", "erdos", "partition",
                             "matroid", "finset", "graph", "bipartite", "poset", "catalan"],
            "Geometry": ["geometry", "geometric", "curve", "surface", "manifold",
                         "projective", "affine", "convex", "kakeya", "algebraic curve",
                         "schubert", "enumerative", "homotopy", "homology", "poincaré",
                         "knot", "fundamental group", "covering space", "cohomology",
                         "simplicial", "topological"],
            "Computation": ["turing", "complexity", "circuit", "reversible", "automaton",
                            "p vs np", "algorithm", "computability", "np-hard",
                            "percolation", "random", "stochastic",
                            "probability", "martingale", "ergodic"],
            "Tropical": ["tropical", "min-plus", "semiring", "maslov", "dequantization",
                         "idempotent"],
            "Physics": ["quantum", "feynman", "path integral", "wave", "lorentz",
                        "yang-mills", "hamiltonian", "lagrangian", "thermodynamic",
                        "navier-stokes", "mass gap", "energy", "spectral",
                        "pde"],
            "Cryptography": ["crypto", "spb", "diffie-hellman", "discrete log",
                             "lattice", "dilithium", "encryption", "post-quantum",
                             "zero-knowledge", "homomorphic", "key exchange",
                             "cipher", "authentication"],
            "EML": ["eml", "exponential-multiplicative", "exp-log", "closure operator"],
            "Bridges": ["bridge", "cross-domain", "unification", "functor",
                        "correspondence", "langlands", "category-theoretic"],
            "MachineLearning": ["neural", "learning", "approximation", "deep learning",
                                "generalization", "transformer", "attention", "robustness",
                                "adversarial", "pac-bayes"],
            "Logic": ["logic", "type theory", "homotopy type", "proof", "decidable",
                      "constructive", "gödel", "incompleteness", "axiom", "ordinal"],
            "Speculative": ["speculative", "science fiction", "consciousness",
                            "alien", "game of life"],
        }
        domain_scores = []
        for domain, keywords in domain_keywords.items():
            score = sum(1 for kw in keywords if kw in text_lower)
            if score > 0:
                domain_scores.append((domain, score))
        # Cap at 2 domains: keep the 2 most relevant by keyword match count
        domain_scores.sort(key=lambda x: -x[1])
        domains = [d for d, s in domain_scores[:2]]
        return domains

    def get_available_directions(
        self, limit: int = 10, domain_filter: Optional[str] = None
    ) -> List[FutureDirection]:
        """Return available directions, optionally filtered by domain, sorted by priority.

        Excludes quarantined directions (those that produced Q<0.3 and have
        a cooldown active). Auto-cleans expired quarantines on every call.
        """
        # Lazy cleanup of expired quarantines
        self.cleanup_expired_quarantines()
        available = [
            d for d in self._directions
            if d.status == "available" and not self.is_quarantined(d)
        ]
        if domain_filter:
            available = [d for d in available if domain_filter in d.domains or not d.domains]
        available.sort(key=lambda d: d.priority_score, reverse=True)
        return available[:limit]

    def _domain_counts(self) -> Dict[str, int]:
        """Count how many available directions each domain has."""
        counts: Dict[str, int] = {}
        for d in self._directions:
            if d.status == "available":
                for domain in d.domains:
                    counts[domain] = counts.get(domain, 0) + 1
        return counts

    def select_direction_weighted(
        self, domain_filter: Optional[str] = None,
        recent_domain_quality: Optional[Dict[str, float]] = None,
        catalog_analyzer=None,
        exclude_domains: Optional[list] = None,
        exclude_titles: Optional[list] = None,
        open_issue_numbers: Optional[set] = None,
    ) -> Optional[FutureDirection]:
        """Select a direction weighted by computed quality score (not just priority).

        Domains with recent high-quality results get boosted via outcome_bonus.
        Domains with recent low-quality results get penalized.
        Overrepresented domains get inverse-frequency penalty to prevent
        Pythagorean/Algebra from dominating dispatch.

        domain_filter: only select directions containing this domain
        exclude_domains: exclude directions containing any of these domains
        exclude_titles: exclude directions whose title matches any in this list (prevents duplicate dispatch)
        open_issue_numbers: set of GitHub issue numbers that are currently OPEN.
            When provided, the injected-direction bypass only returns a
            github_injection direction whose issue is in this set and whose
            attempt_count is under the cap — mirroring dispatchable_injected_directions.
            When None (issue state unknown), injected directions are EXCLUDED from
            the bypass so they cannot be re-dispatched by the standard discovery
            path; they must instead be dispatched via the dedicated injected-issue
            block in aether_tick (which fetches live issue state). This prevents
            the re-publish loop where a closed-issue injected direction kept being
            re-dispatched every tick, overwriting its package and re-commenting.
        """
        # Lazy cleanup of expired quarantines
        self.cleanup_expired_quarantines()
        available = [
            d for d in self._directions
            if d.status == "available" and not self.is_quarantined(d)
        ]

        # --- Bypass for injected directions (high priority) ---
        # Only return an injected direction when we can PROVE its GitHub issue is
        # still open AND it has not exhausted its attempt cap. Without live issue
        # state (open_issue_numbers is None) we must NOT dispatch an injected
        # direction here at all — a closed issue means the work is already done,
        # and re-dispatching overwrites the published package and re-comments on
        # the closed issue (regression: Lean#156). The standard injected-dispatch
        # block in aether_tick supplies open_issue_numbers; other callers pass
        # None and fall through to weighted selection of non-injected directions.
        injected = [d for d in available if getattr(d, 'source', None) == "github_injection"]
        if open_issue_numbers is not None:
            open_set = {int(n) for n in open_issue_numbers}
            # Same gating as dispatchable_injected_directions (attempt cap 3).
            eligible = [
                d for d in injected
                if d.github_issue and int(d.github_issue) in open_set
                and d.attempt_count < 3
            ]
            if eligible:
                return eligible[0]
        # open_issue_numbers is None OR no eligible injected direction: fall
        # through to weighted selection over non-injected directions. Exclude
        # injected directions from that pool so they are never silently picked
        # without issue-state verification.
        available = [d for d in available if getattr(d, 'source', None) != "github_injection"]

        if domain_filter:
            available = [d for d in available if domain_filter in d.domains or not d.domains]
        if exclude_domains:
            available = [d for d in available if not any(ex in d.domains for ex in exclude_domains)]
        if exclude_titles:
            inflight_titles_lower = {t.lower().strip() for t in exclude_titles}
            available = [d for d in available if d.title.lower().strip() not in inflight_titles_lower]
        if not available:
            return None

        # No attempt-count pruning and no automatic retirement. Directions are
        # never removed from the pool based on retries. Low-quality directions are
        # handled by quarantine (Q<0.3) and quality-scoring decay only.
        import random
        scores = [self._compute_quality_score(d, recent_domain_quality, catalog_analyzer) for d in available]

        # Inverse-frequency domain balancing: penalize overrepresented domains
        domain_counts = {}
        for d in available:
            for dom in d.domains:
                domain_counts[dom] = domain_counts.get(dom, 0) + 1
        n_available = len(available)

        for i, d in enumerate(available):
            for dom in d.domains:
                frac = domain_counts.get(dom, 1) / n_available
                if frac > 0.30:  # Domain occupies >30% of available pool
                    # Scale down: e.g. Pythagorean at 56% → weight *= (1 - 0.56) = 0.44
                    scores[i] *= (1.0 - frac)
                elif frac < 0.10:  # Underrepresented domain
                    # Boost: e.g. Cryptography at 1% → weight *= (1 + 0.10) = 1.10
                    scores[i] *= (1.0 + frac)

        # 50/50 menu balancing: nudge selection toward the underrepresented category
        for i, d in enumerate(available):
            scores[i] *= self._category_balance_penalty(d.get_category())

        total = sum(scores)
        if total == 0:
            return random.choice(available)
        weights = [s / total for s in scores]
        return random.choices(available, weights=weights, k=1)[0]

    def _record_selection_category(self, category: str) -> None:
        """Record the category of a selected direction to balance the 50/50 menu."""
        if not category:
            return
        self._selection_log.append(category)
        if len(self._selection_log) > 20:
            self._selection_log = self._selection_log[-20:]

    def _category_balance_penalty(self, category: str) -> float:
        """Return a weight multiplier to keep famous/cross-domain selections balanced.

        Target ratio is 50/50 over the last 20 selections. Underrepresented
        categories get a small boost; overrepresented categories get a small
        penalty. Abduction follow-ups and uncategorized directions are exempt.
        """
        if not category or category == "abduction_followup":
            return 1.0
        tracked = {"famous_subtask", "cross_domain_bridge"}
        if category not in tracked:
            return 1.0
        recent = self._selection_log[-20:]
        if not recent:
            return 1.0
        total = sum(1 for c in recent if c in tracked)
        if total == 0:
            return 1.0
        frac = sum(1 for c in recent if c == category) / total
        if frac < 0.4:
            return 1.2
        if frac > 0.6:
            return 0.8
        return 1.0

    def mark_direction_consumed(self, direction_id: str, exp_id: str) -> None:
        """Mark a direction as in-progress when it's selected for research."""
        from datetime import datetime, timezone
        now_iso = datetime.now(timezone.utc).isoformat()
        consumed_category = ""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "in_progress"
                d.consumed_by_exp_id = exp_id
                d.attempt_count = d.attempt_count + 1
                d.last_attempt_time = now_iso
                consumed_category = d.get_category()
                break
        self._record_selection_category(consumed_category)
        self._save()

    def reconcile_in_progress(self, active_jobs) -> int:
        """Reconcile direction statuses so in_progress reflects the true state of
        active inflight jobs at tick end.

        active_jobs: iterable of (job_id, direction_id, retry_of) tuples for each
        active inflight job (preparing/dispatched/retry_queued).

        For each active job:
          - If it has a direction_id, locate that direction and force it to
            in_progress with consumed_by_exp_id = (retry_of or job_id). This
            re-establishes the link for retries whose direction was released or
            never linked — retry-queued dispatches skip mark_direction_consumed,
            so without this the running retry has no in_progress direction.
          - Else fall back to the consumed_by_exp_id key: any direction whose
            consumed_by_exp_id matches (retry_of or job_id) is forced in_progress.

        Stale in_progress with no active job is cleared by recover_stale_directions
        at tick start. Returns the number of directions flipped to in_progress.
        """
        active_keys = set()
        dir_to_key = {}  # direction_id -> (retry_of or job_id)
        for tup in active_jobs:
            # tolerate 2- or 3-tuples and bare strings
            if isinstance(tup, str):
                job_id, direction_id, retry_of = tup, None, None
            else:
                job_id = tup[0] if len(tup) > 0 else None
                direction_id = tup[1] if len(tup) > 1 else None
                retry_of = tup[2] if len(tup) > 2 else None
            key = retry_of or job_id
            if key:
                active_keys.add(key)
            if direction_id:
                dir_to_key[direction_id] = key

        reconciled = 0
        for d in self._directions:
            if d.id in dir_to_key and d.status != "in_progress":
                d.status = "in_progress"
                d.consumed_by_exp_id = dir_to_key[d.id]
                reconciled += 1
            elif (d.consumed_by_exp_id and d.consumed_by_exp_id in active_keys
                  and d.status != "in_progress"):
                d.status = "in_progress"
                reconciled += 1
        if reconciled:
            self._save()
        return reconciled

    def get_source_exp_ids_for(self, exp_id: str) -> list:
        """Return source_exp_ids of all directions consumed by this exp_id.

        This establishes provenance: the experiment with this exp_id was
        inspired by future directions produced by these source experiments.
        """
        return list(set(
            d.source_exp_id for d in self._directions
            if d.consumed_by_exp_id == exp_id and d.source_exp_id
        ))

    def mark_direction_completed(self, direction_id: str) -> None:
        """Mark a direction as completed after successful research."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "completed"
                # Track domain in recent completions for soft decay
                for domain in d.domains:
                    self._recent_domain_counts[domain] = self._recent_domain_counts.get(domain, 0) + 1
                # Track theme keywords for anti-repetition penalty
                title_words = set(w.lower().strip(".,;:!?()[]") for w in d.title.split()
                                  if len(w) > 4 and w.lower() not in {
                                      "which", "their", "other", "about", "would", "could",
                                      "should", "these", "those", "being", "having", "where",
                                      "there", "every", "between", "through", "during",
                                  })
                desc_words = set(w.lower().strip(".,;:!?()[]") for w in d.description.split()
                                 if len(w) > 5 and w.lower() not in {
                                     "which", "their", "other", "about", "would", "could",
                                     "should", "these", "those", "being", "having", "where",
                                     "there", "every", "between", "through", "during",
                                 })
                theme_keywords = title_words | desc_words
                for kw in theme_keywords:
                    self._recent_theme_keywords[kw] = self._recent_theme_keywords.get(kw, 0) + 1
                # Cap theme keywords at 100 entries, removing least frequent
                if len(self._recent_theme_keywords) > 100:
                    sorted_kws = sorted(self._recent_theme_keywords.items(), key=lambda x: x[1])
                    for kw, _ in sorted_kws[:len(sorted_kws) - 100]:
                        del self._recent_theme_keywords[kw]
                break
        self._save()

    def set_recent_domain_counts(self, counts: Dict[str, int]) -> None:
        """Set recent domain completion counts from external tracking (e.g., catalog analysis)."""
        self._recent_domain_counts = counts

    def mark_direction_abandoned(self, direction_id: str) -> None:
        """Mark a direction as abandoned (e.g., trivial proof).

        Directions are no longer retried; abandoned directions become terminal
        'failed' records so they are not re-dispatched.
        """
        self.mark_direction_failed(direction_id)

    def mark_direction_failed(self, direction_id: str) -> None:
        """Mark a direction as failed, but keep it available for future retries."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "available"  # Reset to available per user request
                d.consumed_by_exp_id = ""
                d.attempt_count = 0
                break
        self._save()

    def get_direction_by_id(self, direction_id: str) -> Optional[FutureDirection]:
        """Look up a direction by its ID (checking active memory first, then completed archives)."""
        for d in self._directions:
            if d.id == direction_id:
                return d
        # Search completed directions archives
        archive_dir = self._file.parent / "completed_directions_archive"
        if archive_dir.exists():
            for af in sorted(archive_dir.glob("archive_part_*.json"), reverse=True):
                try:
                    adata = json.loads(af.read_text(encoding="utf-8"))
                    for item in adata.get("directions", []):
                        if item.get("id") == direction_id:
                            return FutureDirection.from_dict(item)
                except Exception:
                    pass
        return None

    def mark_direction_available(self, direction_id: str) -> None:
        """Reset a direction back to available so it can be retried."""
        for d in self._directions:
            if d.id == direction_id:
                d.status = "available"
                d.consumed_by_exp_id = ""
        self._save()

    def release_consumed_direction(self, exp_id: str) -> None:
        """Release any direction marked in-progress by this exp_id back to available.

        Used when a job was discovered but could not be dispatched (e.g., Aristotle
        queue full), so the direction is not lost.
        """
        released = False
        for d in self._directions:
            if d.consumed_by_exp_id == exp_id and d.status == "in_progress":
                d.status = "available"
                d.consumed_by_exp_id = ""
                released = True
        if released:
            self._save()

    def dispatchable_injected_directions(
        self, open_issue_numbers, max_attempts: int = 3
    ) -> List["FutureDirection"]:
        """Filter github_injection directions to those safe to (re-)dispatch.

        A direction is only dispatchable when all of:
          - status == 'available'
          - source == 'github_injection'
          - it references a GitHub issue that is currently OPEN (github_issue
            non-zero and present in open_issue_numbers) — a closed issue means
            the work was already handled, so it must never be re-dispatched
          - attempt_count < max_attempts — retried to the cap is dead

        This breaks the re-publish loop where closed-issue directions were
        re-dispatched every tick regardless of completion or issue state.
        """
        open_set = {int(n) for n in open_issue_numbers}
        candidates: List["FutureDirection"] = []
        for d in self._directions:
            if d.status != "available":
                continue
            if getattr(d, "source", "") != "github_injection":
                continue
            if not d.github_issue or int(d.github_issue) not in open_set:
                continue
            if d.attempt_count >= max_attempts:
                continue
            candidates.append(d)
        return candidates

    def prune_closed_issue_directions(
        self, open_issue_numbers, reason: str = None
    ) -> int:
        """Prune non-terminal github_injection directions whose issue is closed.

        These are zombies: their GitHub issue was closed (integration succeeded
        or the request was retired), yet the direction never reached a terminal
        state — stale-manager clobbers or failed cleanups kept re-dispatching
        them. Any 'available'/'in_progress' direction whose github_issue is not
        in open_issue_numbers is marked pruned. Returns the number pruned.
        """
        open_set = {int(n) for n in open_issue_numbers}
        pruned_count = 0
        for d in self._directions:
            if getattr(d, "source", "") != "github_injection":
                continue
            if d.status not in ("available", "in_progress"):
                continue
            if d.github_issue and int(d.github_issue) in open_set:
                continue
            d.status = "pruned"
            d.prune_reason = reason or (
                f"github issue #{d.github_issue} closed; direction superseded"
            )
            d.pruned_at = datetime.now(timezone.utc).isoformat()
            pruned_count += 1
        if pruned_count:
            self._save()
        return pruned_count

    def quarantine_direction(self, direction_id: str, days: int = 30) -> None:
        """Quarantine a direction: prevent dispatch for N days.

        Used when a direction produces a very low-quality cycle (Q<0.3).
        The direction stays in the pool but is excluded from dispatch
        until the cooldown expires.
        """
        from datetime import datetime, timezone, timedelta
        for d in self._directions:
            if d.id == direction_id:
                d.quarantined_until = (
                    datetime.now(timezone.utc) + timedelta(days=days)
                ).isoformat()[:19]
                d.status = "available"  # Keep as available, but skip in select
                d.consumed_by_exp_id = ""
                self._save()
                return

    def is_quarantined(self, direction: "FutureDirection") -> bool:
        """Check if a direction is currently quarantined."""
        if not direction.quarantined_until:
            return False
        from datetime import datetime, timezone
        try:
            until = datetime.fromisoformat(direction.quarantined_until)
            return datetime.now(timezone.utc) < until
        except (ValueError, TypeError):
            return False

    def cleanup_expired_quarantines(self) -> int:
        """Remove quarantine flag from directions whose cooldown has expired."""
        from datetime import datetime, timezone
        cleaned = 0
        now = datetime.now(timezone.utc)
        for d in self._directions:
            if d.quarantined_until:
                try:
                    until = datetime.fromisoformat(d.quarantined_until)
                    if now >= until:
                        d.quarantined_until = ""
                        cleaned += 1
                except (ValueError, TypeError):
                    d.quarantined_until = ""
                    cleaned += 1
        if cleaned > 0:
            self._save()
        return cleaned

    def recover_stale_directions(self, max_age_hours: int = 24) -> int:
        """Reset in_progress directions older than max_age_hours back to available.

        Directions whose job is still active in inflight_jobs.json are skipped:
        last_attempt_time is only stamped at discover time, so a long-running
        Phase A+Phase B chain can legitimately exceed max_age_hours — resetting
        such a direction causes a duplicate dispatch (double Aristotle spend)
        and a package overwrite (audit 2026-08-21; live pool showed injected
        directions with attempt_count=47 from exactly this loop).
        """
        from datetime import datetime, timezone, timedelta
        active_job_ids = self._active_inflight_job_ids()
        cutoff = datetime.now(timezone.utc) - timedelta(hours=max_age_hours)
        recovered = 0
        for d in self._directions:
            if d.status == "in_progress":
                if d.consumed_by_exp_id and d.consumed_by_exp_id in active_job_ids:
                    continue  # job still running — never age-reset it
                try:
                    time_str = d.last_attempt_time or d.timestamp
                    ts = datetime.fromisoformat(time_str)
                    # Ensure offset-aware comparison
                    if ts.tzinfo is None:
                        ts = ts.replace(tzinfo=timezone.utc)
                    if ts < cutoff:
                        d.status = "available"
                        d.consumed_by_exp_id = ""
                        recovered += 1
                except (AttributeError, ValueError):
                    d.status = "available"
                    d.consumed_by_exp_id = ""
                    recovered += 1
        if recovered:
            self._save()
        return recovered

    def _active_inflight_job_ids(self) -> set:
        """Job IDs currently present in inflight_jobs.json (best-effort)."""
        inflight_path = self.workspace / "inflight_jobs.json"
        if not inflight_path.exists():
            return set()
        try:
            inflight_data = json.loads(inflight_path.read_text(encoding="utf-8"))
            if isinstance(inflight_data, dict):
                return {
                    v.get("job_id", "") for v in inflight_data.values()
                    if isinstance(v, dict) and v.get("job_id")
                }
            if isinstance(inflight_data, list):
                return {
                    j.get("job_id", "") for j in inflight_data
                    if isinstance(j, dict) and j.get("job_id")
                }
        except Exception:
            pass
        return set()

    def adjust_direction_quality_feedback(
        self, domain: str, quality_score: float, proof_quality: str
    ) -> None:
        """Adjust domain quality penalty of future directions based on quality feedback.

        Domains with poor results get their directions penalized via domain_quality_penalty;
        domains with good results get a boost. The original priority_score is preserved
        so that seed directions (Goldbach=0.95, Riemann=0.95) maintain their importance.
        The domain_quality_penalty is applied during quality score computation in
        _compute_quality_score(), not by overwriting priority_score.
        """
        domain_lower = domain.lower()
        adjusted = 0
        for d in self._directions:
            if d.status != "available":
                continue
            # Check if this direction's domains overlap with the result domain
            dir_domains_lower = " ".join(d.domains).lower()
            if domain_lower not in dir_domains_lower and domain_lower not in d.title.lower():
                continue
            if quality_score < 0.3:
                d.domain_quality_penalty = max(-1.0, d.domain_quality_penalty - 0.15)
                adjusted += 1
            elif quality_score > 0.7:
                d.domain_quality_penalty = min(1.0, d.domain_quality_penalty + 0.10)
                adjusted += 1
        if adjusted:
            self._save()
            print(f"[FD-Manager] Quality feedback: {domain} q={quality_score:.2f} "
                  f"adjusted {adjusted} directions (domain_quality_penalty)")

    def get_recent_domain_quality(self, n: int = 10, memory: 'ResearchMemory' = None) -> Dict[str, float]:
        """Return average quality per domain from the last n experiments.

        Used by select_direction_weighted to boost/penalize domains.
        Requires a ResearchMemory instance to access experiment history.
        """
        if memory is None:
            return {}
        recent = memory._cache[-n:] if hasattr(memory, '_cache') and memory._cache else []
        if not recent:
            return {}
        domain_scores: Dict[str, List[float]] = {}
        for r in recent:
            q = getattr(r, 'quality_score', 0.0)
            if r.domain not in domain_scores:
                domain_scores[r.domain] = []
            domain_scores[r.domain].append(q)
        return {d: sum(scores) / len(scores) for d, scores in domain_scores.items()}

    def get_direction_for_exp(self, exp_id: str) -> Optional[FutureDirection]:
        """Find the direction being researched by a given experiment."""
        for d in self._directions:
            if d.consumed_by_exp_id == exp_id:
                return d
        return None

    def rebalance_domains(self, max_domain_fraction: float = 0.30, prune_bottom_fraction: float = 0.15) -> Dict[str, int]:
        """No-op: automatic domain rebalancing by pruning has been disabled.

        Directions are no longer automatically retired. Domain diversity is
        enforced by inverse-frequency weighting in select_direction_weighted().

        Returns empty dict.
        """
        return {}

    @staticmethod
    def _tokenize(text: str) -> Set[str]:
        """Extract meaningful tokens from text for Jaccard similarity.

        Filters stop words and very short tokens, lowercases.
        """
        stop_words = {
            "the", "and", "or", "for", "in", "to", "is", "are", "by", "with",
            "from", "that", "this", "it", "as", "be", "can", "we", "has", "had",
            "was", "were", "been", "have", "will", "would", "could", "should",
            "may", "might", "shall", "not", "but", "all", "any", "each", "every",
            "both", "few", "more", "most", "other", "some", "such", "than", "too",
            "very", "just", "also", "then", "when", "where", "how", "what", "which",
            "who", "why", "if", "into", "over", "under", "about", "between",
            "through", "during", "before", "after", "above", "below", "only",
            "own", "there", "their", "they", "them", "these", "those",
        }
        words = re.findall(r'[a-zA-Z]{4,}', text.lower())
        return {w for w in words if w not in stop_words}

    def _estimate_direction_similarity(
        self, direction: FutureDirection, recent_directions: List[FutureDirection]
    ) -> float:
        """Compute max Jaccard similarity between a direction and recent completed ones.

        Feature set per direction: domains ∪ tokenized(proof_strategy)
        ∪ tokenized(description[:100]) ∪ {ambition_level}

        Returns the highest similarity score (0-1) against any recent direction.
        """
        import re as _re

        # Build feature set for the candidate direction
        features = set(direction.domains)
        if direction.proof_strategy:
            features |= self._tokenize(direction.proof_strategy)
        if direction.description:
            features |= self._tokenize(direction.description[:100])
        if direction.ambition_level:
            features.add(direction.ambition_level)

        if not features:
            return 0.0

        max_sim = 0.0
        for recent in recent_directions:
            recent_features = set(recent.domains)
            if recent.proof_strategy:
                recent_features |= self._tokenize(recent.proof_strategy)
            if recent.description:
                recent_features |= self._tokenize(recent.description[:100])
            if recent.ambition_level:
                recent_features.add(recent.ambition_level)

            if not recent_features:
                continue

            intersection = len(features & recent_features)
            union = len(features | recent_features)
            if union == 0:
                continue
            sim = intersection / union
            if sim > max_sim:
                max_sim = sim

        return max_sim

    def get_stats(self) -> dict:
        """Return stats about direction consumption."""
        from collections import Counter
        statuses = Counter(d.status for d in self._directions)
        # Retry stats
        retried = [d for d in self._directions if d.attempt_count > 1]
        retry_rate = len(retried) / max(len([d for d in self._directions if d.attempt_count > 0]), 1)
        avg_attempts = sum(d.attempt_count for d in self._directions) / max(len([d for d in self._directions if d.attempt_count > 0]), 1)
        
        # Calculate archived completed stats
        archive_dir = self._file.parent / "completed_directions_archive"
        archived_completed_count = 0
        archive_files_count = 0
        if archive_dir.exists():
            archive_files = list(archive_dir.glob("archive_part_*.json"))
            archive_files_count = len(archive_files)
            for af in archive_files:
                try:
                    adata = json.loads(af.read_text(encoding="utf-8"))
                    archived_completed_count += len(adata.get("directions", []))
                except Exception:
                    pass

        return {
            "total": len(self._directions),
            "available": statuses.get("available", 0),
            "in_progress": statuses.get("in_progress", 0),
            "completed": statuses.get("completed", 0),
            "failed": statuses.get("failed", 0),
            "pruned": len(self._pruned),
            "archived_completed": archived_completed_count,
            "archived_files_count": archive_files_count,
            "retried_directions": len(retried),
            "retry_rate": round(retry_rate, 3),
            "avg_attempts": round(avg_attempts, 2),
        }

    def archive_completed_directions(
        self,
        keep_recent: int = 50,
        max_per_file: int = 200,
    ) -> Dict[str, int]:
        """Archive completed directions exceeding keep_recent threshold into chunked files.

        Archived directions are removed from future_directions.json and saved in
        Packages/completed_directions_archive/archive_part_NNNN.json files, each
        capped at max_per_file items.

        Returns a dictionary summary of archived count and archive files count.
        """
        completed_dirs = [d for d in self._directions if d.status == "completed"]
        if len(completed_dirs) <= keep_recent:
            return {"archived": 0, "kept": len(completed_dirs), "archive_files": 0}

        # Sort completed directions by timestamp/attempt/id, keeping the newest keep_recent in memory
        completed_sorted = sorted(
            completed_dirs,
            key=lambda d: getattr(d, 'timestamp', '') or getattr(d, 'last_attempt_time', '') or getattr(d, 'id', '')
        )
        to_archive = completed_sorted[:-keep_recent]
        to_archive_ids = set(d.id for d in to_archive)

        # Filter out archived directions from active memory list
        self._directions = [d for d in self._directions if d.id not in to_archive_ids]

        # Directory for completed direction archives
        archive_dir = self._file.parent / "completed_directions_archive"
        archive_dir.mkdir(parents=True, exist_ok=True)

        # Load existing archive files to find current max part and check if last file has capacity
        existing_files = sorted(archive_dir.glob("archive_part_*.json"))
        parts_data = []

        for f in existing_files:
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                parts_data.append((f, data))
            except Exception:
                pass

        archived_count = 0
        items_to_write = [d.to_dict() for d in to_archive]
        space = 0

        # Fill capacity in last existing archive file if space available
        if parts_data:
            last_file, last_data = parts_data[-1]
            # Normalize legacy parts: some on-disk parts are bare JSON lists
            # (e.g. archive_part_0006.json); .get() on a list would crash the
            # archiver — and with it every _save — at the 51st completion.
            if isinstance(last_data, dict):
                existing_items = list(last_data.get("directions", []))
            else:
                existing_items = list(last_data)
            space = max_per_file - len(existing_items)
            if space > 0:
                chunk = items_to_write[:space]
                items_to_write = items_to_write[space:]
                existing_items.extend(chunk)
                # Always write the canonical dict payload, converting legacy parts
                last_data = {
                    "part": last_file.stem.split("_")[-1].lstrip("0") or "0",
                    "archived_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "count": len(existing_items),
                    "directions": existing_items,
                }
                last_file.write_text(json.dumps(last_data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
                archived_count += len(chunk)

        # Create new part files for remaining items
        part_num = len(parts_data)
        if parts_data and space > 0 and not items_to_write:
            pass
        else:
            while items_to_write:
                part_num += 1
                chunk = items_to_write[:max_per_file]
                items_to_write = items_to_write[max_per_file:]
                new_file = archive_dir / f"archive_part_{part_num:04d}.json"
                part_payload = {
                    "part": part_num,
                    "archived_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "count": len(chunk),
                    "directions": chunk,
                }
                new_file.write_text(json.dumps(part_payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
                archived_count += len(chunk)

        all_archive_files = list(archive_dir.glob("archive_part_*.json"))
        return {
            "archived": archived_count,
            "kept": len([d for d in self._directions if d.status == "completed"]),
            "archive_files": len(all_archive_files),
        }

    def reset_directions(self, new_directions: Optional[List["FutureDirection"]] = None) -> dict:
        """Reset: mark in_progress as available, then optionally re-seed.

        Returns a summary dict of what was done.
        """
        reset_count = 0
        for d in self._directions:
            if d.status == "in_progress":
                d.status = "available"
                d.consumed_by_exp_id = ""
                reset_count += 1
        seeded = 0
        if new_directions:
            for nd in new_directions:
                self.add_direction(nd)
                seeded += 1
        self._save()
        return {
            "released": reset_count,
            "seeded": seeded,
            "total": len(self._directions),
        }

    def clear_and_reseed(self, new_directions: List["FutureDirection"]) -> dict:
        """Wipe all directions and re-seed from scratch.

        Returns a summary dict.
        """
        old_count = len(self._directions)
        self._directions = []
        for nd in new_directions:
            self.add_direction(nd)
        self._save()
        return {
            "cleared": old_count,
            "seeded": len(self._directions),
        }

    # ── Quality Scoring & Pruning ──

    def _estimate_novelty(self, direction: FutureDirection, catalog_analyzer=None) -> float:
        """Estimate novelty by checking how many similar theorems exist in the catalog.

        More overlap = less novel = lower score. Completely novel topics score high.
        Falls back to direction.priority_score if no catalog analyzer available.
        """
        if catalog_analyzer is None:
            return direction.priority_score

        try:
            domain = direction.domains[0] if direction.domains else "Unknown"
            domain_files = []
            # Try to get files for the direction's domain
            # Use all domains the direction touches
            for d in direction.domains:
                domain_files.extend(catalog_analyzer.get_domain_files(d))
            if not domain_files:
                # Fallback: scan all summaries
                all_summaries = catalog_analyzer.scan()
                domain_lower = domain.lower()
                domain_files = [
                    s for s in all_summaries
                    if s.domain and domain_lower in s.domain.lower()
                ]

            # Count theorems with overlapping keywords
            # Use a two-tier approach: distinctive terms from the title (high weight)
            # plus rare terms from the description (supplementary).
            # Avoid common math/English words that match everything.
            import re
            title_words = re.findall(r'[a-zA-Z]{3,}', direction.title.lower())
            desc_words = re.findall(r'[a-zA-Z]{3,}', direction.description.lower())

            # Broad stop word list covering common English and generic math terms
            stop_words = {
                "the", "and", "or", "for", "in", "to", "is", "are", "by", "with",
                "from", "that", "this", "it", "as", "be", "can", "we", "has", "had",
                "was", "were", "been", "have", "will", "would", "could", "should",
                "may", "might", "shall", "not", "but", "all", "any", "each", "every",
                "both", "few", "more", "most", "other", "some", "such", "than", "too",
                "very", "just", "also", "then", "when", "where", "how", "what", "which",
                "who", "why", "if", "into", "over", "under", "about", "between",
                "through", "during", "before", "after", "above", "below", "only",
                "own", "there", "their", "they", "them", "these", "those",
                # Generic math terms that appear in almost every Lean file
                "theorem", "proof", "prove", "lemma", "prop", "corollary", "def",
                "definition", "set", "function", "let", "assume", "show", "given",
                "using", "based", "since", "therefore", "thus", "hence", "moreover",
                "however", "indeed", "note", "remark", "example", "case", "result",
                "implies", "following", "follows", "construct", "define", "int",
                "real", "nat", "bool", "type", "class", "instance", "term", "value",
                "number", "point", "line", "field", "ring", "group", "map", "fin",
                "list", "option", "sort", "test", "impact", "conjecture", "constant",
                "exists", "forall", "lambda", "variable", "parameter", "return",
                "arithmetic", "automated", "axiom", "consistent", "derive", "develop",
                "general", "specific", "property", "structure", "method", "approach",
                "result", "statement", "condition", "bound", "space", "module",
                "category", "morphism", "object", "element", "sequence", "series",
                "limit", "finite", "infinite", "complete", "partial", "total",
                "order", "relation", "equation", "system", "model", "theory",
                "computable", "algorithm", "computing", "computation", "computational",
            }

            # Tier 1: Title keywords (most distinctive — these are the core topic)
            title_keywords = set(w for w in title_words if w not in stop_words)
            # Tier 2: Description keywords (supplementary — must be longer to reduce noise)
            desc_keywords = set(w for w in desc_words if w not in stop_words and len(w) >= 7)

            overlap = 0
            for f in domain_files:
                decls_lower = " ".join(getattr(f, 'declarations', [])).lower()
                # A file is "overlapping" if it has a title keyword match
                # OR multiple description keyword matches
                title_matches = sum(1 for k in title_keywords if k in decls_lower)
                desc_matches = sum(1 for k in desc_keywords if k in decls_lower)
                if title_matches >= 1 or desc_matches >= 2:
                    overlap += 1

            # Also check title-level novelty: does the exact topic already exist?
            title_lower = direction.title.lower()
            title_overlap = sum(
                1 for f in domain_files
                if title_lower.split(":")[0].strip() in
                   f.relative_path.lower() + " ".join(getattr(f, 'declarations', [])).lower()
            )

            if title_overlap >= 3:
                return 0.35  # exact topic is already heavily mined
            elif overlap == 0:
                return 0.85  # completely novel — high potential
            elif overlap < 5:
                return 0.75  # some grounding — good
            elif overlap < 15:
                return 0.55  # well-trodden area
            else:
                return 0.35  # heavily mined — discourage
        except Exception:
            return direction.priority_score

    def _compute_quality_score(
        self, direction: FutureDirection, recent_domain_quality: Optional[Dict[str, float]] = None,
        catalog_analyzer=None
    ) -> float:
        """Compute a composite quality score for a direction.

        Weights: novelty 20%, outcome_bonus 15%, source 20%, domains 15%,
                 description 10%, strategy 10%, freshness 10%, plus fun bonus.
        Novelty is estimated from catalog overlap when available.
        The outcome_bonus rewards domains with recent high-quality results
        and penalizes domains that have been producing trivial work.
        """
        # novelty: estimated from catalog overlap (replaces hardcoded priority)
        novelty = self._estimate_novelty(direction, catalog_analyzer)

        # outcome_bonus: learn from recent experiment quality in this domain
        outcome_bonus = 0.5  # neutral default
        if recent_domain_quality:
            domain_matches = [
                q for d, q in recent_domain_quality.items()
                if d.lower() in " ".join(direction.domains).lower()
                or d.lower() in direction.title.lower()
            ]
            if domain_matches:
                outcome_bonus = sum(domain_matches) / len(domain_matches)

        # source_bonus: seed directions are higher quality
        if direction.source_path == "seed:manual_v2":
            source_bonus = 1.0
        elif direction.source_path.startswith("seed:"):
            source_bonus = 0.5
        else:
            source_bonus = 0.3

        # domain_richness: well-classified directions are better
        if not direction.domains:
            domain_richness = 0.1
        elif direction.domains == ["Bridges"]:
            domain_richness = 0.1
        else:
            domain_richness = min(1.0, len(direction.domains) / 3.0)

        # description_depth: longer, more detailed descriptions
        desc_len = len(direction.description)
        if desc_len < 80:
            description_depth = 0.0
        else:
            description_depth = min(1.0, (desc_len - 80) / 300.0)

        # strategy_bonus: having a proof strategy means more actionable
        strategy_bonus = 1.0 if direction.proof_strategy else 0.0

        # freshness: newer directions get a slight bonus
        if direction.timestamp:
            try:
                added = datetime.fromisoformat(direction.timestamp)
                if added.tzinfo is None:
                    added = added.replace(tzinfo=timezone.utc)
                days_old = (datetime.now(timezone.utc) - added).days
                freshness = max(0.0, 1.0 - days_old / 90.0)
            except (ValueError, TypeError):
                freshness = 0.5
        else:
            freshness = 0.5

        # fun_bonus: preserve speculative directions
        fun_bonus = 0.05 if "Speculative" in direction.domains else 0.0

        # ambition_bonus: grand challenges are high-risk/high-reward
        ambition_bonus = 1.0 if direction.ambition_level == "grand_challenge" else 0.5

        # catalog_anchor_bonus: directions referencing specific Catalog theorems are more actionable
        catalog_anchor_bonus = 1.0 if direction.catalog_references else 0.3

        # bridge_bonus: cross-domain bridges add value (additive, up to ~0.15)
        bridge_bonus = 0.05 * min(len(direction.domain_bridges), 3) if direction.domain_bridges else 0.0

        # domain_diversity_penalty: oversaturated domains get -0.1
        domain_diversity_penalty = 0.0
        domain_counts = self._domain_counts()
        for d in direction.domains:
            if domain_counts.get(d, 0) > 50:
                domain_diversity_penalty = -0.1
                break

        # soft domain decay: penalize directions whose domains are overrepresented
        # in recent outputs. Decay kicks in after just 1 completion: 0.25^min(1, (count-1)/6)
        # This is aggressive: a domain with 7 completions gets ~0.25x, 13+ completions gets ~0.06x
        domain_decay = 1.0
        if self._recent_domain_counts:
            for d in direction.domains:
                recent_count = self._recent_domain_counts.get(d, 0)
                if recent_count > 1:
                    decay = 0.25 ** min(1.0, (recent_count - 1) / 6.0)
                    domain_decay = min(domain_decay, decay)

        # first_time_domain_bonus: boost directions in domains with 0-2 completions
        # (encourages exploration of underrepresented territory)
        first_time_bonus = 0.0
        if self._recent_domain_counts:
            for d in direction.domains:
                if self._recent_domain_counts.get(d, 0) <= 2:
                    first_time_bonus = 0.15
                    break

        # novelty_bonus: wild/frontier directions tagged "Novelty" get a boost
        novelty_bonus = 0.10 if "Novelty" in direction.domains else 0.0

        # anti-repetition penalty: Jaccard similarity against recent completed directions
        # Higher overlap with recently completed work = more redundant = penalized
        # Feature set: domains ∪ tokenized(proof_strategy) ∪ tokenized(description[:100]) ∪ {ambition_level}
        repetition_penalty = 0.0
        recent_completed = [d for d in self._directions if d.status == "completed"][-20:]
        if recent_completed:
            max_sim = self._estimate_direction_similarity(direction, recent_completed)
            repetition_penalty = -0.05 * max_sim  # up to -0.20 for very similar
            repetition_penalty = max(repetition_penalty, -0.20)

        # ArXiv directions earn their priority through quality scoring, not a flat boost.
        # The quality score already accounts for source_bonus, novelty, description depth, etc.

        # outcome_quality_feedback: if this direction already has a measured outcome,
        # use it as a signal (directions that produced good results are worth more)
        quality_feedback = 0.0
        if direction.outcome_quality > 0:
            quality_feedback = (direction.outcome_quality - 0.5) * 0.1  # small +/-0.05 nudge

        # domain_quality_penalty: accumulated feedback from adjust_direction_quality_feedback()
        # This is separate from priority_score so that seed directions (Goldbach=0.95, Riemann=0.95)
        # maintain their importance even after domains have had poor cycles.
        # The penalty ranges from -1.0 (very bad domain) to +1.0 (very good domain).
        domain_penalty = direction.domain_quality_penalty * 0.15  # scale to +/-0.15 max

        score = (
            0.18 * novelty
            + 0.12 * outcome_bonus
            + 0.18 * source_bonus
            + 0.12 * domain_richness
            + 0.10 * description_depth
            + 0.10 * strategy_bonus
            + 0.08 * freshness
            + 0.07 * ambition_bonus
            + 0.05 * catalog_anchor_bonus
            + fun_bonus
            + bridge_bonus
            + domain_diversity_penalty
            + novelty_bonus
            + first_time_bonus
            + repetition_penalty
            + quality_feedback
            + domain_penalty
        ) * domain_decay
        # Cap at 0.85 so priorities spread across 0.4-0.85 instead of clustering at 1.0
        return min(0.85, score)

    def prune_directions(
        self,
        cap: int = DEFAULT_DIRECTION_CAP,
        dry_run: bool = False,
        min_quality: float = 0.0,
    ) -> dict:
        """No-op: automatic pruning of future directions has been permanently disabled.

        Directions are never deleted or pruned. Selection diversity and pool balancing
        are enforced via inverse-frequency domain weighting in select_direction_weighted().
        """
        return {
            "pruned_count": 0,
            "kept_auto": len([d for d in self._directions if d.status == "available"]),
            "kept_seed": len([d for d in self._directions if d.source_path.startswith("seed:")]),
            "kept_protected": len([d for d in self._directions if d.status in ("in_progress", "completed")]),
            "total_available_after": len([d for d in self._directions if d.status == "available"]),
            "quality_threshold": 0.0,
            "pruned_ids": [],
            "pruned_details": [],
        }

    def restore_direction(self, direction_id: str) -> bool:
        """Restore a pruned direction back to available.

        Returns True if the direction was found and restored.
        """
        for i, d in enumerate(self._pruned):
            if d.id == direction_id:
                d.status = "available"
                d.prune_reason = ""
                d.pruned_at = ""
                d.consumed_by_exp_id = ""
                self._directions.append(d)
                self._pruned.pop(i)
                self._save()
                return True
        return False

    def get_pruned(self, limit: int = 50) -> List[FutureDirection]:
        """Return pruned directions, most recently pruned first."""
        return list(reversed(self._pruned[-limit:]))


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Manage future directions")
    sub = parser.add_subparsers(dest="command")

    reset_p = sub.add_parser("reset", help="Clear and re-seed directions")
    reset_p.add_argument("--keep-completed", action="store_true",
                         help="Keep completed directions (default: wipe all)")

    stats_p = sub.add_parser("stats", help="Show direction statistics")

    prune_p = sub.add_parser("prune", help="Prune low-quality future directions")
    prune_p.add_argument("--cap", type=int, default=DEFAULT_DIRECTION_CAP,
                         help=f"Max available non-seed directions to keep (default: {DEFAULT_DIRECTION_CAP})")
    prune_p.add_argument("--dry-run", action="store_true",
                         help="Show what would be pruned without actually pruning")
    prune_p.add_argument("--min-quality", type=float, default=0.0,
                         help="Minimum quality score threshold (0-1); prune directions below this")
    prune_p.add_argument("--restore", type=str, default=None,
                         help="Restore a pruned direction by ID")

    args = parser.parse_args()
    workspace = Path(".aether_workspace")

    if args.command == "reset":
        from seed_directions import get_seed_directions
        mgr = FutureDirectionsManager(workspace)
        if args.keep_completed:
            result = mgr.reset_directions(get_seed_directions())
        else:
            result = mgr.clear_and_reseed(get_seed_directions())
        print(f"Reset complete: {result}")
        # Sync to Catalog for GitHub Pages
        import shutil
        catalog_fd = Path("../Packages/future_directions.json")
        workspace_fd = workspace / "future_directions.json"
        if workspace_fd.exists() and catalog_fd.parent.exists():
            shutil.copy2(workspace_fd, catalog_fd)
            print(f"Synced future_directions.json to Catalog/")
    elif args.command == "stats":
        mgr = FutureDirectionsManager(workspace)
        stats = mgr.get_stats()
        print(json.dumps(stats, indent=2))
        available = mgr.get_available_directions()
        print(f"\nTop available directions:")
        for d in available[:5]:
            print(f"  [{d.priority_score:.2f}] {d.title} ({d.status})")
    elif args.command == "prune":
        mgr = FutureDirectionsManager(workspace)
        if args.restore:
            success = mgr.restore_direction(args.restore)
            print(f"Direction {args.restore} restored: {success}")
        else:
            result = mgr.prune_directions(
                cap=args.cap,
                dry_run=args.dry_run,
                min_quality=args.min_quality,
            )
            print(json.dumps(result, indent=2))
            if result["pruned_details"]:
                print(f"\nPruned directions:")
                for d in result["pruned_details"]:
                    print(f"  [{d['quality_score']:.4f}] {d['id']}: {d['title']}")
    else:
        parser.print_help()

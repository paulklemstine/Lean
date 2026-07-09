#!/usr/bin/env python3
"""Aether Tick: One-shot pipeline step for CI.

Polls for completed Aristotle jobs, integrates them, dispatches new ones,
then exits. Designed for hourly cron — each run takes 2-5 minutes.

Usage:
    python3 aether_tick.py
    python3 aether_tick.py --max-inflight 9
    python3 aether_tick.py --loop --interval 21600   # continuous loop, every 6h
    python3 aether_tick.py --log aether.log           # tee all output to a log file
"""

import argparse
import asyncio
import fcntl
import http.server
import os
import sys

# Force unbuffered output so logs stream immediately under nohup/systemd
os.environ.setdefault("PYTHONUNBUFFERED", "1")
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
    sys.stderr.reconfigure(line_buffering=True)
import json
import os
import socketserver
import subprocess
import sys
import threading
import time
from datetime import datetime, timedelta, timezone
from typing import Dict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))


class FileLock:
    """Advisory, process-scoped lock file using Unix flock(2).

    Used to ensure only one Aether tick runs across all local/CI processes
    that share the same workspace. This prevents two processes from each
    dispatching up to max_inflight jobs and overflowing the Aristotle queue.
    """

    def __init__(self, path: Path):
        self.path = path
        self._fd = None

    def __enter__(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._fd = open(self.path, "w")
        try:
            fcntl.flock(self._fd.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print(f"[Lock] Waiting for tick lock ({self.path.name}) ...")
            fcntl.flock(self._fd.fileno(), fcntl.LOCK_EX)
        return self

    def __exit__(self, exc_type, exc, tb):
        if self._fd:
            try:
                fcntl.flock(self._fd.fileno(), fcntl.LOCK_UN)
            except Exception:
                pass
            try:
                self._fd.close()
            except Exception:
                pass
        return False

# Load environment variables from .env file in Aether directory
def _load_env_file():
    env_path = Path(__file__).parent / ".env"
    if env_path.exists():
        for line in env_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                k = k.strip()
                v = v.strip().strip("\"'")
                if k and k not in os.environ:
                    os.environ[k] = v

_load_env_file()


# ── Override print to add terminal colors for errors and warnings ──
import builtins
import re as _re

_orig_print = builtins.print

def _colored_print(*args, **kwargs):
    text = " ".join(str(arg) for arg in args)
    text_lower = text.lower()
    
    is_error = (
        "[error]" in text_lower or
        "failed:" in text_lower or
        "failed for" in text_lower or
        "recording failed" in text_lower or
        "error:" in text_lower or
        "exception:" in text_lower or
        "patch failed" in text_lower or
        "dispatch failed" in text_lower or
        "failed to" in text_lower or
        "error occurred" in text_lower
    )
    is_warning = (
        "[warning]" in text_lower or
        "warning:" in text_lower or
        "rejected:" in text_lower or
        "rejected (" in text_lower or
        "skipped (rejected" in text_lower
    )
    
    if is_error:
        # Bold Red (\033[1;31m)
        _orig_print(f"\033[1;31m{text}\033[0m", **kwargs)
    elif is_warning:
        # Bold Yellow (\033[1;33m)
        _orig_print(f"\033[1;33m{text}\033[0m", **kwargs)
    else:
        _orig_print(*args, **kwargs)


from knowledge_extractor import KnowledgeExtractor, ResearchJob
from pi_agent_client import ResearchConcept


REPO_ROOT = Path(__file__).parent.parent

# All known Phase A prompt versions — used for A/B stats printing.
# Extend this when new variants are added.
PHASE_A_VERSIONS = (
    "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15",
    "v16", "v16a", "v16b", "v17", "v18",
    "v19", "v19a", "v19b", "v19c", "v19d",
    "v24", "v25", "v26", "v27", "v28",
)
PACKAGES_DIR = REPO_ROOT / "Packages"


def _print_prompt_version_stats(extractor: "KnowledgeExtractor") -> None:
    """Print prompt version A/B test summary from cycle_analytics.json.

    Shows avg quality, world_class rate, duration, and the winner per version.
    Also shows Phase A/B split stats.
    """
    try:
        import json as _json
        analytics_path = extractor.workspace / "cycle_analytics.json"
        if not analytics_path.exists():
            return
        data = _json.loads(analytics_path.read_text())
        records = data.get("records", [])
        if not records:
            return
        by_ver = {}
        for r in records:
            v = r.get("prompt_version", "unknown")
            by_ver.setdefault(v, []).append(r)
        lines = ["[A/B] Prompt version stats:"]
        for v in PHASE_A_VERSIONS:
            rs = by_ver.get(v, [])
            if not rs:
                continue
            n = len(rs)
            avg_q = sum(r.get("quality_score", 0) for r in rs) / n
            avg_qa = sum(r.get("phase_a_quality_score", r.get("quality_score", 0)) for r in rs) / n
            wc = sum(1 for r in rs if r.get("quality_breakdown", {}).get("grade") == "world_class")
            durs = [r.get("duration_seconds", 0) / 60 for r in rs if r.get("duration_seconds")]
            avg_dur = sum(durs) / len(durs) if durs else 0
            lines.append(f"  {v}: n={n:3d} avg_Q_A={avg_qa:.3f} avg_Q={avg_q:.3f} wc={wc}/{n} ({100*wc/n:.0f}%) avg_dur={avg_dur:.0f}min")
        # Last 20 only, to keep it fresh
        recent = [r for r in records[-20:] if r.get("prompt_version") in PHASE_A_VERSIONS]
        if recent:
            scores = {}
            for v in PHASE_A_VERSIONS:
                vrs = [r for r in recent if r.get("prompt_version") == v]
                if vrs:
                    scores[v] = sum(r.get("quality_score", 0) for r in vrs) / len(vrs)
            if scores:
                leader = max(scores, key=scores.get)
                score_str = " ".join(f"{v}={q:.3f}" for v, q in scores.items())
                lines.append(f"  Last 20: {score_str} -> {leader} leading")

        # Phase B prompt version stats
        by_pb = {}
        for r in records:
            v = r.get("phase_b_prompt_version", "unknown")
            by_pb.setdefault(v, []).append(r)
        pb_lines = []
        for v in ("v1", "v1.1", "v2"):
            rs = by_pb.get(v, [])
            if not rs:
                continue
            n = len(rs)
            avg_q = sum(r.get("quality_score", 0) for r in rs) / n
            pb_lines.append(f"  {v}: n={n:3d} avg_Q={avg_q:.3f}")
        if pb_lines:
            lines.append("")
            lines.append("[A/B] Phase B prompt version stats:")
            lines.extend(pb_lines)

        # Phase A/B split stats
        try:
            from cycle_analytics import CycleAnalytics
            ca = CycleAnalytics(extractor.workspace)
            ps = ca.get_phase_split_stats()
            threshold = extractor._adaptive_phase_b_threshold()
            lines.append("")
            lines.append(f"[Phase] Two-phase split (threshold={threshold:.3f}):")
            lines.append(f"  Total cycles: {ps['n_total']} (packaged={ps['n_complete']}, A_only={ps['n_a_only']}, "
                         f"packaged_pct={ps['pct_packaged']}%)")
            lines.append(f"  Avg Q: packaged={ps['avg_q_packaged']}  A_only={ps['avg_q_a_only']}")
            if ps['skip_reasons']:
                lines.append(f"  Skip reasons: {ps['skip_reasons']}")
            lines.append(f"  p70 quality (recent): {ps['p70_quality_recent']}")
        except Exception as e:
            lines.append(f"  [Phase] stats error (non-fatal): {e}")

        print("\n".join(lines))
    except Exception as e:
        # Non-critical — don't break the tick
        print(f"[A/B] Stats error (non-fatal): {e}")


def _print_quality_metrics(extractor: "KnowledgeExtractor") -> None:
    """Print rolling quality metrics: sorry%, theorem density, proof depth by version.

    Tracks whether output quality is improving, flat, or regressing.
    """
    try:
        import json as _json
        analytics_path = extractor.workspace / "cycle_analytics.json"
        if not analytics_path.exists():
            return
        data = _json.loads(analytics_path.read_text())
        records = data.get("records", [])
        if not records:
            return

        # Last 30 records for rolling metrics
        recent = records[-30:]
        by_ver = {}
        for r in recent:
            v = r.get("prompt_version", "unknown")
            by_ver.setdefault(v, []).append(r)

        lines = ["[Quality] Rolling metrics (last 30 cycles):"]
        for v in ("v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15", "v16", "v16a", "v16b", "v17", "v18", "v19", "v19a", "v19b", "v19c", "v19d"):
            rs = by_ver.get(v, [])
            if not rs:
                continue
            n = len(rs)
            # Sorry rate: fraction of cycles with any sorry
            sorry_cycles = sum(1 for r in rs if r.get("sorry_count", 0) > 0)
            sorry_rate = sorry_cycles / n * 100 if n else 0
            # Avg sorry count per cycle
            avg_sorry = sum(r.get("sorry_count", 0) for r in rs) / n
            # Avg theorem count per cycle
            avg_theorems = sum(r.get("theorem_count", 0) for r in rs) / n
            # Avg quality score
            avg_q = sum(r.get("quality_score", 0) for r in rs) / n
            avg_qa = sum(r.get("phase_a_quality_score", r.get("quality_score", 0)) for r in rs) / n
            # Theorem novelty: new vs strengthening vs duplicate vs disproof
            total_new = sum(r.get("theorem_novelty_new", 0) for r in rs)
            total_strength = sum(r.get("theorem_novelty_strengthening", 0) for r in rs)
            total_dup = sum(r.get("theorem_novelty_duplicate", 0) for r in rs)
            total_disproof = sum(r.get("theorem_novelty_disproof", 0) for r in rs)
            lines.append(f"  {v}: n={n} avg_Q_A={avg_qa:.3f} avg_Q={avg_q:.3f} sorry_rate={sorry_rate:.0f}% "
                         f"avg_sorry={avg_sorry:.1f} avg_theorems={avg_theorems:.0f} "
                         f"novelty=[new={total_new} +{total_strength} dup={total_dup} ¬={total_disproof}]")

        # Trend: compare last 15 vs first 15 of recent
        if len(recent) >= 20:
            first_half = recent[:len(recent)//2]
            second_half = recent[len(recent)//2:]
            q1 = sum(r.get("quality_score", 0) for r in first_half) / len(first_half)
            q2 = sum(r.get("quality_score", 0) for r in second_half) / len(second_half)
            qa1 = sum(r.get("phase_a_quality_score", r.get("quality_score", 0)) for r in first_half) / len(first_half)
            qa2 = sum(r.get("phase_a_quality_score", r.get("quality_score", 0)) for r in second_half) / len(second_half)
            trend = "improving" if q2 > q1 + 0.01 else "declining" if q2 < q1 - 0.01 else "flat"
            lines.append(f"  Trend: {trend} (Q_A: {qa1:.3f} → {qa2:.3f}, Q: {q1:.3f} → {q2:.3f})")

        print("\n".join(lines))
    except Exception as e:
        print(f"[Quality] Metrics error (non-fatal): {e}")


def _print_tick_report(extractor: "KnowledgeExtractor", completed_jobs, remaining: int, queued_remaining: int) -> None:
    """Consolidated end-of-tick telemetry + diagnostics report.

    Gathers every stat block (state, LLM accounting, A/B version stats, Phase
    split, rolling quality, package/lineage counts) into ONE section so the
    tick log ends with a single scannable summary.
    """
    import json as _json
    from collections import Counter
    print("\n" + "=" * 72)
    print("AETHER TICK REPORT")
    print("=" * 72)

    # --- State ---
    try:
        from research_memory import FutureDirectionsManager as _FD
        _if = Counter(j.status for j in extractor.inflight.values())
        _fd = _FD(extractor.workspace)
        _dir = Counter(d.status for d in _fd._directions)
        _active = sum(1 for j in extractor.inflight.values()
                      if j.status in ("preparing", "dispatched", "retry_queued"))
        print(f"[State]   inflight={dict(_if)} | directions={dict(_dir)} "
              f"| active_jobs={_active} in_progress={_dir.get('in_progress', 0)}")
    except Exception as _e:
        print(f"[State]   state check failed: {_e}")

    # --- LLM accounting ---
    try:
        _s = getattr(getattr(extractor, "pi_agent", None), "llm_stats", None)
        if _s:
            _c = _s["calls"]
            _sk = _s["skipped"]
            _skt = sum(_sk.values())
            print(f"[LLM]     calls={_c['total']} "
                  f"(eval={_c.get('eval', 0)} breakthrough={_c.get('breakthrough', 0)} "
                  f"critic={_c.get('critic', 0)}+{_c.get('critic_tiebreak', 0)}tie "
                  f"lint={_c.get('lint', 0)} pruning={_c.get('pruning', 0)} "
                  f"other={_c.get('other', 0)}) | skipped={_skt} "
                  f"(eval={_sk.get('eval', 0)} critic={_sk.get('critic', 0)} "
                  f"lint={_sk.get('lint', 0)} pruning={_sk.get('pruning', 0)})")
    except Exception as _e:
        print(f"[LLM]     stats failed: {_e}")

    # --- Integration summary ---
    print(f"[Done]    {len(completed_jobs)} integrated, {remaining} still inflight, "
          f"{queued_remaining} retry-queued")

    # --- A/B + Phase split + Rolling quality (existing sub-reports) ---
    _print_prompt_version_stats(extractor)
    _print_quality_metrics(extractor)

    # --- Packages + lineage (knowledge graph) ---
    try:
        import glob as _g
        _skip_stems = {"index", "package", "lineage", "future_directions",
                       "future_directions_snapshot", "catalog_tree", "statement"}
        _pkgs = [f for f in _g.glob(str(PACKAGES_DIR / "*.json"))
                 if Path(f).stem not in _skip_stems]
        _lf = PACKAGES_DIR / "lineage.json"
        _ln = _le = _lb = 0
        if _lf.exists():
            _ld = _json.loads(_lf.read_text())
            _ln = len(_ld.get("nodes", []))
            _le = len(_ld.get("edges", []))
            _lb = len(_ld.get("domain_bridges", []))
        _mismatch = "" if _ln == len(_pkgs) else f" (⚠ lineage stale: {len(_pkgs) - _ln} unindexed)"
        print(f"[Packages] index={len(_pkgs)} | lineage={_ln} nodes, {_le} edges, "
              f"{_lb} bridges{_mismatch}")
    except Exception as _e:
        print(f"[Packages] report failed: {_e}")

    # --- Bandit state (Thompson sampling) ---
    try:
        _bs_path = extractor.workspace / "prompt_bandit_state.json"
        if _bs_path.exists():
            _bs = json.loads(_bs_path.read_text())
            if _bs:
                _sorted = sorted(_bs.items(), key=lambda x: x[1].get("alpha",1)/(x[1].get("alpha",1)+x[1].get("beta",1)), reverse=True)
                print("[Bandit]   Thompson sampling posterior (sorted by mean):")
                for _arm, _st in _sorted[:5]:
                    _a = _st.get("alpha", 1.0)
                    _b = _st.get("beta", 1.0)
                    _mean = _a / (_a + _b) if (_a + _b) > 0 else 0
                    _n = _st.get("n", 0) if isinstance(_st.get("n"), (int, float)) else _st.get("count", 0)
                    _q = _st.get("avg_Q", _st.get("avg_quality", 0.0))
                    print(f"[Bandit]   {_arm:6s}: \u03b1={_a:.1f} \u03b2={_b:.1f} mean={_mean:.3f} n={_n} avg_Q={_q:.3f}")
                if _sorted:
                    _leader = _sorted[0][0]
                    _lm = _sorted[0][1].get("alpha",1) / (_sorted[0][1].get("alpha",1) + _sorted[0][1].get("beta",1))
                    print(f"[Bandit]   -> leader: {_leader} (posterior mean {_lm:.3f})")
    except Exception:
        pass

    print("=" * 72)


def _signal_dashboard_update(job_id: str = "", action: str = "update") -> None:
    """Write a lightweight last_update.json so the live dashboard polls refresh."""
    try:
        import json as _json
        status_dir = REPO_ROOT / "docs" / "aether_status"
        status_dir.mkdir(parents=True, exist_ok=True)
        (status_dir / "last_update.json").write_text(
            _json.dumps({
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "action": action,
                "job_id": job_id,
            })
        )
    except Exception:
        pass  # non-critical

# Watchdog: set to True if core files changed after git pull
_core_files_changed = False

# Core Aether Python files that require a restart if they change after git pull
CORE_FILES = [
    "Aether/aether_tick.py",
    "Aether/knowledge_extractor.py",
    "Aether/pi_agent_client.py",
    "Aether/catalog_analyzer.py",
    "Aether/research_memory.py",
    "Aether/insight_extractor.py",
    "Aether/aristotle_loop.py",
    "Aether/output_organizer.py",
    "Aether/quality_evaluator.py",
    "Aether/lineage_extractor.py",
    "Aether/seed_directions.py",
    "Aether/cycle_analytics.py",
    "Aether/catalog_pruner.py",
]


def _snapshot_core_hashes() -> Dict[str, str]:
    """Take a snapshot of SHA256 hashes for all core Aether files."""
    import hashlib
    hashes = {}
    for rel in CORE_FILES:
        fp = REPO_ROOT / rel
        if fp.exists():
            try:
                hashes[rel] = hashlib.sha256(fp.read_bytes()).hexdigest()[:16]
            except Exception:
                hashes[rel] = "?"
    return hashes


def _snapshot_core_mtimes() -> Dict[str, float]:
    """Take a snapshot of mtime for all core Aether files.

    Used by the mtime watchdog to detect user-committed code changes that
    bypassed git pull. SHA256 is too slow to run every tick; mtime is fast.
    """
    mtimes = {}
    for rel in CORE_FILES:
        fp = REPO_ROOT / rel
        if fp.exists():
            try:
                mtimes[rel] = fp.stat().st_mtime
            except Exception:
                mtimes[rel] = 0.0
    return mtimes


def _check_mtime_drift(snapshot: Dict[str, float]) -> bool:
    """Check if any core file's mtime has changed since snapshot was taken.

    Returns True if any file was modified. Used to detect when the user
    has committed code changes directly to local files (bypassing git pull)
    that the running process hasn't picked up.
    """
    changed = []
    for rel, mtime in snapshot.items():
        fp = REPO_ROOT / rel
        if fp.exists():
            try:
                if fp.stat().st_mtime != mtime:
                    changed.append(rel)
            except Exception:
                pass
    if changed:
        print(f"[Watchdog] Core files modified (mtime drift): {changed}")
        return True
    return False


def _check_core_file_changes(pre_pull_hashes: Dict[str, str]) -> bool:
    """Check if any core Aether files changed after a git pull.

    Returns True if any core file changed, indicating a restart is needed.
    """
    post_pull_hashes = _snapshot_core_hashes()
    changed = []
    for rel in CORE_FILES:
        pre = pre_pull_hashes.get(rel, "")
        post = post_pull_hashes.get(rel, "")
        if pre and post and pre != post:
            changed.append(rel)
    if changed:
        print(f"[Watchdog] Core files changed after git pull: {changed}")
        print("[Watchdog] Aether process restart required")
        return True
    return False





async def tick(extractor: KnowledgeExtractor, max_inflight: int, novelty_slots: int = 3) -> None:
    """Run one tick inside a single event loop, with a cross-process lock.

    Only one process can execute a tick at a time. This prevents the local
    loop and CI from each dispatching up to max_inflight jobs and overflowing
    the Aristotle queue.
    """
    lock_path = extractor.workspace / "aether_tick.lock"
    with FileLock(lock_path):
        # Reload inflight state from disk in case another process updated it
        # while we were waiting for the lock.
        extractor._load_inflight()
        # Also reload the long-lived FutureDirectionsManager so it doesn't overwrite the disk file with stale memory
        if hasattr(extractor, "fd_manager"):
            extractor.fd_manager._load()
        # Phase 0: reset per-tick LLM call accounting.
        try:
            if hasattr(extractor, "pi_agent") and extractor.pi_agent is not None:
                extractor.pi_agent.reset_llm_stats()
        except Exception:
            pass
        await _tick_impl(extractor, max_inflight, novelty_slots)


async def _tick_impl(extractor: KnowledgeExtractor, max_inflight: int, novelty_slots: int = 3) -> None:
    """Run one tick inside a single event loop.

    novelty_slots: number of dispatch slots reserved for novelty/wild directions
    """
    # 1. Poll inflight jobs


    # Recover stale in_progress directions (e.g., from crashed ticks)
    from research_memory import FutureDirectionsManager
    fd_manager = FutureDirectionsManager(extractor.workspace)
    recovered = fd_manager.recover_stale_directions()
    if recovered:
        print(f"[Tick] Recovered {recovered} stale direction(s)")

    # Auto-refill novelty pool if it's running low
    available_novelty = len([d for d in fd_manager._directions
                            if d.status == "available" and "Novelty" in d.domains])
    if available_novelty < 5:
        from seed_directions import get_seed_directions
        seed_dirs = get_seed_directions()
        novelty_seeds = [sd for sd in seed_dirs if "Novelty" in sd.domains]
        added = 0
        
        # LLM-driven novelty replenishment
        if hasattr(extractor.pi_agent, 'generate_novelty_directions'):
            try:
                import functools
                from research_memory import FutureDirection
                
                recent_bts = []
                if hasattr(extractor, 'analytics'):
                    breakthroughs = extractor.analytics.get_breakthroughs(threshold=0.8)
                    recent_bts = breakthroughs[-5:] if breakthroughs else []
                if recent_bts:
                    bt_dicts = [{'title': b.concept_title, 'concept': getattr(b, 'concept_description', '')} for b in recent_bts]
                    llm_dirs = await asyncio.to_thread(
                        functools.partial(
                            extractor.pi_agent.generate_novelty_directions,
                            recent_breakthroughs=bt_dicts,
                            count=3
                        )
                    )
                    existing_titles = {d.title.lower().strip() for d in fd_manager._directions}
                    for d in llm_dirs:
                        d_title = d.get('title', '')
                        if d_title and d_title.lower().strip() not in existing_titles:
                            new_dir = FutureDirection(
                                id=fd_manager._next_id(),
                                title=d_title,
                                description=d.get('concept', ''),
                                source_exp_id="llm_novelty",
                                source_path="llm_novelty",
                                timestamp=datetime.now(timezone.utc).isoformat(),
                                status="available",
                                priority_score=0.9
                            )
                            # Tag source='llm_novelty'
                            new_dir.source = "llm_novelty"
                            if hasattr(new_dir, 'domains'):
                                new_dir.domains = ["Novelty"]
                            fd_manager.add_direction(new_dir)
                            added += 1
            except Exception as e:
                print(f"[Tick] LLM novelty generation failed: {e}")

        for sd in novelty_seeds:
            if available_novelty + added >= 5:
                break
            existing_titles = {d.title.lower().strip() for d in fd_manager._directions}
            if sd.title.lower().strip() not in existing_titles:
                sd.id = fd_manager._next_id()
                sd.status = "available"
                fd_manager.add_direction(sd)
                added += 1
        if added:
            fd_manager._save()
            print(f"[Tick] Auto-refilled {added} novelty directions (was {available_novelty})")

    inflight_count = len(extractor.inflight)
    print(f"[Tick] {inflight_count} inflight jobs")

    completed_jobs = []
    if inflight_count > 0:
        completed_jobs = await extractor.poll_all()
        print(f"[Tick] {len(completed_jobs)} jobs completed since last tick")

    # Recover already-completed jobs that weren't integrated (e.g., after restart)
    recovered = [j for j in extractor.inflight.values()
                if j.status == "completed" and j not in completed_jobs]
    if recovered:
        print(f"[Tick] Recovered {len(recovered)} previously-completed jobs for integration")
        completed_jobs.extend(recovered)

    # 2. Integrate completed jobs
    for job in completed_jobs:
        if job.status != "completed":
            print(f"[Tick] Skipping {job.job_id[:8]} (status={job.status})")
            continue

        # Check if another retry of this job has already dispatched Phase B or completed.
        # This prevents duplicate/stale retries from overwriting/aborting active Phase B.
        if job.phase == "A":
            already_dispatched_b = False
            for active_job in extractor.inflight.values():
                if active_job.job_id == job.job_id and active_job.phase in ("B", "B_dispatched", "complete"):
                    already_dispatched_b = True
                    break
            if already_dispatched_b:
                print(f"[Tick] Skipping stale Phase A completed retry {job.job_id[:8]} since Phase B is already active/complete for this job.")
                if job.project_id and job.project_id in extractor.inflight:
                    del extractor.inflight[job.project_id]
                    extractor._save_inflight()
                continue

        # If this is a Phase B completion, preserve Phase A's Lean files
        # so integrate_async doesn't think we have no math.
        is_phase_b_completion = (job.phase == "B" or job.phase == "B_dispatched")
        if is_phase_b_completion:
            print(f"[Tick] Phase B completed for {job.job_id[:8]}: {job.concept.title[:60]}")
            # Snapshot Phase A's Lean content before extract_async overwrites it
            phase_a_lean_backup = job.result_lean
            phase_a_paths_backup = list(job.integrated_paths or [])
            # Mark phase so extract can handle the merge
            job.phase = "complete"  # Will become "complete" after integrate
        else:
            print(f"[Tick] Integrating {job.job_id[:8]}: {job.concept.title[:60]}")
            phase_a_lean_backup = None
            phase_a_paths_backup = None

        job = await extractor.extract_async(job)
        extractor._save_inflight()

        # If Phase B overwrote result_lean, restore Phase A's
        if is_phase_b_completion and phase_a_lean_backup:
            job.result_lean = phase_a_lean_backup
            # Merge integrated_paths: Phase A's Lean + Phase B's articles/demos
            if phase_a_paths_backup:
                existing = set(job.integrated_paths or [])
                for p in phase_a_paths_backup:
                    if p not in existing:
                        job.integrated_paths = (job.integrated_paths or []) + [p]

        if job.error_message:
            print(f"[Tick] Extract failed: {job.error_message}")
            # Auth errors (403/401) mean we can never download this project's
            # results — it belongs to a different account. Mark as failed and
            # release the future direction so it can be retried.
            if "authentication error" in job.error_message or "403" in job.error_message or "401" in job.error_message:
                print(f"[Tick] Auth error on {job.job_id[:8]} — releasing direction")
                extractor._release_direction(job)
                # Remove from inflight so we don't keep retrying
                if job.project_id in extractor.inflight:
                    del extractor.inflight[job.project_id]
                extractor.failed_count += 1
            continue

        # ── End-of-Thought Continuation Prod ──
        if not is_phase_b_completion and job.result_lean:
            continuation_check = extractor.pi_agent.analyze_for_continuation(job.result_lean)
            if continuation_check.get("needs_continuation") and getattr(job, "prod_count", 0) < 2:
                job.prod_count = getattr(job, "prod_count", 0) + 1
                prod_prompt = continuation_check.get("prod_prompt", "Please continue your work to completion.")
                print(f"[Tick] Prodding job {job.job_id[:8]} to continue (Prod {job.prod_count}): {prod_prompt}")
                try:
                    # Resume the existing project on the server
                    await extractor.aristotle.resume_project(job.project_id, prod_prompt)
                    # Reset status to put it back in the polling queue
                    job.status = "dispatched"
                    job.phase = "A"
                    extractor.inflight[job.project_id] = job
                    extractor._save_inflight()
                    # Skip the rest of this loop so it gets polled next tick
                    continue
                except Exception as e:
                    print(f"[Tick] Failed to prod job {job.job_id[:8]}: {e}")

        job = extractor.evaluate(job)
        extractor._save_inflight()

        # ── Dialogue-Based Proof Repair Loop ──
        if not is_phase_b_completion and job.quality_assessment and job.quality_assessment.get("should_retry"):
            is_incremental = False
            if job.quality_score >= 0.6 and job.quality_assessment.get("quality") == "partial":
                job.quality_assessment["accepted_as"] = "incremental"
                is_incremental = True
                print(f"[Tick] Job {job.job_id[:8]} early-accept as incremental (Q={job.quality_score:.3f}).")
            
            if not is_incremental:
                if job.retry_count < extractor.max_retries:
                    print(f"[Tick] Job {job.job_id[:8]} quality check failed (Q={job.quality_score:.3f}, quality={job.quality_assessment.get('quality')}). "
                          f"Initiating proof repair retry {job.retry_count + 1}/{extractor.max_retries}...")
                    
                    # Retrieve suggestion from Pi Agent
                    import functools
                    suggestion = await asyncio.to_thread(
                        functools.partial(
                            extractor.pi_agent.suggest_retry_improvement,
                            concept=job.concept,
                            previous_prompt=job.prompt,
                            result_lean=job.result_lean or "",
                            quality_assessment=job.quality_assessment,
                        )
                    )
                    
                    # Dispatch the retry, passing the current parallel limit so the retry
                    # is queued instead of overflowing Aristotle's queue.
                    current_max_inflight = max_inflight
                    job = await extractor.dispatch_retry_async(job, suggestion, max_inflight=current_max_inflight)
                    extractor._save_inflight()
                    continue
                else:
                    import functools
                    # Max retries reached - attempt decomposition
                    if hasattr(extractor.pi_agent, 'decompose_direction'):
                        job_depth = getattr(job, 'decomposition_depth', 0)
                        if job_depth < 2:
                            print(f"[Tick] Job {job.job_id[:8]} failed {extractor.max_retries} times. Attempting decomposition (depth {job_depth})...")
                            try:
                                # We must read concept title + description to pass to decompose
                                concept_str = f"{job.concept.title}: {job.concept.concept_description}" if hasattr(job.concept, 'title') else str(job.concept)
                                directions = await asyncio.to_thread(
                                    functools.partial(
                                        extractor.pi_agent.decompose_direction,
                                        concept=concept_str,
                                        job_id=job.job_id
                                    )
                                )
                                if directions and hasattr(extractor, 'memory') and hasattr(extractor.memory, 'future_directions'):
                                    mgr = extractor.memory.future_directions
                                    from research_memory import FutureDirection
                                    for idx, d in enumerate(directions):
                                        new_id = f"dir_{int(time.time())}_{job.job_id[-4:]}_{idx}"
                                        new_dir = FutureDirection(
                                            id=new_id,
                                            title=d.get("title", f"Sub-lemma of {job.job_id[:8]}"),
                                            description=d.get("concept", ""),
                                            source_exp_id="decomposition",
                                            source_path="decomposition",
                                            status="available",
                                        )
                                        new_dir.parent_direction = job.job_id
                                        new_dir.decomposed_from_job = job.job_id
                                        new_dir.decomposition_depth = job_depth + 1
                                        new_dir.domains = [getattr(job, 'domain', getattr(job.concept, 'domain', ''))]
                                        if hasattr(mgr, 'directions'):
                                            mgr.directions.append(new_dir)
                                        elif hasattr(mgr, 'add_direction'):
                                            mgr.add_direction(new_dir)
                                        print(f"[Tick]   -> Added decomposed direction: {new_dir.title}")
                                    if hasattr(mgr, '_save'):
                                        mgr._save()
                            except Exception as e:
                                print(f"[Tick] Decomposition failed: {e}")


        # ── Two-phase dispatch: gate Phase B on Phase A quality ──

        # INTEGRATE FIRST: write Phase A Lean files to Catalog.
        # This populates job.integrated_paths so Phase B's _build_project_dir
        # can use ONLY the Phase A Lean files (not the full Catalog).
        # Without this, Phase B falls back to the full 1185-file Catalog.
        job = await extractor.integrate_async(job)
        extractor._save_inflight()

        # Phase A was just evaluated. If the math is good enough, dispatch
        # Phase B to package it. Otherwise mark as A_only and integrate
        # the Lean files directly (no article/paper/widgets).
        #
        # Phase B packages that ARE created are always displayed on the website:
        # the index builder (Packages/update_index.py) and
        # the frontend sidebar do NOT filter by quality_score.
        #
        # CRITICAL: If this is a Phase B completion, skip Phase B dispatch entirely.
        # Phase B already ran — we just need to integrate both Phase A (Lean) and
        # Phase B (article/paper/demo/package) into the Catalog. The old code
        # mistakenly re-dispatched Phase B because job.quality_score (now Phase B's
        # score) was >= threshold and job.result_lean (restored from Phase A) was
        # non-empty, creating an infinite Phase B loop.
        if is_phase_b_completion:
            job.phase = "complete"
        else:
            adaptive = extractor._adaptive_phase_b_threshold()
            # adaptive is the rank-based p70 promotion threshold (top 30%).
            # phase_b_min_score is only a safety floor / operator override
            # (default 0.25); it must NOT re-introduce a high fixed bar or
            # it defeats the adaptive gate (the old 0.6 default did exactly that).
            phase_b_threshold = max(getattr(extractor, 'phase_b_min_score', 0.25), adaptive)
            phase_a_q = job.quality_score
            if phase_a_q >= phase_b_threshold and job.result_lean:
                # Phase B will be dispatched right now (within this same tick loop)
                # Then we wait for Phase B's results in a future tick
                print(f"[Tick] Phase A Q={phase_a_q:.3f} >= {phase_b_threshold:.3f} threshold (adaptive={adaptive:.3f}) — "
                      f"dispatching Phase B for {job.job_id[:8]}")
                # Save Phase A quality score
                job.phase_a_quality_score = phase_a_q
                # Snapshot Phase A result before dispatching B
                job.phase_a_result = {
                    "lean_files": [str(p) for p in (job.integrated_paths or []) if str(p).endswith('.lean')],
                    "theorem_count": job.theorem_count,
                    "sorry_count": job.sorry_count,
                    "quality_score": phase_a_q,
                }
                # Dispatch Phase B
                job = await extractor.dispatch_phase_b_async(job)
                if job.status == "failed":
                    # Phase B dispatch failed — fall back to A_only integration
                    print(f"[Tick] Phase B dispatch failed, falling back to A_only: {job.error_message}")
                    job.phase = "A_only"
                    job.phase_b_skipped_reason = "phase_b_dispatch_failed"
                else:
                    # Phase B dispatched successfully — wait for it next tick
                    # Do NOT integrate yet
                    continue
            else:
                # Phase B skipped — integrate the Lean files only
                if phase_a_q < phase_b_threshold:
                    job.phase = "A_only"
                    # For near-miss cycles (0.3-0.5), mark for potential retry with v8 prompt
                    # The v8 prompt is more robust and may produce better results
                    if phase_a_q >= 0.3:
                        job.phase_b_skipped_reason = "low_quality_near_miss"
                    else:
                        job.phase_b_skipped_reason = "low_quality"
                elif not job.result_lean:
                    job.phase = "A_only"
                    job.phase_b_skipped_reason = "phase_a_failed"
                print(f"[Tick] Phase A Q={phase_a_q:.3f} < {phase_b_threshold:.3f} — "
                      f"skipping Phase B, integrating Lean only ({job.job_id[:8]})")

        # Extract future directions
        extractor._extract_future_directions(job)

        # Cleanup and commit
        job = extractor.cleanup_catalog(job)
        extractor.commit(job)
        print(f"[Tick] Integrated {job.job_id[:8]}: score={job.quality_score:.3f}, "
              f"files={job.files_integrated}, theorems={job.theorem_count}")

        # Immediately remove from inflight — don't wait for the end-of-tick prune.
        # The Sonic cycle bug was caused by integrated jobs accumulating in
        # inflight_jobs.json, leading the stale-recovery to think directions
        # were abandoned and re-dispatch them.
        if job.project_id and job.project_id in extractor.inflight:
            del extractor.inflight[job.project_id]
            extractor._save_inflight()

        # Signal live dashboard update
        _signal_dashboard_update(job.job_id[:8], "cycle_integrated")

        # Record in research journal
        try:
            from research_journal import ResearchJournal
            journal = ResearchJournal(Path(__file__).parent / ".aether_workspace")
            journal.record_cycle(job, quality_score=job.quality_score)
        except Exception as e:
            print(f"[Journal] Recording failed: {e}")

        # ── Breakthrough push: auto-generate follow-up direction for promising cycles ──
        if job.quality_score >= 0.75 and job.theorem_count >= 5:
            print(f"[Push] Q={job.quality_score:.3f} — generating follow-up to push toward breakthrough")
            try:
                from research_memory import FutureDirectionsManager, FutureDirection
                import uuid
                fd_mgr = FutureDirectionsManager(Path(__file__).parent / ".aether_workspace")
                
                # Strip leading repeated "Close Proofs: " or "Deepening: " prefixes
                title_clean = job.concept.title
                while True:
                    lower_title = title_clean.lower().strip()
                    if lower_title.startswith("close proofs:"):
                        title_clean = title_clean[len("close proofs:"):].strip()
                    elif lower_title.startswith("deepening:"):
                        title_clean = title_clean[len("deepening:"):].strip()
                    else:
                        break
                
                follow_up_title = f"Deepening: {title_clean[:80]}"
                follow_up_desc = (
                    f"Building on cycle {job.job_id[:8]} (Q={job.quality_score:.3f}), "
                    f"which proved {job.theorem_count} theorems in {job.concept.domain}. "
                    f"Go DEEPER: prove the strongest remaining conjecture, close open sorries, "
                    f"or extend the core result to a more general setting. "
                    f"Original direction: {job.concept.concept_description[:300]}"
                )
                fd_mgr.add_direction(FutureDirection(
                    id=f"push_{job.job_id[:8]}_{uuid.uuid4().hex[:8]}",
                    title=follow_up_title,
                    description=follow_up_desc,
                    domains=[job.concept.domain] if job.concept.domain else [],
                    priority_score=min(0.95, job.quality_score + 0.1),  # Slightly higher than parent
                    source_exp_id=job.job_id,
                    source_path=job.concept.title[:80],
                ))
                print(f"[Push] Added follow-up direction: {follow_up_title[:60]}")
            except Exception as e:
                print(f"[Push] Follow-up direction failed: {e}")

        # ── Proof convergence: auto-generate sorry-fill directions ──
        if job.sorry_count > 0 and job.quality_score >= 0.4:
            print(f"[SorryFill] {job.sorry_count} sorries in {job.job_id[:8]} — generating fill direction")
            try:
                from research_memory import FutureDirectionsManager, FutureDirection
                import uuid
                fd_mgr = FutureDirectionsManager(Path(__file__).parent / ".aether_workspace")
                
                # Strip leading repeated "Close Proofs: " or "Deepening: " prefixes
                title_clean = job.concept.title
                while True:
                    lower_title = title_clean.lower().strip()
                    if lower_title.startswith("close proofs:"):
                        title_clean = title_clean[len("close proofs:"):].strip()
                    elif lower_title.startswith("deepening:"):
                        title_clean = title_clean[len("deepening:"):].strip()
                    else:
                        break
                
                fill_title = f"Close Proofs: {title_clean[:70]}"
                fill_desc = (
                    f"Cycle {job.job_id[:8]} (Q={job.quality_score:.3f}) proved "
                    f"{job.theorem_count} theorems in {job.concept.domain} but left "
                    f"{job.sorry_count} `sorry` placeholders. Fill them with complete proofs. "
                    f"Focus on the most important theorems first. "
                    f"Original: {job.concept.concept_description[:200]}"
                )
                fd_mgr.add_direction(FutureDirection(
                    id=f"sorry_fill_{job.job_id[:8]}_{uuid.uuid4().hex[:8]}",
                    title=fill_title,
                    description=fill_desc,
                    domains=[job.concept.domain] if job.concept.domain else [],
                    priority_score=min(0.85, job.quality_score + 0.05),
                    source_exp_id=job.job_id,
                    source_path=job.concept.title[:80],
                ))
                print(f"[SorryFill] Added direction: {fill_title[:60]}")
            except Exception as e:
                print(f"[SorryFill] Direction failed: {e}")

        # ── Breakthrough highlighting: tag high-quality packages ──
        if job.quality_score >= 0.8:
            print(f"[🌟 BREAKTHROUGH] {job.job_id[:8]}: score={job.quality_score:.3f} — "
                  f"breakthrough detected, tagging package")
            try:
                import json as json_mod
                # Find the package JSON for this job
                pkg_dir = extractor.workspace / "projects" / job.job_id[:8]
                if not pkg_dir.exists():
                    # Search in Catalog for the package
                    for pkg_file in extractor.catalog_root.rglob("*.json"):
                        if job.job_id[:8] in pkg_file.name or (hasattr(job, 'concept') and
                            hasattr(job.concept, 'title') and
                            job.concept.title[:30].replace(' ', '_').lower() in pkg_file.name.lower()):
                            try:
                                pkg_data = json_mod.loads(pkg_file.read_text())
                                pkg_data["breakthrough"] = True
                                pkg_data["breakthrough_score"] = job.quality_score
                                pkg_file.write_text(json_mod.dumps(pkg_data, indent=2, sort_keys=True))
                                print(f"[🌟 BREAKTHROUGH] Tagged {pkg_file.name}")
                            except Exception:
                                pass
            except Exception as e:
                print(f"[🌟] Breakthrough tagging failed: {e}")

        # If this was a Phase B integration completion, rebuild website index, sync docs/ and push to git
        if is_phase_b_completion and job.status == "integrated":
            print(f"[Tick] Phase B integration complete for {job.job_id[:8]}. Pushing git changes immediately...")
            # Fire-and-forget so git push never blocks the poll/dispatch loop
            publish_task = asyncio.create_task(asyncio.to_thread(rebuild_commit_push))
    for pid, job in list(extractor.inflight.items()):
        if job.status == "dispatch_queued":
            job.status = "retry_queued"
            job.retry_queued_time = time.time()
            print(f"[Tick] Converted dispatch-queued job {job.job_id[:8]} to retry-queued")
    extractor._save_inflight()

    # Prune completed/failed/integrated/rejected jobs from inflight to prevent unbounded growth
    stale_keys = [pid for pid, j in extractor.inflight.items()
                  if j.status in ("completed", "failed", "integrated", "rejected")]
    if stale_keys:
        for pid in stale_keys:
            job = extractor.inflight[pid]
            
            # --- NEW: Close GitHub injected issue if completed ---
            if getattr(job, 'github_issue', None):
                try:
                    import github_injector
                    if job.status == "integrated":
                        comment = f"Aether has completed researching this direction!\n\n**Quality Score**: {job.quality_score:.3f}\n**Theorems Proven**: {job.theorem_count}\n\nThe results have been integrated into the Aether Catalog."
                    elif job.status == "rejected":
                        comment = f"Aether completed researching this direction, but the results did not meet the quality threshold for integration.\n\n**Quality Score**: {job.quality_score:.3f}\n**Theorems Proven**: {job.theorem_count}"
                    else:
                        comment = f"Aether encountered an error or failed to process this direction.\n\n**Status**: {job.status}\n**Error**: {getattr(job, 'error_message', 'Unknown error')}"
                    
                    github_injector.close_injected_direction_with_comment(job.github_issue, comment)
                except Exception as e:
                    print(f"[Tick] Failed to close GitHub issue {job.github_issue}: {e}")
            # -----------------------------------------------------

            if job.project_dir and Path(job.project_dir).exists():
                try:
                    import shutil
                    print(f"[Cleanup] Pruning stale project workspace: {job.project_dir}")
                    shutil.rmtree(str(job.project_dir), ignore_errors=True)
                except Exception as e:
                    print(f"[Cleanup] Warning: failed to clean up stale project directory: {e}")
            del extractor.inflight[pid]
        print(f"[Tick] Pruned {len(stale_keys)} completed jobs from inflight")

    # Auto-cleanup: remove dispatched jobs stuck for >2 hours with no progress
    import time as _time
    now = _time.time()
    stuck_keys = []
    for pid, job in list(extractor.inflight.items()):
        if job.status == "dispatched":
            dispatch_ts = getattr(job, 'dispatch_time', None) or job.get('dispatch_time')
            if dispatch_ts and (now - float(dispatch_ts)) > 7200:
                stuck_keys.append(pid)
            elif not dispatch_ts:
                # No timestamp — assume stale from a previous run
                stuck_keys.append(pid)
    if stuck_keys:
        for pid in stuck_keys:
            job = extractor.inflight[pid]
            extractor._release_direction(job)
            if job.project_dir and Path(job.project_dir).exists():
                try:
                    import shutil
                    print(f"[Cleanup] Removing stuck project workspace: {job.project_dir}")
                    shutil.rmtree(str(job.project_dir), ignore_errors=True)
                except Exception as e:
                    print(f"[Cleanup] Warning: failed to clean up stuck project directory: {e}")
            del extractor.inflight[pid]
        print(f"[Tick] Cleaned up {len(stuck_keys)} stuck dispatched jobs (>2h, no progress)")

    # Retry-queued jobs that have been stuck for too long are considered failed.
    retry_stuck_keys = []
    for pid, job in list(extractor.inflight.items()):
        if job.status == "retry_queued":
            queued_ts = getattr(job, 'retry_queued_time', None)
            if queued_ts and (now - float(queued_ts)) > 3600:
                retry_stuck_keys.append(pid)
    if retry_stuck_keys:
        for pid in retry_stuck_keys:
            job = extractor.inflight[pid]
            job.status = "failed"
            job.error_message = "Retry-queued for >1h without dispatching"
            extractor._release_direction(job)
            if job.project_dir and Path(job.project_dir).exists():
                try:
                    import shutil
                    print(f"[Cleanup] Removing stuck retry project workspace: {job.project_dir}")
                    shutil.rmtree(str(job.project_dir), ignore_errors=True)
                except Exception as e:
                    print(f"[Cleanup] Warning: failed to clean up stuck retry project directory: {e}")
            del extractor.inflight[pid]
        print(f"[Tick] Cleaned up {len(retry_stuck_keys)} retry-queued jobs stuck >1h")

    # Defensive: remove any stray Catalog/{job_id}_retry{N}_aristotle/ staging
    # dirs left over from retry integration.
    _clean_catalog_retry_dirs()


    # ── Self-healing: auto-prune low-quality directions ──
    try:
        from research_memory import FutureDirectionsManager
        fd_heal = FutureDirectionsManager(extractor.workspace)
        stats = fd_heal.get_stats()
        if stats.get("retried_directions", 0) > 0:
            print(f"[Retry] {stats['retried_directions']} retried directions, "
                  f"rate={stats.get('retry_rate',0):.1%}, avg_attempts={stats.get('avg_attempts',0):.2f}")
        if stats["available"] > 500:  # Only prune when pool is large
            result = fd_heal.prune_directions(cap=400, min_quality=0.30)
            if result["pruned_count"] > 0:
                print(f"[Self-heal] Auto-pruned {result['pruned_count']} low-quality directions")
    except Exception as e:
        print(f"[Self-heal] Auto-prune failed: {e}")

    # ── Auto-rebalance: prune overrepresented domains ──
    try:
        from research_memory import FutureDirectionsManager
        fd_rebal = FutureDirectionsManager(extractor.workspace)
        rebal_result = fd_rebal.rebalance_domains(max_domain_fraction=0.30, prune_bottom_fraction=0.15)
        if rebal_result:
            pruned_total = sum(rebal_result.values())
            if pruned_total > 0:
                print(f"[Rebalance] Pruned {pruned_total} overrepresented directions: {rebal_result}")
    except Exception as e:
        print(f"[Rebalance] Domain rebalance failed: {e}")

    # ── Aggressive Catalog curation: remove ~10 low-quality files per tick ──
    try:
        from catalog_pruner import CatalogPruner
        pruner = CatalogPruner(catalog_root=REPO_ROOT / "Catalog", pi_agent=extractor.pi_agent, workspace=extractor.workspace)
        prune_result = pruner.prune(target_remove_count=10)
        removed = prune_result.get("removed", [])
        kept = prune_result.get("kept", [])
        print(f"[Prune] Removed {len(removed)} low-quality files, kept {len(kept)}")
    except Exception as e:
        print(f"[Prune] Catalog curation failed: {e}")

    terminal_jobs = [j for j in completed_jobs if j.phase in ("complete", "A_only") or j.status in ("failed", "rejected")]

    # ── Cycle analytics: record per-cycle metrics ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        for job in terminal_jobs:
            ca.record_cycle(job, insight_extractor=getattr(extractor, 'insight_extractor', None))
        if terminal_jobs:
            ca._save()
            print(f"[Analytics] Recorded {len(terminal_jobs)} cycle(s), total={len(ca.records)}")
    except Exception as e:
        print(f"[Analytics] Cycle recording failed: {e}")

    # ── Breakthrough detection: notify on high-quality cycles ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        breakthroughs = ca.get_breakthroughs(threshold=0.8)
        if breakthroughs:
            # Only notify about new breakthroughs from this tick
            this_tick_ids = {j.job_id for j in terminal_jobs}
            new_bt = [b for b in breakthroughs if b.job_id in this_tick_ids]
            for bt in new_bt:
                print(f"[🌟 BREAKTHROUGH] Q={bt.quality_score:.3f} domain={bt.domain or '?'} "
                      f"title={bt.title[:50]} theorems={bt.theorem_count} sorry={bt.sorry_density*100:.0f}%")
            # Also log funnel analytics
            funnel = ca.get_direction_funnel()
            if "conversion_rate" in funnel:
                print(f"[Funnel] total={funnel['total']} completed={funnel['completed']} "
                      f"seed_conv={funnel.get('seed_conversion_rate',0):.1%} "
                      f"organic_conv={funnel.get('organic_conversion_rate',0):.1%}")
    except Exception as e:
        print(f"[Breakthrough] Detection failed: {e}")

    # ── Quality decay alerting: detect declining domains ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        declining = ca.detect_quality_decay(window=5, threshold=-0.05)
        for d in declining:
            print(f"[⚠️ Decay] {d['domain']}: recent_avg={d['recent_avg']:.3f} "
                  f"prior_avg={d['prior_avg']:.3f} delta={d['delta']:.3f} (n={d['count']})")
            # Auto-inject reset direction for severely declining domains
            if d['delta'] < -0.15 and d['count'] >= 6:
                print(f"[🔄 Reset] Injecting fresh seed for declining domain: {d['domain']}")
                try:
                    from research_memory import FutureDirectionsManager, FutureDirection
                    fd_mgr = FutureDirectionsManager(extractor.workspace)
                    reset_title = f"[Reset] Fresh approach in {d['domain']}"
                    reset_desc = (
                        f"Domain {d['domain']} has declined by {abs(d['delta']):.3f} over recent cycles "
                        f"(recent avg={d['recent_avg']:.3f} vs prior={d['prior_avg']:.3f}). "
                        f"Take a completely fresh approach — different proof techniques, "
                        f"new definitions, or a different subfield within this domain. "
                        f"Avoid repeating approaches that have been producing diminishing returns."
                    )
                    import uuid
                    fd_mgr.add_direction(FutureDirection(
                        id=f"auto_reset_{d['domain']}_{uuid.uuid4().hex[:8]}",
                        title=reset_title,
                        description=reset_desc,
                        domains=[d['domain']],
                        priority_score=0.85,  # High priority to break the pattern
                        source_exp_id="auto_reset",
                        source_path=f"quality_regression_{d['domain']}",
                    ))
                except Exception as re_err:
                    print(f"[Reset] Failed: {re_err}")
            # Adaptive: cycle_analytics quality data is now merged into
            # recent_domain_quality in discover(), which feeds select_direction_weighted()
        # Log current domain quality weights from analytics
        domain_stats = ca.get_domain_stats()
        if domain_stats:
            for dom, stats in sorted(domain_stats.items(), key=lambda x: x[1].get("avg_quality", 0)):
                if stats.get("avg_quality", 0) > 0:
                    print(f"[Weights] {dom}: avg_quality={stats['avg_quality']:.3f} "
                          f"n={stats.get('count',0)} sorry={stats.get('avg_sorry_density',0)*100:.1f}%")
        # Reasoning log stats: how is Aristotle actually behaving?
        try:
            rlog_stats = ca.get_reasoning_log_stats()
            if rlog_stats.get("total_projects", 0) > 0:
                print(f"[Reasoning] {rlog_stats['total_projects']} projects: "
                      f"{rlog_stats['completion_rate']:.0%} completed, "
                      f"avg {rlog_stats['avg_duration_minutes']:.1f}min, "
                      f"{rlog_stats['total_stalls']} stalls, "
                      f"avg {rlog_stats['avg_checkpoints_per_project']:.1f} checkpoints/project")
        except Exception:
            pass
    except Exception as e:
        print(f"[Decay] Quality decay detection failed: {e}")

    # ── Cycle duration analytics: alert on slow cycles ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        recent = ca.records[-5:] if len(ca.records) >= 5 else ca.records
        with_dur = [r for r in recent if r.duration_seconds > 0]
        if with_dur:
            avg_dur = sum(r.duration_seconds for r in with_dur) / len(with_dur)
            slow = [r for r in with_dur if r.duration_seconds > 2 * avg_dur and avg_dur > 0]
            for s in slow:
                mins = s.duration_seconds / 60
                avg_mins = avg_dur / 60
                print(f"[⏱️ Slow] {s.domain or '?'}: {mins:.1f}m (avg {avg_mins:.1f}m) — {(s.title or '?')[:40]}")
            if not slow and with_dur:
                avg_mins = avg_dur / 60
                print(f"[Duration] Avg cycle: {avg_mins:.1f}m across {len(with_dur)} cycles")
    except Exception as e:
        print(f"[Duration] Cycle duration analytics failed: {e}")

    # ── Discovery digest: summarize recent research activity ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        digest = ca.generate_digest(last_n=20)
        if digest.get("total_cycles", 0) > 0:
            print(f"[Digest] Cycles: {digest['total_cycles']} total, "
                  f"{digest['recent_cycles']} recent, "
                  f"avg Q={digest['avg_quality']:.3f}, "
                  f"avg duration={digest['avg_duration_minutes']:.1f}m")
            if digest.get("breakthroughs"):
                for bt in digest["breakthroughs"][:3]:
                    print(f"[🌟 BREAKTHROUGH] Q={bt['quality']:.3f} {bt['domain']}: {bt['title']}")
            if digest.get("trends", {}).get("improving"):
                print(f"[📈 Improving] {', '.join(digest['trends']['improving'])}")
            if digest.get("trends", {}).get("declining"):
                print(f"[📉 Declining] {', '.join(digest['trends']['declining'])}")
            top = digest.get("top_cycles", [])[:3]
            if top:
                top_strs = [f"{t['domain']}:{t['quality']:.2f}" for t in top]
                print(f"[Top] Best recent: {'; '.join(top_strs)}")
    except Exception as e:
        print(f"[Digest] Discovery digest failed: {e}")

    # ── Self-healing: auto-retry failed jobs with modified prompt ──
    # Find recently failed jobs and retry them once with a simpler research mode
    retry_count = 0
    for pid, job in list(extractor.inflight.items()):
        if job.status != "failed" or retry_count >= 1:
            continue
        # Only retry if the job hasn't been retried already
        if getattr(job, '_retried', False):
            continue
        # Only retry jobs that failed due to timeout or extraction errors
        if job.error_message and any(
            kw in job.error_message.lower()
            for kw in ["timeout", "extraction", "empty result"]
        ):
            print(f"[Self-heal] Retrying failed job {job.job_id[:8]}: {job.concept.title[:50]}")
            # Release the current direction and re-discover
            extractor._release_direction(job)
            del extractor.inflight[pid]
            retry_count += 1

    # 3. Retry any queued retries first, before discovering new directions.
    queued_retries = [j for j in extractor.inflight.values() if j.status == "retry_queued"]
    for queued in queued_retries:
        if extractor._count_inflight_dispatched() >= max_inflight:
            print(f"[Tick] No capacity to drain queued retries ({extractor._count_inflight_dispatched()}/{max_inflight} inflight)")
            break
        try:
            queued.status = "preparing"
            queued.preparing_started = time.time()
            project_id = await extractor._dispatch_to_aristotle(queued)
            if queued.project_id and queued.project_id in extractor.inflight:
                del extractor.inflight[queued.project_id]
            if queued.job_id in extractor.inflight:
                del extractor.inflight[queued.job_id]
            queued.project_id = project_id
            queued.status = "dispatched"
            queued.dispatch_time = time.time()
            extractor.inflight[project_id] = queued
            # Retry-queued dispatches skip the discover path, but the direction
            # was never released, so we do not need to re-consume it.
            print(f"[Tick] Dispatched queued retry {project_id[:8]}: {queued.concept.title[:60]}")
        except Exception as e:
            if extractor._is_queue_full_error(e):
                print(f"[Tick] Aristotle queue still full; leaving retry {queued.job_id[:8]} queued")
                queued.status = "retry_queued"
                queued.project_id = None
            else:
                print(f"[Tick] Queued retry dispatch failed for {queued.job_id[:8]}: {e}")
                queued.status = "failed"
                queued.error_message = f"Queued retry dispatch failed: {e}"
                extractor._release_direction(queued)
        extractor._save_inflight()

    # 3b. Refresh external signal feed (arXiv/OEIS/LMFDB → FutureDirections)
    try:
        added_signals = extractor.refresh_external_signals(count_per_source=2)
        if added_signals:
            print(f"[Tick] External signal feed added {added_signals} direction(s)")
    except Exception as e:
        print(f"[Tick] External signal refresh failed: {e}")

    # 4. Dispatch new jobs up to max_inflight (with novelty track)
    current_inflight = extractor._count_inflight_dispatched()
    slots_available = max(0, max_inflight - current_inflight)

    # Domain saturation: exclude domains with ≥3 inflight jobs from new dispatches
    from collections import Counter
    inflight_domains = Counter()
    for j in extractor.inflight.values():
        if j.status not in ("completed", "failed", "integrated", "rejected"):
            domain = getattr(j.concept, 'domain', '') if hasattr(j, 'concept') else ''
            if domain:
                inflight_domains[domain] += 1
    saturated_domains = [d for d, cnt in inflight_domains.items() if cnt >= 3]
    if saturated_domains:
        print(f"[Tick] Domain saturation: {dict(inflight_domains)} — excluding {saturated_domains}")

    if slots_available <= 0:
        print(f"[Tick] No dispatch slots ({current_inflight}/{max_inflight} inflight)")
    else:
        # Probe Aristotle queue capacity once before consuming any directions.
        # This avoids marking directions in_progress and then failing to dispatch.
        try:
            probe_job = ResearchJob(
                job_id="__probe__",
                cycle_n=0,
                concept=ResearchConcept(
                    title="Queue probe",
                    domain="Bridges",
                    concept_description="Probe",
                    mathematical_framing="Probe",
                ),
                prompt="",
                project_dir=Path(__file__).parent,
            )
            # We can't actually dispatch a probe without a valid project dir, so
            # instead do a lightweight ping by checking an existing project's status.
            # If there are already max_inflight jobs running, assume the queue is full.
            if current_inflight >= max_inflight:
                raise RuntimeError("Queue probe: at max_inflight")
        except Exception:
            pass

        # --- NEW: Inject GitHub Issues ---
        try:
            import github_injector
            github_injector.inject_directions_into_memory(extractor.workspace)
        except Exception as e:
            print(f"[Tick] Failed to inject GitHub issues: {e}")

        # Dispatch injected issues bypassing max_inflight
        try:
            from research_memory import FutureDirectionsManager
            local_fd = FutureDirectionsManager(extractor.workspace)
            injected = [d for d in local_fd._directions if d.status == "available" and getattr(d, "source", "") == "github_injection"]
            if injected:
                for fd in injected:
                    print(f"[Tick] Bypassing max_inflight to dispatch injected issue: {fd.title}")
                    try:
                        job = extractor.discover(forced_direction=fd)
                        job = await extractor.dispatch_async(job)
                        if job.project_id:
                            extractor.inflight[job.project_id] = job
                            print(f"[Tick] Dispatched injected issue {job.project_id[:8]}: {job.concept.title[:60]}")
                            _signal_dashboard_update(job.project_id[:8], "dispatched")
                        else:
                            extractor._release_direction(job)
                            print(f"[Tick] Dispatch failed for injected issue {job.concept.title[:60]}, direction released")
                    except Exception as inner_e:
                        print(f"[Tick] Inner error dispatching injected issue: {inner_e}")
                        import traceback
                        traceback.print_exc()
        except Exception as e:
            print(f"[Tick] Failed to dispatch injected issues: {e}")

        standard_slots = max(0, slots_available - novelty_slots)
        wild_slots = min(novelty_slots, slots_available)
        print(f"[Tick] {slots_available} dispatch slots available ({standard_slots} standard, {wild_slots} novelty)")

        queue_full = False

        # Dispatch standard directions
        for _ in range(standard_slots):
            if queue_full:
                break
            job = None
            try:
                job = extractor.discover(domain_filter=None, exclude_domains=["Novelty"] + saturated_domains)
                job = await extractor.dispatch_async(job)
                if job.project_id:
                    extractor.inflight[job.project_id] = job
                    print(f"[Tick] Dispatched {job.project_id[:8]}: {job.concept.title[:60]}")
                    _signal_dashboard_update(job.project_id[:8], "dispatched")
                else:
                    extractor._release_direction(job)
                    print(f"[Tick] Dispatch failed for {job.concept.title[:60]}, direction released")
            except Exception as e:
                if job is not None and (extractor._is_queue_full_error(e) or job.status == "dispatch_queued"):
                    print(f"[Tick] Aristotle queue full; leaving job {job.job_id[:8]} queued and stopping dispatch")
                    job.status = "retry_queued"
                    job.retry_queued_time = time.time()
                    extractor.inflight[job.job_id] = job
                    queue_full = True
                elif job is not None:
                    extractor._release_direction(job)
                    print(f"[Tick] Dispatch error: {e}, direction released")
                else:
                    print(f"[Tick] Dispatch error before discovery: {e}")

        # Dispatch novelty/wild directions
        for _ in range(wild_slots):
            if queue_full:
                break
            job = None
            try:
                job = extractor.discover(domain_filter="Novelty")
                job = await extractor.dispatch_async(job)
                if job.project_id:
                    extractor.inflight[job.project_id] = job
                    print(f"[Tick] Dispatched [NOVELTY] {job.project_id[:8]}: {job.concept.title[:60]}")
                    _signal_dashboard_update(job.project_id[:8], "dispatched_novelty")
                elif job.status == "dispatch_queued":
                    print(f"[Tick] Aristotle queue full; leaving job {job.job_id[:8]} queued and stopping dispatch")
                    job.status = "retry_queued"
                    job.retry_queued_time = time.time()
                    extractor.inflight[job.job_id] = job
                    queue_full = True
                else:
                    extractor._release_direction(job)
                    print(f"[Tick] Dispatch failed for {job.concept.title[:60]}, direction released")
            except Exception as e:
                if job is not None and (extractor._is_queue_full_error(e) or job.status == "dispatch_queued"):
                    print(f"[Tick] Aristotle queue full; leaving job {job.job_id[:8]} queued and stopping dispatch")
                    job.status = "retry_queued"
                    job.retry_queued_time = time.time()
                    extractor.inflight[job.job_id] = job
                    queue_full = True
                elif job is not None:
                    extractor._release_direction(job)
                    print(f"[Tick] Dispatch error: {e}, direction released")
                else:
                    print(f"[Tick] Dispatch error before discovery: {e}")

        # If we hit a queue-full error, do not attempt the novelty fallback
        # because it would consume more directions while Aristotle is full.
        extractor._save_inflight()

    # Reconcile in_progress directions to match active inflight jobs (true state at tick end).
    # Every active job's direction (keyed by direction_id, falling back to consumed_by_exp_id)
    # is forced to in_progress — this re-links retries whose direction was released or never
    # linked (retry-queued dispatches skip mark_direction_consumed). Stale in_progress with
    # no active job is cleared by recover_stale_directions at tick start.
    try:
        _active_jobs = []
        for _j in extractor.inflight.values():
            if hasattr(_j, "status") and _j.status in ("preparing", "dispatched", "retry_queued"):
                _active_jobs.append((
                    _j.job_id,
                    getattr(_j, "direction_id", None),
                    getattr(_j, "retry_of", None),
                ))
        from research_memory import FutureDirectionsManager as _FD
        _n_reconciled = _FD(extractor.workspace).reconcile_in_progress(_active_jobs)
        if _n_reconciled:
            print(f"[Tick] Reconciled {_n_reconciled} direction(s) to in_progress to match active inflight jobs")
    except Exception as _e:
        print(f"[Tick] in_progress reconcile failed: {_e}")

    # Consolidated end-of-tick report (state, LLM, A/B, phase split, quality,
    # packages/lineage). Replaces the previously-scattered stat blocks.
    remaining = extractor._count_inflight_dispatched()
    queued_remaining = len([j for j in extractor.inflight.values() if j.status == "retry_queued"])
    _print_tick_report(extractor, completed_jobs, remaining, queued_remaining)


def resolve_json_conflict(file_path: Path) -> bool:
    import json
    from datetime import datetime
    try:
        content = file_path.read_text(encoding="utf-8", errors="replace")
        if "<<<<<<<" not in content:
            return True
        
        ours_lines = []
        theirs_lines = []
        in_conflict = False
        in_theirs = False
        
        for line in content.splitlines():
            if line.startswith("<<<<<<<"):
                in_conflict = True
                in_theirs = False
            elif line.startswith("======="):
                in_theirs = True
            elif line.startswith(">>>>>>>"):
                in_conflict = False
                in_theirs = False
            else:
                if in_conflict:
                    if in_theirs:
                        theirs_lines.append(line)
                    else:
                        ours_lines.append(line)
                else:
                    ours_lines.append(line)
                    theirs_lines.append(line)
        
        ours_json = json.loads("\n".join(ours_lines))
        theirs_json = json.loads("\n".join(theirs_lines))
        
        merged_directions = {}
        for item in ours_json.get("directions", []) + theirs_json.get("directions", []):
            key = item.get("id") or item.get("timestamp") or str(item)
            merged_directions[key] = item
            
        def get_timestamp(item):
            t = item.get("timestamp")
            if isinstance(t, (int, float)):
                return t
            if isinstance(t, str):
                try:
                    return datetime.fromisoformat(t.replace("Z", "+00:00")).timestamp()
                except Exception:
                    pass
            return 0
            
        sorted_directions = sorted(merged_directions.values(), key=get_timestamp)
        
        merged_syntheses = {}
        merged_syntheses.update(ours_json.get("cycle_syntheses", {}))
        merged_syntheses.update(theirs_json.get("cycle_syntheses", {}))
        
        final_json = {
            "cycle_syntheses": merged_syntheses,
            "directions": sorted_directions
        }
        
        file_path.write_text(json.dumps(final_json, indent=2) + "\n", encoding="utf-8")
        print(f"[GitResolve] Resolved JSON conflict for {file_path.name}")
        return True
    except Exception as e:
        print(f"[GitResolve] Failed to resolve JSON conflict for {file_path}: {e}")
        return False


def resolve_jsonl_conflict(file_path: Path) -> bool:
    import json
    import re
    from datetime import datetime
    try:
        content = file_path.read_text(encoding="utf-8", errors="replace")
        if "<<<<<<<" not in content:
            return True
        
        ours_lines = []
        theirs_lines = []
        in_conflict = False
        in_theirs = False
        
        for line in content.splitlines():
            if line.startswith("<<<<<<<"):
                in_conflict = True
                in_theirs = False
            elif line.startswith("======="):
                in_theirs = True
            elif line.startswith(">>>>>>>"):
                in_conflict = False
                in_theirs = False
            else:
                if in_conflict:
                    if in_theirs:
                        theirs_lines.append(line)
                    else:
                        ours_lines.append(line)
                else:
                    ours_lines.append(line)
                    theirs_lines.append(line)
        
        def parse_lines(lines):
            parsed = []
            for l in lines:
                l = l.strip()
                if not l:
                    continue
                try:
                    parsed.append(json.loads(l))
                except Exception:
                    pass
            return parsed

        ours_json = parse_lines(ours_lines)
        theirs_json = parse_lines(theirs_lines)
        
        merged = {}
        for item in ours_json + theirs_json:
            key = item.get("experiment_id") or item.get("exp_id") or item.get("timestamp") or str(item)
            merged[key] = item
            
        def get_timestamp(item):
            t = item.get("timestamp")
            if isinstance(t, (int, float)):
                return t
            if isinstance(t, str):
                try:
                    return datetime.fromisoformat(t.replace("Z", "+00:00")).timestamp()
                except Exception:
                    pass
            return 0
            
        sorted_items = sorted(merged.values(), key=get_timestamp)
        
        file_path.write_text("\n".join(json.dumps(item) for item in sorted_items) + "\n", encoding="utf-8")
        print(f"[GitResolve] Resolved JSONL conflict for {file_path.name}")
        return True
    except Exception as e:
        print(f"[GitResolve] Failed to resolve JSONL conflict for {file_path}: {e}")
        return False


def resolve_lean_conflict(file_path: Path) -> bool:
    import re
    try:
        content = file_path.read_text(encoding="utf-8", errors="replace")
        if "<<<<<<<" not in content:
            return True
            
        pattern = re.compile(r"<<<<<<<[^\n]*\n(.*?)\n=======\n(.*?)\n>>>>>>>[^\n]*", re.DOTALL)
        
        def replace_block(match):
            ours = match.group(1)
            theirs = match.group(2)
            
            ours_sorries = ours.count("sorry")
            theirs_sorries = theirs.count("sorry")
            
            if theirs_sorries < ours_sorries:
                return theirs
            elif ours_sorries < theirs_sorries:
                return ours
            else:
                return theirs if len(theirs) >= len(ours) else ours
                
        new_content = pattern.sub(replace_block, content)
        file_path.write_text(new_content, encoding="utf-8")
        print(f"[GitResolve] Resolved Lean conflict for {file_path.name} (sorry-minimization)")
        return True
    except Exception as e:
        print(f"[GitResolve] Failed to resolve Lean conflict for {file_path}: {e}")
        return False


def resolve_all_conflicts() -> bool:
    """Identify and programmatically resolve all conflicts in the workspace."""
    # Find all conflicted files via git status
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=30
    )
    if result.returncode != 0:
        return False
        
    resolved_any = False
    for line in result.stdout.splitlines():
        if line.startswith("UU ") or line.startswith("AA ") or line.startswith("UD ") or line.startswith("DU ") or line.startswith("AU ") or line.startswith("UA "):
            path_str = line[3:].strip().strip('"')
            file_path = REPO_ROOT / path_str
            if not file_path.exists():
                continue
                
            success = False
            if file_path.name == "future_directions.json":
                success = resolve_json_conflict(file_path)
            elif file_path.suffix == ".jsonl":
                success = resolve_jsonl_conflict(file_path)
            elif file_path.suffix == ".lean" and file_path.name != "Main.lean":
                success = resolve_lean_conflict(file_path)
            elif file_path.name == "Main.lean":
                try:
                    file_path.write_text("/- Empty Catalog -/\n", encoding="utf-8")
                    success = True
                except Exception:
                    pass
            else:
                r = subprocess.run(
                    ["git", "checkout", "--ours", path_str],
                    cwd=str(REPO_ROOT), capture_output=True, timeout=10
                )
                success = r.returncode == 0
                
            if success:
                subprocess.run(
                    ["git", "add", path_str],
                    cwd=str(REPO_ROOT), capture_output=True, timeout=10
                )
                resolved_any = True
                
    return resolved_any

def _clean_stale_git_locks():
    """Remove .git/index.lock if no git process is running."""
    lock_file = REPO_ROOT / ".git" / "index.lock"
    if lock_file.exists():
        try:
            r = subprocess.run(["pgrep", "-x", "git"], capture_output=True)
            if r.returncode != 0:
                print(f"[Tick] Found stale {lock_file} with no active git process. Removing...")
                lock_file.unlink(missing_ok=True)
            else:
                print(f"[Tick] Found {lock_file} but git is running. Leaving it alone.")
        except Exception as e:
            print(f"[Tick] Failed to clean stale git lock: {e}")


def _clean_catalog_retry_dirs() -> int:
    """Remove stray Catalog/{job_id}_retry{N}_aristotle/ staging dirs.

    Aristotle's result tarballs name the project output folder
    '{job_id}_retry{N}_aristotle/'. Integration strips that prefix and places
    files under Catalog/{domain}/...; this removes any leftover staging dirs
    each tick so they don't accumulate in the Catalog top level.
    """
    import shutil
    catalog = REPO_ROOT / "Catalog"
    removed = 0
    for d in catalog.glob("*_retry*_aristotle"):
        if d.is_dir():
            try:
                shutil.rmtree(d, ignore_errors=True)
                removed += 1
            except Exception as e:
                print(f"[Cleanup] Warning: failed to remove retry dir {d}: {e}")
    if removed:
        print(f"[Cleanup] Removed {removed} stray retry dir(s) from Catalog")
    return removed


def rebuild_commit_push() -> bool:
    """Rebuild website index, sync to docs/, commit all changes, and push to git.
    Returns True if anything was pushed.
    Sets global _core_files_changed if core Python files changed after pull."""
    global _core_files_changed
    pre_pull_hashes = _snapshot_core_hashes()
    print("[Tick] Rebuilding website index...")
    # Regenerate the knowledge graph (lineage.json) BEFORE update_index.py so
    # the website index loads fresh node/edge counts (otherwise lineage.json
    # goes stale and reports fewer packages than the index).
    try:
        _lin = subprocess.run(
            [sys.executable, str(REPO_ROOT / "Aether" / "lineage_extractor.py")],
            capture_output=True, text=True, timeout=60
        )
        if _lin.returncode != 0:
            print(f"[Tick] lineage_extractor.py failed: {_lin.stderr[:200]}")
        elif _lin.stdout.strip():
            print(f"[Tick] {_lin.stdout.strip()}")
    except Exception as _e:
        print(f"[Tick] lineage_extractor.py error: {_e}")
    try:
        result = subprocess.run(
            [sys.executable, "update_index.py"],
            cwd=str(PACKAGES_DIR),
            capture_output=True, text=True, timeout=60
        )
        if result.returncode != 0:
            print(f"[Tick] update_index.py failed: {result.stderr}")
        else:
            print(f"[Tick] {result.stdout.strip()}")
    except Exception as e:
        print(f"[Tick] update_index.py error: {e}")

    # Sync website to docs/ for GitHub Pages (rsync only changed files)
    docs_dir = REPO_ROOT / "docs"
    print("[Tick] Syncing website to docs/...")
    try:
        docs_dir.mkdir(parents=True, exist_ok=True)
        result = subprocess.run(
            ["rsync", "-a", "--info=NAME", str(PACKAGES_DIR) + "/", str(docs_dir) + "/"],
            capture_output=True, text=True, timeout=60
        )
        if result.returncode != 0:
            print(f"[Tick] rsync warning: {result.stderr[:200]}")
        # Update cache-busting version strings in deployed HTML so browsers
        # don't serve stale JS/CSS after a code change.
        try:
            idx_html = docs_dir / "index.html"
            if idx_html.exists():
                html = idx_html.read_text()
                m = re.search(r'v0\.0\.(\d+)', html)
                if m:
                    vnum = m.group(1)
                    html = re.sub(r'style\.css(\?v=[^"]*)?', f'style.css?v=0.0.{vnum}', html)
                    html = re.sub(r'packages\.js(\?v=[^"]*)?', f'packages.js?v=0.0.{vnum}', html)
                    idx_html.write_text(html)
        except Exception:
            pass
        print("[Tick] docs/ synced")
    except Exception as e:
        print(f"[Tick] docs sync error: {e}")

    # Sync workspace status files for the dashboard
    workspace = Path(__file__).parent / ".aether_workspace"
    status_dir = docs_dir / "aether_status"
    try:
        status_dir.mkdir(parents=True, exist_ok=True)
        for status_file in ["inflight_jobs.json", "insights.json", "tick_counter.json", "cycle_analytics.json"]:
            src = workspace / status_file
            if src.exists():
                import shutil
                shutil.copy2(src, status_dir / status_file)
        # Write reasoning log stats for dashboard (separate file to keep cycle_analytics small)
        try:
            from cycle_analytics import CycleAnalytics
            ca = CycleAnalytics(workspace)
            rlog_stats = ca.get_reasoning_log_stats()
            (status_dir / "reasoning_log_stats.json").write_text(
                _json.dumps(rlog_stats, indent=2, sort_keys=True)
            )
        except Exception:
            pass
        # Write lightweight last_update.json for live dashboard polling
        import json as _json
        (status_dir / "last_update.json").write_text(
            _json.dumps({"timestamp": datetime.now(timezone.utc).isoformat(), "action": "tick_complete"})
        )
    except Exception as e:
        print(f"[Tick] status sync error: {e}")

    # Sync dashboard HTML from source
    dashboard_src = Path(__file__).parent / "dashboard_source" / "status.html"
    if dashboard_src.exists():
        try:
            import shutil
            shutil.copy2(dashboard_src, docs_dir / "status.html")
        except Exception as e:
            print(f"[Tick] dashboard sync error: {e}")

    def _has_conflict_markers():
        """Check if any tracked file has git merge conflict markers."""
        result = subprocess.run(
            ["git", "ls-files", "--unmerged"],
            cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=10
        )
        return bool(result.stdout.strip())

    def _regenerate_index_if_needed():
        """Regenerate package_index.js and rsync to docs if conflict markers found
        in any auto-generated website file."""
        pkg_idx = PACKAGES_DIR / "package_index.js"
        fd_js = PACKAGES_DIR / "future_directions.js"
        fd_json = PACKAGES_DIR / "future_directions.json"
        found_conflict = False
        for path in [pkg_idx, fd_js, fd_json]:
            if path.exists():
                content = path.read_text(errors="ignore")
                if "<<<<<<" in content or ">>>>>>" in content:
                    print(f"[Tick] Conflict markers found in {path.name}, regenerating...")
                    found_conflict = True
        if found_conflict:
            r = subprocess.run(
                [sys.executable, "update_index.py"],
                cwd=str(PACKAGES_DIR),
                capture_output=True, text=True, timeout=60
            )
            if r.returncode == 0:
                # Re-rsync the fixed files to docs
                subprocess.run(
                    ["rsync", "-a", str(PACKAGES_DIR) + "/package_index.js",
                     str(docs_dir) + "/package_index.js"],
                    capture_output=True, timeout=30
                )
                subprocess.run(
                    ["rsync", "-a", str(PACKAGES_DIR) + "/future_directions.js",
                     str(docs_dir) + "/future_directions.js"],
                    capture_output=True, timeout=30
                )
                subprocess.run(
                    ["rsync", "-a", str(PACKAGES_DIR) + "/future_directions.json",
                     str(docs_dir) + "/future_directions.json"],
                    capture_output=True, timeout=30
                )
                print("[Tick] Auto-generated files regenerated after conflict")
            else:
                print(f"[Tick] Regeneration failed: {r.stderr}")

    # Clean any stale git locks from previous runs before starting automated git ops
    _clean_stale_git_locks()

    # Git add only changed files (not -A which scans everything)
    try:
        # Stage specific directories instead of -A. The repository can be large,
        # so give git generous timeouts (especially for docs/ and Catalog/).
        subprocess.run(["git", "add", "docs/"], cwd=str(REPO_ROOT), capture_output=True, timeout=120)
        subprocess.run(["git", "add", "Catalog/"], cwd=str(REPO_ROOT), capture_output=True, timeout=180)
        subprocess.run(["git", "add", "Aether/"], cwd=str(REPO_ROOT), capture_output=True, timeout=60)
        # Top-level output dirs (moved out of Catalog/Applications/).
        for _d, _t in (("Packages/", 180), ("Packages_Archive/", 180),
                       ("Papers/", 120), ("Articles/", 120),
                       ("Demos/", 120), ("Visuals/", 60)):
            subprocess.run(["git", "add", _d], cwd=str(REPO_ROOT), capture_output=True, timeout=_t)

        # Force add core state files to ensure they are tracked and pushed
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
            sf_path = REPO_ROOT / sf
            if sf_path.exists():
                subprocess.run(["git", "add", "-f", sf], cwd=str(REPO_ROOT), capture_output=True, timeout=120)

        diff = subprocess.run(
            ["git", "diff", "--cached", "--quiet"],
            cwd=str(REPO_ROOT), capture_output=True, timeout=120
        )
        has_local_changes = (diff.returncode != 0)

        if has_local_changes:
            timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%MZ")
            commit_res = subprocess.run(
                ["git", "commit", "-m", f"Aether local tick {timestamp}"],
                cwd=str(REPO_ROOT), capture_output=True, timeout=180
            )
            if commit_res.returncode != 0:
                print(f"[Tick] git commit failed: {commit_res.stderr.decode('utf-8', errors='replace')}")
                _short_err = commit_res.stderr.decode('utf-8', errors='replace').replace('\n', ' ')[:200]
                print(f"[ALERT] git_publish_failed step=commit rc={commit_res.returncode} detail={_short_err}")
                _webhook = os.environ.get("AETHER_ALERT_WEBHOOK")
                if _webhook:
                    try:
                        import urllib.request, json as _json, time as _time
                        _req = urllib.request.Request(_webhook, data=_json.dumps({'severity':'high', 'step':'commit', 'rc':commit_res.returncode, 'detail':_short_err, 'ts':_time.time()}).encode('utf-8'), headers={'Content-Type': 'application/json'})
                        urllib.request.urlopen(_req, timeout=5)
                    except Exception:
                        pass

        # Stash remaining dirty unstaged/untracked changes to keep working tree clean for merge
        status_res = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=60
        )
        has_unstaged = bool(status_res.stdout.strip())

        stashed = False
        if has_unstaged:
            try:
                stash_res = subprocess.run(
                    ["git", "stash", "push", "--include-untracked", "-m", "Aether tick temporary stash"],
                    cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
                )
                # Check if we actually saved a stash
                stashed = ("No local changes to save" not in stash_res.stdout and "No local changes to save" not in stash_res.stderr)
            except subprocess.TimeoutExpired:
                print("[Tick] git stash timed out (>120s) — likely too many untracked files. Skipping stash and continuing.")
                stashed = False

        # Fetch remote master
        subprocess.run(["git", "fetch", "origin", "master"], cwd=str(REPO_ROOT), capture_output=True, timeout=120)

        # Merge remote master
        merge = subprocess.run(
            ["git", "merge", "origin/master", "--no-edit"],
            cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
        )

        merge_success = (merge.returncode == 0)

        if not merge_success:
            print("[Tick] Merge conflict detected — running programmatic resolvers")
            if _has_conflict_markers():
                resolve_all_conflicts()
                _regenerate_index_if_needed()
                
                # Check if conflicts were successfully resolved
                if not _has_conflict_markers():
                    subprocess.run(["git", "add", "-A"], cwd=str(REPO_ROOT), capture_output=True, timeout=120)
                    merge_commit = subprocess.run(
                        ["git", "-c", "core.editor=true", "commit", "--no-edit"],
                        cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=180
                    )
                    if merge_commit.returncode == 0:
                        print("[Tick] Pull merge conflicts resolved and committed successfully")
                        merge_success = True
                    else:
                        print(f"[Tick] Failed to commit merge: {merge_commit.stderr}")
                        subprocess.run(["git", "merge", "--abort"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)
                else:
                    print("[Tick] Failed to programmatically resolve all merge conflicts")
                    subprocess.run(["git", "merge", "--abort"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)
            else:
                # Pull failed but no conflict markers (e.g. fast-forward conflict or locking issue)
                subprocess.run(["git", "merge", "--abort"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)
                print(f"[Tick] git merge failed (non-auto-resolvable): {merge.stderr}")

        # Final safety check: regenerate index if any conflict markers leaked through
        _regenerate_index_if_needed()

        pushed = False
        if merge_success:
            push = subprocess.run(
                ["git", "push", "origin", "master"], cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
            )
            if push.returncode == 0:
                print("[Tick] Changes committed and pushed to origin/master")
                pushed = True
            else:
                print(f"[Tick] git push failed: {push.stderr}")
                _short_err = push.stderr.replace('\n', ' ')[:200] if isinstance(push.stderr, str) else push.stderr.decode('utf-8', errors='replace').replace('\n', ' ')[:200]
                print(f"[ALERT] git_publish_failed step=push rc={push.returncode} detail={_short_err}")
                _webhook = os.environ.get("AETHER_ALERT_WEBHOOK")
                if _webhook:
                    try:
                        import urllib.request, json as _json, time as _time
                        _req = urllib.request.Request(_webhook, data=_json.dumps({'severity':'high', 'step':'push', 'rc':push.returncode, 'detail':_short_err, 'ts':_time.time()}).encode('utf-8'), headers={'Content-Type': 'application/json'})
                        urllib.request.urlopen(_req, timeout=5)
                    except Exception:
                        pass
        else:
            print("[Tick] Push skipped because merge was not successful")

        # Pop stash if we stashed
        if stashed:
            pop_res = subprocess.run(
                ["git", "stash", "pop"],
                cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
            )
            if pop_res.returncode != 0:
                print("[Tick] Stash pop conflict — auto-resolving stash programmatically")
                resolve_all_conflicts()
                _regenerate_index_if_needed()
                subprocess.run(["git", "add", "-A"], cwd=str(REPO_ROOT), capture_output=True, timeout=120)
                subprocess.run(
                    ["git", "-c", "core.editor=true", "commit", "--no-edit", "-m", "Auto-resolve stash conflict"],
                    cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=180
                )

        # Watchdog: check if core files changed after git pull
        if _check_core_file_changes(pre_pull_hashes):
            _core_files_changed = True

        return True
    except Exception as e:
        import traceback
        print(f"[Tick] git error: {e}")
        print(traceback.format_exc())
        return False


def start_docs_server(port: int = 8000) -> None:
    """Start a local HTTP server for docs/ in a daemon thread."""
    docs_dir = REPO_ROOT / "docs"
    if not docs_dir.is_dir():
        print(f"[Serve] docs/ directory not found at {docs_dir}, skipping server")
        return

    class QuietHandler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(docs_dir), **kwargs)

        def end_headers(self):
            # Disable caching so dashboard always shows fresh data
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
            super().end_headers()

        def log_message(self, format, *args):
            # Only log page requests, not every asset fetch or 404
            if self.path in ('/', '/index.html'):
                super().log_message(format, *args)

        def log_error(self, format, *args):
            # Suppress 404 errors for Chrome DevTools probes etc.
            pass

    class ReusableTCPServer(socketserver.TCPServer):
        allow_reuse_address = True

    try:
        httpd = ReusableTCPServer(("", port), QuietHandler)
    except OSError as e:
        print(f"[Serve] Could not start server on port {port}: {e}")
        return

    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()
    print(f"[Serve] Aether docs serving at http://localhost:{port}")


class TeeStream:
    """A wrapper for a single stream (stdout or stderr) that tees to a log file,
    preventing duplicate writes if the stream is already redirected to the same file.
    """
    def __init__(self, file_handle, original_stream, log_path: Path):
        self._file = file_handle
        self._original_stream = original_stream
        self._is_duplicate = False
        self._at_line_start = True
        try:
            import os
            if hasattr(original_stream, "fileno") and hasattr(file_handle, "fileno"):
                stat_stream = os.fstat(original_stream.fileno())
                stat_log = os.fstat(file_handle.fileno())
                if stat_stream.st_ino > 0 and stat_stream.st_ino == stat_log.st_ino and stat_stream.st_dev == stat_log.st_dev:
                    self._is_duplicate = True
        except Exception:
            pass

    def write(self, data):
        if not data:
            return
        import re as _re
        from datetime import datetime

        # Clean ansi codes for the file copy (the console gets raw data).
        clean_data = _re.sub(r'\033\[[0-9;]*m', '', data)
        # Prepend a timestamp to each line written to the file. This runs in
        # BOTH the duplicate and non-duplicate cases, so the log file always
        # gets per-line timestamps even when stdout was already redirected to
        # it via shell `>>` (which sets _is_duplicate and previously caused
        # timestamping to be skipped entirely).
        lines = clean_data.split('\n')
        for i, line in enumerate(lines):
            if (i > 0 or self._at_line_start) and (i < len(lines) - 1 or line):
                tstr = datetime.now().strftime("[%Y-%m-%d %H:%M:%S] ")
                lines[i] = tstr + line
        self._at_line_start = clean_data.endswith('\n')
        timestamped = '\n'.join(lines)

        if not self._is_duplicate:
            # Distinct file and console: timestamped to file, raw to console.
            self._file.write(timestamped)
            self._file.flush()
            self._original_stream.write(data)
            self._original_stream.flush()
        else:
            # stdout already points at the log file (shell `>>` redirection);
            # writing to self._file too would duplicate output. Send the
            # timestamped text to the original stream, which IS the file.
            self._original_stream.write(timestamped)
            self._original_stream.flush()

    def flush(self):
        if not self._is_duplicate:
            self._file.flush()
        self._original_stream.flush()


class Tee:
    """Tee stdout and stderr to a log file while keeping console output."""

    def __init__(self, log_path: Path):
        self.log_path = log_path
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        # Ensure log file exists so we can stat it
        self.log_path.touch(exist_ok=True)
        self._file = open(log_path, "a", encoding="utf-8", buffering=1)  # line-buffered
        self._original_stdout = sys.stdout
        self._original_stderr = sys.stderr
        
        sys.stdout = TeeStream(self._file, self._original_stdout, log_path)
        sys.stderr = TeeStream(self._file, self._original_stderr, log_path)

    def write(self, data):
        sys.stdout.write(data)

    def flush(self):
        sys.stdout.flush()

    def close(self):
        self._file.close()
        sys.stdout = self._original_stdout
        sys.stderr = self._original_stderr


def main():
    parser = argparse.ArgumentParser(description="Aether Tick: one-shot CI pipeline step")
    parser.add_argument("--max-inflight", type=int, default=9)
    parser.add_argument("--novelty-slots", type=int, default=3,
                        help="Number of dispatch slots reserved for novelty/wild directions (default: 3)")
    parser.add_argument("--config", type=str, default=None)
    parser.add_argument("--ollama-cloud", action="store_true")
    parser.add_argument("--loop", action="store_true",
                        help="Run continuously, sleeping between ticks")
    parser.add_argument("--interval", type=int, default=21600,
                        help="Seconds between ticks in loop mode (default: 21600 = 6h)")
    parser.add_argument("--serve", action="store_true",
                        help="Start a local HTTP server for the docs site")
    parser.add_argument("--serve-port", type=int, default=8000,
                        help="Port for the docs HTTP server (default: 8000)")
    parser.add_argument("--log", type=str, default=None,
                        help="Tee all output to this log file (in addition to console)")
    args = parser.parse_args()

    # Set up log file tee (defaults to .aether_workspace/aether_daemon.log if not specified)
    log_file_name = args.log or ".aether_workspace/aether_daemon.log"
    log_path = Path(log_file_name)
    if not log_path.is_absolute():
        log_path = (Path(__file__).parent / log_path).resolve()
    log_path.parent.mkdir(parents=True, exist_ok=True)
    tee = Tee(log_path)
    print(f"[Tick] Logging all output to {log_path}")

    # Build config
    if args.ollama_cloud:
        import yaml
        config_path = Path(args.config) if args.config else Path(__file__).parent / "config.yaml"
        config = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}
        config.setdefault("pi_agent", {}).setdefault("ollama_cloud", {})["enabled"] = True
        extractor = KnowledgeExtractor(config=config)
    else:
        extractor = KnowledgeExtractor(config_path=args.config)

    if args.serve:
        start_docs_server(args.serve_port)

    if args.loop:
        # Mtime watchdog: snapshot file mtimes at startup. If any core file's
        # mtime advances, the user has committed code changes directly (bypassing
        # git pull), and we need to restart to load them. The SHA256 watchdog
        # only fires on git pull, which doesn't catch this case (Sonic cycle bug).
        _startup_mtimes = _snapshot_core_mtimes()
        global _core_files_changed
        print(f"[Tick] Loop mode — interval={args.interval}s, max_inflight={args.max_inflight}")
        while True:
            _core_files_changed = False
            print(f"\n{'='*60}")
            print(f"[Tick] Aether tick starting at {datetime.now(timezone.utc).isoformat()}")
            try:
                asyncio.run(tick(extractor, args.max_inflight, args.novelty_slots))
            except Exception as e:
                print(f"[Tick] Tick error: {e}")
                import traceback
                traceback.print_exc()
            rebuild_commit_push()

            # Watchdog 1: if core Python files changed after git pull, restart
            if _core_files_changed:
                print("[Watchdog] Restarting Aether process due to core file changes (post-pull)...")
                os.execv(sys.executable, [sys.executable] + sys.argv)

            # Watchdog 2: mtime drift — catches direct file edits / commits
            # that bypass git pull (e.g. user committing locally with `git commit`)
            if _check_mtime_drift(_startup_mtimes):
                print("[Watchdog] Restarting Aether process due to mtime drift...")
                os.execv(sys.executable, [sys.executable] + sys.argv)

            _wake = datetime.now() + timedelta(seconds=args.interval)
            print(f"[Tick] Sleeping {args.interval}s until next tick at "
                  f"{_wake.strftime('%H:%M')}...")
            time.sleep(args.interval)
    else:
        print(f"[Tick] Aether tick starting — max_inflight={args.max_inflight}, novelty_slots={args.novelty_slots}")
        asyncio.run(tick(extractor, args.max_inflight, args.novelty_slots))
        rebuild_commit_push()


if __name__ == "__main__":
    main()
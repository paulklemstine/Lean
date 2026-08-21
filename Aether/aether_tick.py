#!/usr/bin/env python3
"""Aether Tick: One-shot pipeline step for CI.

Polls for completed Aristotle jobs, integrates them, dispatches new ones,
then exits. Designed for hourly cron — each run takes 2-5 minutes.

Usage:
    python3 aether_tick.py
    python3 aether_tick.py --max-inflight 6
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

def _close_github_issue_if_needed(job):
    """Close the GitHub issue associated with an injected direction when it reaches terminal completion."""
    issue_num = getattr(job, 'github_issue', None)
    if not issue_num:
        return

    st = getattr(job, 'status', '')
    phase = getattr(job, 'phase', '')

    # DO NOT close issues for active or queued jobs!
    if st in ("dispatch_queued", "retry_queued", "queued", "preparing", "dispatched", "B_dispatched"):
        return

    try:
        import github_injector
        # Defense against the re-publish loop (Lean#156): if the issue is
        # already CLOSED, a prior run already posted results and closed it.
        # Do NOT post another comment — that produced 6 duplicate result
        # comments on one closed issue as the direction was re-dispatched.
        try:
            _view = github_injector.run_gh_command(
                ["issue", "view", str(issue_num), "--json", "state"])
            if _view:
                import json as _json
                _info = _json.loads(_view)
                if _info.get("state", "").upper() == "CLOSED":
                    print(f"[Tick] Issue #{issue_num} already closed — skipping duplicate result comment")
                    return
        except Exception as _state_e:
            # If we can't verify state, fall through to post (best-effort),
            # but this is rare; gh is available in CI where this runs.
            print(f"[Tick] Could not verify issue #{issue_num} state: {_state_e}")
        if phase == "complete" or st == "integrated":
            # Search Packages/ for the actual generated JSON package
            from pathlib import Path
            pkgs_dir = Path(__file__).parent.parent / "Packages"
            actual_pkg_filename = ""
            if pkgs_dir.exists():
                job_slug = job.job_id[:8] if hasattr(job, 'job_id') else ""
                for pkg_file in pkgs_dir.glob("*.json"):
                    if pkg_file.name in ("index.json", "lineage.json", "future_directions.json", "future_directions_snapshot.json"):
                        continue
                    if job_slug and job_slug in pkg_file.name:
                        actual_pkg_filename = pkg_file.name
                        break
                    if hasattr(job, "concept") and job.concept and job.concept.title:
                        title_clean = job.concept.title.replace(" ", "_").replace("-", "_").lower()[:30]
                        if title_clean in pkg_file.name.lower():
                            actual_pkg_filename = pkg_file.name
                            break
            
            # Only link packages that were actually found: the old fallback
            # fabricated a title-derived filename that 404'd on both the raw
            # URL and the web app (audit 2026-08-21).
            pkg_links = ""
            if actual_pkg_filename:
                pkg_raw_url = f"https://raw.githubusercontent.com/paulklemstine/Lean/master/Packages/{actual_pkg_filename}"
                pkg_web_url = f"https://alethean.org/#pkg={actual_pkg_filename}"
                pkg_links = (
                    f"\n**Research Package (JSON)**: [{actual_pkg_filename}]({pkg_raw_url})\n"
                    f"**Alethean Web App**: [{pkg_web_url}]({pkg_web_url})\n"
                )

            comment = (
                f"### Aether Research Results\n\n"
                f"**Direction**: {getattr(job.concept, 'title', 'Injected Direction')}\n"
                f"**Quality Score**: {job.quality_score:.3f}\n"
                f"**Theorems Proven**: {job.theorem_count}\n"
                f"{pkg_links}\n"
                f"The formalizations, research article, paper, and interactive visualization demo have all been integrated into the Aether Catalog."
            )
        elif st == "rejected":
            comment = f"Aether completed researching this direction, but the results did not meet the quality threshold for integration.\n\n**Quality Score**: {job.quality_score:.3f}\n**Theorems Proven**: {job.theorem_count}"
        elif st in ("failed", "error"):
            comment = f"Aether encountered an unrecoverable error while processing this direction.\n\n**Status**: {st}\n**Error**: {getattr(job, 'error_message', 'Unknown error')}"
        else:
            return

        # Auto-close ONLY successful completions. A failed/rejected job posts
        # its explanation but the issue STAYS OPEN — closing failures hid them
        # from the owner and enabled the stray-closure cascade
        # (audit 2026-08-21).
        if st in ("failed", "error", "rejected"):
            _posted = github_injector.run_gh_command(
                ["issue", "comment", str(issue_num), "-b", comment])
            if _posted is None:
                print(f"[Tick] WARNING: failure comment on #{issue_num} failed "
                      f"— issue left open, un-commented")
            else:
                print(f"[Tick] Posted failure explanation on #{issue_num}; "
                      f"issue left open for the owner to decide")
        else:
            github_injector.close_injected_direction_with_comment(
                issue_num, comment)
    except Exception as e:
        print(f"[Tick] Failed to close GitHub issue {issue_num}: {e}")

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

PACKAGES_DIR = REPO_ROOT / "Packages"


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





async def tick(extractor: KnowledgeExtractor, max_inflight: int, novelty_slots: int = 0) -> None:
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
        # Push max_inflight onto the extractor so ALL dispatch methods
        # (dispatch_async, dispatch_phase_b_async, dispatch_retry_async)
        # share one authoritative limit instead of relying on per-method defaults.
        extractor.max_inflight = max_inflight
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


async def _safe_get_active_jobs_count(aristotle_client) -> int:
    if not aristotle_client:
        return -1
    try:
        fn = getattr(aristotle_client, "get_active_jobs_count", None)
        if not fn:
            return -1
        res = fn()
        if asyncio.iscoroutine(res) or hasattr(res, "__await__"):
            res = await res
        if isinstance(res, (int, float)):
            return int(res)
        return -1
    except Exception as e:
        print(f"[Aristotle] Failed to query server active jobs count: {e}")
        return -1


def _print_running_jobs(extractor: "KnowledgeExtractor") -> None:
    """List currently-running (active or queued) jobs with their research phase.

    Phase indicates whether the job is producing Phase A math (A) or a Phase B
    research package (B). Shown at the top of each tick so the operator can see
    what's in flight at a glance.
    """
    _RUNNING_STATUSES = ("preparing", "dispatched", "B_dispatched",
                         "retry_queued", "dispatch_queued", "queued")
    running = [j for j in extractor.inflight.values()
               if getattr(j, "status", "") in _RUNNING_STATUSES]
    if not running:
        print("[Tick]   (no running jobs)")
        return
    # Phase B jobs first, then active, then queued, oldest-first
    running.sort(key=lambda j: (
        0 if getattr(j, "phase", "A") in ("B", "B_dispatched") else 1,
        0 if getattr(j, "status", "") in ("preparing", "dispatched") else 1,
        getattr(j, "dispatch_time", 0.0) or getattr(j, "retry_queued_time", 0.0) or 0.0,
    ))
    for j in running:
        phase = getattr(j, "phase", "A")
        badge = "B" if phase in ("B", "B_dispatched") else "A"
        title = ""
        if getattr(j, "concept", None) is not None:
            title = getattr(j.concept, "title", "") or ""
        print(f"[Tick]   [{badge}] {getattr(j, 'job_id', '?')[:8]:>8} "
              f"{getattr(j, 'status', '?'):<15} {title[:64]}")
    # Slot accounting: slot-holders vs queue depth. Directions showing
    # in_progress include queued jobs — this line is the real Aristotle
    # capacity picture (audit 2026-08-21: 14 in_progress directions read as
    # 14 server jobs when only 5 slots were busy).
    slot_holders = [j for j in running
                    if getattr(j, "status", "") in ("preparing", "dispatched", "B_dispatched")]
    queued_n = len(running) - len(slot_holders)
    print(f"[Tick]   Aristotle slots busy: {len(slot_holders)}/6, "
          f"queued awaiting a slot: {queued_n}")


async def _tick_impl(extractor: KnowledgeExtractor, max_inflight: int, novelty_slots: int = 0) -> None:
    """Run one tick inside a single event loop.

    novelty_slots: number of dispatch slots reserved for novelty/wild directions
    """
    # 1. Poll inflight jobs first to update completed/IDLE jobs and refresh local status
    try:
        completed_jobs = await extractor.poll_all()
    except Exception as poll_e:
        print(f"[Tick] Error polling inflight jobs: {poll_e}")
        completed_jobs = []

    # 1b. Purge queued jobs stuck too long to ever dispatch (zombie retries).
    # These inflate the local inflight count and saturate the queue view,
    # blocking fresh dispatches. Each is released so its direction re-enters
    # the pool (where the injected-issue gate then filters closed-issue ones).
    try:
        purged_queued = extractor.purge_stale_queued_jobs(max_age_hours=6)
        if purged_queued:
            print(f"[Tick] Purged {purged_queued} stale queued job(s) that could not dispatch")
    except Exception as e:
        print(f"[Tick] Warning: queued job purge failed: {e}")

    # 2. Ground-truth capacity check: query Aristotle server for active job count
    server_count_at_start = await _safe_get_active_jobs_count(extractor.aristotle)
    local_count_at_start = extractor._count_inflight_dispatched()
    effective_count = server_count_at_start if server_count_at_start >= 0 else local_count_at_start

    queued_count = len([
        j for j in extractor.inflight.values()
        if getattr(j, "status", None) in ("dispatch_queued", "retry_queued", "queued")
    ])

    print(f"[Tick] Job memory: {len(extractor.inflight)} total jobs tracked "
          f"({effective_count} active on Aristotle server, {queued_count} queued locally)")
    print("[Tick] Running jobs:")
    _print_running_jobs(extractor)

    if effective_count > max_inflight:
        print(f"[Guard] WARNING: {effective_count} active jobs detected (local={local_count_at_start}, "
              f"server={server_count_at_start}) exceeds max_inflight={max_inflight}. "
              f"Will integrate completed jobs but skip ALL new dispatching this tick.")
    elif server_count_at_start >= 0 and server_count_at_start != local_count_at_start:
        print(f"[Guard] Local tracking ({local_count_at_start}) synced with server ({server_count_at_start}); "
              f"using server_active={effective_count} for capacity decisions")

    # Recover stale in_progress directions (e.g., from crashed ticks)
    from research_memory import FutureDirectionsManager
    fd_manager = FutureDirectionsManager(extractor.workspace)
    recovered = fd_manager.recover_stale_directions()
    if recovered:
        print(f"[Tick] Recovered {recovered} stale direction(s)")

    # Prune closed-issue injected zombies and drop their queued jobs, so the
    # queue drain below never re-dispatches work whose GitHub issue closed
    # (the re-publish loop). Runs at tick start because the drain loop is
    # earlier than the injected-dispatch gate.
    try:
        import github_injector
        open_issues = github_injector.fetch_injected_directions()
        open_nums = {int(i.get("number", 0)) for i in open_issues if i.get("number")}
        if open_nums:
            pruned_inj = fd_manager.prune_closed_issue_directions(open_nums)
            if pruned_inj:
                print(f"[Tick] Pruned {pruned_inj} closed-issue injected direction(s)")
            pruned_ids = {
                d.id for d in fd_manager._directions
                if d.status == "pruned" and d.source == "github_injection"
            }
            dropped = 0
            for pid, job in list(extractor.inflight.items()):
                if getattr(job, "status", None) not in ("retry_queued", "dispatch_queued", "queued"):
                    continue
                if getattr(job, "direction_id", None) in pruned_ids:
                    try:
                        extractor._release_direction(job)
                    except Exception as rel_e:
                        print(f"[Tick] Warning: could not release zombie job {job.job_id[:8]}: {rel_e}")
                    del extractor.inflight[pid]
                    dropped += 1
            if dropped:
                extractor._save_inflight()
                print(f"[Tick] Dropped {dropped} queued job(s) for closed-issue injected directions")
    except Exception as e:
        print(f"[Tick] Warning: injected-issue zombie cleanup failed: {e}")

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

        # ── Special handling for Direction Tournament jobs ──
        # Tournament jobs only need to download results and parse TOURNAMENT_RESULTS.
        # They skip normal quality evaluation, retry logic, Phase B, and Catalog integration.
        if getattr(job, 'direction_id', '') == '__direction_tournament__':
            print(f"[Tournament] Processing completed tournament job {job.job_id[:8]}...")
            try:
                job = await extractor.extract_async(job)
                if job.error_message:
                    print(f"[Tournament] Extract failed: {job.error_message}")
                else:
                    # Mark integrated so _extract_future_directions passes its
                    # status guard (it early-returns unless status=="integrated").
                    # Tournament jobs skip integrate_async, so set the flag here.
                    job.status = "integrated"
                    extractor._extract_future_directions(job)
                    print(f"[Tournament] Tournament job {job.job_id[:8]} processed successfully")
            except Exception as e:
                print(f"[Tournament] Error processing tournament job: {e}")
            # Remove from inflight regardless
            if job.project_id and job.project_id in extractor.inflight:
                del extractor.inflight[job.project_id]
                extractor._save_inflight()
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

        if job.error_message and not extractor._is_stale_dispatch_error(job.error_message):
            print(f"[Tick] Job failed: {job.error_message}")
            extractor._release_direction(job)
            if job.project_id and job.project_id in extractor.inflight:
                del extractor.inflight[job.project_id]
            if job.job_id and job.job_id in extractor.inflight:
                del extractor.inflight[job.job_id]
            extractor._save_inflight()
            extractor.failed_count += 1
            continue
        elif job.error_message:
            # Transient dispatch condition (e.g. queue full / queued for retry)
            # recorded before the job was requeued — the job has since completed
            # successfully, so this is NOT a failure. Integrate normally: the
            # direction stays consumed and the research thread stays alive.
            print(f"[Tick] Ignoring stale dispatch message on completed job {job.job_id[:8]}: {job.error_message}")

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
                                if directions:
                                    # extractor.memory is the ResearchMemory jsonl
                                    # store, not the direction pool — the old
                                    # hasattr check was always False, so decomposed
                                    # sub-lemmas were generated by an LLM call and
                                    # then silently discarded (audit 2026-08-21).
                                    from research_memory import FutureDirectionsManager, FutureDirection
                                    mgr = FutureDirectionsManager(extractor.workspace)
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
                                        mgr.add_direction(new_dir)
                                        print(f"[Tick]   -> Added decomposed direction: {new_dir.title}")
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
            is_injected = bool(getattr(job, 'github_issue', 0))
            if (phase_a_q >= phase_b_threshold or is_injected) and (job.result_lean or is_injected):
                # Phase B will be dispatched right now (within this same tick loop)
                # Then we wait for Phase B's results in a future tick
                reason_str = f"injected issue #{job.github_issue}" if is_injected else f"Phase A Q={phase_a_q:.3f} >= {phase_b_threshold:.3f}"
                print(f"[Tick] {reason_str} — dispatching Phase B for {job.job_id[:8]}")
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
                job = await extractor.dispatch_phase_b_async(job, max_inflight=max_inflight)
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

        # Close GitHub issue if this job was an injected direction
        _close_github_issue_if_needed(job)

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
                
                # Junk parent titles must not be amplified into 0.85+ children
                # (audit 2026-08-21).
                from fd_splitter import clean_title as _clean_title
                if not _clean_title(title_clean):
                    raise ValueError(
                        f"parent title is a junk fragment: {title_clean[:60]!r}")
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
                
                from fd_splitter import clean_title as _clean_title
                if not _clean_title(title_clean):
                    raise ValueError(
                        f"parent title is a junk fragment: {title_clean[:60]!r}")
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

        if is_phase_b_completion and job.status == "integrated":
            print(f"[Tick] Phase B integration complete for {job.job_id[:8]}. Changes queued for end-of-tick commit.")
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
            
            # Close GitHub issue if this job was an injected direction
            _close_github_issue_if_needed(job)

            if job.project_dir and Path(job.project_dir).exists():
                try:
                    import shutil
                    print(f"[Cleanup] Pruning stale project workspace: {job.project_dir}")
                    shutil.rmtree(str(job.project_dir), ignore_errors=True)
                except Exception as e:
                    print(f"[Cleanup] Warning: failed to clean up stale project directory: {e}")
            del extractor.inflight[pid]
        print(f"[Tick] Pruned {len(stale_keys)} completed jobs from inflight")



    # Defensive: remove any stray Catalog/{job_id}_retry{N}_aristotle/ staging
    # dirs left over from retry integration.
    _clean_catalog_retry_dirs()


    # ── Self-healing & Quality Control: Automatic Aristotle Direction Tournament ──
    try:
        from research_memory import FutureDirectionsManager
        from direction_tournament import DirectionTournament
        fd_heal = FutureDirectionsManager(extractor.workspace)
        stats = fd_heal.get_stats()
        if stats.get("retried_directions", 0) > 0:
            print(f"[Retry] {stats['retried_directions']} retried directions, "
                  f"rate={stats.get('retry_rate',0):.1%}, avg_attempts={stats.get('avg_attempts',0):.2f}")
        
        # Trigger Option B Direction Tournament when available directions > 1000
        avail_dirs = stats.get("available", 0)
        if avail_dirs > 1000:
            # Skip if a tournament job is already inflight
            tournament_already_inflight = any(
                getattr(j, 'direction_id', '') == '__direction_tournament__'
                for j in extractor.inflight.values()
            )
            if tournament_already_inflight:
                print(f"[Tournament] Available directions={avail_dirs} > 1000 but tournament job already inflight — skipping.")
            else:
                local_inflight = extractor._count_inflight_dispatched()
                server_running = await _safe_get_active_jobs_count(extractor.aristotle)
                current_inflight = max(local_inflight, server_running) if server_running >= 0 else local_inflight
                if current_inflight >= max_inflight:
                    print(f"[Tournament] Skipping tournament: at max_inflight ({current_inflight}/{max_inflight})")
                else:
                    dt = DirectionTournament(workspace=extractor.workspace)
                    batch = dt.get_candidate_batch(batch_size=10)
                    dispatched_ids = [d.id for d in batch] if batch else []
                    if batch and len(batch) >= 5:
                        print(f"[Tournament] Available directions={avail_dirs} > 1000. Running Direction Tournament for {len(batch)} candidates...")
                        prompt = dt.build_tournament_prompt(batch, target_winners=2)
                        if hasattr(extractor, 'aristotle') and extractor.aristotle and hasattr(extractor.aristotle, 'submit_lean_project_only'):
                            import tempfile
                            with tempfile.TemporaryDirectory() as tmp_dir:
                                tmp_path = Path(tmp_dir)
                                (tmp_path / "lakefile.lean").write_text("import Lake\nopen Lake DSL\npackage tournament\n@default_target lean_lib Tournament where srcDir := \".\"")
                                (tmp_path / "Tournament.lean").write_text("import Mathlib\n-- Direction Tournament Evaluation")
                                (tmp_path / "TOURNAMENT_PROMPT.md").write_text(prompt)
                                try:
                                    proj_id = await extractor.aristotle.submit_lean_project_only(
                                        prompt=prompt,
                                        project_dir=tmp_path
                                    )
                                    print(f"[Tournament] Successfully queued Aristotle evaluation project: {proj_id}")
                                    # Track tournament job in inflight so results get polled & processed
                                    from knowledge_extractor import ResearchJob, ResearchConcept
                                    tournament_job = ResearchJob(
                                        job_id=f"tournament_{proj_id[:8]}",
                                        cycle_n=0,
                                        concept=ResearchConcept(
                                            title="Direction Tournament Evaluation",
                                            domain="meta",
                                            concept_description="Aristotle evaluates candidate directions for quality pruning",
                                            mathematical_framing="Direction tournament: select top directions by mathematical merit"
                                        ),
                                        prompt=prompt,
                                        project_id=proj_id,
                                        status="dispatched",
                                        dispatch_time=time.time(),
                                        direction_id="__direction_tournament__",
                                        tournament_dispatched_ids=dispatched_ids,
                                    )
                                    extractor.inflight[proj_id] = tournament_job
                                    extractor._save_inflight()
                                    print(f"[Tournament] Tournament job {proj_id[:8]} added to inflight for polling")
                                except Exception as sub_err:
                                    print(f"[Tournament] Aristotle submission note: {sub_err}")
    except Exception as e:
        print(f"[Tournament] Automatic direction tournament check: {e}")

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

    # ── Duration analytics: flag unusually slow or fast cycles ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        recent_recs = ca.records[-20:] if hasattr(ca, "records") else []
        with_dur = [r for r in recent_recs if getattr(r, "duration_seconds", 0) > 0]
        if with_dur:
            avg_dur = sum(r.duration_seconds for r in with_dur) / len(with_dur)
            slow = [r for r in with_dur if r.duration_seconds > 2 * avg_dur and avg_dur > 0]
            for s in slow:
                mins = s.duration_seconds / 60
                avg_mins = avg_dur / 60
                print(f"[⏱️ Slow] {s.domain or '?'}: {mins:.1f}m (avg {avg_mins:.1f}m) — {(s.title or '?')[:40]}")
    except Exception as e:
        print(f"[Duration] Cycle duration analytics failed: {e}")

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

    # 3. Retry or dispatch any queued jobs first, before discovering new directions.
    queued_jobs = [j for j in extractor.inflight.values() if j.status in ("retry_queued", "dispatch_queued")]
    if queued_jobs:
        # Prioritize Phase B packaging jobs (phase == "B") over Phase A discovery
        queued_jobs.sort(key=lambda j: (0 if getattr(j, "phase", "") == "B" else 1, getattr(j, "retry_queued_time", 0.0)))
        server_running = await _safe_get_active_jobs_count(extractor.aristotle)
    else:
        server_running = -1

    for queued in queued_jobs:
        local_inflight = extractor._count_inflight_dispatched()
        current_inflight = max(local_inflight, server_running) if server_running >= 0 else local_inflight
        if current_inflight >= max_inflight:
            print(f"[Tick] No capacity to drain queued jobs ({current_inflight}/{max_inflight} inflight, {server_running} on server)")
            break
        try:
            queued.status = "preparing"
            queued.preparing_started = time.time()
            project_id = await extractor._dispatch_to_aristotle(queued)
            # Re-key to project_id, set dispatched status/timing, and clear any
            # stale error_message (e.g. "Queue full" / "queued for retry") from
            # the attempt that queued the job — otherwise it would later discard
            # a successful integration as a "failure".
            extractor._mark_requeued_dispatch_success(queued, project_id)
            print(f"[Tick] Dispatched queued job {project_id[:8]}: {queued.concept.title[:60]}")
        except Exception as e:
            if extractor._is_queue_full_error(e):
                print(f"[Tick] Aristotle queue still full; leaving job {queued.job_id[:8]} queued")
                queued.status = "retry_queued" if getattr(queued, "phase", "") == "B" or getattr(queued, "retry_count", 0) > 0 else "dispatch_queued"
                queued.project_id = None
            else:
                print(f"[Tick] Queued job dispatch failed for {queued.job_id[:8]}: {e}")
                queued.status = "failed"
                queued.error_message = f"Queued job dispatch failed: {e}"
                extractor._release_direction(queued)
        
        # We just dispatched a job, so the server running count goes up
        if server_running >= 0:
            server_running += 1
        extractor._save_inflight()

    # 3b. Refresh external signal feed (arXiv/OEIS/LMFDB → FutureDirections)
    try:
        added_signals = extractor.refresh_external_signals(count_per_source=2)
        if added_signals:
            print(f"[Tick] External signal feed added {added_signals} direction(s)")
    except Exception as e:
        print(f"[Tick] External signal refresh failed: {e}")

    # 4. Dispatch new jobs up to max_inflight (with novelty track)
    local_inflight = extractor._count_inflight_dispatched()
    server_running = await _safe_get_active_jobs_count(extractor.aristotle)
    current_inflight = max(local_inflight, server_running) if server_running >= 0 else local_inflight
    print(f"[Tick] Inflight check: {local_inflight} local tracking, {server_running} actual on server -> using {current_inflight}")
    slots_available = max(0, max_inflight - current_inflight)

    # ── HARD GUARD: refuse to dispatch if already at or over max_inflight ──
    # This catches stale-file scenarios where the local count under-reports.
    if server_running >= 0 and server_running >= max_inflight:
        print(f"[Guard] Server reports {server_running} active jobs — at/over max_inflight={max_inflight}. "
              f"Skipping ALL dispatching this tick.")
        slots_available = 0

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
            # Close GitHub issues for consumed directions that were never closed
            # (prevents duplicate re-injection on future ticks)
            github_injector.close_orphaned_issues(extractor.workspace)
        except Exception as e:
            print(f"[Tick] Failed to inject GitHub issues: {e}")

        # Dispatch injected issues (respecting max_inflight)
        try:
            import github_injector
            # Only directions whose GitHub issue is still OPEN may be dispatched;
            # a closed issue means the work was already handled, so re-dispatching
            # it every tick was the re-publish loop.
            open_issues = github_injector.fetch_injected_directions()
            open_issue_numbers = {int(i.get("number", 0)) for i in open_issues if i.get("number")}
            if not open_issue_numbers:
                # gh unavailable or no open approved-direction issues: do not
                # dispatch AND do not prune (we cannot verify issue state).
                print("[Tick] No open approved-direction issues (or gh unavailable); skipping injected dispatch")
            else:
                from research_memory import FutureDirectionsManager
                local_fd = FutureDirectionsManager(extractor.workspace)
                # Stray-close guard: an injected direction whose job is STILL
                # live but whose issue was closed (manual stray, UI accident,
                # comment-then-close with a failed comment) gets its issue
                # REOPENED, not pruned — a comment-less close must not kill
                # active research (audit 2026-08-21: #162/#167/#169/#170).
                _active_job_ids = {
                    getattr(_j, "job_id", "") for _j in extractor.inflight.values()
                    if getattr(_j, "status", "") in ("preparing", "dispatched", "B_dispatched", "retry_queued", "dispatch_queued")
                }
                _stray = local_fd.stray_closed_injected_directions(
                    open_issue_numbers, _active_job_ids)
                for _d in _stray:
                    print(f"[Tick] Stray-close guard: issue #{_d.github_issue} "
                          f"closed but job for {_d.id} is live — reopening")
                    try:
                        github_injector.run_gh_command([
                            "issue", "reopen", str(_d.github_issue)])
                        github_injector.run_gh_command([
                            "issue", "comment", str(_d.github_issue), "-b",
                            "Reopened automatically: this issue was closed while "
                            "its research job was still active. The job continues."])
                        open_issue_numbers.add(int(_d.github_issue))
                    except Exception as _re_e:
                        print(f"[Tick] Stray-close reopen failed for #{_d.github_issue}: {_re_e}")
                # Self-heal: prune non-terminal github_injection zombies whose
                # issue closed (kept being re-dispatched by stale clobbers).
                pruned_issue_dirs = local_fd.prune_closed_issue_directions(open_issue_numbers)
                if pruned_issue_dirs:
                    print(f"[Tick] Pruned {pruned_issue_dirs} closed-issue injected direction(s)")
                injected = local_fd.dispatchable_injected_directions(
                    open_issue_numbers, max_attempts=3)
                # Cross-check against active inflight jobs: the dispatch gate only
                # sees pool status, and the age-based stale recovery can flip an
                # in_progress direction back to available while its job still runs
                # (last_attempt_time is stamped at discover only). Dispatching it
                # again means duplicate Aristotle spend + package overwrite.
                _active_dir_ids = {getattr(_j, "direction_id", "") for _j in extractor.inflight.values()}
                _active_issues = {getattr(_j, "github_issue", 0) for _j in extractor.inflight.values()}
                _skipped_active = [d for d in injected
                                   if d.id in _active_dir_ids or d.github_issue in _active_issues]
                if _skipped_active:
                    for d in _skipped_active:
                        print(f"[Tick] Injected issue #{d.github_issue} already has an active job; skipping re-dispatch")
                    injected = [d for d in injected
                                if d.id not in _active_dir_ids and d.github_issue not in _active_issues]
                # Attempt-cap terminal state: an injected direction that exhausted
                # its dispatch attempts (e.g. during an Aristotle outage) while its
                # issue is still open would strand forever — undispatchable, but
                # never terminal, so no path ever closes the issue. Prune it here so
                # close_orphaned_issues closes the issue with the honest reason.
                _capped = [d for d in local_fd._directions
                           if getattr(d, "source", "") == "github_injection"
                           and d.status == "available"
                           and d.attempt_count >= 3
                           and d.github_issue in open_issue_numbers]
                if _capped:
                    for d in _capped:
                        d.status = "pruned"
                        d.prune_reason = (f"dispatch failed {d.attempt_count} times; "
                                          f"attempt cap exhausted")
                    local_fd._save()
                    print(f"[Tick] Retired {len(_capped)} injected direction(s) at the "
                          f"attempt cap; closing their issues")
                    try:
                        github_injector.close_orphaned_issues(extractor.workspace)
                    except Exception as _cap_e:
                        print(f"[Tick] Attempt-cap issue close failed: {_cap_e}")
                for fd in injected:
                    local_inflight = extractor._count_inflight_dispatched()
                    server_running = await _safe_get_active_jobs_count(extractor.aristotle)
                    current_inflight = max(local_inflight, server_running) if server_running >= 0 else local_inflight
                    if current_inflight >= max_inflight:
                        print(f"[Tick] Reached max_inflight ({max_inflight}); leaving injected issue queued: {fd.title}")
                        break
                    print(f"[Tick] Dispatching injected issue: {fd.title}")
                    try:
                        job = extractor.discover(forced_direction=fd)
                        job = await extractor.dispatch_async(job, max_inflight=max_inflight)
                        if job.project_id:
                            extractor.inflight[job.project_id] = job
                            print(f"[Tick] Dispatched injected issue {job.project_id[:8]}: {job.concept.title[:60]}")
                            _signal_dashboard_update(job.project_id[:8], "dispatched")
                        elif getattr(job, "status", None) in ("dispatch_queued", "retry_queued"):
                            print(f"[Tick] Queued injected issue {job.job_id[:8]}: {job.concept.title[:60]} (at max_inflight)")
                            extractor._save_inflight()
                            break
                        else:
                            extractor._release_direction(job)
                            print(f"[Tick] Dispatch failed for injected issue {job.concept.title[:60]}, direction released")
                            # The dispatch_async failure reason is on the job;
                            # refund the attempt when it was infra, not research.
                            _err = str(getattr(job, "error_message", "") or "")
                            if extractor._is_auth_error(_err):
                                extractor._refund_attempt(job)
                    except Exception as inner_e:
                        print(f"[Tick] Inner error dispatching injected issue: {inner_e}")
                        import traceback
                        traceback.print_exc()
                        break
        except Exception as e:
            print(f"[Tick] Failed to dispatch injected issues: {e}")

        # Recalculate slots available in case injected issues consumed them
        local_inflight = extractor._count_inflight_dispatched()
        server_running = await extractor.aristotle.get_active_jobs_count()
        current_inflight = max(local_inflight, server_running) if server_running >= 0 else local_inflight
        slots_available = max(0, max_inflight - current_inflight)

        if novelty_slots > 0:
            standard_slots = max(0, slots_available - novelty_slots)
            wild_slots = min(novelty_slots, slots_available)
            print(f"[Tick] {slots_available} dispatch slots available ({standard_slots} standard, {wild_slots} novelty)")
        else:
            standard_slots = slots_available
            wild_slots = 0
            print(f"[Tick] {slots_available} dispatch slots available")

        queue_full = False

        # Dispatch standard/unrestricted directions
        for _ in range(standard_slots):
            if queue_full:
                break
            job = None
            try:
                # When novelty_slots is 0, do not exclude Novelty from candidate directions
                excluded = saturated_domains if novelty_slots == 0 else (["Novelty"] + saturated_domains)
                job = extractor.discover(domain_filter=None, exclude_domains=excluded)
                job = await extractor.dispatch_async(job, max_inflight=max_inflight)
                if job.project_id:
                    extractor.inflight[job.project_id] = job
                    print(f"[Tick] Dispatched {job.project_id[:8]}: {job.concept.title[:60]}")
                    _signal_dashboard_update(job.project_id[:8], "dispatched")
                elif getattr(job, "status", None) in ("dispatch_queued", "retry_queued"):
                    print(f"[Tick] Aristotle queue full; leaving job {job.job_id[:8]} queued and stopping dispatch")
                    queue_full = True
                    extractor._save_inflight()
                else:
                    extractor._release_direction(job)
                    print(f"[Tick] Dispatch failed for {job.concept.title[:60]}, direction released")
                    _err = str(getattr(job, "error_message", "") or "")
                    if extractor._is_auth_error(_err):
                        extractor._refund_attempt(job)
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
                    if extractor._is_auth_error(e):
                        extractor._refund_attempt(job)
                else:
                    print(f"[Tick] Dispatch error before discovery: {e}")

        # Dispatch novelty/wild directions if explicitly requested via novelty_slots
        for _ in range(wild_slots):
            if queue_full:
                break
            job = None
            try:
                job = extractor.discover(domain_filter="Novelty")
                job = await extractor.dispatch_async(job, max_inflight=max_inflight)
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
                    _err = str(getattr(job, "error_message", "") or "")
                    if extractor._is_auth_error(_err):
                        extractor._refund_attempt(job)
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
                    if extractor._is_auth_error(e):
                        extractor._refund_attempt(job)
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
            if hasattr(_j, "status") and _j.status in ("preparing", "dispatched", "retry_queued", "dispatch_queued", "B_dispatched"):
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

    # End-of-tick summary (the detailed stats report was removed 2026-08-12 —
    # not used anymore; running jobs + phase are shown at tick start instead).
    remaining = extractor._count_inflight_dispatched()
    print(f"[Done]    {len(completed_jobs)} integrated, {remaining} still inflight")


def _merge_direction_objects(d_ours: dict, d_theirs: dict) -> dict:
    # Lifecycle precedence for pull races: terminal states must beat
    # non-terminal ones no matter which side carries them, or a stale local
    # "available" resurrects a direction the other writer already completed or
    # pruned — and it gets re-dispatched (audit 2026-08-21).
    _STATUS_RANK = {"available": 0, "in_progress": 1, "pruned": 2, "completed": 3}
    merged = dict(d_ours)
    for k, v in d_theirs.items():
        if k not in merged or merged[k] is None or merged[k] == "" or merged[k] == 0:
            merged[k] = v
        elif k == "status":
            if _STATUS_RANK.get(str(v), 0) > _STATUS_RANK.get(str(merged.get(k)), 0):
                merged[k] = v
        elif k == "attempt_count":
            merged[k] = max(int(d_ours.get(k, 0) or 0), int(d_theirs.get(k, 0) or 0))
        elif k == "outcome_quality":
            merged[k] = max(float(d_ours.get(k, 0.0) or 0.0), float(d_theirs.get(k, 0.0) or 0.0))
        elif k == "consumed_by_exp_id":
            merged[k] = d_ours.get(k) or d_theirs.get(k) or ""
        elif k in ("last_attempt_time", "last_reviewed_at"):
            t_ours = str(d_ours.get(k) or "")
            t_theirs = str(d_theirs.get(k) or "")
            merged[k] = max(t_ours, t_theirs)
        elif k in ("cleanup_review_count", "decomposition_depth"):
            merged[k] = max(int(d_ours.get(k, 0) or 0), int(d_theirs.get(k, 0) or 0))
        elif isinstance(v, list) and isinstance(merged.get(k), list):
            combined = merged[k] + [x for x in v if x not in merged[k]]
            merged[k] = combined
    return merged


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

        try:
            ours_json = json.loads("\n".join(ours_lines))
        except Exception:
            ours_json = {}
        try:
            theirs_json = json.loads("\n".join(theirs_lines))
        except Exception:
            theirs_json = {}

        if not ours_json and not theirs_json:
            subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
            print(f"[GitResolve] Fallback checkout --ours for {file_path.name}")
            return True

        merged_directions = {}
        for item in ours_json.get("directions", []):
            if isinstance(item, dict):
                key = item.get("id") or item.get("timestamp") or str(item)
                merged_directions[key] = item
        for item in theirs_json.get("directions", []):
            if isinstance(item, dict):
                key = item.get("id") or item.get("timestamp") or str(item)
                if key in merged_directions:
                    merged_directions[key] = _merge_direction_objects(merged_directions[key], item)
                else:
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
        if isinstance(ours_json.get("cycle_syntheses"), dict):
            merged_syntheses.update(ours_json["cycle_syntheses"])
        if isinstance(theirs_json.get("cycle_syntheses"), dict):
            merged_syntheses.update(theirs_json["cycle_syntheses"])

        # Merge the remaining pool sections — dropping them (as this resolver
        # once did) silently discarded the pruned list and the domain-balancing
        # statistics on every pull-race resolution (audit 2026-08-21).
        merged_pruned = {}
        for item in ours_json.get("pruned", []) or []:
            if isinstance(item, dict):
                merged_pruned[item.get("id") or str(item)] = item
        for item in theirs_json.get("pruned", []) or []:
            if isinstance(item, dict):
                key = item.get("id") or str(item)
                merged_pruned[key] = (_merge_direction_objects(merged_pruned[key], item)
                                      if key in merged_pruned else item)

        def _merge_counts(a, b):
            out = dict(a) if isinstance(a, dict) else {}
            if isinstance(b, dict):
                for ck, cv in b.items():
                    try:
                        out[ck] = max(float(out.get(ck, 0) or 0), float(cv or 0))
                    except (TypeError, ValueError):
                        out[ck] = cv
            return out

        merged_domain_counts = _merge_counts(ours_json.get("recent_domain_counts"),
                                             theirs_json.get("recent_domain_counts"))
        merged_theme_keywords = _merge_counts(ours_json.get("recent_theme_keywords"),
                                              theirs_json.get("recent_theme_keywords"))

        merged_selection_log = []
        for log_item in (ours_json.get("selection_log") or []) + (theirs_json.get("selection_log") or []):
            if log_item not in merged_selection_log:
                merged_selection_log.append(log_item)
        merged_selection_log = merged_selection_log[-200:]

        final_json = {
            "cycle_syntheses": merged_syntheses,
            "directions": sorted_directions,
            "pruned": list(merged_pruned.values()),
            "recent_domain_counts": merged_domain_counts,
            "recent_theme_keywords": merged_theme_keywords,
            "selection_log": merged_selection_log,
        }

        file_path.write_text(json.dumps(final_json, indent=2) + "\n", encoding="utf-8")
        print(f"[GitResolve] Resolved JSON conflict for {file_path.name}")
        return True
    except Exception as e:
        print(f"[GitResolve] Failed to resolve JSON conflict for {file_path}: {e}")
        subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
        return True


def _merge_jsonl_record(rec_ours: dict, rec_theirs: dict) -> dict:
    merged = dict(rec_ours)
    for k, v in rec_theirs.items():
        if k not in merged or merged[k] is None or merged[k] == "":
            merged[k] = v
        elif k in ("quality_score", "priority_score"):
            merged[k] = max(float(rec_ours.get(k, 0.0) or 0.0), float(rec_theirs.get(k, 0.0) or 0.0))
        elif k in ("proof_text", "lean_code", "code"):
            str_o = str(rec_ours.get(k, ""))
            str_t = str(v)
            if len(str_t) > len(str_o):
                merged[k] = str_t
        elif k == "status":
            if str(v).lower() in ("success", "integrated", "verified", "complete"):
                merged[k] = v
    return merged


def resolve_jsonl_conflict(file_path: Path) -> bool:
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
            if not isinstance(item, dict):
                continue
            key = item.get("experiment_id") or item.get("exp_id") or item.get("timestamp") or str(item)
            if key in merged:
                merged[key] = _merge_jsonl_record(merged[key], item)
            else:
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
        subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
        return True


def resolve_generic_json_conflict(file_path: Path) -> bool:
    import json
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

        try:
            ours_obj = json.loads("\n".join(ours_lines))
            theirs_obj = json.loads("\n".join(theirs_lines))
        except Exception:
            subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
            return True

        if isinstance(ours_obj, dict) and isinstance(theirs_obj, dict):
            merged = dict(ours_obj)
            merged.update(theirs_obj)
        elif isinstance(ours_obj, list) and isinstance(theirs_obj, list):
            merged = ours_obj + [x for x in theirs_obj if x not in ours_obj]
        else:
            merged = ours_obj

        file_path.write_text(json.dumps(merged, indent=2) + "\n", encoding="utf-8")
        print(f"[GitResolve] Resolved generic JSON conflict for {file_path.name}")
        return True
    except Exception as e:
        print(f"[GitResolve] Failed generic JSON conflict for {file_path}: {e}")
        subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
        return True


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
        if "<<<<<<<" in new_content:
            subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
            print(f"[GitResolve] Fallback checkout --ours for Lean file {file_path.name}")
            return True

        file_path.write_text(new_content, encoding="utf-8")
        print(f"[GitResolve] Resolved Lean conflict for {file_path.name} (sorry-minimization)")
        return True
    except Exception as e:
        print(f"[GitResolve] Failed to resolve Lean conflict for {file_path}: {e}")
        subprocess.run(["git", "checkout", "--ours", str(file_path)], capture_output=True)
        return True


def resolve_all_conflicts() -> bool:
    """Identify and programmatically resolve all conflicts in the workspace."""
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=30
    )
    if result.returncode != 0:
        return False

    resolved_any = False
    for line in result.stdout.splitlines():
        if line.startswith("UU ") or line.startswith("AA ") or line.startswith("UD ") or line.startswith("DU ") or line.startswith("AU ") or line.startswith("UA "):
            state = line[:2]
            path_str = line[3:].strip().strip('"')
            file_path = REPO_ROOT / path_str
            if not file_path.exists():
                if state in ("DU", "UA"):
                    # Deleted by us, modified/added by them: their side is the
                    # data-preserving one. Leaving these unresolved aborts every
                    # merge, so pushes stall tick after tick with no alert
                    # (audit 2026-08-21).
                    r = subprocess.run(
                        ["git", "checkout", "--theirs", path_str],
                        cwd=str(REPO_ROOT), capture_output=True, timeout=10
                    )
                    if r.returncode == 0:
                        subprocess.run(
                            ["git", "add", path_str],
                            cwd=str(REPO_ROOT), capture_output=True, timeout=10
                        )
                        resolved_any = True
                        print(f"[GitResolve] Restored theirs for delete/modify conflict: {path_str}")
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
            elif file_path.suffix == ".json":
                success = resolve_generic_json_conflict(file_path)
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

def _clean_stale_git_locks() -> bool:
    """Remove .git/index.lock if no git process is running.
    Returns True if safe to proceed (no lock or lock cleared), False if locked by active git."""
    lock_file = REPO_ROOT / ".git" / "index.lock"
    if not lock_file.exists():
        return True
    try:
        git_running = None  # None = could not determine (pgrep unavailable)
        try:
            r = subprocess.run(["pgrep", "-x", "git"], capture_output=True, timeout=10)
            git_running = (r.returncode == 0)
        except Exception:
            pass
        if git_running is False:
            print(f"[Tick] Found stale {lock_file} with no active git process. Removing...")
            lock_file.unlink(missing_ok=True)
            return True
        else:
            # pgrep missing/failed or git alive: NEVER delete a lock we could
            # not verify is stale — that corrupts a concurrent git operation
            # (audit 2026-08-21).
            print(f"[Tick] Found {lock_file} but git state is "
                  f"{'active' if git_running else 'unknown'}. Leaving it alone.")
            return git_running is not True
    except Exception as e:
        print(f"[Tick] Failed to clean stale git lock: {e}")
        return False


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
            capture_output=True, text=True, timeout=300
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
            capture_output=True, text=True, timeout=600
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
            ["rsync", "-a", "--delete", "--info=NAME", str(PACKAGES_DIR) + "/", str(docs_dir) + "/"],
            capture_output=True, text=True, timeout=300
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
        for status_file in ["inflight_jobs.json", "insights.json", "cycle_analytics.json"]:
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
        if result.stdout.strip():
            return True
        grep_res = subprocess.run(
            ["git", "grep", "-l", "^<<<<<<< "],
            cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=15
        )
        return bool(grep_res.stdout.strip())

    def _regenerate_index_if_needed(force=False):
        """Regenerate package_index.js and rsync to docs if conflict markers found
        in any auto-generated website file or force=True."""
        pkg_idx = PACKAGES_DIR / "package_index.js"
        fd_js = PACKAGES_DIR / "future_directions.js"
        fd_json = PACKAGES_DIR / "future_directions.json"
        found_conflict = force
        if not found_conflict:
            for path in [pkg_idx, fd_js, fd_json]:
                if path.exists():
                    content = path.read_text(errors="ignore")
                    if "<<<<<<<" in content or ">>>>>>>" in content:
                        print(f"[Tick] Conflict markers found in {path.name}, regenerating...")
                        found_conflict = True
                        break
        if found_conflict:
            r = subprocess.run(
                [sys.executable, "update_index.py"],
                cwd=str(PACKAGES_DIR),
                capture_output=True, text=True, timeout=600
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
    if not _clean_stale_git_locks():
        print("[Tick] Aborting commit/push phase: another git process is active and holds index.lock")
        return False

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

        # Force add core state files to ensure they are tracked and pushed.
        # future_directions.json lives in Packages/ (single source of truth).
        state_files = [
            "Packages/future_directions.json",
            "Aether/.aether_workspace/cycle_analytics.json",
            "Aether/.aether_workspace/research_journal.json",
            "Aether/.aether_workspace/research_threads.json",
            "Aether/.aether_workspace/inflight_jobs.json",
            "Aether/.aether_workspace/insights.json",
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

        # Stage all new and modified files generated during the tick
        subprocess.run(["git", "add", "-A"], cwd=str(REPO_ROOT), capture_output=True, timeout=120)

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
                _regenerate_index_if_needed(force=True)
                
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
            for _push_attempt in range(1, 4):
                push = subprocess.run(
                    ["git", "push", "origin", "master"], cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
                )
                if push.returncode == 0:
                    print("[Tick] Changes committed and pushed to origin/master")
                    pushed = True
                    break
                _push_err = push.stderr if isinstance(push.stderr, str) else push.stderr.decode('utf-8', errors='replace')
                # Non-fast-forward: the other writer (local loop / Action) pushed
                # first. Pull with the programmatic resolvers and retry instead of
                # stalling every future tick behind a diverged master
                # (audit 2026-08-21).
                if _push_attempt < 3 and ("rejected" in _push_err or "fast-forward" in _push_err):
                    print(f"[Tick] Push rejected (non-fast-forward) — pulling and retrying "
                          f"({_push_attempt}/3)")
                    subprocess.run(
                        ["git", "pull", "--no-rebase", "origin", "master"],
                        cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
                    )
                    resolve_all_conflicts()
                    subprocess.run(["git", "add", "-A"], cwd=str(REPO_ROOT), capture_output=True, timeout=120)
                    # Commit the merge; "nothing to commit" is fine — retry the push either way.
                    subprocess.run(
                        ["git", "-c", "core.editor=true", "commit", "--no-edit"],
                        cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=180
                    )
                    continue
                _short_err = _push_err.replace('\n', ' ')[:200]
                print(f"[Tick] git push failed: {_push_err}")
                print(f"[ALERT] git_publish_failed step=push rc={push.returncode} detail={_short_err}")
                _webhook = os.environ.get("AETHER_ALERT_WEBHOOK")
                if _webhook:
                    try:
                        import urllib.request, json as _json, time as _time
                        _req = urllib.request.Request(_webhook, data=_json.dumps({'severity':'high', 'step':'push', 'rc':push.returncode, 'detail':_short_err, 'ts':_time.time()}).encode('utf-8'), headers={'Content-Type': 'application/json'})
                        urllib.request.urlopen(_req, timeout=5)
                    except Exception:
                        pass
                break
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
                _regenerate_index_if_needed(force=True)
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
    parser.add_argument("--max-inflight", type=int, default=6)
    parser.add_argument("--novelty-slots", type=int, default=2,
                        help="Number of dispatch slots reserved for novelty/wild directions (default: 2)")
    parser.add_argument("--config", type=str, default=None)
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
    # Ollama Cloud tier removed (2026-08-21): Aristotle is the only LLM.
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
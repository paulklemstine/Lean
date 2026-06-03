#!/usr/bin/env python3
"""Aether Tick: One-shot pipeline step for CI.

Polls for completed Aristotle jobs, integrates them, dispatches new ones,
then exits. Designed for hourly cron — each run takes 2-5 minutes.

Usage:
    python3 aether_tick.py
    python3 aether_tick.py --max-inflight 9
    python3 aether_tick.py --loop --interval 21600   # continuous loop, every 6h
"""

import argparse
import asyncio
import http.server
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

from knowledge_extractor import KnowledgeExtractor

REPO_ROOT = Path(__file__).parent.parent
PACKAGES_DIR = REPO_ROOT / "Catalog" / "Applications" / "Packages"

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
    """Run one tick inside a single event loop.

    novelty_slots: number of dispatch slots reserved for novelty/wild directions
    """
    # 1. Poll inflight jobs
    extractor._load_inflight()

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
        for sd in novelty_seeds:
            existing_titles = {d.title.lower().strip() for d in fd_manager._directions}
            if sd.title.lower().strip() not in existing_titles:
                sd.id = fd_manager._next_id()
                sd.status = "available"
                fd_manager.add_direction(sd)
                added += 1
        if added:
            fd_manager._save()
            print(f"[Tick] Auto-refilled {added} novelty directions from seeds (was {available_novelty})")

    inflight_count = len(extractor.inflight)
    print(f"[Tick] {inflight_count} inflight jobs")

    completed_jobs = []
    if inflight_count > 0:
        completed_jobs = await extractor.poll_all()
        print(f"[Tick] {len(completed_jobs)} jobs completed since last tick")

    # 2. Integrate completed jobs
    for job in completed_jobs:
        if job.status != "completed":
            print(f"[Tick] Skipping {job.job_id[:8]} (status={job.status})")
            continue

        print(f"[Tick] Integrating {job.job_id[:8]}: {job.concept.title[:60]}")
        job = await extractor.extract_async(job)
        extractor._save_inflight()

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

        job = extractor.evaluate(job)
        extractor._save_inflight()

        job = await extractor.integrate_async(job)
        extractor._save_inflight()

        # Extract future directions
        extractor._extract_future_directions(job)

        # Cleanup and commit
        job = extractor.cleanup_catalog(job)
        extractor.commit(job)
        print(f"[Tick] Integrated {job.job_id[:8]}: score={job.quality_score:.3f}, "
              f"files={job.files_integrated}, theorems={job.theorem_count}")

    # Prune completed/failed/integrated/rejected jobs from inflight to prevent unbounded growth
    stale_keys = [pid for pid, j in extractor.inflight.items()
                  if j.status in ("completed", "failed", "integrated", "rejected")]
    if stale_keys:
        for pid in stale_keys:
            del extractor.inflight[pid]
        print(f"[Tick] Pruned {len(stale_keys)} completed jobs from inflight")

    # ── Self-healing: auto-prune low-quality directions ──
    try:
        from research_memory import FutureDirectionsManager
        fd_heal = FutureDirectionsManager(extractor.workspace)
        stats = fd_heal.get_stats()
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

    # ── Cycle analytics: record per-cycle metrics ──
    try:
        from cycle_analytics import CycleAnalytics
        ca = CycleAnalytics(extractor.workspace)
        for job in completed_jobs:
            ca.record_cycle(job, insight_extractor=getattr(extractor, 'insight_extractor', None))
        if completed_jobs:
            ca._save()
            print(f"[Analytics] Recorded {len(completed_jobs)} cycle(s), total={len(ca.records)}")
    except Exception as e:
        print(f"[Analytics] Cycle recording failed: {e}")

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

    # 3. Dispatch new jobs up to max_inflight (with novelty track)
    current_inflight = len([j for j in extractor.inflight.values()
                           if j.status not in ("completed", "failed", "integrated", "rejected")])
    slots_available = max_inflight - current_inflight

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

    if slots_available > 0:
        standard_slots = max(0, slots_available - novelty_slots)
        wild_slots = min(novelty_slots, slots_available)
        print(f"[Tick] {slots_available} dispatch slots available ({standard_slots} standard, {wild_slots} novelty)")

        # Dispatch standard directions
        for _ in range(standard_slots):
            try:
                job = extractor.discover(domain_filter=None, exclude_domains=["Novelty"] + saturated_domains)
                job = await extractor.dispatch_async(job)
                if job.project_id:
                    extractor.inflight[job.project_id] = job
                    print(f"[Tick] Dispatched {job.project_id[:8]}: {job.concept.title[:60]}")
                else:
                    extractor._release_direction(job)
                    print(f"[Tick] Dispatch failed for {job.concept.title[:60]}, direction released")
            except Exception as e:
                extractor._release_direction(job)
                print(f"[Tick] Dispatch error: {e}, direction released")

        # Dispatch novelty/wild directions
        for _ in range(wild_slots):
            try:
                job = extractor.discover(domain_filter="Novelty")
                job = await extractor.dispatch_async(job)
                if job.project_id:
                    extractor.inflight[job.project_id] = job
                    print(f"[Tick] Dispatched [NOVELTY] {job.project_id[:8]}: {job.concept.title[:60]}")
                else:
                    extractor._release_direction(job)
                    # Fallback: try any available direction if no novelty direction found
                    print(f"[Tick] No novelty direction available, trying standard fallback")
                    job = extractor.discover()
                    job = await extractor.dispatch_async(job)
                    if job.project_id:
                        extractor.inflight[job.project_id] = job
                        print(f"[Tick] Dispatched {job.project_id[:8]}: {job.concept.title[:60]}")
                    else:
                        extractor._release_direction(job)
            except Exception as e:
                extractor._release_direction(job)
                print(f"[Tick] Dispatch error: {e}, direction released")
        extractor._save_inflight()
    else:
        print(f"[Tick] No dispatch slots ({current_inflight}/{max_inflight} inflight)")

    # Summary
    remaining = len([j for j in extractor.inflight.values()
                    if j.status not in ("completed", "failed", "integrated", "rejected")])
    print(f"[Tick] Done — {len(completed_jobs)} integrated, {remaining} still inflight")


def rebuild_commit_push() -> bool:
    """Rebuild website index, sync to docs/, commit all changes, and push to git.
    Returns True if anything was pushed.
    Sets global _core_files_changed if core Python files changed after pull."""
    global _core_files_changed
    pre_pull_hashes = _snapshot_core_hashes()
    print("[Tick] Rebuilding website index...")
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
            ["rsync", "-a", "--delete", "--info=NAME", str(PACKAGES_DIR) + "/", str(docs_dir) + "/"],
            capture_output=True, text=True, timeout=60
        )
        if result.returncode != 0:
            print(f"[Tick] rsync warning: {result.stderr[:200]}")
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
    except Exception as e:
        print(f"[Tick] status sync error: {e}")

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

    # Git add only changed files (not -A which scans everything)
    try:
        # Stage specific directories instead of -A
        subprocess.run(["git", "add", "docs/"], cwd=str(REPO_ROOT), capture_output=True, timeout=60)
        subprocess.run(["git", "add", ".aether_workspace/"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)
        subprocess.run(["git", "add", "Catalog/"], cwd=str(REPO_ROOT), capture_output=True, timeout=60)
        subprocess.run(["git", "add", "Aether/"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)

        diff = subprocess.run(
            ["git", "diff", "--cached", "--quiet"],
            cwd=str(REPO_ROOT), capture_output=True, timeout=30
        )
        if diff.returncode == 0:
            print("[Tick] No changes to commit")
            return False

        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%MZ")
        subprocess.run(
            ["git", "commit", "-m", f"Aether local tick {timestamp}"],
            cwd=str(REPO_ROOT), capture_output=True, timeout=30
        )

        # Pull with merge (not rebase) — .gitattributes marks auto-generated
        # files with merge=ours so they resolve automatically. Merge handles
        # conflicts in one step instead of replaying every local commit.
        # Pre-merge: stash any uncommitted changes to avoid conflicts
        subprocess.run(["git", "stash", "--include-untracked"],
                       cwd=str(REPO_ROOT), capture_output=True, timeout=30)

        pull = subprocess.run(
            ["git", "pull", "--no-rebase", "origin", "master"],
            cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
        )

        # Post-merge: restore stashed changes, handling conflicts gracefully
        stash_result = subprocess.run(
            ["git", "stash", "pop"],
            cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=30
        )
        if stash_result.returncode != 0:
            # Stash pop conflict — stage everything and commit
            print("[Tick] Stash pop conflict — auto-resolving")
            subprocess.run(["git", "add", "-A"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)
            # If there are real merge conflicts in tracked files, take ours
            if _has_conflict_markers():
                subprocess.run(["git", "checkout", "--ours", "."],
                               cwd=str(REPO_ROOT), capture_output=True, timeout=30)
                subprocess.run(["git", "add", "-A"], cwd=str(REPO_ROOT), capture_output=True, timeout=30)
            subprocess.run(
                ["git", "-c", "core.editor=true", "commit", "--no-edit", "-m", "Auto-resolve stash conflict"],
                cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=30
            )
        if pull.returncode != 0:
            # Check if the conflict is on auto-generated files we can fix
            if _has_conflict_markers():
                # Regenerate auto-generated files to resolve conflicts
                _regenerate_index_if_needed()
                # Also resolve workspace future_directions.json if conflicted
                ws_fd = REPO_ROOT / "Aether" / ".aether_workspace" / "future_directions.json"
                if ws_fd.exists():
                    content = ws_fd.read_text(errors="ignore")
                    if "<<<<<<" in content or ">>>>>>" in content:
                        # Take our version (local) for the workspace file
                        subprocess.run(
                            ["git", "checkout", "--ours", str(ws_fd)],
                            cwd=str(REPO_ROOT), capture_output=True, timeout=10
                        )
                        subprocess.run(["git", "add", str(ws_fd)],
                                       cwd=str(REPO_ROOT), capture_output=True, timeout=10)
                # Stage all auto-generated resolved files
                auto_gen_files = [
                    "Catalog/Applications/Packages/package_index.js",
                    "Catalog/Applications/Packages/future_directions.js",
                    "Catalog/Applications/Packages/future_directions.json",
                    "Catalog/Applications/Packages/future_directions_snapshot.json",
                    "docs/package_index.js",
                    "docs/future_directions.js",
                    "docs/future_directions.json",
                    "docs/future_directions_snapshot.json",
                ]
                # For any remaining conflicted auto-gen files, take ours
                for f in auto_gen_files:
                    fp = REPO_ROOT / f
                    if fp.exists():
                        content = fp.read_text(errors="ignore")
                        if "<<<<<<" in content or ">>>>>>" in content:
                            subprocess.run(
                                ["git", "checkout", "--ours", f],
                                cwd=str(REPO_ROOT), capture_output=True, timeout=10
                            )
                # Stage all changes and complete the merge
                subprocess.run(
                    ["git", "add"] + auto_gen_files + [str(ws_fd)],
                    cwd=str(REPO_ROOT), capture_output=True, timeout=30
                )
                # Complete the merge commit
                merge_result = subprocess.run(
                    ["git", "-c", "core.editor=true", "commit", "--no-edit"],
                    cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=30
                )
                if merge_result.returncode != 0:
                    print(f"[Tick] Merge commit failed: {merge_result.stderr}")
                    subprocess.run(["git", "merge", "--abort"], cwd=str(REPO_ROOT), capture_output=True)
                    return False
                print("[Tick] Merge conflicts on auto-generated files resolved")
            else:
                subprocess.run(["git", "merge", "--abort"], cwd=str(REPO_ROOT), capture_output=True)
                print(f"[Tick] git pull failed (non-auto-resolvable): {pull.stderr}")
                return False

        # Final safety check: regenerate index if any conflict markers leaked through
        _regenerate_index_if_needed()

        push = subprocess.run(
            ["git", "push"], cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=120
        )
        if push.returncode != 0:
            print(f"[Tick] git push failed: {push.stderr}")
            return False

        print("[Tick] Changes committed and pushed")

        # Watchdog: check if core files changed after git pull
        if _check_core_file_changes(pre_pull_hashes):
            _core_files_changed = True

        return True
    except Exception as e:
        print(f"[Tick] git error: {e}")
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
    args = parser.parse_args()

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

            # Watchdog: if core Python files changed after git pull, restart the process
            if _core_files_changed:
                print("[Watchdog] Restarting Aether process due to core file changes...")
                os.execv(sys.executable, [sys.executable] + sys.argv)

            print(f"[Tick] Sleeping {args.interval}s until next tick...")
            time.sleep(args.interval)
    else:
        print(f"[Tick] Aether tick starting — max_inflight={args.max_inflight}, novelty_slots={args.novelty_slots}")
        asyncio.run(tick(extractor, args.max_inflight, args.novelty_slots))
        rebuild_commit_push()


if __name__ == "__main__":
    main()
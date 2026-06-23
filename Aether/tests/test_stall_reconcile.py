"""TDD tests for stall cap (wall-clock), preparing timeout, and direction reconcile.

Covers:
- Stall hard cap is wall-clock based (not checkpoint elapsed), 24h default.
- No-checkpoint jobs are covered by the cap (regression: previously skipped).
- Warn at 90min does NOT fail the job.
- Preparing timeout force-fails jobs stuck in preparing.
- reconcile_in_progress re-links a direction by direction_id (retries).
- _recover_stale_directions clears orphaned in_progress.
- ResearchJob.direction_id round-trips through serialization.
"""
import asyncio
import json
import sys
import tempfile
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


# ─── Fixtures ────────────────────────────────────────────────────────────

@pytest.fixture
def temp_workspace():
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


def _make_extractor(temp_workspace, inflight_jobs):
    """Build a minimal KnowledgeExtractor with mocked externals for poll_all."""
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    ext.config = {}
    ext.inflight = {j.job_id: j for j in inflight_jobs}
    ext.failed_count = 0
    ext.aristotle = MagicMock()
    ext.aristotle.poll_project = AsyncMock(return_value={
        "status": "RUNNING", "complete": False, "has_files": False, "percent_complete": 0,
    })
    ext._quarantine_direction_for_job = MagicMock()
    ext._release_direction = MagicMock()
    ext._save_inflight = MagicMock()
    return ext


def _job(job_id="j1", status="dispatched", dispatch_time=0.0, preparing_started=0.0,
         direction_id=None, retry_of=None):
    from knowledge_extractor import ResearchJob, ResearchConcept
    return ResearchJob(
        job_id=job_id,
        cycle_n=1,
        concept=ResearchConcept(
            title="t", domain="Algebra", concept_description="d",
            mathematical_framing="d", lean_guess="", research_mode="team",
            novelty_estimate=0.5, breakthrough_potential=0.5,
        ),
        prompt="p",
        status=status,
        dispatch_time=dispatch_time,
        preparing_started=preparing_started,
        direction_id=direction_id,
        retry_of=retry_of,
    )


# ─── Stall cap (wall-clock) ──────────────────────────────────────────────

def test_stall_cap_wall_clock_force_fail(temp_workspace):
    """A dispatched job older than the 24h wall-clock cap is force-failed and
    returned in completed — independent of reasoning checkpoints."""
    import time
    now = time.time()
    job = _job(job_id="stalled1", status="dispatched",
               dispatch_time=now - 1450 * 60)  # 24h10m, over the 24h cap
    ext = _make_extractor(temp_workspace, [job])
    completed = asyncio.run(ext.poll_all())
    assert job.status == "failed", f"Expected failed, got {job.status}"
    assert "wall-clock cap" in (job.error_message or ""), job.error_message
    assert job in completed
    ext._quarantine_direction_for_job.assert_called_once()


def test_stall_cap_no_checkpoint_covered(temp_workspace):
    """Regression: a job with NO reasoning checkpoints is still force-failed by
    the wall-clock cap. (Old code only checked checkpoints, so these slipped.)"""
    import time
    now = time.time()
    job = _job(job_id="nockpt", status="dispatched",
               dispatch_time=now - 1450 * 60)  # 24h10m, over the 24h cap
    ext = _make_extractor(temp_workspace, [job])
    # poll_project would return RUNNING, but the wall-clock cap fires first
    completed = asyncio.run(ext.poll_all())
    assert job.status == "failed"
    assert job in completed
    ext.aristotle.poll_project.assert_not_called()  # cap fired before polling


def test_stall_warn_under_cap(temp_workspace):
    """A dispatched job at 100min (over 90min warn, under 24h cap) is NOT failed."""
    import time
    now = time.time()
    job = _job(job_id="warn1", status="dispatched",
               dispatch_time=now - 100 * 60)
    ext = _make_extractor(temp_workspace, [job])
    asyncio.run(ext.poll_all())
    assert job.status == "dispatched", f"Expected dispatched (warn only), got {job.status}"


# ─── Preparing timeout ────────────────────────────────────────────────────

def test_preparing_timeout_force_fail(temp_workspace):
    """A job stuck in 'preparing' past the 30min bound is force-failed and its
    direction is released."""
    import time
    now = time.time()
    job = _job(job_id="stuckprep", status="preparing",
               preparing_started=now - 35 * 60, direction_id="dir-prep")
    ext = _make_extractor(temp_workspace, [job])
    completed = asyncio.run(ext.poll_all())
    assert job.status == "failed"
    assert "preparing" in (job.error_message or "").lower()
    assert job in completed
    ext._release_direction.assert_called_once_with(job)


def test_preparing_under_timeout_not_failed(temp_workspace):
    """A job preparing for only 5min is left alone (not failed)."""
    import time
    now = time.time()
    job = _job(job_id="preparing_fresh", status="preparing",
               preparing_started=now - 5 * 60)
    ext = _make_extractor(temp_workspace, [job])
    asyncio.run(ext.poll_all())
    assert job.status == "preparing"


# ─── Reconcile by direction_id ──────────────────────────────────────────

def _write_directions(temp_workspace, directions):
    """Write a future_directions.json with the given FutureDirection-like dicts."""
    data = {"directions": directions, "pruned": []}
    (temp_workspace / "future_directions.json").write_text(json.dumps(data))


def test_reconcile_relinks_by_direction_id(temp_workspace):
    """An active job with direction_id whose direction was released/available is
    flipped back to in_progress with consumed_by_exp_id = job_id (retry link)."""
    _write_directions(temp_workspace, [
        {"id": "dir-A", "title": "A", "description": "d", "source_exp_id": "s",
         "source_path": "p", "status": "available", "consumed_by_exp_id": ""},
    ])
    from research_memory import FutureDirectionsManager
    mgr = FutureDirectionsManager(temp_workspace)
    n = mgr.reconcile_in_progress([("job-A", "dir-A", None)])
    assert n == 1
    d = next(x for x in mgr._directions if x.id == "dir-A")
    assert d.status == "in_progress"
    assert d.consumed_by_exp_id == "job-A"


def test_reconcile_relinks_retry_by_retry_of(temp_workspace):
    """A retry job (retry_of set) re-links its direction with consumed_by_exp_id
    = retry_of (the original job id)."""
    _write_directions(temp_workspace, [
        {"id": "dir-R", "title": "R", "description": "d", "source_exp_id": "s",
         "source_path": "p", "status": "completed", "consumed_by_exp_id": ""},
    ])
    from research_memory import FutureDirectionsManager
    mgr = FutureDirectionsManager(temp_workspace)
    # retry job: job_id="retry1", retry_of="orig1", direction_id="dir-R"
    n = mgr.reconcile_in_progress([("retry1", "dir-R", "orig1")])
    assert n == 1
    d = next(x for x in mgr._directions if x.id == "dir-R")
    assert d.status == "in_progress"
    assert d.consumed_by_exp_id == "orig1"


def test_reconcile_noop_when_already_in_progress(temp_workspace):
    """A direction already in_progress for the active job is not recounted.

    A recent last_attempt_time keeps it in_progress through the manager's
    init-time _recover_stale_directions (grace period), so reconcile is a
    true no-op."""
    from datetime import datetime, timezone
    recent = datetime.now(timezone.utc).isoformat()
    _write_directions(temp_workspace, [
        {"id": "dir-X", "title": "X", "description": "d", "source_exp_id": "s",
         "source_path": "p", "status": "in_progress", "consumed_by_exp_id": "jobX",
         "last_attempt_time": recent},
    ])
    from research_memory import FutureDirectionsManager
    mgr = FutureDirectionsManager(temp_workspace)
    n = mgr.reconcile_in_progress([("jobX", "dir-X", None)])
    assert n == 0
    d = next(x for x in mgr._directions if x.id == "dir-X")
    assert d.status == "in_progress"
    assert d.consumed_by_exp_id == "jobX"


# ─── Orphan recovery ─────────────────────────────────────────────────────

def test_recover_stale_resets_orphan_in_progress(temp_workspace):
    """An in_progress direction whose job is gone (not in inflight, not in
    analytics, past grace) is reset to available."""
    _write_directions(temp_workspace, [
        {"id": "dir-O", "title": "O", "description": "d", "source_exp_id": "s",
         "source_path": "p", "status": "in_progress", "consumed_by_exp_id": "ghostjob",
         "last_attempt_time": "2020-01-01T00:00:00+00:00"},  # long ago, past grace
    ])
    from research_memory import FutureDirectionsManager
    mgr = FutureDirectionsManager(temp_workspace)
    # No inflight_jobs.json and no cycle_analytics.json -> ghostjob is truly stale
    mgr._recover_stale_directions()
    d = next(x for x in mgr._directions if x.id == "dir-O")
    assert d.status == "available"
    assert d.consumed_by_exp_id == ""


# ─── direction_id serialization ──────────────────────────────────────────

def test_direction_id_round_trips(temp_workspace):
    """A saved inflight dict with direction_id reconstructs via ResearchJob(**d);
    an old dict without it loads as None (backward compatible)."""
    from knowledge_extractor import ResearchJob, ResearchConcept
    concept = ResearchConcept(
        title="t", domain="Algebra", concept_description="d",
        mathematical_framing="d", lean_guess="", research_mode="team",
        novelty_estimate=0.5, breakthrough_potential=0.5,
    )
    j = ResearchJob(job_id="ser1", cycle_n=1, concept=concept, prompt="p",
                    direction_id="dir-S", preparing_started=1234.0)
    # serialize like _save_inflight does
    d = {}
    for k, v in j.__dict__.items():
        d[k] = v.__dict__ if hasattr(v, "__dict__") else v
    d["concept"] = concept  # ResearchConcept reconstructs fine
    # round-trip
    j2 = ResearchJob(**d)
    assert j2.direction_id == "dir-S"
    assert j2.preparing_started == 1234.0

    # old record without the fields -> defaults
    d.pop("direction_id")
    d.pop("preparing_started")
    j3 = ResearchJob(**d)
    assert j3.direction_id is None
    assert j3.preparing_started == 0.0
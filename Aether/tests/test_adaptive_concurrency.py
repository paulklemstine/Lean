import pytest
import time
import os
from pathlib import Path
from unittest.mock import MagicMock, AsyncMock, patch

from adaptive_concurrency import AdaptiveConcurrencyManager, ConcurrencyState


def test_adaptive_concurrency_default_and_save(tmp_path):
    mgr = AdaptiveConcurrencyManager(tmp_path, default_max=9, cooldown_seconds=60.0)
    # When no state file exists, should return configured_max
    assert mgr.get_effective_max_inflight(9) == 9

    # Record queue full with 1 active job
    new_limit = mgr.record_queue_full(current_active=1)
    assert new_limit == 1
    assert (tmp_path / "adaptive_concurrency.json").exists()

    # Effective limit should now be 1
    assert mgr.get_effective_max_inflight(9) == 1

    # Reload from disk
    mgr2 = AdaptiveConcurrencyManager(tmp_path, default_max=9, cooldown_seconds=60.0)
    assert mgr2.get_effective_max_inflight(9) == 1


def test_adaptive_concurrency_probing_and_expansion(tmp_path):
    mgr = AdaptiveConcurrencyManager(tmp_path, default_max=9, cooldown_seconds=10.0)
    mgr.record_queue_full(current_active=2)

    # Immediately after queue full: limit is 2
    assert mgr.get_effective_max_inflight(9) == 2

    # Simulate cooldown expiration by backdating last_queue_full_time
    state = mgr.load_state()
    state.last_queue_full_time = time.time() - 20.0
    mgr.save_state(state)

    # Cooldown expired: should allow probe limit of 2 + 1 = 3
    assert mgr.get_effective_max_inflight(9) == 3

    # Dispatch succeeds with 3 active: should raise detected_limit to 3
    mgr.record_dispatch_success(current_active=3, configured_max=9)
    state = mgr.load_state()
    assert state.detected_limit == 3


def test_fifo_preservation_in_sorting():
    from types import SimpleNamespace

    j1 = SimpleNamespace(job_id="first", phase="A", retry_queued_time=100.0, preparing_started=0.0, dispatch_time=0.0)
    j2 = SimpleNamespace(job_id="second", phase="A", retry_queued_time=200.0, preparing_started=0.0, dispatch_time=0.0)
    j3 = SimpleNamespace(job_id="phase_b", phase="B", retry_queued_time=300.0, preparing_started=0.0, dispatch_time=0.0)

    def _queue_sort_key(j):
        is_b = 0 if getattr(j, "phase", "") in ("B", "B_dispatched") else 1
        ts = getattr(j, "retry_queued_time", 0.0) or getattr(j, "preparing_started", 0.0) or getattr(j, "dispatch_time", 0.0) or 0.0
        return (is_b, ts if ts > 0 else 1e12)

    jobs = [j2, j1, j3]
    jobs.sort(key=_queue_sort_key)

    # Phase B must be first, then first (ts=100), then second (ts=200)
    assert jobs[0].job_id == "phase_b"
    assert jobs[1].job_id == "first"
    assert jobs[2].job_id == "second"


@pytest.mark.asyncio
async def test_circuit_breaker_stops_queued_drain(tmp_path):
    from aether_tick import _tick_impl
    from knowledge_extractor import KnowledgeExtractor, ResearchJob, ResearchConcept

    os.environ["AETHER_DISABLE_TOURNAMENT"] = "1"
    (tmp_path / "future_directions.json").write_text("[]", encoding="utf-8")

    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    extractor.max_inflight = 9
    extractor.refresh_external_signals = MagicMock(return_value=0)
    extractor.discover = MagicMock()

    aristotle_mock = MagicMock()
    aristotle_mock.get_active_jobs_count = AsyncMock(return_value=1)
    aristotle_mock.cleanup_stale_server_tasks = AsyncMock(return_value=0)
    extractor.aristotle = aristotle_mock

    # Setup 3 queued jobs with recent timestamps
    now = time.time()
    j1 = ResearchJob(
        job_id="job_1", cycle_n=1,
        concept=ResearchConcept(title="Job 1", domain="Physics", concept_description="", mathematical_framing=""),
        prompt="", project_dir=tmp_path / "p1", status="dispatch_queued", retry_queued_time=now - 30.0
    )
    j2 = ResearchJob(
        job_id="job_2", cycle_n=1,
        concept=ResearchConcept(title="Job 2", domain="Physics", concept_description="", mathematical_framing=""),
        prompt="", project_dir=tmp_path / "p2", status="dispatch_queued", retry_queued_time=now - 20.0
    )
    j3 = ResearchJob(
        job_id="job_3", cycle_n=1,
        concept=ResearchConcept(title="Job 3", domain="Physics", concept_description="", mathematical_framing=""),
        prompt="", project_dir=tmp_path / "p3", status="dispatch_queued", retry_queued_time=now - 10.0
    )
    extractor.inflight = {"job_1": j1, "job_2": j2, "job_3": j3}

    call_count = 0
    async def mock_dispatch(job):
        nonlocal call_count
        call_count += 1
        raise RuntimeError("QUEUE FULL: You have too many projects in progress.")

    extractor._dispatch_to_aristotle = mock_dispatch
    extractor.poll_all = AsyncMock(return_value=[])

    with patch("github_injector.fetch_injected_directions", return_value=[]), \
         patch("github_injector.inject_directions_into_memory"), \
         patch("github_injector.close_orphaned_issues"), \
         patch("subprocess.run", return_value=MagicMock(returncode=0, stdout="", stderr="")):
        await _tick_impl(extractor, max_inflight=9)

    # Circuit breaker should have tripped on job_1: exactly 1 call made, NOT 3!
    assert call_count == 1
    # Remaining jobs must still be queued
    assert extractor.inflight["job_2"].status in ("dispatch_queued", "retry_queued")
    assert extractor.inflight["job_3"].status in ("dispatch_queued", "retry_queued")


@pytest.mark.asyncio
async def test_discovery_gate_blocks_new_when_queued_exist(tmp_path):
    from aether_tick import _tick_impl
    from knowledge_extractor import KnowledgeExtractor, ResearchJob, ResearchConcept

    os.environ["AETHER_DISABLE_TOURNAMENT"] = "1"
    (tmp_path / "future_directions.json").write_text("[]", encoding="utf-8")

    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    extractor.max_inflight = 9
    extractor.refresh_external_signals = MagicMock(return_value=0)
    extractor.discover = MagicMock()

    aristotle_mock = MagicMock()
    # At start & Step 3: 9 active (full). In Step 4: 8 active (1 slot opens).
    aristotle_mock.get_active_jobs_count = AsyncMock(side_effect=[9, 9, 8])
    aristotle_mock.cleanup_stale_server_tasks = AsyncMock(return_value=0)
    extractor.aristotle = aristotle_mock

    # 1 queued job waiting
    now = time.time()
    j1 = ResearchJob(
        job_id="job_queued", cycle_n=1,
        concept=ResearchConcept(title="Queued Job", domain="Physics", concept_description="", mathematical_framing=""),
        prompt="", project_dir=tmp_path / "pq", status="dispatch_queued", retry_queued_time=now - 10.0
    )
    extractor.inflight = {"job_queued": j1}

    extractor._dispatch_to_aristotle = AsyncMock()
    extractor.poll_all = AsyncMock(return_value=[])

    with patch("github_injector.fetch_injected_directions", return_value=[]), \
         patch("github_injector.inject_directions_into_memory"), \
         patch("github_injector.close_orphaned_issues"), \
         patch("subprocess.run", return_value=MagicMock(returncode=0, stdout="", stderr="")):
        await _tick_impl(extractor, max_inflight=9)

    # Queued job was NOT drained due to lack of capacity in Step 3, and remains queued
    assert "job_queued" in extractor.inflight
    assert extractor.inflight["job_queued"].status in ("dispatch_queued", "retry_queued")
    # Even though 1 slot opened in Step 4 (8 active), discover must NOT be called
    # because queued work is pending and prioritized.
    assert extractor.discover.call_count == 0

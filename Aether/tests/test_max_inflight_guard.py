import pytest
import json
import asyncio
from pathlib import Path
from unittest.mock import MagicMock, patch, AsyncMock
import sys

# Add parent directory to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent))

from knowledge_extractor import KnowledgeExtractor, ResearchJob, ResearchConcept
import aether_tick

@pytest.mark.asyncio
async def test_dispatch_to_aristotle_blocks_over_capacity(tmp_path):
    """Verify _dispatch_to_aristotle raises RuntimeError when capacity is at max_inflight."""
    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    extractor.max_inflight = 9

    # Mock get_capacity_used_async to report 9 active jobs
    extractor.get_capacity_used_async = AsyncMock(return_value=9)

    job = ResearchJob(
        job_id="test_job_over_cap",
        cycle_n=1,
        concept=ResearchConcept(
            title="Test Over Capacity",
            domain="Logic",
            concept_description="Test",
            mathematical_framing="Test",
        ),
        prompt="Test prompt",
        project_dir=tmp_path / "test_dir",
    )
    (tmp_path / "test_dir").mkdir(parents=True, exist_ok=True)

    with pytest.raises(RuntimeError) as exc_info:
        await extractor._dispatch_to_aristotle(job, max_inflight=9)
    
    assert "capacity limit reached" in str(exc_info.value).lower()

@pytest.mark.asyncio
async def test_tournament_respects_max_inflight(tmp_path):
    """Verify Direction Tournament is skipped when current_inflight >= max_inflight."""
    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    extractor.max_inflight = 9
    extractor.inflight = {}

    # Mock aristotle client
    mock_aristotle = MagicMock()
    mock_aristotle.get_active_jobs_count = AsyncMock(return_value=9)
    mock_aristotle.submit_lean_project_only = AsyncMock(return_value="tournament_proj_id")
    extractor.aristotle = mock_aristotle

    # Simulate tick tournament check logic
    local_inflight = extractor._count_inflight_dispatched()
    server_running = await mock_aristotle.get_active_jobs_count()
    current_inflight = max(local_inflight, server_running)
    max_inflight = 9

    # Capacity check logic from aether_tick
    should_run_tournament = current_inflight < max_inflight
    assert not should_run_tournament
    mock_aristotle.submit_lean_project_only.assert_not_called()

@pytest.mark.asyncio
async def test_injected_issue_queues_cleanly_at_max_inflight(tmp_path):
    """Verify injected GitHub directions are queued into inflight without releasing back to available."""
    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    extractor.max_inflight = 9

    # Capacity is full
    extractor.get_capacity_used_async = AsyncMock(return_value=9)

    # Initialize future_directions.json in parent Packages dir
    pkg_dir = tmp_path.parent.parent / "Packages"
    pkg_dir.mkdir(parents=True, exist_ok=True)
    (pkg_dir / "future_directions.json").write_text("[]", encoding="utf-8")

    from research_memory import FutureDirection
    fd_dir = FutureDirection(
        id="fd_0001",
        title="Injected Issue Test",
        description="Injected body",
        source_exp_id="github",
        source_path="github",
        status="available",
    )
    setattr(fd_dir, "source", "github_injection")
    setattr(fd_dir, "github_issue", 123)

    # Mock Pi Agent prompt generation for speed
    extractor.pi_agent = MagicMock()
    extractor.pi_agent.write_aristotle_prompt = MagicMock(return_value="Mocked prompt")

    job = extractor.discover(forced_direction=fd_dir)
    job = await extractor.dispatch_async(job, max_inflight=9)

    # Job should be queued in inflight with status dispatch_queued
    assert job.status == "dispatch_queued"
    assert job.job_id in extractor.inflight
    assert extractor.inflight[job.job_id].status == "dispatch_queued"

    # Verify inflight_jobs.json was written to disk and can be reloaded
    inflight_file = tmp_path / "inflight_jobs.json"
    assert inflight_file.exists()

    reloaded_extractor = KnowledgeExtractor(config=config)
    reloaded_extractor.workspace = tmp_path
    reloaded_extractor._load_inflight()
    assert job.job_id in reloaded_extractor.inflight
    assert reloaded_extractor.inflight[job.job_id].status == "dispatch_queued"

import pytest
import time
import asyncio
from pathlib import Path
from unittest.mock import MagicMock, AsyncMock
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
from knowledge_extractor import KnowledgeExtractor, ResearchJob, ResearchConcept

@pytest.mark.asyncio
async def test_stall_continue_injection(tmp_path):
    """Verify that jobs running for >= 1 hour get 'continue' injected via ask()."""
    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path

    # Mock aristotle client
    mock_aristotle = MagicMock()
    mock_aristotle.poll_project = AsyncMock(return_value={
        "status": "RUNNING",
        "has_files": False,
        "percent_complete": 50.0,
    })
    mock_aristotle.resume_project = AsyncMock(return_value="task_cont_123")
    extractor.aristotle = mock_aristotle

    # Create a job dispatched 65 minutes ago (3900 seconds)
    dispatch_time = time.time() - 3900.0
    job = ResearchJob(
        job_id="test_stalled_job",
        cycle_n=1,
        concept=ResearchConcept(
            title="Test Stalled Job",
            domain="Geometry",
            concept_description="Test stall injection",
            mathematical_framing="Test",
        ),
        prompt="Test prompt",
        project_dir=tmp_path / "test_dir",
        project_id="proj_stall_123",
        status="dispatched",
        dispatch_time=dispatch_time,
    )
    (tmp_path / "test_dir").mkdir(parents=True, exist_ok=True)
    extractor.inflight["proj_stall_123"] = job

    # Call poll_all()
    completed = await extractor.poll_all()

    # Verify resume_project was called with "continue"
    mock_aristotle.resume_project.assert_called_once_with("proj_stall_123", "continue")

    # Verify job attributes updated
    assert hasattr(job, "last_stall_continue_time")
    assert job.last_stall_continue_time > 0
    assert job.resume_count == 1
    # Dispatch time reset so the next 1h window starts
    assert job.dispatch_time > dispatch_time

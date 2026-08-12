import pytest
import time
import asyncio
from pathlib import Path
from unittest.mock import MagicMock, AsyncMock
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))
from knowledge_extractor import KnowledgeExtractor, ResearchJob, ResearchConcept

@pytest.mark.asyncio
async def test_stall_finish_injection(tmp_path):
    """Verify that jobs running for >= 4 hours get 'finish' injected via ask() and are completed."""
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

    # Create a job dispatched 4.5 hours ago (16200 seconds)
    dispatch_time = time.time() - 16200.0
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

    # Verify resume_project was called with "finish"
    mock_aristotle.resume_project.assert_called_once_with("proj_stall_123", "finish")

    # Verify finish was sent but job remains in inflight (not completed) while status is RUNNING
    assert hasattr(job, "last_stall_continue_time")
    assert job.last_stall_continue_time > 0
    assert getattr(job, "stall_finish_sent", False) is True
    assert job.status == "dispatched"
    assert job not in completed

    # Now simulate Aristotle ending the job (IDLE with has_files=True)
    mock_aristotle.poll_project = AsyncMock(return_value={
        "status": "IDLE",
        "has_files": True,
        "percent_complete": 100.0,
    })
    completed2 = await extractor.poll_all()
    assert job.status == "completed"
    assert job in completed2

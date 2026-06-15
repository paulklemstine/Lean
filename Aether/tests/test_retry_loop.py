"""Tests for the Dialogue-Based Proof Repair / Retry Loop in Aether.

Covers:
- ResearchJob carries retry_count and retry_of.
- dispatch_retry_async updates concept, prompt, paths, increments count, and dispatches.
- dispatch_retry synchronous wrapper executes successfully.
- run_single_cycle intercepts failures and retries under max_retries if should_retry is True.
- run_continuous intercepts failures and dispatches retries asynchronously.
- aether_tick.py tick function intercepts failures and dispatches retries asynchronously.
"""

import asyncio
import json
import os
import sys
import tempfile
import shutil
import time
from pathlib import Path
from unittest.mock import MagicMock, patch, AsyncMock

import pytest

# Ensure project root is on the path
sys.path.insert(0, str(Path(__file__).parent.parent))

from pi_agent_client import ResearchConcept
from knowledge_extractor import KnowledgeExtractor, ResearchJob


@pytest.fixture
def tmp_workspace():
    """Create a temporary workspace for the extractor."""
    with tempfile.TemporaryDirectory() as tmpdir:
        ws = Path(tmpdir)
        catalog = ws / "Catalog"
        catalog.mkdir()
        
        # Pre-create a mock lean file
        mock_file = catalog / "Algebra" / "Matrix.lean"
        mock_file.parent.mkdir(parents=True, exist_ok=True)
        mock_file.write_text("-- test lean content")
        
        # Pre-create mock configs
        (catalog / "lean-toolchain").write_text("leanprover/lean4:v4.7.0")
        (catalog / "lakefile.toml").write_text("[package]\nname = \"catalog\"")
        
        yield ws


@pytest.fixture
def research_concept():
    """Build a sample ResearchConcept for testing."""
    return ResearchConcept(
        title="Test Proof Repair Theorem",
        domain="Algebra",
        concept_description="A test concept to evaluate proof repair loop",
        mathematical_framing="Proof repair framing",
        lean_guess="theorem test_repair : True := trivial",
        novelty_estimate=0.5,
        breakthrough_potential=0.5,
    )


@pytest.fixture
def research_job(research_concept):
    """Build a sample ResearchJob for testing."""
    return ResearchJob(
        job_id="test-job-retry-123",
        cycle_n=1,
        concept=research_concept,
        prompt="original prompt",
    )


def test_research_job_carries_retry_fields(research_job):
    """Verify ResearchJob is initialized with default retry fields."""
    assert hasattr(research_job, "retry_count")
    assert hasattr(research_job, "retry_of")
    assert research_job.retry_count == 0
    assert research_job.retry_of is None


def test_dispatch_retry_async_updates_and_dispatches(tmp_workspace, research_job):
    """Test that dispatch_retry_async correctly updates properties and dispatches to Aristotle."""
    config = {
        "catalog": {"root_dir": str(tmp_workspace / "Catalog")},
        "workspace": str(tmp_workspace),
        "pi_agent": {"model": "mock"},
        "autoresearch": {"max_retries": 3}
    }
    
    extractor = KnowledgeExtractor(config=config)
    
    # Mock Aristotle dispatch
    extractor._dispatch_to_aristotle = AsyncMock(return_value="mock-project-id-xyz")
    
    suggestion = {
        "revised_concept_description": "revised description",
        "revised_prompt": "revised prompt text",
        "revised_catalog_references": ["Algebra/Matrix.lean"],
        "revised_research_mode": "formalize",
        "confidence": 0.9
    }
    
    # Track the original job ID
    original_job_id = research_job.job_id
    
    # Run async function
    job = asyncio.run(extractor.dispatch_retry_async(research_job, suggestion))
    
    # Check that concept and prompt were updated
    assert job.concept.concept_description == "revised description"
    assert job.prompt == "revised prompt text"
    assert job.concept.catalog_references == ["Algebra/Matrix.lean"]
    assert job.concept.research_mode == "formalize"
    
    # Check retry tracking fields
    assert job.retry_count == 1
    assert job.retry_of == original_job_id
    
    # Check project directory suffix is added
    assert "_retry1" in job.project_dir.name
    assert job.project_dir.exists()
    assert (job.project_dir / "PROMPT.md").read_text() == "revised prompt text"
    
    # Check status and inflight tracking
    assert job.status == "dispatched"
    assert job.project_id == "mock-project-id-xyz"
    assert "mock-project-id-xyz" in extractor.inflight
    assert extractor.inflight["mock-project-id-xyz"] == job


def test_dispatch_retry_sync_wrapper(tmp_workspace, research_job):
    """Test the synchronous wrapper dispatch_retry behaves correctly."""
    config = {
        "catalog": {"root_dir": str(tmp_workspace / "Catalog")},
        "workspace": str(tmp_workspace),
        "pi_agent": {"model": "mock"}
    }
    
    extractor = KnowledgeExtractor(config=config)
    extractor._dispatch_to_aristotle = AsyncMock(return_value="mock-project-id-sync")
    
    suggestion = {
        "revised_concept_description": "revised sync description",
        "revised_prompt": "revised sync prompt text",
        "revised_catalog_references": [],
        "revised_research_mode": "prove",
        "confidence": 0.8
    }
    
    job = extractor.dispatch_retry(research_job, suggestion)
    assert job.retry_count == 1
    assert job.status == "dispatched"
    assert job.project_id == "mock-project-id-sync"


def test_run_single_cycle_proof_repair_loop(tmp_workspace, research_job):
    """Verify that run_single_cycle executes retry dispatches when quality is low."""
    config = {
        "catalog": {"root_dir": str(tmp_workspace / "Catalog")},
        "workspace": str(tmp_workspace),
        "pi_agent": {"model": "mock"},
        "autoresearch": {"max_retries": 2}
    }
    
    extractor = KnowledgeExtractor(config=config)
    
    # Mock pi_agent suggest method
    extractor.pi_agent = MagicMock()
    extractor.pi_agent.write_aristotle_prompt.return_value = "mock prompt text"
    extractor.pi_agent.suggest_retry_improvement.return_value = {
        "revised_concept_description": "improved description",
        "revised_prompt": "improved prompt",
        "revised_catalog_references": [],
        "revised_research_mode": "prove",
        "confidence": 0.95
    }
    
    # Mock pipeline steps
    extractor.discover = MagicMock(return_value=research_job)
    extractor._dispatch_to_aristotle = AsyncMock(return_value="mock-aristotle-project")
    def mock_await(j, *args, **kwargs):
        j.status = "completed"
        return j
    extractor._await_job = MagicMock(side_effect=mock_await)
    extractor.extract = MagicMock(return_value=research_job)
    extractor.integrate = MagicMock(return_value=research_job)
    extractor._extract_future_directions = MagicMock()
    extractor.cleanup_catalog = MagicMock(return_value=research_job)
    extractor.commit = MagicMock()
    
    # We will simulate the evaluation step.
    # On first call (retry_count=0): low quality, should_retry=True.
    # On second call (retry_count=1): low quality, should_retry=True.
    # On third call (retry_count=2): high quality or max retries hit.
    def mock_evaluate(job):
        job.quality_score = 0.2
        if job.retry_count < 2:
            job.quality_assessment = {"quality": "low", "should_retry": True}
        else:
            job.quality_assessment = {"quality": "high", "should_retry": False}
        return job
    
    extractor.evaluate = mock_evaluate
    
    # Run the cycle
    final_job = extractor.run_single_cycle()
    
    # Since max_retries = 2:
    # 0 -> retry 1 -> retry 2 -> evaluate (no more retry since retry_count == 2 == max_retries)
    assert final_job.retry_count == 2
    assert extractor.pi_agent.suggest_retry_improvement.call_count == 2
    assert extractor.integrate.call_count == 1  # Integrate should only run once at the end


def test_run_continuous_proof_repair_loop(tmp_workspace, research_job):
    """Verify that run_continuous intercepts failed jobs and re-dispatches them."""
    config = {
        "catalog": {"root_dir": str(tmp_workspace / "Catalog")},
        "workspace": str(tmp_workspace),
        "pi_agent": {"model": "mock"},
        "autoresearch": {"max_retries": 2}
    }
    
    extractor = KnowledgeExtractor(config=config)
    
    # Setup job
    research_job.status = "completed"
    research_job.phase = "A"
    research_job.project_id = "mock-project-id"
    
    # Put jobs in inflight to saturate max_inflight so run_continuous doesn't try to discover and dispatch new jobs
    extractor.inflight = {
        "mock-project-id": research_job,
        "other-job": MagicMock(status="dispatched")
    }
    
    # Mock pi_agent
    extractor.pi_agent = MagicMock()
    extractor.pi_agent.suggest_retry_improvement.return_value = {
        "revised_concept_description": "continuous improved description",
        "revised_prompt": "continuous improved prompt",
        "revised_catalog_references": [],
        "revised_research_mode": "prove",
        "confidence": 0.95
    }
    
    # Mock methods
    extractor._dispatch_to_aristotle = AsyncMock(return_value="mock-aristotle-project")
    extractor.extract_async = AsyncMock(return_value=research_job)
    
    # Simulated evaluation: should_retry is True
    def mock_evaluate(job):
        job.quality_score = 0.2
        job.quality_assessment = {"quality": "low", "should_retry": True}
        return job
    extractor.evaluate = mock_evaluate
    
    # To break out of the run_continuous loop after processing the first batch:
    poll_count = 0
    async def mock_poll_all():
        nonlocal poll_count
        poll_count += 1
        if poll_count == 1:
            return [research_job]
        else:
            extractor.cycle_count = 999  # break loop
            return []
            
    extractor.poll_all = mock_poll_all
    
    asyncio.run(extractor.run_continuous(max_inflight=2, max_cycles=1, poll_interval=1))
    
    # Assert retry count was incremented to 1
    assert research_job.retry_count == 1


def test_aether_tick_proof_repair_loop(tmp_workspace, research_job):
    """Verify that aether_tick.py tick function intercepts failed jobs and retries them."""
    import aether_tick
    
    config = {
        "catalog": {"root_dir": str(tmp_workspace / "Catalog")},
        "workspace": str(tmp_workspace),
        "pi_agent": {"model": "mock"},
        "autoresearch": {"max_retries": 2}
    }
    
    extractor = KnowledgeExtractor(config=config)
    
    # Prepare job
    research_job.status = "completed"
    research_job.phase = "A"
    research_job.project_id = "mock-project-id"
    extractor.inflight = {"mock-project-id": research_job}
    
    # Mock pi_agent
    extractor.pi_agent = MagicMock()
    extractor.pi_agent.suggest_retry_improvement.return_value = {
        "revised_concept_description": "tick improved description",
        "revised_prompt": "tick improved prompt",
        "revised_catalog_references": [],
        "revised_research_mode": "prove",
        "confidence": 0.95
    }
    
    # Mock extractor methods
    extractor.poll_all = AsyncMock(return_value=[research_job])
    extractor.extract_async = AsyncMock(return_value=research_job)
    extractor._dispatch_to_aristotle = AsyncMock(return_value="mock-aristotle-project")
    
    # Sim evaluate
    def mock_evaluate(job):
        job.quality_score = 0.2
        job.quality_assessment = {"quality": "low", "should_retry": True}
        return job
    extractor.evaluate = mock_evaluate
    
    # Mock FutureDirectionsManager, CatalogPruner, and CycleAnalytics
    with patch("research_memory.FutureDirectionsManager") as mock_fd_mgr, \
         patch("catalog_pruner.CatalogPruner") as mock_pruner, \
         patch("cycle_analytics.CycleAnalytics") as mock_analytics:
         
        # Initialize mocks
        fd_mgr_instance = mock_fd_mgr.return_value
        fd_mgr_instance.recover_stale_directions.return_value = 0
        fd_mgr_instance.rebalance_domains.return_value = {}
        
        fd_mgr_instance.get_stats.return_value = {
            "available": 0,
            "retried_directions": 0,
            "retry_rate": 0.0,
            "avg_attempts": 0.0
        }
        
        # Create 5 mock directions to avoid get_seed_directions calling
        mock_direction = MagicMock()
        mock_direction.status = "available"
        mock_direction.domains = ["Novelty"]
        fd_mgr_instance._directions = [mock_direction] * 5
        
        mock_pruner.return_value.prune.return_value = {"removed": [], "kept": []}
        mock_analytics.return_value.get_breakthroughs.return_value = []
        mock_analytics.return_value.detect_quality_decay.return_value = []
        mock_analytics.return_value.get_domain_stats.return_value = {}
        mock_analytics.return_value.get_reasoning_log_stats.return_value = {}
        mock_analytics.return_value.records = []
        
        # Run tick with max_inflight=0 to avoid any dispatch slot polling/errors
        asyncio.run(aether_tick.tick(extractor, max_inflight=0))
        
        # Check that retry_count was incremented to 1
        assert research_job.retry_count == 1

import pytest
import asyncio
from unittest.mock import MagicMock
from knowledge_extractor import ResearchJob, ResearchConcept
from research_memory import FutureDirectionsManager

class AsyncMock(MagicMock):
    async def __call__(self, *args, **kwargs):
        return super(AsyncMock, self).__call__(*args, **kwargs)

def test_decompose_direction_on_max_retries(tmp_path, monkeypatch):
    async def run_test():
        import aether_tick
        import research_journal as _rj
        # Hermetic: neutralize real-filesystem side effects of _tick_impl
        monkeypatch.setattr(aether_tick, "_signal_dashboard_update", lambda *a, **k: None)
        monkeypatch.setattr(aether_tick, "rebuild_commit_push", lambda: False)
        class _NoopJournal:
            def __init__(self, workspace): pass
            def record_cycle(self, job, quality_score=0.0): pass
        monkeypatch.setattr(_rj, "ResearchJournal", _NoopJournal)

        extractor = MagicMock()
        extractor.workspace = tmp_path
        extractor.max_retries = 2
        extractor.phase_b_min_score = 0.7
        extractor._adaptive_phase_b_threshold = MagicMock(return_value=0.5)
        extractor._count_inflight_dispatched = MagicMock(return_value=1)
        extractor.refresh_external_signals = MagicMock(return_value=0)
        
        extractor.pi_agent = MagicMock()
        extractor.pi_agent.decompose_direction = MagicMock(return_value=[
            {"title": "Sub 1", "concept": "Concept 1"},
            {"title": "Sub 2", "concept": "Concept 2"}
        ])

        job = ResearchJob(
            job_id="job_failed_1234",
            cycle_n=1,
            concept=ResearchConcept(title="Hard concept", domain="Algebra", concept_description="Desc", mathematical_framing="Desc", lean_guess="...", research_mode="prove", novelty_estimate=0.5, breakthrough_potential=0.5),
            prompt="prompt",
        )
        job.retry_count = 2 # Max retries
        job.quality_score = 0.2
        job.quality_assessment = {"should_retry": True, "quality": "insufficient"}
        job.status = "completed"
        job.phase = "A"
        job.files_integrated = 0
        job.theorem_count = 0
        job.sorry_count = 0
        
        extractor.inflight = {job.job_id: job}
        extractor.poll_all = AsyncMock(return_value=[job])
        extractor.extract_async = AsyncMock(return_value=job)
        extractor.evaluate = MagicMock(return_value=job)
        extractor.integrate_async = AsyncMock(return_value=job)
        extractor.cleanup_catalog = MagicMock(return_value=job)
        extractor.commit = MagicMock()
        
        fd_manager = FutureDirectionsManager(tmp_path)
        
        class MockMemory:
            future_directions = fd_manager
            
        extractor.memory = MockMemory()
        
        await aether_tick._tick_impl(extractor, max_inflight=1, novelty_slots=0)
        
        extractor.pi_agent.decompose_direction.assert_called_once()
        
        fd_manager2 = FutureDirectionsManager(tmp_path)
        titles = [d.title for d in fd_manager2._directions]
        
        found_sub1 = any(d.title == "Sub 1" and d.parent_direction == "job_failed_1234" and d.decomposition_depth == 1 for d in fd_manager2._directions)
        assert found_sub1, f"Found titles: {titles}"

    asyncio.run(run_test())

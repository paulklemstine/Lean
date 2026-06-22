import pytest
import asyncio
from unittest.mock import MagicMock
from knowledge_extractor import ResearchJob, ResearchConcept

class AsyncMock(MagicMock):
    async def __call__(self, *args, **kwargs):
        return super(AsyncMock, self).__call__(*args, **kwargs)

def test_early_accept_and_phase_b_gate(tmp_path, monkeypatch):
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
        extractor.phase_b_min_score = 0.7
        extractor._adaptive_phase_b_threshold = MagicMock(return_value=0.5)
        extractor.max_retries = 2
        extractor._count_inflight_dispatched = MagicMock(return_value=1)
        extractor.refresh_external_signals = MagicMock(return_value=0)
        
        job = ResearchJob(
            job_id="job_incremental",
            cycle_n=1,
            concept=ResearchConcept(title="Incremental", domain="Algebra", concept_description="desc", mathematical_framing="desc", lean_guess="...", research_mode="prove", novelty_estimate=0.5, breakthrough_potential=0.5),
            prompt="prompt",
        )
        job.quality_score = 0.65
        job.result_lean = "theorem..."
        job.quality_assessment = {"should_retry": True, "quality": "partial"}
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
        extractor.dispatch_retry_async = AsyncMock()
        extractor.dispatch_phase_b_async = AsyncMock(return_value=job)
        extractor.cleanup_catalog = MagicMock(return_value=job)
        extractor.commit = MagicMock()
        
        await aether_tick._tick_impl(extractor, max_inflight=1, novelty_slots=0)
        
        assert job.quality_assessment["accepted_as"] == "incremental"
        extractor.dispatch_retry_async.assert_not_called()
        extractor.dispatch_phase_b_async.assert_not_called()
        
        job.quality_score = 0.75
        job.phase = "A"
        job.status = "completed"
        extractor.inflight = {job.job_id: job}
        extractor.poll_all = AsyncMock(return_value=[job])
        
        extractor.dispatch_retry_async.reset_mock()
        extractor.dispatch_phase_b_async.reset_mock()
        
        await aether_tick._tick_impl(extractor, max_inflight=1, novelty_slots=0)
        extractor.dispatch_phase_b_async.assert_called_once()
        
    asyncio.run(run_test())

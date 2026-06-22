import pytest
import asyncio
from unittest.mock import MagicMock
from research_memory import FutureDirectionsManager

def test_llm_driven_novelty(tmp_path, monkeypatch):
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

        original_to_thread = asyncio.to_thread
        async def mock_to_thread(func, *args, **kwargs):
            return func(*args, **kwargs)
        aether_tick.asyncio.to_thread = mock_to_thread
        
        try:
            extractor = MagicMock()
            extractor.workspace = tmp_path  # Crucial: aether_tick uses this to create fd_manager
            extractor.inflight = {}
            extractor.poll_all = MagicMock()
            extractor._count_inflight_dispatched = MagicMock(return_value=1)
            extractor.refresh_external_signals = MagicMock(return_value=0)
            
            extractor.analytics = MagicMock()
            mock_bt = MagicMock()
            mock_bt.concept_title = "Quantum Break"
            mock_bt.concept_description = "Cool desc"
            # It uses get_breakthroughs(threshold=...)
            extractor.analytics.get_breakthroughs = MagicMock(return_value=[mock_bt])
            
            extractor.pi_agent = MagicMock()
            
            def mock_generate(*args, **kwargs):
                return [{"title": "LLM Novelty 1", "concept": "New concept"}]
                
            extractor.pi_agent.generate_novelty_directions = MagicMock(side_effect=mock_generate)
            
            # Create a real fd_manager so it creates the file
            fd_manager = FutureDirectionsManager(tmp_path)
            fd_manager._directions = []
            
            class MockMemory:
                future_directions = fd_manager
            
            extractor.memory = MockMemory()
            
            await aether_tick._tick_impl(extractor, max_inflight=1, novelty_slots=3)
            
            # aether_tick creates a NEW FutureDirectionsManager instance reading from disk!
            # It wrote it to disk, so we can re-read it
            fd_manager2 = FutureDirectionsManager(tmp_path)
            
            titles = [d.title for d in fd_manager2._directions]
            assert "LLM Novelty 1" in titles
        finally:
            aether_tick.asyncio.to_thread = original_to_thread

    asyncio.run(run_test())

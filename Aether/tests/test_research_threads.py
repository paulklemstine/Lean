"""TDD tests for the Research Thread system.

Run with: pytest tests/test_research_threads.py -v
"""
import json
import pytest
from pathlib import Path

from research_threads import ResearchThread, ResearchThreadManager


@pytest.fixture
def tmp_workspace(tmp_path):
    ws = tmp_path / "aether_test"
    ws.mkdir()
    return ws


@pytest.fixture
def manager(tmp_workspace):
    return ResearchThreadManager(tmp_workspace)


# ── Test: Thread creation ──

class TestThreadCreation:
    def test_start_thread(self, manager):
        thread = manager.start_thread(root_direction_id="fd_0001", job_id="job_a")
        assert thread.thread_id.startswith("th_")
        assert thread.root_direction_id == "fd_0001"
        assert thread.cycles == ["job_a"]
        assert thread.status == "active"
        assert thread.last_progress_cycle == 0

    def test_persistence(self, tmp_workspace):
        m1 = ResearchThreadManager(tmp_workspace)
        t1 = m1.start_thread("fd_0001", "job_a")
        m1.append_cycle(t1.thread_id, "job_b", "theorem foo : 1 = 1 := by rfl\nlemma bar : 2 = 2 := by rfl")

        m2 = ResearchThreadManager(tmp_workspace)
        loaded = m2.get_thread(t1.thread_id)
        assert loaded is not None
        assert loaded.root_direction_id == "fd_0001"
        assert loaded.cycles == ["job_a", "job_b"]
        assert loaded.last_progress_cycle == 1


# ── Test: Knowledge delta detection ──

class TestKnowledgeDelta:
    def test_delta_on_new_theorem(self, manager):
        t = manager.start_thread("fd_0001", "job_1")
        has_delta = manager.append_cycle(t.thread_id, "job_2", "theorem new_result : True := by trivial")
        assert has_delta is True
        assert t.last_progress_cycle == 1

    def test_no_delta_on_same_idents(self, manager):
        t = manager.start_thread("fd_0001", "job_1")
        lean = "theorem same : 1 = 1 := by rfl\nlemma helper : 2 = 2 := by rfl"
        manager.append_cycle(t.thread_id, "job_2", lean)
        manager.append_cycle(t.thread_id, "job_3", lean)
        assert t.last_progress_cycle == 1

    def test_delta_on_new_definition(self, manager):
        t = manager.start_thread("fd_0001", "job_1")
        manager.append_cycle(t.thread_id, "job_2", "theorem a : True := trivial")
        has_delta = manager.append_cycle(t.thread_id, "job_3", "def new_struct := Nat\nlemma about_it : new_struct = Nat := rfl")
        assert has_delta is True


# ── Test: Stagnation termination ──

class TestStagnationTermination:
    def test_auto_terminate_after_four_stagnant_cycles(self, manager):
        t = manager.start_thread("fd_0001", "job_0")
        lean = "theorem same : True := trivial"
        # First cycle after start produces a delta, then four stagnant cycles kill it.
        manager.append_cycle(t.thread_id, "job_1", lean)
        manager.append_cycle(t.thread_id, "job_2", lean)
        manager.append_cycle(t.thread_id, "job_3", lean)
        manager.append_cycle(t.thread_id, "job_4", lean)
        manager.append_cycle(t.thread_id, "job_5", lean)
        assert manager.get_thread(t.thread_id).status == "terminated"
        assert manager.get_thread(t.thread_id).termination_reason == "stagnation"

    def test_progress_resets_stagnation_counter(self, manager):
        t = manager.start_thread("fd_0001", "job_0")
        base = "theorem same : True := trivial"
        manager.append_cycle(t.thread_id, "job_1", base)
        manager.append_cycle(t.thread_id, "job_2", base)
        manager.append_cycle(t.thread_id, "job_3", base)
        # Progress here prevents termination on next cycle
        manager.append_cycle(t.thread_id, "job_4", "theorem fresh : False := by trivial")
        manager.append_cycle(t.thread_id, "job_5", base)
        manager.append_cycle(t.thread_id, "job_6", base)
        manager.append_cycle(t.thread_id, "job_7", base)
        manager.append_cycle(t.thread_id, "job_8", base)
        assert manager.get_thread(t.thread_id).status == "terminated"
        assert t.last_progress_cycle == 4


# ── Test: Thread lifecycle helpers ──

class TestLifecycleHelpers:
    def test_get_active_threads(self, manager):
        t1 = manager.start_thread("fd_0001", "job_a")
        t2 = manager.start_thread("fd_0002", "job_b")
        manager.terminate_thread(t1.thread_id, "test")
        active = manager.get_active_threads()
        assert len(active) == 1
        assert active[0].thread_id == t2.thread_id

    def test_complete_thread(self, manager):
        t = manager.start_thread("fd_0001", "job_a")
        manager.complete_thread(t.thread_id)
        assert manager.get_thread(t.thread_id).status == "completed"

    def test_terminate_thread(self, manager):
        t = manager.start_thread("fd_0001", "job_a")
        manager.terminate_thread(t.thread_id, "novelty_failure")
        assert manager.get_thread(t.thread_id).status == "terminated"
        assert manager.get_thread(t.thread_id).termination_reason == "novelty_failure"

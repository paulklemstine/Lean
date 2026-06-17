"""TDD tests for the Thread Promise Critic.

Run with: pytest tests/test_thread_promise_critic.py -v
"""
import json
import pytest

from research_threads import ResearchThreadManager
from specialized_critics import ThreadPromiseCritic


class FakePiAgent:
    def __init__(self, response):
        self.response = response

    def _call_ollama(self, system: str, user: str, timeout=None) -> str:
        return self.response


def make_thread(tmp_path):
    mgr = ResearchThreadManager(tmp_path / "ws")
    t = mgr.start_thread("fd_0001", "job_a")
    mgr.append_cycle(t.thread_id, "job_b", "theorem fresh : True := trivial")
    return mgr, t


class TestThreadPromiseCritic:
    def test_recommendation_parsed(self, tmp_path):
        agent = FakePiAgent(json.dumps({"promise_score": 0.7, "recommendation": "continue", "rationale": "promising"}))
        critic = ThreadPromiseCritic(agent)
        mgr, t = make_thread(tmp_path)
        result = critic.evaluate(t, cycle_quality_scores=[0.4, 0.7])
        assert result["promise_score"] == pytest.approx(0.7, 0.001)
        assert result["recommendation"] == "continue"

    def test_default_to_continue_on_bad_json(self, tmp_path):
        agent = FakePiAgent("not json")
        critic = ThreadPromiseCritic(agent)
        mgr, t = make_thread(tmp_path)
        result = critic.evaluate(t, cycle_quality_scores=[0.4, 0.7])
        assert result["recommendation"] in ("continue", "terminate")
        assert 0.0 <= result["promise_score"] <= 1.0

    def test_clamp_score(self, tmp_path):
        agent = FakePiAgent(json.dumps({"promise_score": 1.5, "recommendation": "terminate"}))
        critic = ThreadPromiseCritic(agent)
        mgr, t = make_thread(tmp_path)
        result = critic.evaluate(t, cycle_quality_scores=[0.4, 0.7])
        assert result["promise_score"] == pytest.approx(1.0, 0.001)

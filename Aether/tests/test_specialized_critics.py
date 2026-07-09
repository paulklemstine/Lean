"""TDD tests for specialized Phase A critics.

Run with: pytest tests/test_specialized_critics.py -v
"""
import json
import pytest
from pathlib import Path

from specialized_critics import SpecializedCritic, CriticScores


class FakePiAgent:
    """Mock PiAgent that returns predetermined JSON responses."""
    def __init__(self, response):
        self.response = response

    def _call_ollama(self, system: str, user: str, timeout=None) -> str:
        return self.response


@pytest.fixture
def fake_pi_agent():
    return FakePiAgent(json.dumps({
        "correctness": {"score": 0.9, "rationale": "Compiles, no sorry."},
        "novelty": {"score": 0.7, "rationale": "Likely new."},
        "depth": {"score": 0.8, "rationale": "Deep proof."},
        "presentation": {"score": 0.6, "rationale": "Okay prose."}
    }))


class TestCriticParsing:
    def test_parse_json_scores(self, fake_pi_agent):
        critic = SpecializedCritic(fake_pi_agent)
        scores = critic.evaluate(lean_source="theorem a : True := trivial", concept_title="Test")
        assert isinstance(scores, CriticScores)
        assert scores.correctness == 0.9
        assert scores.novelty == 0.7
        assert scores.depth == 0.8
        assert scores.presentation == 0.6

    def test_clamp_out_of_range_scores(self):
        agent = FakePiAgent(json.dumps({
            "correctness": {"score": 1.5, "rationale": ""},
            "novelty": {"score": -0.2, "rationale": ""},
            "depth": {"score": 0.5, "rationale": ""},
            "presentation": {"score": 0.5, "rationale": ""}
        }))
        critic = SpecializedCritic(agent)
        scores = critic.evaluate(lean_source="", concept_title="Test")
        assert scores.correctness == 1.0
        assert scores.novelty == 0.0
        assert scores.depth == 0.5

    def test_fallback_when_no_json(self):
        agent = FakePiAgent("not json")
        critic = SpecializedCritic(agent)
        scores = critic.evaluate(lean_source="", concept_title="Test")
        assert scores.correctness == 0.5
        assert scores.novelty == 0.5


class TestCriticAggregation:
    def test_aggregate_score(self):
        scores = CriticScores(
            correctness=1.0,
            novelty=0.5,
            depth=0.5,
            presentation=0.5,
            rationale={},
        )
        assert pytest.approx(scores.aggregate(), 0.001) == (
            0.5 * 0.35 + 0.5 * 0.45 + 0.5 * 0.20
        )

    def test_correctness_gate(self):
        scores = CriticScores(
            correctness=0.0,
            novelty=1.0,
            depth=1.0,
            presentation=1.0,
            rationale={},
        )
        assert scores.aggregate() == 0.0

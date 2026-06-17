"""TDD tests for specialized Phase A critics.

Run with: pytest tests/test_specialized_critics.py -v
"""
import json
import pytest
from pathlib import Path

from specialized_critics import SpecializedCritic, CriticScores


class FakePiAgent:
    """Mock PiAgent that returns predetermined JSON responses."""
    def __init__(self, responses):
        self.responses = responses
        self._idx = 0

    def _call_ollama(self, system: str, user: str, timeout=None) -> str:
        response = self.responses[self._idx % len(self.responses)]
        self._idx += 1
        return response


@pytest.fixture
def fake_pi_agent():
    return FakePiAgent([
        json.dumps({"score": 0.9, "rationale": "Compiles, no sorry."}),
        json.dumps({"score": 0.7, "rationale": "Likely new."}),
        json.dumps({"score": 0.8, "rationale": "Deep proof."}),
        json.dumps({"score": 0.6, "rationale": "Okay prose."}),
    ])


class TestCriticParsing:
    def test_parse_json_scores(self, fake_pi_agent):
        critic = SpecializedCritic(fake_pi_agent)
        scores = critic.evaluate(lean_source="theorem a : True := trivial", concept_title="Test")
        assert isinstance(scores, CriticScores)
        assert 0.0 <= scores.correctness <= 1.0
        assert 0.0 <= scores.novelty <= 1.0
        assert 0.0 <= scores.depth <= 1.0
        assert 0.0 <= scores.presentation <= 1.0

    def test_clamp_out_of_range_scores(self):
        agent = FakePiAgent([
            json.dumps({"score": 1.5}),
            json.dumps({"score": -0.2}),
            json.dumps({"score": 0.5}),
            json.dumps({"score": 0.5}),
        ])
        critic = SpecializedCritic(agent)
        scores = critic.evaluate(lean_source="", concept_title="Test")
        assert scores.correctness == 1.0
        assert scores.novelty == 0.0
        assert scores.depth == 0.5

    def test_fallback_when_no_json(self):
        agent = FakePiAgent(["not json"] * 4)
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

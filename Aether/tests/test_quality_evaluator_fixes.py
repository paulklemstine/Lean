#!/usr/bin/env python3
"""Tests for quality_evaluator fixes: result_fields, artifact_richness, actionability."""

import pytest
from pathlib import Path

from quality_evaluator import QualityEvaluator, QualityScore


@pytest.fixture
def qe():
    """QualityEvaluator without Pi-Agent (local-only scoring)."""
    return QualityEvaluator(pi_agent=None)


class TestArtifactRichnessWithResultFields:
    def test_all_artifacts_in_fields(self, qe):
        """All 4 artifact types present in result_fields → full score."""
        result_fields = {
            "result_paper": "x" * 200,
            "result_demo": "x" * 200,
            "result_discussion": "x" * 200,
            "result_future_directions": "x" * 200,
        }
        score = qe._eval_artifacts(None, result_fields)
        assert score >= 0.9  # All 4 artifacts contribute

    def test_partial_artifacts(self, qe):
        """Only 2 of 4 artifact types → partial score."""
        result_fields = {
            "result_demo": "x" * 200,
            "result_future_directions": "x" * 200,
        }
        score = qe._eval_artifacts(None, result_fields)
        assert 0.3 <= score <= 0.7  # 2 of 4 artifacts

    def test_no_artifacts(self, qe):
        """No result_fields and no result_dir → base score."""
        score = qe._eval_artifacts(None, None)
        assert score == 0.1

    def test_empty_fields(self, qe):
        """Empty strings in result_fields → not counted."""
        result_fields = {
            "result_paper": "",
            "result_demo": "",
        }
        score = qe._eval_artifacts(None, result_fields)
        assert score == 0.1  # Nothing substantial

    def test_short_content(self, qe):
        """Short content (<100 chars) → half weight."""
        result_fields = {
            "result_paper": "x" * 50,  # Between 20 and 100
        }
        score = qe._eval_artifacts(None, result_fields)
        assert score > 0.0  # Gets half weight
        assert score < 0.3   # Not full weight

    def test_filesystem_takes_priority(self, qe, tmp_path):
        """If both filesystem and result_fields exist, filesystem wins."""
        # Create a real RESEARCH_REPORT.md on disk
        report = tmp_path / "RESEARCH_REPORT.md"
        report.write_text("x" * 200)

        result_fields = {
            "result_paper": "y" * 200,  # Different content
        }
        score = qe._eval_artifacts(tmp_path, result_fields)
        # Should find the filesystem file
        assert score >= 0.25  # At least the report

    def test_fallback_from_filesystem_to_fields(self, qe, tmp_path):
        """If filesystem doesn't have the file, result_fields provides fallback."""
        # Empty tmp_path — no RESEARCH_REPORT.md on disk
        result_fields = {
            "result_paper": "x" * 200,
            "result_future_directions": "x" * 200,
        }
        score = qe._eval_artifacts(tmp_path, result_fields)
        assert score >= 0.4  # Gets both from result_fields


class TestActionabilityWithResultFields:
    def test_actionability_from_future_directions_field(self, qe):
        """Actionability can be computed from result_future_directions field."""
        fd_text = (
            "# Future Directions\n\n"
            "1. Prove that tropical semirings satisfy the data processing inequality\n"
            "2. Show that Berggren trees have logarithmic depth\n"
            "3. Establish a tropical central limit theorem\n\n"
            "We conjecture that the tropical Shannon theorem holds."
        )
        result_fields = {"result_future_directions": fd_text}
        score = qe._eval_actionability(None, result_fields)
        assert score > 0.1  # Better than empty

    def test_actionability_nothing_available(self, qe):
        """No future directions at all → minimum score."""
        score = qe._eval_actionability(None, None)
        assert score == 0.1


class TestLLMDimensionsDegenerateDetection:
    def test_degenerate_scores_rejected(self, qe):
        """Without pi_agent, heuristic fallback is used for importance/usefulness/applications."""
        score = qe.evaluate(
            lean_source="theorem foo : 1 + 1 = 2 := by omega",
            concept_title="Test",
            result_fields={"result_paper": "x" * 200},
        )
        # Without pi_agent, heuristic fallback is computed from proof_depth/novelty/cross_domain
        # These are non-zero values derived from the lean source
        assert score.importance > 0.0
        assert score.usefulness > 0.0
        assert score.applications > 0.0


class TestFullEvaluateWithResultFields:
    def test_evaluate_passes_result_fields(self, qe):
        """Full evaluate() passes result_fields to sub-evaluators."""
        result_fields = {
            "result_paper": "x" * 200,
            "result_demo": "x" * 200,
            "result_future_directions": "x" * 200,
        }
        score = qe.evaluate(
            lean_source="theorem foo : 1 + 1 = 2 := by omega\nlemma bar : 2 + 2 = 4 := by omega",
            concept_title="Test Theorem",
            result_fields=result_fields,
            phase="B",
        )
        # artifact_richness should be > 0.1 (the old default)
        assert score.artifact_richness > 0.1
        # actionability should be > 0.1
        assert score.actionability > 0.1


class TestAdversarialEvaluateDomains:
    def test_adversarial_evaluate_no_agent_respects_domains(self, qe):
        """Without pi_agent, adversarial_evaluate uses primary_score with domains."""
        score = QualityScore(proof_depth=1.0, novelty=0.0)
        unweighted = qe.adversarial_evaluate(
            lean_source="",
            primary_score=score,
            domains=None,
        )
        weighted = qe.adversarial_evaluate(
            lean_source="",
            primary_score=score,
            domains=["NumberTheory"],
        )
        assert weighted["primary_composite"] != unweighted["primary_composite"]
        assert weighted["primary_composite"] == score.composite_with_domains(["NumberTheory"])

    def test_adversarial_evaluate_with_agent_respects_domains(self, monkeypatch):
        """With pi_agent, adversarial_evaluate, critic, and tiebreaker use domain-weighted composite."""
        class MockPiAgent:
            def _call_ollama(self, system: str, user: str, timeout=None, category="other") -> str:
                # Return scores that yield different composites depending on domains
                import json
                return json.dumps({
                    "proof_depth": 1.0,
                    "novelty": 0.0,
                    "cross_domain": 0.0,
                    "artifact_richness": 0.0,
                    "actionability": 0.0,
                    "importance": 0.0,
                    "usefulness": 0.0,
                    "applications": 0.0,
                    "catalog_anchoring": 0.0,
                })
            def _parse_json_response(self, raw: str):
                import json
                return json.loads(raw)

        agent = MockPiAgent()
        qe_with_agent = QualityEvaluator(pi_agent=agent)
        primary = QualityScore(proof_depth=0.5, novelty=0.5)

        # 1. Unweighted run
        unweighted_res = qe_with_agent.adversarial_evaluate(
            lean_source="theorem foo : True := trivial",
            primary_score=primary,
            domains=None,
        )
        # 2. Weighted run (with NumberTheory domain)
        weighted_res = qe_with_agent.adversarial_evaluate(
            lean_source="theorem foo : True := trivial",
            primary_score=primary,
            domains=["NumberTheory"],
        )

        # Verify that primary_composite is domain-weighted
        assert unweighted_res["primary_composite"] == round(primary.composite_with_domains(None), 4)
        assert weighted_res["primary_composite"] == round(primary.composite_with_domains(["NumberTheory"]), 4)
        assert unweighted_res["primary_composite"] != weighted_res["primary_composite"]

        # Verify that adversarial_composite is domain-weighted
        # The mocked critic returns proof_depth=1.0, novelty=0.0.
        critic_score = QualityScore(proof_depth=1.0)
        assert unweighted_res["adversarial_composite"] == round(critic_score.composite_with_domains(None), 4)
        assert weighted_res["adversarial_composite"] == round(critic_score.composite_with_domains(["NumberTheory"]), 4)
        assert unweighted_res["adversarial_composite"] != weighted_res["adversarial_composite"]


class TestResearchJobFilesIntegrated:
    def test_default_files_integrated(self):
        """New ResearchJob defaults files_integrated to 0."""
        from knowledge_extractor import ResearchJob
        job = ResearchJob(job_id="test", cycle_n=1, concept=None, prompt="")
        assert job.files_integrated == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
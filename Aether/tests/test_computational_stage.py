"""TDD tests for the computational experimentation stage.

Run with: pytest tests/test_computational_stage.py -v
"""
import pytest

from computational_stage import ComputationalStage


class TestSandboxExecution:
    def test_run_simple_python(self):
        stage = ComputationalStage(timeout=10)
        result = stage.run("x = [i*i for i in range(5)]\nprint(x)")
        assert result["success"] is True
        assert "[0, 1, 4, 9, 16]" in result["stdout"]

    def test_run_with_error(self):
        stage = ComputationalStage(timeout=10)
        result = stage.run("1 / 0")
        assert result["success"] is False
        assert "ZeroDivisionError" in result["stderr"]

    def test_timeout(self):
        stage = ComputationalStage(timeout=1)
        result = stage.run("import time\ntime.sleep(5)")
        assert result["success"] is False
        assert "timeout" in result["stderr"].lower()


class TestEvidencePrompt:
    def test_prompt_mentions_evidence(self):
        stage = ComputationalStage()
        prompt = stage.augment_prompt("Prove Goldbach.")
        assert "ComputationalEvidence" in prompt or "computational evidence" in prompt.lower()

    def test_prompt_allows_skip_with_justification(self):
        stage = ComputationalStage()
        prompt = stage.augment_prompt("Prove Goldbach.")
        assert "justify" in prompt.lower() or "skip" in prompt.lower()

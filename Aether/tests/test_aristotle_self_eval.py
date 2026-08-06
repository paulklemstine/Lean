#!/usr/bin/env python3
"""Unit tests for Aristotle Phase A self-evaluation and quality scoring."""

import json
import pytest
from pathlib import Path
from quality_evaluator import QualityEvaluator, QualityScore


def test_extract_self_evaluation_from_json_file(tmp_path):
    """Test extracting Aristotle self-evaluation from SELF_EVALUATION.json file."""
    eval_file = tmp_path / "SELF_EVALUATION.json"
    eval_data = {
        "quality_score": 0.85,
        "proof_depth": 0.90,
        "novelty": 0.80,
        "grade": "world_class",
        "rationale": "Proved non-trivial bounds for tropical matrix semirings."
    }
    eval_file.write_text(json.dumps(eval_data), encoding="utf-8")

    qeval = QualityEvaluator()
    res = qeval.extract_self_evaluation(result_dir=tmp_path)

    assert res is not None
    assert res["quality_score"] == 0.85
    assert res["proof_depth"] == 0.90
    assert res["novelty"] == 0.80
    assert res["grade"] == "world_class"
    assert res["source"] == "SELF_EVALUATION.json"


def test_extract_self_evaluation_from_result_fields():
    """Test extracting self-evaluation from result_fields dict."""
    eval_data = {
        "quality_score": 0.65,
        "proof_depth": 0.70,
        "novelty": 0.60,
        "grade": "substantial",
        "rationale": "Solid Lean 4 formalization with minor generalizations."
    }
    qeval = QualityEvaluator()
    res = qeval.extract_self_evaluation(result_fields={"SELF_EVALUATION.json": json.dumps(eval_data)})

    assert res is not None
    assert res["quality_score"] == 0.65
    assert res["grade"] == "substantial"
    assert res["source"] == "result_fields"


def test_evaluate_with_self_evaluation(tmp_path):
    """Test QualityEvaluator.evaluate adopting self-evaluation metrics for Phase A."""
    eval_file = tmp_path / "SELF_EVALUATION.json"
    eval_data = {
        "quality_score": 0.88,
        "proof_depth": 0.92,
        "novelty": 0.85,
        "grade": "world_class",
        "rationale": "High rigor proof without sorries."
    }
    eval_file.write_text(json.dumps(eval_data), encoding="utf-8")

    lean_code = """
    theorem foo (n : Nat) : n + 0 = n := by
      induction n with
      | zero => rfl
      | succ n ih => rw [Nat.add_zero]
    """

    qeval = QualityEvaluator()
    score = qeval.evaluate(
        lean_source=lean_code,
        result_dir=tmp_path,
        phase="A",
    )

    assert score.proof_depth == 0.92
    assert score.novelty == 0.85
    assert score.importance == 0.88
    assert score.composite >= 0.70


def test_evaluate_sorry_penalty(tmp_path):
    """Test that unresolved sorries apply a safety penalty even with self-evaluation."""
    eval_file = tmp_path / "SELF_EVALUATION.json"
    eval_data = {
        "quality_score": 0.90,
        "proof_depth": 0.90,
        "novelty": 0.90,
        "grade": "world_class",
    }
    eval_file.write_text(json.dumps(eval_data), encoding="utf-8")

    lean_code_with_sorry = """
    theorem foo (n : Nat) : n = n := by sorry
    """

    qeval = QualityEvaluator()
    score = qeval.evaluate(
        lean_source=lean_code_with_sorry,
        result_dir=tmp_path,
        phase="A",
    )

    # With 1 sorry, penalty is 1 - 0.2*1 = 0.8
    assert score.proof_depth < 0.90
    assert score.importance < 0.90


def test_evaluate_fallback_when_no_self_eval():
    """Test fallback to standard structural evaluation when SELF_EVALUATION.json is missing."""
    lean_code = """
    theorem foo (n : Nat) : n + 0 = n := by
      induction n with
      | zero => rfl
      | succ n ih => rw [Nat.add_zero]
    """
    qeval = QualityEvaluator()
    score = qeval.evaluate(lean_source=lean_code, phase="A")

    assert score.proof_depth > 0.0
    assert score.composite > 0.0

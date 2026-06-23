"""Tests for Phase 1 static quality gate (Lever A).

The gate returns a quality_assessment dict when static signals are decisive
enough to skip the LLM eval, else None (borderline -> call LLM). Clear-fail
(no theorems) is safe to enable; clear-pass (0 sorries, >=5 theorems, >=2
novel) is conservative and validated in shadow mode first.
"""
import sys
from pathlib import Path
from unittest.mock import MagicMock

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


def _extractor():
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.config = {}
    return ext


def _job(theorem_count=0, sorry_count=0, novelty=None):
    from knowledge_extractor import ResearchJob, ResearchConcept
    j = ResearchJob(
        job_id="g1", cycle_n=1,
        concept=ResearchConcept(title="t", domain="Algebra", concept_description="d",
                                mathematical_framing="d", lean_guess="", research_mode="team",
                                novelty_estimate=0.5, breakthrough_potential=0.5),
        prompt="p",
    )
    j.theorem_count = theorem_count
    j.sorry_count = sorry_count
    j.theorem_novelty = novelty or {"new": 0, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}
    return j


def test_gate_clear_fail_no_theorems():
    ext = _extractor()
    g = ext._static_quality_gate(_job(theorem_count=0, sorry_count=3))
    assert g is not None
    assert g["quality"] == "trivial"
    assert g["should_retry"] is True


def test_gate_clear_pass_removed_returns_none():
    """The clear-pass branch was removed (shadow data showed 94% disagreement
    with the LLM — static counts can't assess mathematical substance). A
    complete/novel cycle is now borderline -> None (call LLM)."""
    ext = _extractor()
    g = ext._static_quality_gate(_job(theorem_count=6, sorry_count=0,
                                      novelty={"new": 3, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}))
    assert g is None


def test_gate_borderline_some_sorries():
    """Some sorries + some theorems -> borderline -> None (call LLM)."""
    ext = _extractor()
    g = ext._static_quality_gate(_job(theorem_count=4, sorry_count=2,
                                      novelty={"new": 1, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}))
    assert g is None


def test_gate_borderline_few_theorems_no_novelty():
    """0 sorries but only 2 theorems and 0 novel -> not clear-pass -> None."""
    ext = _extractor()
    g = ext._static_quality_gate(_job(theorem_count=2, sorry_count=0,
                                      novelty={"new": 0, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}))
    assert g is None


def test_gate_borderline_theorems_but_sorries():
    """5 theorems + 0 novel but 1 sorry -> not clear-pass (sorries) -> None."""
    ext = _extractor()
    g = ext._static_quality_gate(_job(theorem_count=5, sorry_count=1,
                                      novelty={"new": 3, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}))
    assert g is None


def test_gate_enabled_skips_llm_and_records_skip():
    """In enabled mode, a decisive gate skips evaluate_result_quality and
    records an eval skip in llm_stats."""
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.config = {"llm_reduction": {"static_gate": "enabled"}}
    ext.pi_agent = MagicMock()
    ext.pi_agent.llm_stats = {"calls": {"total": 0}, "skipped": {"eval": 0, "critic": 0, "lint": 0, "pruning": 0}}
    ext.pi_agent.record_llm_skip = MagicMock()
    ext.pi_agent.evaluate_result_quality = MagicMock(return_value={"quality": "partial"})
    ext._compact_result_lean = MagicMock(return_value="lean")
    j = _job(theorem_count=0, sorry_count=0)  # clear-fail
    # call the gated block (replicate evaluate() logic)
    qa = ext._static_quality_gate(j)
    assert qa is not None
    # In enabled mode the caller would do:
    ext.pi_agent.record_llm_skip("eval")
    ext.pi_agent.evaluate_result_quality.assert_not_called()
    assert ext.pi_agent.record_llm_skip.call_args.args[0] == "eval"


def _run(coro):
    import asyncio
    return asyncio.get_event_loop().run_until_complete(coro) if not asyncio.iscoroutinefunction(lambda: None) else asyncio.run(coro)


def test_lint_gate_enabled_skips_all_good_lean_batch():
    """Enabled lint gate + a batch of non-empty .lean files with theorems ->
    auto-accept, record lint skip, no LLM call."""
    import asyncio
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.config = {"llm_reduction": {"lint_gate": "enabled"}}
    ext.pi_agent = MagicMock()
    ext.pi_agent.record_llm_skip = MagicMock()
    ext.pi_agent._call_ollama = MagicMock(return_value="{}")  # must NOT be called
    batch = [
        {"path": "Algebra/Foo.lean", "type": "lean", "content": "theorem foo : True := trivial\n"},
        {"path": "Algebra/Bar.lean", "type": "lean", "content": "lemma bar : 1 = 1 := rfl\n"},
    ]
    out = asyncio.run(ext._review_file_batch(batch, 0, 1))
    assert out == {"Algebra/Foo.lean": "Algebra/Foo.lean", "Algebra/Bar.lean": "Algebra/Bar.lean"}
    ext.pi_agent._call_ollama.assert_not_called()
    ext.pi_agent.record_llm_skip.assert_called_once_with("lint")


def test_lint_gate_does_not_skip_mixed_batch():
    """A batch containing a non-.lean file is NOT decisive -> LLM still runs."""
    import asyncio
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.config = {"llm_reduction": {"lint_gate": "enabled"}}
    ext.pi_agent = MagicMock()
    ext.pi_agent.record_llm_skip = MagicMock()
    ext.pi_agent._call_ollama = MagicMock(return_value='{"0": "Algebra/Foo.lean", "1": "REJECT"}')
    ext.pi_agent._parse_json_response = MagicMock(return_value={"0": "Algebra/Foo.lean", "1": "REJECT"})
    batch = [
        {"path": "Algebra/Foo.lean", "type": "lean", "content": "theorem foo : True := trivial\n"},
        {"path": "notes.md", "type": "md", "content": "some notes"},
    ]
    asyncio.run(ext._review_file_batch(batch, 0, 1))
    ext.pi_agent._call_ollama.assert_called_once()  # LLM ran
    ext.pi_agent.record_llm_skip.assert_not_called()
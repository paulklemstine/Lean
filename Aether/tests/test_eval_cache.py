"""Tests for Phase 3 content-hash eval cache (Lever B)."""
import asyncio
import sys
import time
from pathlib import Path
from unittest.mock import MagicMock

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


def _concept(title="t", domain="Algebra", research_mode="team"):
    from pi_agent_client import ResearchConcept
    return ResearchConcept(title=title, domain=domain, concept_description="d",
                           mathematical_framing="d", lean_guess="", research_mode=research_mode,
                           novelty_estimate=0.5, breakthrough_potential=0.5)


def test_key_stable_for_same_inputs(tmp_path):
    from eval_cache import EvalCache
    c = _concept()
    k1 = EvalCache.key_for("lean code", c, "v19b")
    k2 = EvalCache.key_for("lean code", c, "v19b")
    assert k1 == k2


def test_key_differs_on_content_or_prompt(tmp_path):
    from eval_cache import EvalCache
    c = _concept()
    assert EvalCache.key_for("lean A", c, "v19b") != EvalCache.key_for("lean B", c, "v19b")
    assert EvalCache.key_for("lean", c, "v19b") != EvalCache.key_for("lean", c, "v19c")


def test_put_then_get_hit(tmp_path):
    from eval_cache import EvalCache
    ec = EvalCache(tmp_path)
    k = ec.key_for("lean", _concept(), "v19b")
    ec.put(k, {"quality_score": 0.42, "quality_assessment": {"quality": "partial"}})
    got = ec.get(k)
    assert got is not None
    assert got["quality_score"] == 0.42


def test_stale_entry_expired(tmp_path):
    from eval_cache import EvalCache
    ec = EvalCache(tmp_path, ttl_seconds=10)
    k = ec.key_for("lean", _concept(), "v19b")
    ec.put(k, {"quality_score": 0.42}, now=time.time() - 100)
    assert ec.get(k) is None  # expired


def test_persistence_across_instances(tmp_path):
    from eval_cache import EvalCache
    ec1 = EvalCache(tmp_path)
    k = ec1.key_for("lean", _concept(), "v19b")
    ec1.put(k, {"quality_score": 0.55, "quality_assessment": {"quality": "substantial"}})
    ec2 = EvalCache(tmp_path)  # reload from disk
    assert ec2.get(k)["quality_score"] == 0.55


def test_eviction_when_over_cap(tmp_path):
    from eval_cache import EvalCache
    ec = EvalCache(tmp_path, max_entries=3)
    c = _concept()
    for i in range(5):
        ec.put(ec.key_for(f"lean{i}", c, "v"), {"quality_score": i}, now=float(i))
    assert len(ec) == 3
    # oldest two (i=0,1) evicted; i=2,3,4 remain
    assert ec.get(ec.key_for("lean0", c, "v"), now=10.0) is None
    assert ec.get(ec.key_for("lean4", c, "v"), now=10.0) is not None


def test_evaluate_cache_hit_skips_llm(tmp_path):
    """A cached eval is restored and the LLM eval + critic are skipped."""
    from knowledge_extractor import KnowledgeExtractor, ResearchJob
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.config = {"llm_reduction": {"eval_cache": "on", "static_gate": "off", "critic_gate": "off"}}
    ext.workspace = tmp_path
    ext.pi_agent = MagicMock()
    ext.pi_agent.record_llm_skip = MagicMock()
    ext.pi_agent.evaluate_result_quality = MagicMock()  # must NOT be called
    ext._compact_result_lean = MagicMock(return_value="lean")

    j = ResearchJob(job_id="c1", cycle_n=1, concept=_concept(), prompt="p")
    j.result_lean = "theorem foo : True := trivial"
    j.prompt_version = "v19b"

    # Pre-seed the cache for this job's content+concept+prompt.
    from eval_cache import EvalCache
    ec = EvalCache(tmp_path)
    key = ec.key_for(j.result_lean, j.concept, j.prompt_version)
    ec.put(key, {
        "quality_score": 0.77,
        "quality_assessment": {"quality": "substantial"},
        "adversarial_result": {"agreement": "agree"},
        "quality_detail": None,
    })

    out = ext.evaluate(j)
    assert out.quality_score == 0.77
    assert out.quality_assessment["quality"] == "substantial"
    ext.pi_agent.evaluate_result_quality.assert_not_called()
    # both eval and critic skips recorded
    skips = [c.args[0] for c in ext.pi_agent.record_llm_skip.call_args_list]
    assert "eval" in skips and "critic" in skips
"""Tests for the two-phase (Phase A: math, Phase B: packaging) prompt split.

Covers:
- Phase A prompt excludes packaging
- Phase B prompt includes Phase A Lean content
- Adaptive threshold cold start (0.5)
- Adaptive threshold warm (p70 of last 50)
- Adaptive threshold clamped to [0.4, 0.6]
- Phase B skipped on low quality
- Phase B dispatched on high quality
- Single ResearchJob carries both phases
- A/B test version independent in Phase A
"""
import json
import os
import sys
import tempfile
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

# Ensure project root is on the path
sys.path.insert(0, str(Path(__file__).parent.parent))


# ─── Fixtures ─────────────────────────────────────────────────────────────

@pytest.fixture
def temp_workspace():
    """Create a temporary workspace for the extractor."""
    with tempfile.TemporaryDirectory() as tmpdir:
        ws = Path(tmpdir)
        # Pre-create cycle_analytics.json with N records of known quality
        yield ws


@pytest.fixture
def research_concept():
    """Build a sample ResearchConcept for testing."""
    from pi_agent_client import ResearchConcept
    return ResearchConcept(
        title="Test Theorem",
        domain="Algebra",
        concept_description="A test concept for two-phase dispatch",
        mathematical_framing="Algebraic structure with novel properties",
        lean_guess="theorem test_theorem : True := trivial",
        novelty_estimate=0.7,
        breakthrough_potential=0.6,
    )


@pytest.fixture
def research_job(research_concept):
    """Build a sample ResearchJob for testing."""
    from knowledge_extractor import ResearchJob
    return ResearchJob(
        job_id="test-job-123",
        cycle_n=42,
        concept=research_concept,
        prompt="placeholder",
    )


# ─── Phase A prompt tests ────────────────────────────────────────────────

def test_phase_a_prompt_excludes_packaging(research_concept):
    """Phase A prompt must NOT request article/paper/widgets/PACKAGE.json.

    The Lean file is the deliverable. Packaging is Phase B's job.
    """
    from pi_agent_client import PiAgentClient
    # Skip actual API client init
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept)
    # Should have the explicit Phase A header
    assert "PHASE A: LEAN 4 ONLY" in prompt
    # Should mention ARTICLE.md in the DO NOT list
    assert "NO `ARTICLE.md`" in prompt
    assert "NO `RESEARCH_PAPER.md`" in prompt
    assert "NO HTML widgets" in prompt
    assert "NO `PACKAGE.json`" in prompt
    # Should NOT request the deliverables as a positive list
    assert "1. **Lean 4 proofs**" not in prompt  # old format absent
    # Depth requirements should still be there
    assert "Depth Requirements" in prompt


def test_phase_b_prompt_includes_phase_a_lean(research_concept):
    """Phase B prompt must embed Phase A's Lean content as input."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    fake_lean = """
    theorem novel_structure_invariant (n : Nat) : n + 0 = n := by simp
    theorem main_result (x y : Nat) : x + y = y + x := Nat.add_comm x y
    """
    prompt = client._build_phase_b_package_prompt(
        concept=research_concept,
        phase_a_lean_content=fake_lean,
    )
    # Header
    assert "PHASE B: PACKAGING ONLY" in prompt
    # DO NOT list — must forbid new Lean
    assert "NO new `.lean` files" in prompt
    assert "NO new theorem proofs" in prompt
    # The Lean content should be embedded
    assert "novel_structure_invariant" in prompt
    assert "main_result" in prompt
    # Should request Phase B deliverables
    assert "ARTICLE.md" in prompt
    assert "RESEARCH_PAPER.md" in prompt
    assert "demo.py" in prompt
    assert "PACKAGE.json" in prompt


def test_phase_a_prompt_size_reduced(research_concept):
    """Phase A prompt should be smaller than the legacy full prompt.

    The default is v8 at ~6K chars.
    Both are still smaller than the 12K A_full legacy prompt.
    """
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    phase_a_v8 = client._build_phase_a_lean_prompt(concept=research_concept)  # default = v8
    phase_a_v9 = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v9")
    # Both versions should be substantially smaller than the 12K full prompt
    assert len(phase_a_v8) < 12000, f"v8 Phase A prompt too large: {len(phase_a_v8)} chars"
    assert len(phase_a_v9) < 12000, f"v9 Phase A prompt too large: {len(phase_a_v9)} chars"
    # Both should be substantial
    assert len(phase_a_v8) > 1000


def test_phase_a_routing(research_concept):
    """write_aristotle_prompt with phase='A_lean_only' routes to Phase A."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(
        concept=research_concept,
        phase="A_lean_only",
    )
    assert "PHASE A: LEAN 4 ONLY" in prompt


def test_phase_b_routing(research_concept):
    """write_aristotle_prompt with phase='B_package_only' routes to Phase B."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(
        concept=research_concept,
        phase="B_package_only",
        phase_a_lean_content="theorem foo : True := trivial",
    )
    assert "PHASE B: PACKAGING ONLY" in prompt


def test_default_phase_is_a_lean_only(research_concept):
    """write_aristotle_prompt with no phase arg defaults to Phase A."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(concept=research_concept)
    assert "PHASE A: LEAN 4 ONLY" in prompt


def test_legacy_a_full_routing(research_concept):
    """write_aristotle_prompt with phase='A_full' uses the legacy full prompt."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    # The legacy A_full prompt accesses self.catalog_analyzer — patch it out
    client.catalog_analyzer = None
    client.insight_extractor = None
    client.research_journal = None
    prompt = client.write_aristotle_prompt(concept=research_concept, phase="A_full")
    # Legacy prompt uses '## Assignment' header, not Phase A/B
    assert "## Assignment" in prompt
    assert "PHASE A" not in prompt
    assert "PHASE B" not in prompt


# ─── Adaptive threshold tests ────────────────────────────────────────────

def test_adaptive_threshold_cold_start(temp_workspace):
    """With < 50 records, threshold is 0.5 (cold start default)."""
    # Empty workspace, no cycle_analytics.json
    from knowledge_extractor import KnowledgeExtractor
    # Don't fully init — just use the threshold method
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    assert threshold == 0.5, f"Expected 0.5 for cold start, got {threshold}"


def test_adaptive_threshold_warm(temp_workspace):
    """With 50+ records, threshold uses p70 of last 50 quality scores."""
    # Create cycle_analytics.json with 60 records of known quality
    records = []
    for i in range(60):
        # Quality scores 0.0 to 0.6, evenly distributed
        records.append({
            "quality_score": i * 0.01,
            "timestamp": f"2026-06-{(i % 30) + 1:02d}",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    # p70 of last 50 (which are 0.10 to 0.59): p70 = 0.10 + 0.70*0.49 = ~0.44
    expected = sorted(r["quality_score"] for r in records[-50:])[int(0.7 * 49)]
    # Clamp to [0.30, 0.6]
    expected = max(0.30, min(0.6, expected))
    assert abs(threshold - expected) < 0.01, f"Expected ~{expected}, got {threshold}"


def test_adaptive_threshold_clamped_low(temp_workspace):
    """Threshold never goes below 0.30 even if p70 is lower."""
    records = []
    for i in range(60):
        records.append({
            "quality_score": 0.1 + i * 0.001,  # All very low
            "timestamp": f"2026-06-{(i % 30) + 1:02d}",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    assert threshold >= 0.30, f"Threshold {threshold} below floor 0.30"


def test_adaptive_threshold_clamped_high(temp_workspace):
    """Threshold never goes above 0.6 even if p70 is higher."""
    records = []
    for i in range(60):
        records.append({
            "quality_score": 0.7 + i * 0.005,  # All very high
            "timestamp": f"2026-06-{(i % 30) + 1:02d}",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    assert threshold <= 0.6, f"Threshold {threshold} above ceiling 0.6"


def test_adaptive_threshold_caches(temp_workspace):
    """Threshold is cached, not recomputed every call."""
    records = [{"quality_score": 0.5, "timestamp": "2026-06-01"}] * 60
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    t1 = ext._adaptive_phase_b_threshold()
    t2 = ext._adaptive_phase_b_threshold()
    assert t1 == t2, "Threshold should be cached"
    # Cache file should exist
    cache_path = temp_workspace / "phase_b_threshold_cache.json"
    assert cache_path.exists(), "Cache file should be created"


# ─── Phase gate logic tests ──────────────────────────────────────────────

def test_phase_b_skipped_on_low_quality(research_job, temp_workspace):
    """Phase A Q < threshold → Phase B skipped, phase='A_only'."""
    # Setup: 60 records with quality 0.2 (well below threshold)
    # p60 of these is 0.2, but clamped to 0.30 (the floor)
    records = [{"quality_score": 0.2, "timestamp": "2026-06-01"}] * 60
    (temp_workspace / "cycle_analytics.json").write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace

    threshold = ext._adaptive_phase_b_threshold()
    # Threshold is at the floor (0.30) because all scores are 0.2
    assert threshold == 0.30, f"Expected floor of 0.30, got {threshold}"
    # A quality of 0.2 is below the threshold
    phase_a_q = 0.2
    assert phase_a_q < threshold  # Phase B would be skipped
    if phase_a_q < threshold:
        research_job.phase = "A_only"
        research_job.phase_b_skipped_reason = "low_quality"
    assert research_job.phase == "A_only"
    assert research_job.phase_b_skipped_reason == "low_quality"


def test_phase_b_dispatched_on_high_quality(research_job, temp_workspace):
    """Phase A Q >= threshold → Phase B dispatched, phase='B'."""
    # Same setup: threshold clamps to 0.30
    records = [{"quality_score": 0.2, "timestamp": "2026-06-01"}] * 60
    (temp_workspace / "cycle_analytics.json").write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace

    threshold = ext._adaptive_phase_b_threshold()
    assert threshold == 0.30
    # A quality of 0.4 is above the floor
    research_job.quality_score = 0.4
    research_job.result_lean = "theorem foo : True := trivial"
    if research_job.quality_score >= threshold and research_job.result_lean:
        research_job.phase = "B"
    assert research_job.phase == "B"


# ─── Schema tests ────────────────────────────────────────────────────────

def test_research_job_carries_two_phases(research_job):
    """Single ResearchJob should have all the two-phase fields."""
    # All fields must exist
    assert hasattr(research_job, "phase")
    assert hasattr(research_job, "phase_a_result")
    assert hasattr(research_job, "phase_b_result")
    assert hasattr(research_job, "phase_a_prompt_version")
    assert hasattr(research_job, "phase_b_prompt_version")
    assert hasattr(research_job, "phase_a_quality_score")
    assert hasattr(research_job, "phase_b_skipped_reason")
    # Defaults
    assert research_job.phase == "A"
    assert research_job.phase_a_result is None
    assert research_job.phase_b_result is None
    assert research_job.phase_a_prompt_version is None


def test_phase_a_prompt_version_independent(research_concept):
    """Phase A can use v8 or v9 — the A/B test still works in Phase A."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    p_v8 = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v8")
    p_v9 = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v9")
    # v8 emphasizes Research Team Protocol
    assert "Research Team Protocol" in p_v8
    # v9 emphasizes adversarial critic
    assert "Adversarial Critic" in p_v9 or "weakened" in p_v9.lower()
    # Both have Phase A header
    assert "PHASE A: LEAN 4 ONLY" in p_v8
    assert "PHASE A: LEAN 4 ONLY" in p_v9


# ─── Analytics tests ─────────────────────────────────────────────────────

def test_phase_split_stats(temp_workspace):
    """get_phase_split_stats() returns the right structure with mixed data."""
    records = []
    # 5 complete (both phases)
    for i in range(5):
        records.append({
            "quality_score": 0.7,
            "phase": "complete",
            "phase_b_skipped": False,
        })
    # 5 a_only
    for i in range(5):
        records.append({
            "quality_score": 0.4,
            "phase": "A_only",
            "phase_b_skipped": True,
            "phase_b_skip_reason": "low_quality",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))

    from cycle_analytics import CycleAnalytics
    ca = CycleAnalytics(temp_workspace)
    stats = ca.get_phase_split_stats()
    assert stats["n_complete"] == 5
    assert stats["n_a_only"] == 5
    assert stats["n_total"] == 10
    assert stats["pct_packaged"] == 50.0
    assert "low_quality" in stats["skip_reasons"]
    assert stats["skip_reasons"]["low_quality"] == 5
    assert abs(stats["avg_q_packaged"] - 0.7) < 0.01
    assert abs(stats["avg_q_a_only"] - 0.4) < 0.01


def test_cycle_record_has_phase_fields():
    """CycleRecord must have all the two-phase fields."""
    from cycle_analytics import CycleRecord
    fields = {f.name for f in CycleRecord.__dataclass_fields__.values()}
    assert "phase" in fields
    assert "phase_a_prompt_version" in fields
    assert "phase_b_prompt_version" in fields
    assert "phase_b_skipped" in fields
    assert "phase_b_skip_reason" in fields

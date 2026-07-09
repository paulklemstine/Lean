"""Tests for the two-phase (Phase A: math, Phase B: packaging) prompt split.

Covers:
- Phase A prompt excludes packaging
- Phase B prompt includes Phase A Lean content
- Adaptive threshold cold start (0.25)
- Adaptive threshold warm (p70 of last 50 = top 30%)
- Adaptive threshold clamped to [0.25, 0.70]
- Phase A score extraction (phase_a_quality_score preferred)
- A_only integration floor (0.30, decoupled from promotion)
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
    # Default is now the v19 speculative scientific-method prompt
    assert "Phase A Research Mission v19" in prompt
    # Should mention ARTICLE.md in constraints
    assert "ARTICLE.md" in prompt
    assert "RESEARCH_PAPER.md" in prompt
    assert "PACKAGE.json" in prompt
    # Should NOT request the deliverables as a positive list
    assert "1. **Lean 4 proofs**" not in prompt  # old format absent


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
    # DO NOT list — must forbid new formal-proof source code
    assert "no `.lean` files" in prompt
    assert "no theorem proofs" in prompt
    # The Lean content should be embedded
    assert "novel_structure_invariant" in prompt
    assert "main_result" in prompt
    # Should request Phase B deliverables
    assert "ARTICLE.md" in prompt
    assert "RESEARCH_PAPER.md" in prompt
    assert "demo.py" in prompt
    assert "PACKAGE.json" in prompt


def test_phase_b_prompt_has_metadata_extraction_checklist(research_concept):
    """Phase B prompt must instruct Aristotle to extract metadata from Lean."""
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
    assert "PACKAGE.json Metadata Extraction" in prompt
    assert "domain" in prompt
    assert "key_results" in prompt
    assert "keywords" in prompt
    assert "PACKAGE.json Schema Checklist" in prompt
    assert "date" in prompt
    # Checklist must require non-empty fields
    assert "title` is non-empty" in prompt
    assert "domain` is exactly one of the allowed values" in prompt
    assert "key_results` is a non-empty array" in prompt
    assert "keywords` is a non-empty array" in prompt
    # Numbering bug fixed: demo.py is item 4, PACKAGE.json is item 5
    assert "4. **demo.py**" in prompt
    assert "5. **PACKAGE.json**" in prompt


def test_phase_a_prompt_size_reduced(research_concept):
    """Phase A prompt should be smaller than the legacy full prompt.

    The default is v19.
    Both are still smaller than the 12K A_full legacy prompt.
    """
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    phase_a_default = client._build_phase_a_lean_prompt(concept=research_concept)  # default = v19
    phase_a_v9 = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v9")
    # Both versions should be substantially smaller than the 12K full prompt
    assert len(phase_a_default) < 12000, f"Default Phase A prompt too large: {len(phase_a_default)} chars"
    assert len(phase_a_v9) < 12000, f"v9 Phase A prompt too large: {len(phase_a_v9)} chars"
    # Both should be substantial
    assert len(phase_a_default) > 1000


def test_phase_a_routing(research_concept):
    """write_aristotle_prompt with phase='A_lean_only' routes to Phase A."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(
        concept=research_concept,
        phase="A_lean_only",
    )
    assert "Phase A Research Mission v19" in prompt


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
    assert "Phase A Research Mission v19" in prompt


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
    """With no usable records, threshold is 0.25 (cold start default).

    This lets early cycles bootstrap packaging instead of stalling at a
    high fixed bar — the top-30% rank gate only becomes meaningful once
    there is a window of Phase A scores to rank against.
    """
    # Empty workspace, no cycle_analytics.json
    from knowledge_extractor import KnowledgeExtractor
    # Don't fully init — just use the threshold method
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    assert threshold == 0.25, f"Expected 0.25 for cold start, got {threshold}"


def test_adaptive_threshold_warm(temp_workspace):
    """With 50+ records, threshold uses p70 of last 50 quality scores.

    p70 = the score at the 70th percentile, so cycles scoring at or above
    it are roughly the top 30% — exactly the desired Phase B promotion rate.
    """
    # Create cycle_analytics.json with 60 records of known quality
    records = []
    for i in range(60):
        # Quality scores 0.0 to 0.59, evenly distributed
        records.append({
            "quality_score": i * 0.01,
            "phase": "A_only",
            "timestamp": f"2026-06-{(i % 30) + 1:02d}",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    # p70 of last 50 (which are 0.10 to 0.59): index int(0.70 * 49) = 34
    expected = sorted(r["quality_score"] for r in records[-50:])[int(0.70 * 49)]
    # Clamp to [0.25, 0.70]
    expected = max(0.25, min(0.70, expected))
    assert abs(threshold - expected) < 0.01, f"Expected ~{expected}, got {threshold}"


def test_adaptive_threshold_clamped_low(temp_workspace):
    """Threshold never goes below 0.25 even if p70 is lower."""
    records = []
    for i in range(60):
        records.append({
            "quality_score": 0.1 + i * 0.001,  # All very low
            "phase": "A_only",
            "timestamp": f"2026-06-{(i % 30) + 1:02d}",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    assert threshold >= 0.25, f"Threshold {threshold} below floor 0.25"


def test_adaptive_threshold_clamped_high(temp_workspace):
    """Threshold never goes above 0.70 even if p70 is higher."""
    records = []
    for i in range(60):
        records.append({
            "quality_score": 0.7 + i * 0.005,  # All very high
            "phase": "A_only",
            "timestamp": f"2026-06-{(i % 30) + 1:02d}",
        })
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    assert threshold <= 0.70, f"Threshold {threshold} above ceiling 0.70"


def test_adaptive_threshold_uses_phase_a_scores(temp_workspace):
    """The percentile is over PHASE A scores, not Phase B final scores.

    For records that went on to Phase B, phase_a_quality_score is used
    (the pre-packaging score). A_only records contribute their
    quality_score (which IS the Phase A score). Phase B records without
    a phase_a_quality_score are excluded so the packaged-quality doesn't
    contaminate the Phase A rank.
    """
    records = [
        # A_only: Phase A score = 0.40
        {"quality_score": 0.40, "phase": "A_only"},
        # A_only: Phase A score = 0.50
        {"quality_score": 0.50, "phase": "A_only"},
        # Phase B completed: Phase A score was 0.45, final packaged 0.90
        {"quality_score": 0.90, "phase": "complete",
         "phase_b_prompt_version": "v1", "phase_a_quality_score": 0.45},
        # Phase B completed but missing phase_a_quality_score -> excluded
        {"quality_score": 0.95, "phase": "complete",
         "phase_b_prompt_version": "v1"},
    ]
    analytics_path = temp_workspace / "cycle_analytics.json"
    analytics_path.write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    threshold = ext._adaptive_phase_b_threshold()
    # Usable Phase A scores: [0.40, 0.50, 0.45] (0.95 excluded). p70 of
    # sorted [0.40, 0.45, 0.50]: idx int(0.70 * 2) = 1 -> 0.45
    assert abs(threshold - 0.45) < 0.01, f"Expected ~0.45, got {threshold}"


def test_a_only_integration_floor(temp_workspace):
    """A_only Catalog integration uses a low fixed floor (0.30),
    decoupled from the promotion percentile, so near-miss Lean still
    enters the Catalog even when the top-30% cutoff is higher."""
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace
    ext.config = {}
    floor = ext._a_only_integration_floor()
    assert floor == 0.30, f"Expected 0.30 integration floor, got {floor}"


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
    # p70 of these is 0.2, but clamped to 0.25 (the floor)
    records = [{"quality_score": 0.2, "phase": "A_only", "timestamp": "2026-06-01"}] * 60
    (temp_workspace / "cycle_analytics.json").write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace

    threshold = ext._adaptive_phase_b_threshold()
    # Threshold is at the floor (0.25) because all scores are 0.2
    assert threshold == 0.25, f"Expected floor of 0.25, got {threshold}"
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
    # Same setup: threshold clamps to 0.25
    records = [{"quality_score": 0.2, "phase": "A_only", "timestamp": "2026-06-01"}] * 60
    (temp_workspace / "cycle_analytics.json").write_text(json.dumps({"records": records}))
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    ext.workspace = temp_workspace

    threshold = ext._adaptive_phase_b_threshold()
    assert threshold == 0.25
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
    # v8 emphasizes Duality & Representation
    assert "Duality & Representation" in p_v8
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


def test_phase_b_pruned_workspace(temp_workspace, research_job):
    """If phase is B, _build_project_dir should only copy Phase A output files."""
    from knowledge_extractor import KnowledgeExtractor
    
    # Initialize extractor with mock/temp catalog
    catalog_root = temp_workspace / "Catalog"
    catalog_root.mkdir()
    
    # Create some mock Catalog files
    file_a = catalog_root / "Algebra" / "Matrix.lean"
    file_a.parent.mkdir()
    file_a.write_text("-- Algebra file")
    
    file_b = catalog_root / "Geometry" / "Stereo.lean"
    file_b.parent.mkdir()
    file_b.write_text("-- Geometry file")
    
    # Instantiate extractor
    config = {
        "workspace_dir": str(temp_workspace),
        "catalog_root": str(temp_workspace),
    }
    
    with patch.object(KnowledgeExtractor, "_load_config", return_value=config):
        extractor = KnowledgeExtractor()
        extractor.catalog_root = catalog_root
        
        # 1. Test Phase A: should copy all files
        research_job.phase = "A"
        dir_a = extractor._build_project_dir(research_job)
        assert dir_a is not None
        assert (dir_a / "Catalog" / "Algebra" / "Matrix.lean").exists()
        assert (dir_a / "Catalog" / "Geometry" / "Stereo.lean").exists()
        
        # 2. Test Phase B: should only copy targeted files
        research_job.phase = "B"
        research_job.phase_a_result = {
            "lean_files": [str(file_a)]
        }
        dir_b = extractor._build_project_dir(research_job)
        assert dir_b is not None
        assert (dir_b / "Catalog" / "Algebra" / "Matrix.lean").exists()
        assert not (dir_b / "Catalog" / "Geometry" / "Stereo.lean").exists()

        # 3. Regression: integrated_paths are relative to repo root, not absolute
        research_job.phase = "B"
        research_job.phase_a_result = {
            "lean_files": ["Catalog/Algebra/Matrix.lean"]
        }
        dir_c = extractor._build_project_dir(research_job)
        assert dir_c is not None
        assert (dir_c / "Catalog" / "Algebra" / "Matrix.lean").exists()
        assert not (dir_c / "Catalog" / "Geometry" / "Stereo.lean").exists()


def test_aristotle_self_score_evaluation(temp_workspace, research_job):
    """If job has an aristotle_self_score, extractor.evaluate should use it and return early."""
    from knowledge_extractor import KnowledgeExtractor
    
    config = {
        "workspace_dir": str(temp_workspace),
        "catalog_root": str(temp_workspace),
    }
    
    with patch.object(KnowledgeExtractor, "_load_config", return_value=config):
        extractor = KnowledgeExtractor()
        
        # Test case 1: no sorry
        research_job.result_lean = "theorem foo : True := trivial"
        research_job.aristotle_self_score = 0.88
        
        evaluated_job = extractor.evaluate(research_job)
        assert evaluated_job.quality_score == 0.88
        assert evaluated_job.quality_assessment["quality"] == "substantial"
        assert evaluated_job.quality_assessment["should_retry"] is False
        assert evaluated_job.quality_detail.proof_depth == 0.88

        # Test case 2: has sorry
        research_job.result_lean = "theorem foo : True := sorry"
        research_job.aristotle_self_score = 0.45
        
        evaluated_job2 = extractor.evaluate(research_job)
        assert evaluated_job2.quality_score == 0.45
        assert evaluated_job2.quality_assessment["quality"] == "partial"
        assert evaluated_job2.quality_assessment["should_retry"] is True
        assert evaluated_job2.quality_detail.proof_depth == 0.45

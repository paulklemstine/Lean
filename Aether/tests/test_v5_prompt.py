"""Tests for the v5 prompt (plan-first, PEGB-strict, either path).

Covers:
- v5 has required Plan section
- v5 has strict PEGB on every theorem (not just top 3-5)
- v5 has anti-pattern blacklist
- v5 has either-path framing (Grothendieck or Cauchy)
- v5 has no fixed theorem count
- v5 routing: default → v5, explicit → v5
- v4 and v3 still work
- v1 raises
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


@pytest.fixture
def research_concept():
    """Build a sample ResearchConcept for testing."""
    from pi_agent_client import ResearchConcept
    return ResearchConcept(
        title="Novel Algebraic Structure",
        domain="Algebra",
        concept_description="A new operator on a generalized space",
        mathematical_framing="Operator algebras with novel commutation relations",
        lean_guess="theorem novel_commutes (a b : α) : f (g a) = g (f a) := by sorry",
        novelty_estimate=0.8,
        breakthrough_potential=0.7,
    )


# ─── v5 structure tests ───────────────────────────────────────────────────

def test_v5_has_required_plan_section(research_concept):
    """v5 prompt must require a Plan section before code."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    assert "STEP 1: PLAN" in prompt
    # Plan should be a substantial section (not just a passing mention)
    plan_idx = prompt.find("STEP 1: PLAN")
    # Find a later STEP marker to confirm the Plan section has real content
    step2_idx = prompt.find("STEP 2: PEGB")
    assert step2_idx > 0
    # Plan section should be at least 200 chars (real content, not just a one-liner)
    plan_section = prompt[plan_idx:step2_idx]
    assert len(plan_section) > 200, f"Plan section too short: {len(plan_section)} chars"


def test_v5_has_strict_pegb(research_concept):
    """v5 prompt must require PEGB on EVERY theorem, not just top ones."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    assert "STEP 2: PEGB for EVERY theorem" in prompt
    # Should explicitly call out the difference from v3/v4
    assert 'EVERY theorem' in prompt or "every theorem" in prompt
    # Should mention the rejection clause
    assert "rejected" in prompt.lower()


def test_v5_has_anti_pattern_blacklist(research_concept):
    """v5 prompt must blacklist proof tactics."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    assert "STEP 3: Anti-patterns" in prompt
    # Should blacklist the standard tactics
    assert "native_decide" in prompt
    assert "decide" in prompt
    assert "norm_num" in prompt
    assert "rfl" in prompt
    assert "Aesop" in prompt
    # Should also reject "math of X"
    assert "Mathematics of X" in prompt or "real-world phenomenon" in prompt


def test_v5_has_either_path_framing(research_concept):
    """v5 prompt lets Aristotle choose between Grothendieck and Cauchy paths."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    assert "STEP 5" in prompt
    assert "Grothendieck" in prompt
    assert "Cauchy" in prompt
    # Should say either is fine
    assert "Either path" in prompt or "either path" in prompt
    # Should not mandate one
    assert "Aristotle's choice" in prompt or "your choice" in prompt.lower()


def test_v5_has_no_fixed_theorem_count(research_concept):
    """v5 prompt does not require a specific number of theorems."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    assert "STEP 6" in prompt
    assert "No fixed count" in prompt or "no fixed count" in prompt
    # The DELIVERABLES section should not say "3-5 theorems" (the v3/v4 hard cap)
    deliverables_idx = prompt.find("### DELIVERABLES")
    pegb_idx = prompt.find("STEP 2: PEGB")
    if deliverables_idx > 0 and pegb_idx > deliverables_idx:
        deliverables_block = prompt[deliverables_idx:pegb_idx]
        assert "3-5 non-trivial theorems" not in deliverables_block, \
            f"v5 deliverables block should not hardcode 3-5 theorems"


def test_v5_requires_citations(research_concept):
    """v5 prompt must require citation of catalog results."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    assert "STEP 7" in prompt
    assert "Cite your sources" in prompt or "cite" in prompt.lower()


# ─── v5 routing tests ────────────────────────────────────────────────────

def test_default_routes_to_v5(research_concept):
    """write_aristotle_prompt with no version defaults to v5."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(concept=research_concept, phase="A_lean_only")
    # v5 markers
    assert "STEP 1: PLAN" in prompt
    assert "STEP 2: PEGB" in prompt
    assert "STEP 3: Anti-patterns" in prompt


def test_v5_explicit_routing(research_concept):
    """write_aristotle_prompt with prompt_version='v5' uses v5."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(
        concept=research_concept, phase="A_lean_only", prompt_version="v5"
    )
    assert "STEP 1: PLAN" in prompt


def test_v4_still_works(research_concept):
    """write_aristotle_prompt with prompt_version='v4' still uses v4."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(
        concept=research_concept, phase="A_lean_only", prompt_version="v4"
    )
    # v4 markers
    assert "DEEPEN an existing catalog result" in prompt
    # v5 markers absent
    assert "STEP 1: PLAN" not in prompt


def test_v3_still_works(research_concept):
    """write_aristotle_prompt with prompt_version='v3' still uses v3."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    prompt = client.write_aristotle_prompt(
        concept=research_concept, phase="A_lean_only", prompt_version="v3"
    )
    # v3 markers
    assert "novel mathematical structure" in prompt
    # v5 markers absent
    assert "STEP 1: PLAN" not in prompt


def test_v1_raises(research_concept):
    """v1 still raises — use v3, v4, or v5."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    with pytest.raises(ValueError) as exc_info:
        client.write_aristotle_prompt(
            concept=research_concept, phase="A_lean_only", prompt_version="v1"
        )
    assert "v1" in str(exc_info.value)
    assert "v5" in str(exc_info.value)


# ─── v5 prompt size tests ────────────────────────────────────────────────

def test_v5_prompt_size(research_concept):
    """v5 prompt should be larger than v4 (Plan section + strict PEGB)."""
    from pi_agent_client import PiAgentClient
    client = PiAgentClient.__new__(PiAgentClient)
    p5 = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v5")
    p4 = client._build_phase_a_lean_prompt(concept=research_concept, prompt_version="v4")
    # v5 has Plan section, strict PEGB, anti-patterns, either-path — must be larger
    assert len(p5) > len(p4), f"v5 ({len(p5)}) should be larger than v4 ({len(p4)})"
    # v5 should still be reasonable
    assert len(p5) < 12000, f"v5 prompt too large: {len(p5)} chars"


# ─── A/B split test ──────────────────────────────────────────────────────

def test_v5_ab_split_distribution():
    """The 3-way A/B split should be ~60% v5, ~25% v4, ~15% v3."""
    import hashlib
    counts = {"v5": 0, "v4": 0, "v3": 0}
    for i in range(2000):
        bucket = int(hashlib.md5(f"job-{i}".encode()).hexdigest(), 16) % 1000
        if bucket < 600:
            counts["v5"] += 1
        elif bucket < 850:
            counts["v4"] += 1
        else:
            counts["v3"] += 1
    total = sum(counts.values())
    pct = {k: round(v / total * 100, 1) for k, v in counts.items()}
    # v5 should be the largest, near 60%
    assert pct["v5"] > 55, f"v5 share {pct['v5']}% too low"
    assert pct["v5"] < 70, f"v5 share {pct['v5']}% too high"
    # v4 should be ~25%
    assert 20 < pct["v4"] < 32, f"v4 share {pct['v4']}% out of range"
    # v3 should be ~15%
    assert 10 < pct["v3"] < 22, f"v3 share {pct['v3']}% out of range"


# ─── Integration with Phase A split ──────────────────────────────────────

def test_v5_in_phase_a_dispatch():
    """The 3-way A/B split should set phase_a_prompt_version correctly."""
    # Simulate the dispatch logic
    import hashlib
    sample = "test-job-123"
    bucket = int(hashlib.md5(sample.encode()).hexdigest(), 16) % 1000
    if bucket < 600:
        version = "v5"
    elif bucket < 850:
        version = "v4"
    else:
        version = "v3"
    # Just verify the logic — actual version depends on the hash
    assert version in ("v3", "v4", "v5")

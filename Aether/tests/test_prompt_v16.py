"""Tests for Phase A v16 prompt family.

Covers:
- v16 prompt contains research-team scientific-method loop
- v16 prompt contains self-critique checklist
- v16 prompt contains anti-trivial guardrails
- v16 prompt forbids packaging deliverables
- v16 future-directions rules are present
- v16a adds extra adversarial mandate
- v16b adds extra bridge mandate
- Prompt version selection respects configured weights
- v16 is routed correctly through write_aristotle_prompt
"""
import os
import sys
import tempfile
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


@pytest.fixture
def research_concept():
    """Build a sample ResearchConcept for testing."""
    from pi_agent_client import ResearchConcept
    return ResearchConcept(
        title="Test Tropical Bridge Theorem",
        domain="Tropical",
        concept_description="A test concept for v16 prompt structure",
        mathematical_framing="Tropical geometry meets number theory",
        lean_guess="theorem tropical_bridge (n : Nat) : n = n := rfl",
        novelty_estimate=0.7,
        breakthrough_potential=0.6,
        catalog_references=["Catalog/Tropical/Basic.lean"],
        research_mode="prove",
    )


@pytest.fixture
def pi_client():
    """Create a minimal PiAgentClient instance for prompt builders."""
    from pi_agent_client import PiAgentClient
    with tempfile.TemporaryDirectory() as tmpdir:
        client = PiAgentClient(
            model="openai-large",
            catalog_root=Path(tmpdir) / "Catalog",
            use_ollama=True,  # avoid cloud API calls
        )
        yield client


def test_v16_has_team_loop(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Principal Investigator" in prompt
    assert "Hypothesizer" in prompt
    assert "Experimenter" in prompt
    assert "Analyst" in prompt
    assert "Critic" in prompt
    assert "Stage 1 — Hypothesize" in prompt
    assert "Stage 2 — Experiment" in prompt
    assert "Stage 3 — Generalize" in prompt
    assert "Stage 4 — Critique" in prompt
    assert "Stage 5 — Future" in prompt


def test_v16_has_self_critique_checklist(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Self-Critique Checklist" in prompt
    assert "No theorem is trivial" in prompt
    assert "Every main theorem has 0 sorries" in prompt
    assert "Lab Notes blocks contain real hypotheses" in prompt


def test_v16_has_anti_trivial_guardrails(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Anti-Trivial Guardrails" in prompt
    assert "Inhabited X" in prompt
    assert "native_decide" in prompt
    assert "insight-bearing tactic" in prompt


def test_v16_forbids_packaging(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Strictly Forbidden in Phase A" in prompt
    assert "ARTICLE.md" in prompt
    assert "RESEARCH_PAPER.md" in prompt
    assert "demo.py" in prompt
    assert "PACKAGE.json" in prompt


def test_v16_future_directions_rules(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "FUTURE_DIRECTIONS.md" in prompt
    assert "The key insight is..." in prompt
    assert "Why now?" in prompt


def test_v16a_extra_adversarial(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v16a",
    )
    assert "Extra Adversarial Mandate (v16a)" in prompt
    assert "counterexample" in prompt.lower()


def test_v16b_extra_bridge(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v16_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v16b",
    )
    assert "Extra Bridge Mandate (v16b)" in prompt
    assert "two" in prompt and "different catalog domains" in prompt


def test_select_phase_a_prompt_version_respects_weights():
    from pi_agent_client import select_phase_a_prompt_version
    # Deterministic when only one candidate
    assert select_phase_a_prompt_version({"v15": 1.0}) == "v15"
    assert select_phase_a_prompt_version({"v16": 1.0}) == "v16"
    # weights=None uses the configured A/B weights (currently v19 family)
    version = select_phase_a_prompt_version()
    assert version.startswith("v19")
    # Empty / zero weights fall back to the stable baseline v19
    assert select_phase_a_prompt_version({}) == "v19"
    assert select_phase_a_prompt_version({"v16": 0.0}) == "v19"


def test_write_aristotle_prompt_routes_v16(pi_client, research_concept):
    prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v16",
        phase="A_lean_only",
    )
    assert "Phase A Research Mission v16" in prompt
    assert "Self-Critique Checklist" in prompt


def test_write_aristotle_prompt_routes_v15(pi_client, research_concept):
    prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v15",
        phase="A_lean_only",
    )
    assert "MATHEMATICAL RESEARCH MISSION" in prompt
    # v15 should NOT have the v16 self-critique checklist
    assert "Self-Critique Checklist" not in prompt


def test_v17_is_concise(pi_client, research_concept):
    prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v17",
        phase="A_lean_only",
    )
    assert "Phase A Research Mission v17" in prompt
    assert "Concise Scientific Loop" in prompt
    # v17 strips long examples, so it should be shorter than v16
    v16_prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v16",
        phase="A_lean_only",
    )
    assert len(prompt) < len(v16_prompt)


def test_v18_is_mode_specific(pi_client, research_concept):
    prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v18",
        phase="A_lean_only",
    )
    assert "Phase A Research Mission v18" in prompt
    assert "Mode-Specific Mission: prove" in prompt


def test_v18_sorry_fill_mode(pi_client):
    from pi_agent_client import ResearchConcept
    concept = ResearchConcept(
        title="Fill remaining sorries",
        domain="Algebra",
        concept_description="Fill sorries in an existing file",
        mathematical_framing="sorry_fill target",
        research_mode="sorry_fill",
    )
    prompt = pi_client.write_aristotle_prompt(
        concept=concept,
        catalog_references=["Catalog/Algebra/Target.lean"],
        prompt_version="v18",
        phase="A_lean_only",
    )
    assert "Phase A Research Mission v18" in prompt
    assert "Mode-Specific Mission: sorry_fill" in prompt
    assert " Hypothesizer" in prompt
    assert " Experimenter" in prompt

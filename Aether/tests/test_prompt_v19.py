"""Tests for Phase A v19 prompt family.

The v19 family is the new baseline: v12 Speculative Specifier fused with the
v16 scientific-method loop and anti-trivial guardrails. The A/B variants are:
- v19  : baseline
- v19a : + 50/50 famous-subtask / cross-domain menu constraint
- v19b : + mandatory pre-proof computational experimentation stage
- v19c : + recursive abduction / thread continuation mandate
- v19d : + external signal awareness (arXiv / OEIS / LMFDB)
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
        title="Test Speculative Bridge Theorem",
        domain="Bridges",
        concept_description="A test concept for v19 prompt structure",
        mathematical_framing="Number theory meets tropical geometry",
        lean_guess="theorem test_bridge (n : Nat) : n = n := rfl",
        novelty_estimate=0.7,
        breakthrough_potential=0.6,
        catalog_references=["Catalog/NumberTheory/Basic.lean"],
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


V19_VARIANTS = ["v19", "v19a", "v19b", "v19c", "v19d", "v24", "v25", "v26", "v27", "v28"]


def test_v19_baseline_has_speculative_and_team_loop(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v19",
    )
    assert "Phase A Research Mission v19" in prompt
    assert "Speculative Scientific-Method Loop" in prompt
    assert "Principal Investigator" in prompt
    assert "Hypothesizer" in prompt
    assert "Experimenter" in prompt
    assert "Analyst" in prompt
    assert "Critic" in prompt
    assert "Stage 1 — Hypothesize" in prompt
    assert "Stage 5 — Synthesize" in prompt


def test_v19_has_anti_trivial_guardrails(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Anti-Trivial Guardrails" in prompt
    assert "Inhabited X" in prompt
    assert "native_decide" in prompt
    assert "insight-bearing tactic" in prompt


def test_v19_has_self_critique_checklist(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Self-Critique Checklist" in prompt
    assert "No theorem is trivial" in prompt
    assert "Every main theorem has 0 sorries" in prompt
    assert "Lab Notes blocks contain real" in prompt


def test_v19_forbids_packaging(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "Strictly Forbidden in Phase A" in prompt
    assert "ARTICLE.md" in prompt
    assert "RESEARCH_PAPER.md" in prompt
    assert "demo.py" in prompt
    assert "PACKAGE.json" in prompt


def test_v19_future_directions_requirements(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    assert "FUTURE_DIRECTIONS.md" in prompt
    assert "The key insight is..." in prompt
    assert "Why now?" in prompt


@pytest.mark.parametrize("version", V19_VARIANTS)
def test_v19_variants_routed(pi_client, research_concept, version):
    prompt = pi_client._build_phase_a_lean_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version=version,
    )
    assert f"Phase A Research Mission {version}" in prompt


def test_v19a_has_menu_constraint(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v19a",
    )
    assert "Menu Balance Constraint" in prompt
    assert "Millennium" in prompt
    assert "two or more catalog" in prompt.lower()
    assert "domains" in prompt.lower()


def test_v19b_has_computational_stage(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v19b",
    )
    assert "Pre-Proof Computational Experimentation Stage" in prompt
    assert "ComputationalEvidence.md" in prompt
    assert "OEIS" in prompt
    assert "LMFDB" in prompt


def test_v19c_has_abduction_thread(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v19c",
    )
    assert "Recursive Abduction" in prompt
    assert "Thread Continuation" in prompt
    assert "next-cycle sub-conjectures" in prompt


def test_v19d_has_external_signal(pi_client, research_concept):
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        prompt_version="v19d",
    )
    assert "External Signal Awareness" in prompt
    assert "arXiv" in prompt
    assert "OEIS" in prompt
    assert "LMFDB" in prompt


def test_version_selection_defaults_to_v19_family():
    """select_phase_a_prompt_version with default weights returns a v19 variant."""
    from pi_agent_client import select_phase_a_prompt_version, DEFAULT_PHASE_A_PROMPT_WEIGHTS
    for _ in range(50):
        version = select_phase_a_prompt_version()
        assert version in V19_VARIANTS, f"unexpected version {version}"
    assert "v19" in DEFAULT_PHASE_A_PROMPT_WEIGHTS
    assert abs(sum(DEFAULT_PHASE_A_PROMPT_WEIGHTS.values()) - 1.0) < 1e-9


def test_phase_a_routes_v19_by_default(pi_client, research_concept):
    prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        phase="A_lean_only",
    )
    assert "Phase A Research Mission v19" in prompt
    assert "Speculative Scientific-Method Loop" in prompt


def test_v19_prompts_forbid_positive_packaging_deliverables(pi_client, research_concept):
    """v19 must NOT request article/paper/demo as deliverables; only forbid them."""
    prompt = pi_client._build_phase_a_v19_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
    )
    # It should contain the forbidden list
    assert "Strictly Forbidden in Phase A" in prompt
    # It should not contain a positive numbered deliverable asking for demos/articles
    assert "1. **ARTICLE.md**" not in prompt
    assert "1. **RESEARCH_PAPER.md**" not in prompt
    assert "1. **demo.py**" not in prompt

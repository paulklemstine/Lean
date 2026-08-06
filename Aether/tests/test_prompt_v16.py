"""Tests for Phase A prompt generator locked to v19c.

Covers:
- Phase A prompt version selection defaults to v19c
- write_aristotle_prompt routes to v19c
"""
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
        concept_description="A test concept for v19c prompt structure",
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


def test_select_phase_a_prompt_version_locked():
    from pi_agent_client import select_phase_a_prompt_version
    version = select_phase_a_prompt_version()
    assert version == "v19c"
    assert select_phase_a_prompt_version({}) == "v19c"


def test_write_aristotle_prompt_routes_v19c(pi_client, research_concept):
    prompt = pi_client.write_aristotle_prompt(
        concept=research_concept,
        catalog_references=research_concept.catalog_references,
        phase="A_lean_only",
    )
    assert "Phase A Research Mission" in prompt
    assert "SELF_EVALUATION.json" in prompt

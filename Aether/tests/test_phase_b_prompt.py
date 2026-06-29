"""Tests for Phase B packaging prompt versions and display policy."""
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


@pytest.fixture
def research_concept():
    from pi_agent_client import ResearchConcept
    return ResearchConcept(
        title="Test Phase B Package",
        domain="Algebra",
        concept_description="A test concept for Phase B",
        mathematical_framing="Algebraic structures",
        lean_guess="theorem test (n : Nat) : n = n := rfl",
        catalog_references=["Catalog/Algebra/Basic.lean"],
        research_mode="prove",
    )


@pytest.fixture
def pi_client():
    from pi_agent_client import PiAgentClient
    return PiAgentClient.__new__(PiAgentClient)


def test_default_phase_b_prompt_is_v1_1(pi_client, research_concept):
    prompt = pi_client._build_phase_b_package_prompt(
        concept=research_concept,
        phase_a_lean_content="theorem foo : True := trivial",
    )
    assert "PHASE B: PACKAGING ONLY" in prompt
    assert "PACKAGE.json Metadata Extraction" in prompt


# v2 Phase B prompt retired for v1.0 (A/B finalized to v1.1); the two
# v2-specific prompt tests were removed here.


def test_phase_b_default_fallback_is_v1_1():
    from pi_agent_client import select_phase_b_prompt_version
    assert select_phase_b_prompt_version({}) == "v1.1"
    assert select_phase_b_prompt_version({"v2": 0.0}) == "v1.1"


def test_phase_b_version_selection_respects_weights():
    from pi_agent_client import select_phase_b_prompt_version, DEFAULT_PHASE_B_PROMPT_WEIGHTS
    # v1.0: A/B finalized — v1.1 is the only arm, so selection is always v1.1.
    for _ in range(50):
        assert select_phase_b_prompt_version() == "v1.1"
    assert "v1.1" in DEFAULT_PHASE_B_PROMPT_WEIGHTS
    assert "v2" not in DEFAULT_PHASE_B_PROMPT_WEIGHTS
    assert abs(sum(DEFAULT_PHASE_B_PROMPT_WEIGHTS.values()) - 1.0) < 1e-9


def test_package_index_does_not_filter_by_quality():
    """update_index.py must include all packages regardless of quality_score."""
    script = Path(__file__).parent.parent.parent / "Packages" / "update_index.py"
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        # Write two dummy packages: one high quality, one low quality
        (tmp / "high_q.json").write_text(json.dumps({
            "title": "High Quality Result",
            "domain": "Algebra",
            "date": "2026-06-17T12:00:00Z",
            "exp_id": "high001",
            "quality_score": 0.85,
        }), encoding="utf-8")
        (tmp / "low_q.json").write_text(json.dumps({
            "title": "Low Quality Result",
            "domain": "Novelty",
            "date": "2026-06-17T11:00:00Z",
            "exp_id": "low001",
            "quality_score": 0.15,
        }), encoding="utf-8")

        # update_index.py chdirs to its own directory, so copy it into the temp
        # directory and run it from there.
        local_script = tmp / "update_index.py"
        local_script.write_text(script.read_text(encoding="utf-8"), encoding="utf-8")
        result = subprocess.run(
            ["python3", str(local_script)],
            cwd=str(tmp),
            capture_output=True,
            text=True,
            timeout=60,
        )
        assert result.returncode == 0, f"update_index.py failed: {result.stderr}"

        index_path = tmp / "package_index.js"
        assert index_path.exists()
        content = index_path.read_text(encoding="utf-8")
        # Extract the first JSON array assigned to window.PACKAGE_INDEX
        match = re.search(r"window\.PACKAGE_INDEX\s*=\s*(\[.*?\]);", content, re.DOTALL)
        assert match, "Could not find PACKAGE_INDEX array in generated index"
        index = json.loads(match.group(1))
        titles = {p["title"] for p in index}
        assert "High Quality Result" in titles
        assert "Low Quality Result" in titles

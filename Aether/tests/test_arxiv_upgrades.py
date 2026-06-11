#!/usr/bin/env python3
"""Tests for upgraded arXiv provider, miner, and parsing functionalities."""

import json
from pathlib import Path
from unittest.mock import MagicMock

import pytest

from arxiv_provider import ArxivTexProvider, ArxivPaper
from arxiv_miner import ArxivMiner
from research_memory import FutureDirection, FutureDirectionsManager, ResearchMemory, ExperimentRecord


@pytest.fixture
def temp_workspace(tmp_path):
    """Create a temporary workspace for research memory."""
    ws = tmp_path / "workspace"
    ws.mkdir()
    (ws / ".aether_workspace").mkdir()
    return ws


def test_relevance_scoring():
    """Verify that _score_paper_relevance prioritizes papers matching math/custom terms."""
    provider = ArxivTexProvider()

    paper_math = ArxivPaper(
        paper_id="1",
        title="Tropical semirings and algebraic curves",
        abstract="We define a new theorem about tropical semirings using lattice structures.",
        categories="math.CO math.AG",
    )
    paper_cs = ArxivPaper(
        paper_id="2",
        title="Web development framework in Javascript",
        abstract="This paper introduces a web application framework designed to make website building easier.",
        categories="cs.SE",
    )

    # Scored on math terms
    score_math = provider._score_paper_relevance(paper_math)
    score_cs = provider._score_paper_relevance(paper_cs)
    assert score_math > score_cs

    # Scored on custom keywords
    score_kw = provider._score_paper_relevance(paper_math, keywords=["tropical", "semiring"])
    assert score_kw > score_math


def test_custom_latex_environments():
    """Verify that custom LaTeX environments are extracted correctly."""
    provider = ArxivTexProvider()
    
    tex_source = r"""
\documentclass{article}
\newtheorem{mythm}{My Theorem}
\newtheorem*{mylem}{My Lemma}
\begin{document}
\begin{abstract}
This is a paper abstract.
\end{abstract}
\section{Introduction}
Here is some text.
\begin{mythm}
This is a custom theorem statement.
\end{mythm}
\begin{mylem}
This is a custom lemma statement.
\end{mylem}
\end{document}
"""
    extracted = provider._extract_theorem_rich_content(tex_source)
    assert "ABSTRACT" in extracted
    assert "mythm" in extracted.lower()
    assert "mylem" in extracted.lower()
    assert "My Theorem" in extracted or "custom theorem" in extracted


def test_get_recent_keywords(temp_workspace):
    """Verify keyword extraction from ResearchMemory."""
    # Write mock experiments to ResearchMemory
    mem = ResearchMemory(temp_workspace)
    mem.record(ExperimentRecord(
        exp_id="exp1",
        domain="Tropical",
        concept_title="Tropical Berggren Monoid",
        concept_description="Verify algebraic monoid properties.",
        status="success",
        key_theorems=["berggren_monoid_assoc", "tropical_monoid_identity"],
    ))
    mem.record(ExperimentRecord(
        exp_id="exp2",
        domain="Algebra",
        concept_title="Lipschitz Robustness Bounds",
        concept_description="Robustness bounds for neural nets.",
        status="success",
        key_theorems=["lipschitz_robustness_bound"],
    ))
    mem.record(ExperimentRecord(
        exp_id="exp3",
        domain="Algebra",
        concept_title="Failed Attempt",
        concept_description="Something that failed.",
        status="failure",
        key_theorems=[],
    ))

    # Initialize ArxivMiner with a FutureDirectionsManager pointing to same workspace
    fd_manager = FutureDirectionsManager(temp_workspace)
    miner = ArxivMiner(
        pi_agent=MagicMock(),
        catalog_analyzer=MagicMock(),
        research_memory=fd_manager,
    )

    keywords = miner._get_recent_keywords()
    # Check that success terms are present, and failure/stop words are not
    assert "berggren" in keywords or "tropical" in keywords
    assert "lipschitz" in keywords
    assert "failed" not in keywords
    assert "theorem" not in keywords


def test_parse_lean_theorem_stub(temp_workspace):
    """Verify parsing of lean_theorem_stub in _parse_direction_response."""
    fd_manager = FutureDirectionsManager(temp_workspace)
    mock_agent = MagicMock()
    parsed_dict = {
        "title": "Tropical Pythagorean Bridge",
        "description": "Conjecture: Every Pythagorean triple satisfies a tropical equation. Test: Verify. Impact: New bridge.",
        "domain": "Tropical",
        "catalog_references": ["Algebra/Berggren.lean"],
        "domain_bridges": ["Algebra <-> Tropical"],
        "ambition_level": "grand_challenge",
        "proof_strategy": "Direct proof",
        "lean_theorem_stub": "theorem tropical_pythagorean (a b c : Real) : True := by sorry",
        "arxiv_id": "2310.12345",
    }
    mock_agent._parse_json_response.return_value = parsed_dict

    miner = ArxivMiner(
        pi_agent=mock_agent,
        catalog_analyzer=MagicMock(),
        research_memory=fd_manager,
    )
    
    paper = ArxivPaper(
        paper_id="2310.12345",
        title="Test Paper",
        authors="Test Authors",
        source_url="http://arxiv.org/abs/2310.12345",
    )
    
    llm_response = json.dumps({
        "title": "Tropical Pythagorean Bridge",
        "description": "Conjecture: Every Pythagorean triple satisfies a tropical equation. Test: Verify. Impact: New bridge.",
        "domain": "Tropical",
        "catalog_references": ["Algebra/Berggren.lean"],
        "domain_bridges": ["Algebra <-> Tropical"],
        "ambition_level": "grand_challenge",
        "proof_strategy": "Direct proof",
        "lean_theorem_stub": "theorem tropical_pythagorean (a b c : Real) : True := by sorry",
        "arxiv_id": "2310.12345",
    })
    
    direction = miner._parse_direction_response(llm_response, paper)
    assert direction is not None
    assert direction.title == "Tropical Pythagorean Bridge"
    assert direction.lean_theorem_stub == "theorem tropical_pythagorean (a b c : Real) : True := by sorry"

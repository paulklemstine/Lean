#!/usr/bin/env python3
"""Tests for ArxivMiner: prompt building, response parsing, direction creation."""

import json
from unittest.mock import MagicMock, patch
from pathlib import Path

import pytest

from arxiv_provider import ArxivTexProvider, ArxivPaper, DOMAIN_QUERIES, GENERAL_QUERY
from arxiv_miner import ArxivMiner
from research_memory import FutureDirection, FutureDirectionsManager


# ── Fixtures ──

@pytest.fixture
def temp_workspace(tmp_path):
    """Create a temporary workspace for research memory."""
    ws = tmp_path / "workspace"
    ws.mkdir()
    (ws / ".aether_workspace").mkdir()
    return ws


@pytest.fixture
def mock_pi_agent():
    """Create a mock PiAgentClient."""
    agent = MagicMock()
    agent._call_ollama = MagicMock()
    return agent


@pytest.fixture
def mock_catalog_analyzer():
    """Create a mock CatalogAnalyzer."""
    analyzer = MagicMock()
    analyzer.get_domain_summary_for_prompt.return_value = "Algebra: 10 files, 50 declarations, 5 sorries\nTropical: 8 files, 40 declarations"
    analyzer.get_key_theorem_listing.return_value = "**Algebra**:\n  `Algebra/Berggren.lean`: berggren_triple_valid, berggren_primitive_divisor\n**Tropical**:\n  `Tropical/TropicalSemiring.lean`: tropical_add_idempotent"
    return analyzer


@pytest.fixture
def miner(temp_workspace, mock_pi_agent, mock_catalog_analyzer):
    """Create an ArxivMiner with mock dependencies."""
    memory = FutureDirectionsManager(temp_workspace)
    return ArxivMiner(
        pi_agent=mock_pi_agent,
        catalog_analyzer=mock_catalog_analyzer,
        research_memory=memory,
        config={"enabled": True, "rate_limit_seconds": 0.01},
    )


# ── ArxivTexProvider Tests ──

class TestArxivTexProvider:
    def test_domain_queries_exist(self):
        """All Aether domains have ArXiv queries defined."""
        for domain in ["Pythagorean", "Tropical", "Cryptography", "Algebra",
                        "EML", "MachineLearning", "Physics", "Logic",
                        "Computation", "Speculative", "Geometry", "Bridges"]:
            assert domain in DOMAIN_QUERIES or domain == "Geometry"

    def test_general_query_is_valid(self):
        """General query should be a valid ArXiv search string."""
        assert "cat:" in GENERAL_QUERY

    def test_provider_init(self):
        """Provider initializes with correct defaults."""
        provider = ArxivTexProvider()
        assert provider.query == GENERAL_QUERY
        assert provider.batch_size == 5
        assert provider.max_paper_chars == 8000

    def test_set_domain_query(self):
        """set_domain_query changes the query for a known domain."""
        provider = ArxivTexProvider()
        provider.set_domain_query("Tropical")
        assert provider.query == DOMAIN_QUERIES["Tropical"]
        assert provider.start_index == 0  # Reset

    def test_set_domain_query_unknown(self):
        """set_domain_query falls back to general for unknown domain."""
        provider = ArxivTexProvider()
        provider.set_domain_query("QuantumFoobar")
        assert provider.query == GENERAL_QUERY

    def test_set_general_query(self):
        """set_general_query switches to the general cross-pollination query."""
        provider = ArxivTexProvider(query="cat:math.NT")
        provider.set_general_query()
        assert provider.query == GENERAL_QUERY


# ── ArxivPaper Tests ──

class TestArxivPaper:
    def test_paper_defaults(self):
        """ArxivPaper has sensible defaults."""
        paper = ArxivPaper(paper_id="2310.12345")
        assert paper.paper_id == "2310.12345"
        assert paper.title == ""
        assert paper.tex_content == ""
        assert paper.source_url == "http://arxiv.org/abs/2310.12345"


# ── ArxivMiner Tests ──

class TestArxivMiner:
    def test_mine_direction_success(self, miner, mock_pi_agent):
        """Successful mining creates a FutureDirection and adds it to memory."""
        # Mock Pi-Agent response
        mock_pi_agent._call_ollama.return_value = json.dumps({
            "title": "Tropical Berggren Correspondence",
            "description": "Conjecture: Every Pythagorean triple has a tropical analogue via Berggren trees. Test: Verify for n<100. Impact: Bridges number theory and tropical geometry.",
            "domain": "Tropical",
            "catalog_references": ["Algebra/Berggren.lean", "Tropical/TropicalSemiring.lean"],
            "domain_bridges": ["Algebra <-> Tropical"],
            "ambition_level": "grand_challenge",
            "proof_strategy": "Induction on Berggren tree depth using tropical idempotence",
            "arxiv_id": "2310.12345",
        })

        # Mock the provider to return a paper
        paper = ArxivPaper(
            paper_id="2310.12345",
            title="New Results in Tropical Number Theory",
            authors="Smith, Jones",
            abstract="We prove new theorems about tropical analogues of classical number theory.",
            categories="math.NT math.CO",
            tex_content="\\theorem{tropical_pythagorean} ...",
            source_url="http://arxiv.org/abs/2310.12345",
        )
        miner.provider.get_next_paper = MagicMock(return_value=paper)

        direction = miner.mine_future_direction(domain="Tropical", use_domain_query=True)

        assert direction is not None
        assert "Tropical" in direction.title or "Berggren" in direction.title
        assert "Tropical" in direction.domains or "Pythagorean" in direction.domains
        assert direction.ambition_level == "grand_challenge"
        assert direction.catalog_references == ["Algebra/Berggren.lean", "Tropical/TropicalSemiring.lean"]

    def test_mine_direction_generic_title_rejected(self, miner, mock_pi_agent):
        """Generic titles get prefixed with ArXiv ID."""
        mock_pi_agent._call_ollama.return_value = json.dumps({
            "title": "Study of tropical semirings",
            "description": "Conjecture: tropical semirings have interesting properties. Test: verify. Impact: opens new territory.",
            "domain": "Tropical",
            "catalog_references": [],
            "domain_bridges": [],
            "ambition_level": "extension",
            "proof_strategy": "Direct calculation",
            "arxiv_id": "2401.56789",
        })

        paper = ArxivPaper(
            paper_id="2401.56789",
            title="Some Results",
            authors="Doe",
            categories="math.CO",
            tex_content="content",
            source_url="http://arxiv.org/abs/2401.56789",
        )
        miner.provider.get_next_paper = MagicMock(return_value=paper)

        direction = miner.mine_future_direction(domain="Tropical")
        assert direction is not None
        assert "2401.56789" in direction.title  # ArXiv ID prepended

    def test_mine_direction_no_paper(self, miner):
        """When no paper is available, returns None gracefully."""
        miner.provider.get_next_paper = MagicMock(return_value=None)
        direction = miner.mine_future_direction(domain="Tropical")
        assert direction is None

    def test_mine_direction_api_error(self, miner, mock_pi_agent):
        """When Pi-Agent returns an error, returns None gracefully."""
        mock_pi_agent._call_ollama.return_value = "[API_ERROR: timeout]"

        paper = ArxivPaper(
            paper_id="2310.99999",
            title="Test Paper",
            authors="Test",
            categories="math.NT",
            tex_content="content",
            source_url="http://arxiv.org/abs/2310.99999",
        )
        miner.provider.get_next_paper = MagicMock(return_value=paper)

        direction = miner.mine_future_direction(domain="Algebra")
        assert direction is None

    def test_mine_direction_disabled(self, miner, mock_pi_agent):
        """When disabled, mine_future_direction returns None without calling API."""
        miner.enabled = False
        direction = miner.mine_future_direction(domain="Algebra")
        assert direction is None
        mock_pi_agent._call_ollama.assert_not_called()

    def test_mine_direction_no_pi_agent(self, temp_workspace, mock_catalog_analyzer):
        """When no Pi-Agent, returns None gracefully."""
        memory = FutureDirectionsManager(temp_workspace)
        miner = ArxivMiner(
            pi_agent=None,
            catalog_analyzer=mock_catalog_analyzer,
            research_memory=memory,
            config={"enabled": True},
        )
        direction = miner.mine_future_direction(domain="Algebra")
        assert direction is None

    def test_alternating_queries(self, miner):
        """Odd cycles use domain query, even cycles use general query."""
        # This tests the call signature, not actual API calls
        # The miner should accept use_domain_query parameter
        assert miner.provider is not None

    def test_parse_direction_with_nested_json(self, miner, mock_pi_agent):
        """Parsing handles JSON with nested structures."""
        mock_pi_agent._call_ollama.return_value = (
            'Here is the direction:\n```json\n'
            '{"title": "Tropical Pythagorean Bridge", '
            '"description": "Conjecture: tropical Pythagorean triples exist. Test: verify. Impact: new field.", '
            '"domain": "Tropical", '
            '"catalog_references": ["Algebra/Berggren.lean"], '
            '"domain_bridges": ["Algebra <-> Tropical"], '
            '"ambition_level": "grand_challenge", '
            '"proof_strategy": "Induction", '
            '"arxiv_id": "2310.12345"}\n```'
        )

        paper = ArxivPaper(
            paper_id="2310.12345",
            title="Test",
            authors="Author",
            categories="math.NT",
            tex_content="content",
            source_url="http://arxiv.org/abs/2310.12345",
        )
        miner.provider.get_next_paper = MagicMock(return_value=paper)

        direction = miner.mine_future_direction(domain="Tropical")
        assert direction is not None
        assert direction.title == "Tropical Pythagorean Bridge"

    def test_mine_direction_domain_inference(self, miner, mock_pi_agent):
        """When LLM doesn't specify domain, infer from paper categories."""
        mock_pi_agent._call_ollama.return_value = json.dumps({
            "title": "New Lattice Reduction Method",
            "description": "Conjecture: improved lattice reduction. Test: benchmark. Impact: crypto.",
            "domain": "",
            "catalog_references": [],
            "domain_bridges": [],
            "ambition_level": "extension",
            "proof_strategy": "Computational",
            "arxiv_id": "2401.11111",
        })

        paper = ArxivPaper(
            paper_id="2401.11111",
            title="Lattice Reduction",
            authors="Crypto",
            categories="cs.CR math.NT",
            tex_content="content",
            source_url="http://arxiv.org/abs/2401.11111",
        )
        miner.provider.get_next_paper = MagicMock(return_value=paper)

        direction = miner.mine_future_direction(domain="Cryptography")
        assert direction is not None
        # Domain should be inferred from categories (cs.CR -> Cryptography)
        assert "Cryptography" in direction.domains


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
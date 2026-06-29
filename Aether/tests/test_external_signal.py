"""TDD tests for the external signal feed.

Run with: pytest tests/test_external_signal.py -v
"""
import json
import pytest

from external_signal import ExternalSignalFeed
from research_memory import FutureDirectionsManager


class FakeArxivProvider:
    def __init__(self, papers):
        self.papers = papers
        self._idx = 0
        self.query = ""

    def set_query(self, query):
        self.query = query

    def get_next_paper(self, keywords=None):
        if self._idx >= len(self.papers):
            return None
        p = self.papers[self._idx]
        self._idx += 1
        return p


class FakePiAgent:
    def __init__(self, response):
        self.response = response

    def _call_ollama(self, system: str, user: str, timeout=None) -> str:
        return self.response

    def _parse_json_response(self, raw):
        try:
            return json.loads(raw)
        except Exception:
            return None


class TestArxivSignal:
    def test_fetch_arxiv_direction(self, tmp_path):
        paper = type("P", (), {
            "paper_id": "2401.00001",
            "title": "Tropical Geometry of Neural Networks",
            "authors": "A. Smith",
            "abstract": "We study tropical activations.",
            "categories": "cs.LG math.CO",
            "tex_content": "theorem tropical_nn : True := trivial",
            "source_url": "http://arxiv.org/abs/2401.00001",
        })()
        provider = FakeArxivProvider([paper])
        agent = FakePiAgent(json.dumps({
            "title": "Tropical NN Conjecture",
            "description": "Conjecture: tropical activations are piecewise linear. Test: verify on ReLU networks.",
            "domain": "MachineLearning",
            "catalog_references": [],
            "domain_bridges": ["MachineLearning <-> Tropical"],
            "ambition_level": "extension",
            "proof_strategy": "Use tropical semiring.",
            "lean_theorem_stub": "theorem tropical_relu : True := by sorry",
            "arxiv_id": "2401.00001",
        }))
        mgr = FutureDirectionsManager(tmp_path / "ws")
        feed = ExternalSignalFeed(agent, mgr)
        feed.arxiv_provider = provider
        directions = feed.fetch_arxiv_directions(domain="MachineLearning", count=1)
        assert len(directions) == 1
        assert directions[0].title == "Tropical NN Conjecture"
        assert directions[0].category == "cross_domain_bridge"


class TestOeisSignal:
    def test_parse_oeis_response(self, tmp_path):
        agent = FakePiAgent("")
        mgr = FutureDirectionsManager(tmp_path / "ws")
        feed = ExternalSignalFeed(agent, mgr)
        
        # Test dict format with 'results'
        sample_dict = {
            "results": [
                {"name": "Prime numbers", "data": "2,3,5,7,11,13", "keyword": "nonn", "number": "40"}
            ]
        }
        dirs_dict = feed._parse_oeis_results(sample_dict)
        assert len(dirs_dict) == 1
        assert dirs_dict[0].title == "OEIS sequence: Prime numbers"
        
        # Test direct list format
        sample_list = [
            {"name": "Fibonacci numbers", "data": "1,1,2,3,5,8", "keyword": "nonn", "number": "45"}
        ]
        dirs_list = feed._parse_oeis_results(sample_list)
        assert len(dirs_list) == 1
        assert dirs_list[0].title == "OEIS sequence: Fibonacci numbers"

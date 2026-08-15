"""TDD tests for the external signal feed.

Run with: pytest tests/test_external_signal.py -v
"""
import json
import pytest

from external_signal import ExternalSignalFeed
from research_memory import FutureDirection, FutureDirectionsManager


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


# ── Regression: stale ExternalSignalFeed must not clobber newer completions ──

class TestStaleManagerClobber:
    """The feed holds a FutureDirectionsManager constructed at extractor init.
    If a fresh manager marks a direction completed mid-tick (integration), the
    feed's in-memory copy is stale; saving a new external direction via
    add_direction must NOT serialize the stale state back to disk and revert
    the completion (the re-publish loop root cause).
    """

    def test_feed_add_does_not_revert_completed(self, tmp_path):
        ws = tmp_path / "ws"
        ws.mkdir()

        # Early manager: direction added and consumed (in_progress on disk).
        m_early = FutureDirectionsManager(ws)
        d = FutureDirection(
            id="fd_0001",
            title="Stale Clobber Direction",
            description="Prove that tropical semiring units form a group under min-plus composition.",
            source_exp_id="exp_001",
            source_path="test",
            domains=["Tropical"],
            priority_score=0.80,
        )
        m_early.add_direction(d)
        m_early.mark_direction_consumed("fd_0001", "job_001")

        # Feed constructed at "extractor init": its manager snapshot is in_progress.
        feed = ExternalSignalFeed(pi_agent=None, fd_manager=FutureDirectionsManager(ws), workspace=ws)
        assert feed.fd_manager.get_direction_by_id("fd_0001").status == "in_progress"

        # Mid-tick: a fresh manager completes the direction (integration path).
        fresh = FutureDirectionsManager(ws)
        fresh.mark_direction_completed("fd_0001")

        # The feed then adds a new external direction — must NOT clobber the completion.
        ext = FutureDirection(
            id="fd_0002",
            title="Fresh External Signal Direction",
            description="Investigate min-plus eigenvalue gaps yielding circuit lower bounds for parity languages.",
            source_exp_id="arxiv",
            source_path="arxiv",
            domains=["Tropical"],
            priority_score=0.80,
        )
        feed._add_directions([ext])

        reloaded = FutureDirectionsManager(ws)
        assert reloaded.get_direction_by_id("fd_0001").status == "completed"
        assert reloaded.get_direction_by_id("fd_0002") is not None

    def test_refresh_resyncs_manager_from_disk(self, tmp_path):
        ws = tmp_path / "ws"
        ws.mkdir()

        m_early = FutureDirectionsManager(ws)
        d = FutureDirection(
            id="fd_0011",
            title="Refresh Resync Direction",
            description="Classify min-plus automata recognizing weighted languages via tropical Myhill-Nerode theory.",
            source_exp_id="exp_001",
            source_path="test",
            domains=["Tropical"],
            priority_score=0.80,
        )
        m_early.add_direction(d)
        m_early.mark_direction_consumed("fd_0011", "job_011")

        feed = ExternalSignalFeed(pi_agent=None, fd_manager=FutureDirectionsManager(ws), workspace=ws)

        # A fresh manager completes the direction while the feed still holds stale state.
        FutureDirectionsManager(ws).mark_direction_completed("fd_0011")

        # refresh() exercises the resync path (may or may not add directions).
        feed.refresh(count_per_source=1)
        reloaded = FutureDirectionsManager(ws)
        assert reloaded.get_direction_by_id("fd_0011").status == "completed"

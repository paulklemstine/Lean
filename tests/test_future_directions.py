"""Tests for Aether/research_memory.py — FutureDirectionsManager logic."""

import sys
from pathlib import Path
from tempfile import mkdtemp

import pytest

# Ensure Aether/ is on sys.path for imports
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "Aether"))


class TestInferDomainsFixA:
    """The root-cause bug: _infer_domains must return [] on no match."""

    def test_no_bridges_fallback(self):
        from research_memory import FutureDirectionsManager

        tmpdir = mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        result = mgr._infer_domains("The quick brown fox jumps over the lazy dog")
        assert result == [], f"Expected [], got {result}"

    def test_known_domain_still_works(self):
        from research_memory import FutureDirectionsManager

        tmpdir = mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        result = mgr._infer_domains("Prove a Goldbach conjecture about primes")
        assert len(result) >= 1


def _write_pool(tmpdir, directions):
    """Write a directions pool JSON and return the workspace path."""
    import json

    p = Path(tmpdir) / "future_directions.json"
    p.write_text(json.dumps({"directions": directions}))
    return Path(tmpdir)


def _injected_direction(did, issue, priority=1000.0):
    """An owner-approved github_injection direction (priority 1000 by design)."""
    return {
        "id": did, "title": f"Injected {did}",
        "description": "x" * 100, "status": "available",
        "source_exp_id": "github", "source_path": "github",
        "priority_score": priority, "source": "github_injection",
        "github_issue": issue,
    }


def _regular_direction(did, priority=0.5):
    """A self-generated pool direction."""
    return {
        "id": did, "title": f"Pool {did}",
        "description": "y" * 100, "status": "available",
        "source_exp_id": "exp_test", "source_path": "test",
        "priority_score": priority,
    }


class TestTournamentInjectedExemption:
    """Owner-approved (github_injection) directions must never be
    tournament candidates and never tournament-pruned.

    Regression 2026-08-21: GitHub issues #157 and #159 were pruned by the
    direction tournament with an EMPTY justification at attempt_count=0 —
    before ever being dispatched — and close_orphaned_issues then closed
    their issues with the false message "Aether has already processed this
    direction". Root cause: injected directions carry priority_score=1000,
    which sorts them to the FRONT of every tournament candidate batch.
    """

    def test_candidate_batch_excludes_injected(self):
        """get_candidate_batch must never return github_injection directions."""
        from direction_tournament import DirectionTournament

        directions = [_injected_direction(f"fd_100{i}", issue=157 + i)
                      for i in range(3)]
        directions += [_regular_direction(f"fd_200{i}") for i in range(5)]
        tmpdir = _write_pool(mkdtemp(), directions)

        dt = DirectionTournament(workspace=tmpdir)
        batch = dt.get_candidate_batch(batch_size=10)

        batch_ids = [d.id for d in batch]
        assert all(not d.source == "github_injection" for d in batch), (
            f"Injected directions must not be tournament candidates, got {batch_ids}"
        )
        assert len(batch) == 5, f"Expected only the 5 pool directions, got {batch_ids}"

    def test_injected_sorts_first_without_fix(self):
        """Documents the bug mechanics: priority 1000 puts injected directions
        at the front of the naive priority sort — which is exactly why the
        exemption in get_candidate_batch is required."""
        from direction_tournament import DirectionTournament

        directions = [_injected_direction("fd_1000", issue=157),
                      _regular_direction("fd_2000", priority=0.9)]
        tmpdir = _write_pool(mkdtemp(), directions)

        dt = DirectionTournament(workspace=tmpdir)
        mgr = dt.FutureDirectionsManager(tmpdir)
        available = [d for d in mgr._directions if d.status == "available"]
        available.sort(key=lambda d: (bool(d.lean_theorem_stub), -d.priority_score))
        assert available[0].source == "github_injection", (
            "Precondition: without the exemption, the injected direction sorts first"
        )

    def test_apply_tournament_outcomes_never_prunes_injected(self):
        """The LIVE tournament write-back (DirectionTournament.apply_tournament_outcomes,
        called from knowledge_extractor) must refuse to prune injected directions,
        even if one somehow appears in the rejection list."""
        from direction_tournament import DirectionTournament

        directions = [_injected_direction("fd_1000", issue=157),
                      _regular_direction("fd_2000")]
        tmpdir = _write_pool(mkdtemp(), directions)
        dt = DirectionTournament(workspace=tmpdir)

        result = dt.apply_tournament_outcomes(
            winners=[{"id": "fd_2000", "reason": "winner", "lean_stub": "theorem foo : True"}],
            rejections=[{"id": "fd_1000", "reason": "too speculative"}],
            dispatched_ids={"fd_1000", "fd_2000"},
        )

        mgr = dt.FutureDirectionsManager(tmpdir)
        injected = next(d for d in mgr._directions if d.id == "fd_1000")
        assert injected.status == "available", (
            f"Injected direction must never be pruned, got {injected.status}"
        )
        assert injected.prune_reason == "", "No prune reason should be set"
        assert result["retired"] == 0, "Retired count must not include injected directions"

    def test_empty_rejection_reason_gets_default(self):
        """An empty/whitespace rejection reason must be replaced by the
        default text — never recorded as a bare 'tournament_rejected: '.
        Exercises the LIVE apply_tournament_outcomes path."""
        from direction_tournament import DirectionTournament

        directions = [_regular_direction(f"fd_200{i}") for i in range(3)]
        tmpdir = _write_pool(mkdtemp(), directions)
        dt = DirectionTournament(workspace=tmpdir)

        dt.apply_tournament_outcomes(
            winners=[],
            rejections=[{"id": "fd_2000", "reason": ""},
                        {"id": "fd_2001", "reason": "   "},
                        "fd_2002"],
            dispatched_ids={"fd_2000", "fd_2001", "fd_2002"},
        )

        mgr = dt.FutureDirectionsManager(tmpdir)
        d0 = next(d for d in mgr._directions if d.id == "fd_2000")
        d1 = next(d for d in mgr._directions if d.id == "fd_2001")
        d2 = next(d for d in mgr._directions if d.id == "fd_2002")
        assert d0.prune_reason == "tournament_rejected: rejected in aristotle tournament"
        assert d1.prune_reason == "tournament_rejected: rejected in aristotle tournament"
        # A bare ID string normalizes to reason="" -> default text, not bare colon
        assert d2.prune_reason == "tournament_rejected: rejected in aristotle tournament"


class TestOrphanCloserTruthfulMessage:
    """close_orphaned_issues must tell the truth about WHY an issue is closed.

    Regression 2026-08-21: issues #157/#159 were closed with "Aether has
    already processed this direction" when in fact the direction had been
    tournament-rejected before any research ran.
    """

    def _run_closer(self, tmpdir, direction):
        import json
        import github_injector
        from unittest.mock import patch

        fd_file = Path(tmpdir) / "future_directions.json"
        fd_file.write_text(json.dumps({"directions": [direction]}))

        comments = []

        def fake_gh(args):
            if args[:2] == ["issue", "view"]:
                return '{"state": "OPEN"}'
            if args[:2] == ["issue", "comment"]:
                comments.append(args[-1])
            return ""

        with patch.object(github_injector, "run_gh_command", side_effect=fake_gh):
            closed = github_injector.close_orphaned_issues(Path(tmpdir))
        return closed, comments

    def test_tournament_rejected_issue_gets_truthful_comment(self):
        closed, comments = self._run_closer(mkdtemp(), {
            "id": "fd_0001", "title": "Rejected direction",
            "description": "x" * 100, "status": "pruned",
            "source_exp_id": "github", "source_path": "github",
            "source": "github_injection", "github_issue": 42,
            "prune_reason": "tournament_rejected: too speculative",
        })
        assert closed == 1
        assert len(comments) == 1
        assert "tournament_rejected" in comments[0], (
            f"Comment must state the real reason, got: {comments[0]!r}"
        )
        assert "already processed" not in comments[0]

    def test_completed_issue_keeps_original_comment(self):
        closed, comments = self._run_closer(mkdtemp(), {
            "id": "fd_0001", "title": "Completed direction",
            "description": "x" * 100, "status": "completed",
            "source_exp_id": "github", "source_path": "github",
            "source": "github_injection", "github_issue": 43,
        })
        assert closed == 1
        assert comments == ["Aether has already processed this direction. Closing as handled."]

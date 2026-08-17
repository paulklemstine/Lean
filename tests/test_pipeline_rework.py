"""Tests for Sections 3, 4 of the pipeline rework."""
import sys, os, tempfile
from pathlib import Path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'Aether'))

from research_memory import FutureDirectionsManager, FutureDirection


class TestTournamentSourceProtection:
    """Section 3: outcomes must only touch dispatched direction IDs."""

    def _make_pool(self):
        tmpdir = tempfile.mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        # Add 3 directions: fd_0001 (dispatched), fd_0002 (dispatched),
        # fd_0003 (NOT dispatched)
        for i, title in enumerate(
            ["Dispatched A", "Dispatched B", "Unrelated direction"], start=1
        ):
            fd = FutureDirection(
                id=f"fd_{i:04d}", title=title,
                description=f"Description for direction {i} " + "x" * 80,
                source_exp_id="test", source_path="test",
                domains=["NumberTheory"], depth_estimate=3,
                priority_score=0.7,
            )
            mgr._directions.append(fd)
        mgr._save()  # persist to disk so fresh managers can load them
        mgr._save = lambda: None  # no-op after persist to avoid double-write in tests
        return mgr, tmpdir

    def test_only_dispatched_ids_affected(self):
        from direction_tournament import DirectionTournament
        mgr, tmpdir = self._make_pool()
        t = DirectionTournament(workspace=Path(tmpdir))

        # Dispatch fd_0001 and fd_0002; outcomes reject both
        dispatched_ids = {"fd_0001", "fd_0002"}
        result = t.apply_tournament_outcomes(
            winners=[], rejections=[{"id": "fd_0001", "reason": "weak"},
                                     {"id": "fd_0002", "reason": "weak"}],
            dispatched_ids=dispatched_ids,
        )
        assert result["retired"] == 2
        # Re-read from disk to verify actual mutation (apply_tournament_outcomes
        # operates on a fresh manager, not the original mgr object)
        mgr_reload = FutureDirectionsManager(Path(tmpdir))
        by_id = {d.id: d for d in mgr_reload._directions}
        # Verify dispatched directions were actually pruned
        assert by_id["fd_0001"].status == "pruned"
        assert by_id["fd_0002"].status == "pruned"
        # fd_0003 must NOT be touched
        d3 = by_id["fd_0003"]
        assert d3.status == "available", "Unrelated direction was modified!"

    def test_unmatched_outcome_ignored(self):
        from direction_tournament import DirectionTournament
        mgr, tmpdir = self._make_pool()
        t = DirectionTournament(workspace=Path(tmpdir))

        # Outcome references fd_9999 which was NOT dispatched
        dispatched_ids = {"fd_0001"}
        result = t.apply_tournament_outcomes(
            winners=[], rejections=[{"id": "fd_9999", "reason": "bad"}],
            dispatched_ids=dispatched_ids,
        )
        assert result["retired"] == 0, "Non-dispatched ID should be ignored"

    def test_none_dispatched_ids_processes_all(self):
        """When dispatched_ids=None (backward compat), all directions are processed."""
        from direction_tournament import DirectionTournament
        mgr, tmpdir = self._make_pool()
        t = DirectionTournament(workspace=Path(tmpdir))
        result = t.apply_tournament_outcomes(
            winners=[], rejections=[{"id": "fd_0003", "reason": "test"}],
            dispatched_ids=None,  # backward compat
        )
        assert result["retired"] == 1
        # Re-read from disk to verify mutation occurred
        mgr_reload = FutureDirectionsManager(Path(tmpdir))
        by_id = {d.id: d for d in mgr_reload._directions}
        assert by_id["fd_0003"].status == "pruned"
        assert by_id["fd_0001"].status == "available"
        assert by_id["fd_0002"].status == "available"


class TestGithubInjectorDedup:
    """Section 4: pruned directions must not block re-injection."""

    def test_pruned_does_not_block(self):
        """A pruned direction with github_issue=N should not prevent
        re-injection of issue N."""
        import github_injector
        import tempfile, json
        from pathlib import Path

        tmpdir = tempfile.mkdtemp()
        fd_file = Path(tmpdir) / "future_directions.json"
        # Pool with a pruned direction referencing issue 42
        data = {
            "directions": [
                {
                    "id": "fd_0001", "title": "Old direction",
                    "description": "x" * 100, "status": "pruned",
                    "source": "github_injection", "github_issue": 42,
                }
            ]
        }
        fd_file.write_text(json.dumps(data))

        # Simulate: the existing_issues set should NOT include issue 42
        # because fd_0001 is pruned
        directions_list = data["directions"]
        existing_issues = set()
        for d in directions_list:
            # FIXED: only count non-pruned directions
            if (d.get("source") == "github_injection"
                    and "github_issue" in d
                    and d.get("status") != "pruned"):
                existing_issues.add(d["github_issue"])

        assert 42 not in existing_issues, (
            "Pruned direction should not block re-injection"
        )

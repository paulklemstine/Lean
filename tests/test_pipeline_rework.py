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
        re-injection of issue N via the real production function."""
        import json
        import github_injector
        from unittest.mock import patch

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

        # Mock fetch to return issue 42 as an open issue
        fake_issue = [{"number": 42, "title": "Reopened issue",
                       "body": "Fresh content for issue 42"}]
        with patch.object(github_injector, "fetch_injected_directions",
                          return_value=fake_issue):
            count = github_injector.inject_directions_into_memory(Path(tmpdir))

        assert count == 1, f"Expected 1 injection (issue 42 re-injected), got {count}"
        # Verify the new direction was written to disk
        written = json.loads(fd_file.read_text())
        issue_nums = [d["github_issue"] for d in written["directions"]]
        assert 42 in issue_nums, "Issue 42 should have been re-injected"

    def test_live_direction_still_blocks(self):
        """A non-pruned direction with github_issue=N still blocks
        re-injection of issue N (normal dedup still works)."""
        import json
        import github_injector
        from unittest.mock import patch

        tmpdir = tempfile.mkdtemp()
        fd_file = Path(tmpdir) / "future_directions.json"
        data = {
            "directions": [
                {
                    "id": "fd_0001", "title": "Active direction",
                    "description": "x" * 100, "status": "available",
                    "source": "github_injection", "github_issue": 42,
                }
            ]
        }
        fd_file.write_text(json.dumps(data))

        fake_issue = [{"number": 42, "title": "Same issue",
                       "body": "Should not be injected again"}]
        with patch.object(github_injector, "fetch_injected_directions",
                          return_value=fake_issue):
            count = github_injector.inject_directions_into_memory(Path(tmpdir))

        assert count == 0, f"Expected 0 injections (issue 42 already live), got {count}"


class TestPhaseBGateParity:
    """Section 4: docstring/code parity on the Phase B gate."""

    def test_gate_returns_p50_not_p70(self):
        """The code computes p50; verify it doesn't return p70."""
        import knowledge_extractor
        import tempfile, json
        from pathlib import Path

        tmpdir = tempfile.mkdtemp()
        analytics_path = Path(tmpdir) / "cycle_analytics.json"
        # Create 10 records with known scores
        records = [{"phase": "A_only", "quality_score": i / 10.0}
                   for i in range(10)]
        analytics_path.write_text(json.dumps({"records": records}))

        ke = object.__new__(knowledge_extractor.KnowledgeExtractor)
        ke.workspace = Path(tmpdir)
        threshold = ke._adaptive_phase_b_threshold()
        # With scores [0.0, 0.1, 0.2, ..., 0.9], p50 index = int(0.5*9)=4
        # so threshold = sorted[4] = 0.4 (integer truncation, not rounding)
        assert abs(threshold - 0.4) < 0.01, (
            f"Expected p50≈0.4 (int-truncated median), got {threshold}"
        )

    def test_clamp_upper_is_055(self):
        """Upper clamp is 0.55, not 0.70."""
        import knowledge_extractor
        import tempfile, json
        from pathlib import Path

        tmpdir = tempfile.mkdtemp()
        records = [{"phase": "A_only", "quality_score": 0.9}
                   for _ in range(20)]
        analytics_path = Path(tmpdir) / "cycle_analytics.json"
        analytics_path.write_text(json.dumps({"records": records}))

        ke = object.__new__(knowledge_extractor.KnowledgeExtractor)
        ke.workspace = Path(tmpdir)
        threshold = ke._adaptive_phase_b_threshold()
        assert abs(threshold - 0.55) < 0.01, (
            f"Expected clamp to pin at 0.55, got {threshold}"
        )


class TestCorpusRegression:
    """Validate against the full real corpus: 1186 blobs.
    Frozen numbers from the v2b prototype validation run."""

    MIN_DIRECTIONS = 4661
    MAX_ZERO_ADDS = 4
    MAX_JUNK = 0

    def test_corpus_metrics(self):
        """The core regression: 1186 blobs, >=4661 dirs, <=4 zero-add, 0 junk."""
        import json, glob, os
        from pathlib import Path
        from research_memory import FutureDirectionsManager
        from fd_splitter import split_directions_from_text

        PACKAGES = Path(__file__).parent.parent / "Packages"
        samples = []

        # Collect future_directions from package JSONs
        for f in sorted(glob.glob(str(PACKAGES / "*.json"))):
            fn = os.path.basename(f)
            if fn.startswith(("future_directions", "lineage", "package_index")):
                continue
            try:
                p = json.load(open(f))
            except Exception:
                continue
            if isinstance(p, dict) and p.get("future_directions"):
                fd = p["future_directions"]
                if isinstance(fd, str) and len(fd.strip()) > 40:
                    samples.append(("pkg:" + fn, fd))

        # Collect # -prefixed pool descriptions
        try:
            data = json.load(open(PACKAGES / "future_directions.json"))
            for d in data.get("directions", []):
                if isinstance(d, dict):
                    de = d.get("description", "")
                    if (isinstance(de, str) and de.strip().startswith("#")
                            and len(de) > 80):
                        samples.append(("pool:" + str(d.get("id", "")), de))
        except Exception:
            pass

        # Dedup by leading text
        seen = set()
        uniq = []
        for lab, t in samples:
            h = t.strip()[:200]
            if h not in seen:
                seen.add(h)
                uniq.append((lab, t))

        total = 0
        zero_adds = []
        junk_count = 0
        # Narrow recap-style patterns only — no math terminology
        BAD = [
            "natural next steps", "what was", "what survived",
            "what failed", "what this", "next steps", "future directions",
            "concrete next steps",
        ]

        import tempfile
        for i, (lab, t) in enumerate(uniq):
            ws = Path(tempfile.mkdtemp())
            mgr = FutureDirectionsManager(ws)
            mgr._save = lambda: None
            added, _ = split_directions_from_text(mgr, t, "ev", "fd_md")
            total += max(0, added)
            if added == 0:
                zero_adds.append(lab)
            for d in mgr._directions:
                tl = d.title.lower()
                if any(b in tl for b in BAD):
                    junk_count += 1

        assert total >= self.MIN_DIRECTIONS, (
            f"Expected >= {self.MIN_DIRECTIONS} directions, got {total}"
        )
        assert len(zero_adds) <= self.MAX_ZERO_ADDS, (
            f"Expected <= {self.MAX_ZERO_ADDS} zero-adds, got {len(zero_adds)}: {zero_adds}"
        )
        assert junk_count <= self.MAX_JUNK, (
            f"Expected <= {self.MAX_JUNK} junk titles, got {junk_count}"
        )

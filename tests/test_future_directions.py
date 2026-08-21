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


class TestSaveResilience:
    """Batch 1 defuse: the auto-archive time bomb and the corrupt-JSON pool wipe.

    Regression basis (audit 2026-08-21): the live archive contained a legacy
    bare-list part (archive_part_0006.json); archive_completed_directions calls
    .get() on it, the AttributeError escapes _save BEFORE the pool is written,
    and every subsequent save fails permanently once a 51st direction completes.
    Separately, _load's bare except turns one corrupt read of the 6.3MB pool
    into a silent empty pool that the next save persists to git.
    """

    def _mgr(self, tmpdir, directions):
        from research_memory import FutureDirectionsManager

        _write_pool(tmpdir, directions)
        return FutureDirectionsManager(Path(tmpdir))

    def _completed(self, n, start=0):
        dirs = [_regular_direction(f"fd_30{i:02d}") for i in range(start, start + n)]
        for d in dirs:
            d["status"] = "completed"
        return dirs

    def test_archive_survives_legacy_list_part(self):
        """A legacy bare-list archive part must be normalized, not crash the archiver."""
        import json

        tmpdir = mkdtemp()
        directions = self._completed(51)
        tmpdir = _write_pool(tmpdir, directions)
        archive_dir = Path(tmpdir) / "completed_directions_archive"
        archive_dir.mkdir()
        # Legacy part: bare JSON list, as archive_part_0006.json is on disk
        legacy = [{"id": "fd_0001", "title": "old", "status": "completed"}]
        (archive_dir / "archive_part_0001.json").write_text(json.dumps(legacy))

        mgr = self._mgr(tmpdir, directions)
        result = mgr.archive_completed_directions(keep_recent=50, max_per_file=200)

        assert result["archived"] >= 1
        # The legacy part must have been rewritten in dict format
        data = json.loads((archive_dir / "archive_part_0001.json").read_text())
        assert isinstance(data, dict) and "directions" in data

    def test_save_persists_even_if_archiver_raises(self):
        """An archiver exception must never block _save from persisting the pool."""
        from research_memory import FutureDirectionsManager

        tmpdir = mkdtemp()
        directions = self._completed(51)
        mgr = self._mgr(tmpdir, directions)
        mgr.archive_completed_directions = lambda **kw: (_ for _ in ()).throw(
            RuntimeError("boom"))

        mgr._save()  # must not raise

        import json
        saved = json.loads((Path(tmpdir) / "future_directions.json").read_text())
        assert len(saved["directions"]) == 51, "Pool must be persisted despite archiver failure"

    def test_corrupt_pool_file_backed_up_with_loud_error(self):
        """One corrupt read must leave a .corrupt- backup and print an error —
        never silently proceed with an empty pool."""
        import json as _json

        from research_memory import FutureDirectionsManager

        tmpdir = mkdtemp()
        p = Path(tmpdir) / "future_directions.json"
        p.write_text('{"directions": [ TRUNCATED')

        mgr = FutureDirectionsManager(Path(tmpdir))  # must not raise

        backups = list(Path(tmpdir).glob("future_directions.json.corrupt-*"))
        assert backups, "Corrupt file must be preserved for forensics"
        assert backups[0].read_text() == '{"directions": [ TRUNCATED'

    def test_save_is_atomic_no_tmp_left(self):
        """_save writes via tmp+rename: valid JSON lands, no .tmp siblings remain."""
        import json

        tmpdir = mkdtemp()
        mgr = self._mgr(tmpdir, [_regular_direction("fd_3001")])
        mgr._save()

        assert json.loads((Path(tmpdir) / "future_directions.json").read_text())
        assert not list(Path(tmpdir).glob("*.tmp")), "Atomic write must clean up its tmp file"


class TestStaleRecoverySafety:
    """Batch 2: stale recovery must never fight live jobs or failed records.

    Audit 2026-08-21: age-based recovery re-dispatched injected directions
    whose research chain outlived 24h from discover (live pool showed
    attempt_count=47), and manager-internal recovery marked directions
    completed for FAILED jobs, silently consuming their retry slot.
    """

    def _mgr(self, tmpdir, directions):
        from research_memory import FutureDirectionsManager

        _write_pool(tmpdir, directions)
        return FutureDirectionsManager(Path(tmpdir))

    def _in_progress(self, did, job_id, age_hours):
        d = _regular_direction(did)
        d["status"] = "in_progress"
        d["consumed_by_exp_id"] = job_id
        from datetime import datetime, timezone, timedelta

        ts = datetime.now(timezone.utc) - timedelta(hours=age_hours)
        d["last_attempt_time"] = ts.isoformat()
        return d

    def test_age_recovery_skips_active_inflight_jobs(self):
        import json

        tmpdir = mkdtemp()
        d = self._in_progress("fd_4001", "job_live", age_hours=48)
        tmpdir = _write_pool(tmpdir, [d])
        # The job is still active in inflight_jobs.json
        (Path(tmpdir) / "inflight_jobs.json").write_text(json.dumps(
            {"proj1": {"job_id": "job_live", "status": "dispatched"}}))

        mgr = self._mgr(tmpdir, [d])
        recovered = mgr.recover_stale_directions(max_age_hours=24)

        assert recovered == 0, "A direction with a live job must never be age-reset"
        assert mgr._directions[0].status == "in_progress"

    def test_age_recovery_releases_truly_stale(self):
        tmpdir = mkdtemp()
        d = self._in_progress("fd_4001", "job_gone", age_hours=48)
        mgr = self._mgr(tmpdir, [d])

        mgr.recover_stale_directions(max_age_hours=24)

        # Construction-time internal recovery may release it first; either way
        # the end state must be available (no live job, analytics, or grace).
        assert mgr._directions[0].status == "available"

    def test_internal_recovery_never_marks_failed_jobs_completed(self):
        import json

        tmpdir = mkdtemp()
        d = self._in_progress("fd_4001", "job_failed", age_hours=48)
        tmpdir = _write_pool(tmpdir, [d])
        # Analytics recorded the job as FAILED
        (Path(tmpdir) / "cycle_analytics.json").write_text(json.dumps(
            {"records": [{"job_id": "job_failed", "failed": True,
                          "error_message": "dispatch error"}]}))

        mgr = self._mgr(tmpdir, [d])
        mgr._recover_stale_directions()

        assert mgr._directions[0].status == "available", (
            "A failed job's direction must return to the pool, not be marked completed"
        )

    def test_tournament_outcomes_skip_in_progress_candidates(self):
        """A candidate dispatched for real research after batch selection must
        not be retired by the tournament's stale verdict."""
        from datetime import datetime, timezone

        from direction_tournament import DirectionTournament

        d = _regular_direction("fd_5001")
        d["status"] = "in_progress"
        d["consumed_by_exp_id"] = "job_x"
        # Fresh attempt time: without it, construction-time stale recovery
        # releases the fixture before the tournament path runs.
        d["last_attempt_time"] = datetime.now(timezone.utc).isoformat()
        tmpdir = _write_pool(mkdtemp(), [d])
        dt = DirectionTournament(workspace=tmpdir)

        result = dt.apply_tournament_outcomes(
            winners=[],
            rejections=[{"id": "fd_5001", "reason": "weak"}],
            dispatched_ids={"fd_5001"},
        )

        mgr = dt.FutureDirectionsManager(tmpdir)
        assert mgr._directions[0].status == "in_progress"
        assert result["retired"] == 0


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


class TestStrayCloseGuard:
    """A comment-less issue closure must not kill live research.

    Audit 2026-08-21: #162/#167/#169/#170 were retired because their issues
    were found closed while their jobs were dispatched/queued.
    """

    def _mgr_with_live(self, tmpdir, issue, job_id):
        import json

        from research_memory import FutureDirectionsManager

        d = _injected_direction("fd_6001", issue=issue)
        d["status"] = "in_progress"
        d["consumed_by_exp_id"] = job_id
        # The job must be live in inflight_jobs.json, or construction-time
        # stale recovery releases the fixture before the guard runs.
        tmpdir = _write_pool(tmpdir, [d])
        (Path(tmpdir) / "inflight_jobs.json").write_text(json.dumps(
            {"proj": {"job_id": job_id, "status": "dispatched"}}))
        return FutureDirectionsManager(Path(tmpdir))

    def test_stray_closed_detected(self):
        mgr = self._mgr_with_live(mkdtemp(), issue=167, job_id="job_live")
        strays = mgr.stray_closed_injected_directions(
            open_issue_numbers=[158, 159],  # 167 NOT open
            live_job_ids={"job_live"},
        )
        assert len(strays) == 1 and strays[0].github_issue == 167

    def test_open_issue_not_flagged(self):
        mgr = self._mgr_with_live(mkdtemp(), issue=167, job_id="job_live")
        strays = mgr.stray_closed_injected_directions(
            open_issue_numbers=[167], live_job_ids={"job_live"})
        assert strays == []

    def test_dead_job_not_flagged(self):
        mgr = self._mgr_with_live(mkdtemp(), issue=167, job_id="job_done")
        strays = mgr.stray_closed_injected_directions(
            open_issue_numbers=[158], live_job_ids={"other_job"})
        assert strays == []

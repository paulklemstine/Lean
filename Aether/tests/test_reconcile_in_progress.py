"""TDD test for tick-end in_progress reconciliation.

in_progress must reflect the true state of active inflight jobs at tick end:
- a 'preparing' job's direction (not yet marked in_progress) -> in_progress
- a retrying job's direction (left completed/failed by the original attempt,
  keyed by retry_of) -> in_progress
- a stale in_progress with no active job is left untouched (recover_stale handles it)
"""
from research_memory import FutureDirection, FutureDirectionsManager


def _dir(did, title, desc, consumed_by, status):
    d = FutureDirection(
        id=did, title=title, description=desc,
        source_exp_id="s", source_path="s", domains=["Algebra"], priority_score=0.7,
    )
    d.consumed_by_exp_id = consumed_by
    d.status = status
    return d


def test_reconcile_in_progress_matches_active_jobs(tmp_path):
    ws = tmp_path / "ws"
    ws.mkdir()
    mgr = FutureDirectionsManager(ws)

    # d1: consumed by jobA (a 'preparing' job) but status left 'available' (the gap)
    d1 = _dir("d1", "Preparing job direction",
              "unique alpha beta gamma delta epsilon zeta eta theta iota.", "jobA", "available")
    # d2: consumed by jobB's ORIGINAL id (a retry) but status 'completed'
    d2 = _dir("d2", "Retrying job direction",
              "unique kappa lambda mu nu xi omicron pi rho sigma tau upsilon.", "jobB_orig", "completed")
    # d3: already in_progress, active
    d3 = _dir("d3", "Active in progress",
              "unique phi chi psi omega aa bb cc dd ee ff gg hh.", "jobC", "in_progress")
    # d4: in_progress but jobD NOT active (stale) — reconcile must NOT touch it
    d4 = _dir("d4", "Stale in progress",
              "unique ii jj kk ll mm nn oo pp qq rr ss tt uu.", "jobD", "in_progress")

    for d in (d1, d2, d3, d4):
        mgr._directions.append(d)
    mgr._save()

    # active jobs: jobA (preparing, key=jobA), jobB (retry_of=jobB_orig, key=jobB_orig), jobC. jobD NOT active.
    active_keys = {"jobA", "jobB_orig", "jobC"}
    n = mgr.reconcile_in_progress(active_keys)

    assert n == 2, f"expected 2 reconciled (d1, d2), got {n}"
    # Check in-memory state (a fresh FutureDirectionsManager would run recover_stale_directions
    # on load and reset stale in_progress, which is the correct separate behavior).
    by_id = {d.id: d.status for d in mgr._directions}
    assert by_id["d1"] == "in_progress", "preparing job's direction must be reconciled to in_progress"
    assert by_id["d2"] == "in_progress", "retrying job's direction must be reconciled to in_progress"
    assert by_id["d3"] == "in_progress"
    assert by_id["d4"] == "in_progress", "stale in_progress must be left untouched (recover_stale handles it)"


def test_reconcile_in_progress_noop_when_clean(tmp_path):
    """If all active jobs' directions are already in_progress, reconcile changes nothing."""
    ws = tmp_path / "ws"; ws.mkdir()
    mgr = FutureDirectionsManager(ws)
    d = _dir("d1", "Already active", "unique zz yy xx ww vv uu tt ss rr qq pp oo nn.", "jobA", "in_progress")
    mgr._directions.append(d); mgr._save()
    n = mgr.reconcile_in_progress({"jobA"})
    assert n == 0
    assert mgr._directions[0].status == "in_progress"
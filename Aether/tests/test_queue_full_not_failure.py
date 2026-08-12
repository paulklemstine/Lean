#!/usr/bin/env python3
"""Regression tests: a transient "Queue full" dispatch condition must never
cause a later-successful job to be treated as a failure.

Bug: dispatch_async / dispatch set ``job.error_message = "Queue full: ..."``
when Aristotle is at capacity and the job is requeued. Nothing cleared that
message, so when the job was later re-dispatched and completed successfully,
the integrate step in aether_tick.py saw a truthy ``error_message`` and:

1. Released the direction back to available (``_release_direction``),
2. Killed the research thread (``_terminate_thread_for_job(..., "job_failed")``),
3. Discarded the successful result entirely.

Three real cycles (619c4714, 444f44fe, 0129ba2f) were thrown away this way in
a single tick on 2026-08-12. The direction must only be released if the job
genuinely fails, never for a queue-full / queued-for-retry condition.
"""

import pytest

from knowledge_extractor import KnowledgeExtractor, ResearchConcept, ResearchJob


def _make_concept(title):
    return ResearchConcept(
        title=title,
        domain="Algebra",
        concept_description="A research direction about %s." % title,
        mathematical_framing="Framing for %s." % title,
    )


def _make_extractor(tmp_path):
    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    return extractor


def _queued_job(job_id="q-1", phase="A"):
    job = ResearchJob(
        job_id=job_id,
        cycle_n=1,
        concept=_make_concept("Queued concept"),
        prompt="Research the queued concept.",
        status="retry_queued",
    )
    job.phase = phase
    job.retry_queued_time = 123.0
    job.direction_id = "fd_42"
    return job


# ---------------------------------------------------------------------------
# _is_queue_full_error must recognize the exact message that dispatch writes.
# ---------------------------------------------------------------------------

def test_is_queue_full_error_matches_exact_message(tmp_path):
    extractor = _make_extractor(tmp_path)
    msg = "Queue full: Aristotle capacity limit reached (9/9). Dispatch blocked."
    assert extractor._is_queue_full_error(msg) is True
    assert extractor._is_queue_full_error(RuntimeError(msg)) is True
    assert extractor._is_queue_full_error("A genuine research failure") is False


# ---------------------------------------------------------------------------
# _is_stale_dispatch_error: which messages are NOT genuine failures.
# ---------------------------------------------------------------------------

def test_stale_dispatch_error_recognizes_queue_full(tmp_path):
    extractor = _make_extractor(tmp_path)
    msg = "Queue full: Aristotle capacity limit reached (9/9). Dispatch blocked."
    assert extractor._is_stale_dispatch_error(msg) is True


def test_stale_dispatch_error_recognizes_queued_for_retry(tmp_path):
    extractor = _make_extractor(tmp_path)
    # poll_all's wall-clock HARD CAP requeues with this message; the job is
    # not failed, it is queued for another attempt.
    msg = "wall-clock cap exceeded (1.5h) — queued for retry (1/3)"
    assert extractor._is_stale_dispatch_error(msg) is True


def test_stale_dispatch_error_rejects_genuine_failures(tmp_path):
    extractor = _make_extractor(tmp_path)
    genuine = [
        "wall-clock cap exceeded (1.5h); no retries left",  # terminal, quarantined
        "Extraction failed: no result files",
        "Result download failed (2 attempts)",
        "API error: server returned 500",
        "Zombie no progress (12.0h)",
        "Unresponsive after finish instruction (canceled)",
        "Timed out after 172800s",
    ]
    for msg in genuine:
        assert extractor._is_stale_dispatch_error(msg) is False, msg


def test_stale_dispatch_error_handles_empty(tmp_path):
    extractor = _make_extractor(tmp_path)
    assert extractor._is_stale_dispatch_error(None) is False
    assert extractor._is_stale_dispatch_error("") is False


# ---------------------------------------------------------------------------
# _mark_requeued_dispatch_success: successful re-dispatch clears stale message.
# ---------------------------------------------------------------------------

def test_requeued_dispatch_success_clears_stale_error_message(tmp_path):
    extractor = _make_extractor(tmp_path)
    job = _queued_job(phase="A")
    job.error_message = "Queue full: Aristotle capacity limit reached (9/9). Dispatch blocked."
    extractor.inflight[job.job_id] = job

    extractor._mark_requeued_dispatch_success(job, "proj-abc")

    assert job.status == "dispatched"
    assert job.project_id == "proj-abc"
    assert job.error_message is None, "stale queue-full message must not survive re-dispatch"
    # Re-keyed from job_id -> project_id in inflight.
    assert job.job_id not in extractor.inflight
    assert extractor.inflight["proj-abc"] is job
    # The direction stays consumed/in_progress — it is NOT released on re-dispatch.
    assert job.direction_id == "fd_42"


def test_requeued_dispatch_success_phase_b_status(tmp_path):
    extractor = _make_extractor(tmp_path)
    job = _queued_job(phase="B")
    job.error_message = "Queue full: Aristotle capacity limit reached (9/9). Dispatch blocked."
    extractor.inflight[job.job_id] = job

    extractor._mark_requeued_dispatch_success(job, "proj-def")

    assert job.status == "B_dispatched"
    assert job.error_message is None
    assert extractor.inflight["proj-def"] is job

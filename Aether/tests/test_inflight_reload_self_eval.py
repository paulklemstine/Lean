#!/usr/bin/env python3
"""Regression tests for reloading inflight jobs that carry Aristotle self-evaluation data.

Bug: during integrate, ``job.result_self_evaluation`` / ``job.self_evaluation`` were
set as dynamic attributes (SELF_EVALUATION.json content). ``_save_inflight`` persisted
them, but ``ResearchJob`` had no corresponding dataclass fields, so ``_load_inflight``
called ``ResearchJob(**d)`` and raised ``TypeError: ... unexpected keyword argument
'result_self_evaluation'``, silently discarding every inflight job on restart.
"""

import json
from pathlib import Path

from knowledge_extractor import KnowledgeExtractor, ResearchConcept, ResearchJob


def _make_concept(title):
    return ResearchConcept(
        title=title,
        domain="Computation",
        concept_description="A research direction about %s." % title,
        mathematical_framing="Framing for %s." % title,
    )


def _make_extractor(tmp_path):
    config = {"autoresearch": {"max_inflight": 9}, "workspace": str(tmp_path)}
    extractor = KnowledgeExtractor(config=config)
    extractor.workspace = tmp_path
    return extractor


def test_inflight_roundtrip_preserves_self_evaluation(tmp_path):
    """A job whose self-evaluation was set must survive save -> reload intact."""
    extractor = _make_extractor(tmp_path)

    job = ResearchJob(
        job_id="abc-123",
        cycle_n=1,
        concept=_make_concept("Tropical matrix semirings"),
        prompt="Prove something about tropical matrix semirings.",
        status="dispatched",
    )
    # These are set during integrate when SELF_EVALUATION.json is parsed.
    job.result_self_evaluation = '{"quality_score": 0.85}'
    job.self_evaluation = '{"quality_score": 0.85}'
    extractor.inflight[job.job_id] = job

    extractor._save_inflight()
    assert (tmp_path / "inflight_jobs.json").exists()

    # Fresh instance: previously this raised TypeError and recovered 0 jobs.
    reloaded = _make_extractor(tmp_path)
    reloaded._load_inflight()

    assert job.job_id in reloaded.inflight
    recovered = reloaded.inflight[job.job_id]
    assert recovered.status == "dispatched"
    assert recovered.result_self_evaluation == '{"quality_score": 0.85}'
    assert recovered.self_evaluation == '{"quality_score": 0.85}'


def test_load_skips_unknown_keys_instead_of_crashing(tmp_path):
    """Defense-in-depth: stray/unknown keys are stripped, other jobs still load."""
    extractor = _make_extractor(tmp_path)

    good = ResearchJob(
        job_id="good-1",
        cycle_n=1,
        concept=_make_concept("p-adic interpolation"),
        prompt="Research p-adic interpolation.",
        status="dispatched",
    )
    bad = ResearchJob(
        job_id="bad-1",
        cycle_n=2,
        concept=_make_concept("A future-removed field"),
        prompt="Old job.",
        status="dispatched",
    )
    extractor.inflight[good.job_id] = good
    extractor.inflight[bad.job_id] = bad

    # Simulate a job serialized by older code carrying a key that no longer
    # exists on the dataclass (e.g. a field that was later removed/renamed).
    extractor._save_inflight()
    path = tmp_path / "inflight_jobs.json"
    data = json.loads(path.read_text())
    data[bad.job_id]["no_such_field_anymore"] = "stale"
    path.write_text(json.dumps(data, indent=2))

    reloaded = _make_extractor(tmp_path)
    reloaded._load_inflight()

    assert good.job_id in reloaded.inflight
    assert bad.job_id in reloaded.inflight
    assert "no_such_field_anymore" not in reloaded.inflight[bad.job_id].__dict__

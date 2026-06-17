"""TDD tests for the recursive abduction loop.

Run with: pytest tests/test_abduction_loop.py -v
"""
import json
import pytest

from research_threads import ResearchThreadManager


class FakePiAgent:
    def __init__(self, response):
        self.response = response

    def _call_ollama(self, system: str, user: str, timeout=None) -> str:
        return self.response

    def write_aristotle_prompt(self, *args, **kwargs):
        # Return a string that includes thread_context if provided
        thread_context = kwargs.get("thread_context", "")
        concept = kwargs.get("concept")
        title = concept.title if concept else "?"
        return f"## Research Thread Context\n{thread_context}\n\nConcept: {title}"


class TestThreadContextRecording:
    def test_concept_titles_recorded(self, tmp_path):
        mgr = ResearchThreadManager(tmp_path / "ws")
        t = mgr.start_thread("fd_0001", "job_a")
        t.cycle_concepts = ["Root conjecture"]
        mgr._save()

        mgr2 = ResearchThreadManager(tmp_path / "ws")
        loaded = mgr2.get_thread(t.thread_id)
        assert loaded.cycle_concepts == ["Root conjecture"]


class TestPromptAugmentation:
    def test_thread_context_in_prompt(self):
        agent = FakePiAgent("")
        # Minimal stand-in: the fake writer exposes thread_context in the prompt.
        prompt = agent.write_aristotle_prompt(
            concept=None,
            thread_context="Previous cycle proved Lemma A. Next: prove Lemma B.",
        )
        assert "Previous cycle proved Lemma A" in prompt

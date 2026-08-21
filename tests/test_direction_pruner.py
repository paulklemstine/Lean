# tests/test_direction_pruner.py
"""Tests for the direction pruner (tournament) prompt: merit-based keep/purge,
never a fixed quota. Regression 2026-08-21: the prompt's example JSON showed
exactly 2 winners + 2 rejections for a 10-candidate batch, anchoring the judge
into 'keep only 2 out of 10'."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'Aether'))

from direction_tournament import DirectionTournament, _normalize_entry


class _Dir:
    def __init__(self, did, title, desc):
        self.id = did
        self.title = title
        self.description = desc
        self.domains = ["NumberTheory"]
        self.lean_theorem_stub = ""
        self.priority_score = 0.5
        self.status = "available"
        self.source = ""


BATCH = [_Dir(f"fd_{i:04d}", f"Direction {i}", "Prove the conjecture. " * 5)
         for i in range(10)]


class TestPrunerPromptMeritBased:
    def test_no_count_anchoring_example(self):
        """The example JSON must not show a fixed 2-winner split."""
        prompt = DirectionTournament().build_tournament_prompt(BATCH)
        assert '"<id1>", "<id2>"' not in prompt, (
            "Example anchors the judge toward exactly 2 winners")
        assert "top 2" not in prompt.lower()
        assert "keep only" not in prompt.lower()
        assert "2 winners" not in prompt.lower()

    def test_merit_based_language_present(self):
        prompt = DirectionTournament().build_tournament_prompt(BATCH)
        low = " ".join(prompt.lower().split())  # normalize line wraps
        assert "decide" in low
        assert "no fixed number" in low
        assert "all 10" in low  # explicit 0..N range stated
        assert "purge" in low
        assert "do not split evenly" in low

    def test_rejections_require_reasons(self):
        prompt = DirectionTournament().build_tournament_prompt(BATCH)
        assert '"reason"' in prompt, (
            "Rejections must carry a specific mathematical justification")

    def test_all_candidates_listed(self):
        prompt = DirectionTournament().build_tournament_prompt(BATCH)
        for d in BATCH:
            assert d.id in prompt

    def test_target_winners_param_ignored(self):
        """Passing a quota must not change the prompt text."""
        dt = DirectionTournament()
        p1 = dt.build_tournament_prompt(BATCH, target_winners=2)
        p2 = dt.build_tournament_prompt(BATCH, target_winners=7)
        assert p1 == p2


class TestNormalizeEntry:
    def test_dict_with_reason(self):
        e = _normalize_entry({"id": "fd_0001", "reason": "redundant with fd_0002"})
        assert e == {"id": "fd_0001", "reason": "redundant with fd_0002"}

    def test_bare_string_empty_reason(self):
        assert _normalize_entry("fd_0001") == {"id": "fd_0001", "reason": ""}

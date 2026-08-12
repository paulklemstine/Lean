#!/usr/bin/env python3
"""Unit tests for Option B Direction Tournament."""

import os
import sys
import unittest
import tempfile
import json
from pathlib import Path

# Add Aether to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from research_memory import FutureDirectionsManager, FutureDirection
from direction_tournament import DirectionTournament


class TestDirectionTournament(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.workspace = Path(self.temp_dir.name)
        
        # Populate test directions
        self.dirs = [
            FutureDirection(
                id=f"dir_test_{i}",
                title=f"Test Conjecture {i}",
                description=f"Description for test conjecture {i} with sufficient mathematical detail.",
                source_exp_id="exp_test",
                source_path="test_path",
                domains=["Algebra"] if i % 2 == 0 else ["Topology"],
                priority_score=0.5 + (i * 0.05),
                status="available",
            )
            for i in range(1, 11)
        ]
        
        data = {
            "directions": [d.to_dict() for d in self.dirs],
            "pruned": [],
        }
        (self.workspace / "future_directions.json").write_text(json.dumps(data), encoding="utf-8")
        self.tournament = DirectionTournament(workspace=self.workspace)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_get_candidate_batch(self):
        batch = self.tournament.get_candidate_batch(batch_size=5)
        self.assertEqual(len(batch), 5)
        
        algebra_batch = self.tournament.get_candidate_batch(domain="Algebra", batch_size=10)
        self.assertTrue(all("Algebra" in d.domains for d in algebra_batch))

    def test_build_tournament_prompt(self):
        batch = self.tournament.get_candidate_batch(batch_size=3)
        prompt = self.tournament.build_tournament_prompt(batch, target_winners=1)

        self.assertIn("winners", prompt)
        self.assertIn("rejections", prompt)

    def test_load_tournament_results(self):
        """The JSON result file is loaded and normalized into id dicts."""
        import tempfile
        from pathlib import Path
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp)
            (p / "tournament_results.json").write_text(
                '{"winners": ["dir_test_1", "dir_test_2"],'
                ' "rejections": ["dir_test_3", {"id": "dir_test_4", "reason": "trivial"}]}'
            )
            res = self.tournament.load_tournament_results(p)
        self.assertIsNotNone(res)
        self.assertEqual([w["id"] for w in res["winners"]], ["dir_test_1", "dir_test_2"])
        self.assertEqual([r["id"] for r in res["rejections"]], ["dir_test_3", "dir_test_4"])
        self.assertEqual(res["rejections"][1]["reason"], "trivial")

    def test_parse_tournament_report(self):
        """Legacy Markdown fallback parser still extracts ids."""
        sample_report = """
## TOURNAMENT_RESULTS

### WINNERS
- ID: dir_test_2 (Title: Test Conjecture 2)
```lean
theorem test_conjecture_2 : 1 + 1 = 2 := by sorry
```

### REJECTIONS
- dir_test_1 : Trivial identity collapsing under basic simplification
- dir_test_3 : Redundant with existing Catalog/Algebra/Group.lean theorem
"""
        parsed = self.tournament.parse_tournament_report(sample_report)
        self.assertEqual(len(parsed["winners"]), 1)
        self.assertEqual(parsed["winners"][0]["id"], "dir_test_2")

        self.assertEqual(len(parsed["rejections"]), 2)
        self.assertEqual(parsed["rejections"][0]["id"], "dir_test_1")
        self.assertIn("Trivial identity", parsed["rejections"][0]["reason"])

    def test_parse_rejection_id_prefix_format(self):
        """Regression: '- ID: fd_0003: reason' must resolve to fd_0003, not 'ID'."""
        sample_report = """## TOURNAMENT_RESULTS

### WINNERS
- ID: dir_test_2
```lean
theorem test_conjecture_2 : 1 + 1 = 2 := by sorry
```

### REJECTIONS
- ID: dir_test_1: Trivial identity collapsing under basic simplification
- ID: dir_test_3: Redundant with existing Catalog theorem
- dir_test_4: Trivial consequence of the intermediate value theorem
"""
        parsed = self.tournament.parse_tournament_report(sample_report)
        rej_ids = [r["id"] for r in parsed["rejections"]]
        # Must NOT capture the literal "ID"; must capture the direction ids.
        self.assertNotIn("ID", rej_ids)
        self.assertIn("dir_test_1", rej_ids)
        self.assertIn("dir_test_3", rej_ids)
        self.assertIn("dir_test_4", rej_ids)
        self.assertEqual(len(rej_ids), 3)

    def test_apply_tournament_outcomes(self):
        # Entries may be plain IDs (from the JSON file) or dicts.
        winners = ["dir_test_2", {"id": "dir_test_5", "reason": ""}]
        rejections = [{"id": "dir_test_1", "reason": "Trivial"}, "dir_test_3"]

        res = self.tournament.apply_tournament_outcomes(winners, rejections)
        self.assertEqual(res["promoted"], 2)
        self.assertEqual(res["retired"], 2)

        mgr = FutureDirectionsManager(self.workspace)
        dir2 = next((d for d in mgr._directions if d.id == "dir_test_2"), None)
        self.assertIsNotNone(dir2)
        self.assertEqual(dir2.status, "available")
        self.assertEqual(dir2.priority_score, 0.90)

        dir1 = next((d for d in mgr._directions if d.id == "dir_test_1"), None)
        self.assertIsNotNone(dir1)
        self.assertEqual(dir1.status, "pruned")
        self.assertIn("tournament_rejected: Trivial", dir1.prune_reason)

        dir3 = next((d for d in mgr._directions if d.id == "dir_test_3"), None)
        self.assertIsNotNone(dir3)
        self.assertEqual(dir3.status, "pruned")
        # A plain-ID rejection with no reason gets the default message.
        self.assertIn("tournament_rejected", dir3.prune_reason)


if __name__ == "__main__":
    unittest.main()

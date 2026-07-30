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
        
        self.assertIn("ARISTOTLE DIRECTION TOURNAMENT EVALUATION", prompt)
        self.assertIn("Candidate 1", prompt)
        self.assertIn("Select the top 1 WINNER conjectures", prompt)

    def test_parse_tournament_report(self):
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
        self.assertIn("theorem test_conjecture_2", parsed["winners"][0]["lean_stub"])
        
        self.assertEqual(len(parsed["rejections"]), 2)
        self.assertEqual(parsed["rejections"][0]["id"], "dir_test_1")
        self.assertIn("Trivial identity", parsed["rejections"][0]["reason"])

    def test_apply_tournament_outcomes(self):
        winners = [{"id": "dir_test_2", "lean_stub": "theorem test_2 : True := by sorry"}]
        rejections = [{"id": "dir_test_1", "reason": "Trivial"}]

        res = self.tournament.apply_tournament_outcomes(winners, rejections)
        self.assertEqual(res["promoted"], 1)
        self.assertEqual(res["retired"], 1)

        mgr = FutureDirectionsManager(self.workspace)
        dir2 = next((d for d in mgr._directions if d.id == "dir_test_2"), None)
        self.assertIsNotNone(dir2)
        self.assertEqual(dir2.status, "available")
        self.assertEqual(dir2.priority_score, 0.90)
        self.assertIn("theorem test_2", dir2.lean_theorem_stub)

        dir1 = next((d for d in mgr._directions if d.id == "dir_test_1"), None)
        self.assertIsNotNone(dir1)
        self.assertEqual(dir1.status, "pruned")
        self.assertIn("tournament_rejected: Trivial", dir1.prune_reason)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Unit tests for completed directions auto-archiving and chunking."""

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

# Add Aether to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent))

from research_memory import FutureDirectionsManager, FutureDirection


class TestArchiveCompletedDirections(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.workspace = Path(self.temp_dir.name)
        self.packages_dir = self.workspace / "Packages"
        self.packages_dir.mkdir(parents=True, exist_ok=True)
        self.archive_dir = self.packages_dir / "completed_directions_archive"

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_archive_completed_directions_chunking(self):
        """Test archiving completed directions above keep_recent limit into chunk files."""
        # Create 120 completed directions and 10 available directions
        directions = []
        for i in range(120):
            directions.append(
                FutureDirection(
                    id=f"dir_comp_{i:04d}",
                    title=f"Completed Conjecture {i}",
                    description=f"Description for completed conjecture {i}",
                    source_exp_id=f"exp_{i}",
                    source_path="test_path",
                    status="completed",
                    timestamp=f"2026-07-01T{i%24:02d}:00:00Z",
                )
            )
        for i in range(10):
            directions.append(
                FutureDirection(
                    id=f"dir_avail_{i:04d}",
                    title=f"Available Conjecture {i}",
                    description=f"Description for available conjecture {i}",
                    source_exp_id=f"exp_avail_{i}",
                    source_path="test_path",
                    status="available",
                )
            )

        data = {
            "directions": [d.to_dict() for d in directions],
            "pruned": [],
        }
        fd_file = self.packages_dir / "future_directions.json"
        fd_file.write_text(json.dumps(data), encoding="utf-8")

        mgr = FutureDirectionsManager(self.workspace)
        mgr._file = fd_file  # Explicit test file binding

        # Perform archiving: keep 20 completed directions in memory, max 50 per archive file
        res = mgr.archive_completed_directions(keep_recent=20, max_per_file=50)

        self.assertEqual(res["archived"], 100)  # 120 total completed - 20 kept = 100 archived
        self.assertEqual(res["kept"], 20)
        self.assertEqual(res["archive_files"], 2)  # 100 items / 50 per file = 2 chunk files

        # Verify archive files exist and have max 50 items
        part1 = self.archive_dir / "archive_part_0001.json"
        part2 = self.archive_dir / "archive_part_0002.json"
        self.assertTrue(part1.exists())
        self.assertTrue(part2.exists())

        data1 = json.loads(part1.read_text(encoding="utf-8"))
        data2 = json.loads(part2.read_text(encoding="utf-8"))
        self.assertEqual(data1["count"], 50)
        self.assertEqual(data2["count"], 50)

        # Verify direction lookup fallback works for archived direction
        archived_dir = mgr.get_direction_by_id("dir_comp_0005")
        self.assertIsNotNone(archived_dir)
        self.assertEqual(archived_dir.id, "dir_comp_0005")

        # Verify stats output
        stats = mgr.get_stats()
        self.assertEqual(stats["completed"], 20)
        self.assertEqual(stats["archived_completed"], 100)
        self.assertEqual(stats["archived_files_count"], 2)


if __name__ == "__main__":
    unittest.main()

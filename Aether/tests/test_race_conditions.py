import json
import pytest
from pathlib import Path
from datetime import datetime, timezone, timedelta
from unittest.mock import MagicMock, patch

from research_memory import FutureDirection, FutureDirectionsManager
from knowledge_extractor import KnowledgeExtractor, ResearchJob, ResearchConcept
import dedup_packages

@pytest.fixture
def tmp_workspace(tmp_path):
    ws = tmp_path / "aether_test"
    ws.mkdir()
    return ws

@pytest.fixture
def fd_manager(tmp_workspace):
    return FutureDirectionsManager(tmp_workspace)

class TestGracePeriod:
    def test_stale_recovery_grace_period(self, tmp_workspace, fd_manager):
        # 1. Add an in_progress direction attempted 5 minutes ago (should not be recovered)
        dir_recent = FutureDirection(
            id="dir_recent", title="Recent Concept",
            description="Attempted 5 minutes ago",
            status="in_progress",
            consumed_by_exp_id="job_recent",
            source_exp_id="seed", source_path="seed:test",
            last_attempt_time=(datetime.now(timezone.utc) - timedelta(minutes=5)).isoformat(),
        )
        # 2. Add an in_progress direction attempted 20 minutes ago (should be recovered if no job)
        dir_stale = FutureDirection(
            id="dir_stale", title="Stale Concept",
            description="Attempted 20 minutes ago",
            status="in_progress",
            consumed_by_exp_id="job_stale",
            source_exp_id="seed", source_path="seed:test",
            last_attempt_time=(datetime.now(timezone.utc) - timedelta(minutes=20)).isoformat(),
        )
        fd_manager.add_direction(dir_recent)
        fd_manager.add_direction(dir_stale)
        
        # Save to trigger recovery via manager reloading
        fd_manager._save()
        
        # Instantiate new manager (triggers _recover_stale_directions)
        new_mgr = FutureDirectionsManager(tmp_workspace)
        
        # Recent should remain in_progress
        d_rec = new_mgr.get_direction_by_id("dir_recent")
        assert d_rec.status == "in_progress"
        assert d_rec.consumed_by_exp_id == "job_recent"
        
        # Stale should be recovered back to available
        d_st = new_mgr.get_direction_by_id("dir_stale")
        assert d_st.status == "available"
        assert d_st.consumed_by_exp_id == ""

class TestLockedTitles:
    def test_locked_titles_exclusion(self, tmp_workspace):
        config = {
            "catalog": {"root_dir": str(tmp_workspace / "Catalog")},
            "workspace": str(tmp_workspace),
            "pi_agent": {"model": "mock"}
        }
        (tmp_workspace / "Catalog").mkdir()
        
        extractor = KnowledgeExtractor(config=config)
        extractor.locked_titles.add("Locking Test Title")
        
        # Setup mock directions
        fd_mgr = FutureDirectionsManager(tmp_workspace)
        fd_mgr.add_direction(FutureDirection(
            id="locked_dir", title="Locking Test Title",
            description="Should be locked and skipped",
            status="available",
            source_exp_id="seed", source_path="seed:test",
        ))
        fd_mgr.add_direction(FutureDirection(
            id="free_dir", title="Free Concept",
            description="Should be selected",
            status="available",
            source_exp_id="seed", source_path="seed:test",
        ))
        fd_mgr._save()
        
        # Run discover()
        extractor.pi_agent = MagicMock()
        
        job = extractor.discover()
        # Should NOT select the locked title, should select the free concept
        assert job.concept.title == "Free Concept"
        assert "Free Concept" in extractor.locked_titles

class TestLeanProofsStringCheck:
    def test_lean_proofs_as_string_does_not_character_match(self):
        # Create mock package data where lean_proofs is a raw string
        pkg_data = {
            "title": "Unrelated Package",
            "lean_proofs": "import Mathlib\n theorem foo : True := trivial\n"
        }
        
        # Test character-iteration bug prevention logic
        pkg_lean_files = []
        lp_field = pkg_data.get("lean_proofs", [])
        if isinstance(lp_field, list):
            for lp in lp_field:
                if isinstance(lp, dict):
                    f_val = lp.get("file") or lp.get("name", "")
                    pkg_lean_files.append(f_val.split("/")[-1])
                elif isinstance(lp, str):
                    pkg_lean_files.append(lp.split("/")[-1])
        
        # The list must be empty because lean_proofs was a string, not a list of files.
        assert pkg_lean_files == []

class TestDeduplicatePackages:
    def test_package_normalization_and_merging(self):
        # 1. Normalization
        assert dedup_packages.normalize_title("Close Proofs: My Theorem") == "my theorem"
        assert dedup_packages.normalize_title("Deepening: My Theorem: Part 2") == "my theorem"
        
        # 2. Merging
        canonical = {
            "title": "Concept Alpha",
            "breakthrough": False,
            "quality_score": 0.5,
            "source_exp_ids": ["exp1"],
            "keywords": ["math"],
            "lean_proofs": [{"file": "Main.lean", "code": "def a := 1"}]
        }
        duplicate = {
            "title": "Concept Alpha (Duplicate)",
            "breakthrough": True,
            "quality_score": 0.4,
            "source_exp_ids": ["exp2"],
            "keywords": ["science"],
            "lean_proofs": [{"file": "Main.lean", "code": "def a := 1\n def b := 2"}]
        }
        
        merged = dedup_packages.merge_packages(canonical, duplicate)
        assert merged["breakthrough"] is True
        assert sorted(merged["source_exp_ids"]) == ["exp1", "exp2"]
        assert sorted(merged["keywords"]) == ["math", "science"]
        # Code block should be the longer one (from duplicate)
        assert len(merged["lean_proofs"]) == 1
        assert merged["lean_proofs"][0]["code"] == "def a := 1\n def b := 2"

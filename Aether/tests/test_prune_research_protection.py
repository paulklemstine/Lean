"""Research-protection test for CatalogPruner.

The pruner must NEVER delete real research files, even when the LLM curator
says to remove them. Only true junk (empty stubs, sorry-dense junk, SalvagedBest)
may be auto-removed. Controlled by AETHER_CATALOG_CURATE_DELETE (default off).
"""
from pathlib import Path
from unittest.mock import MagicMock
import pytest
import catalog_pruner


def _make_pruner(tmp_path, monkeypatch):
    monkeypatch.delenv("AETHER_CATALOG_CURATE_DELETE", raising=False)
    # Stub CatalogAnalyzer so __init__ doesn't scan a real catalog
    monkeypatch.setattr(catalog_pruner, "CatalogAnalyzer", lambda root: MagicMock())
    pruner = catalog_pruner.CatalogPruner(
        catalog_root=tmp_path, pi_agent=MagicMock(), workspace=tmp_path
    )
    return pruner


def test_research_protected_junk_cleaned(tmp_path, monkeypatch):
    pruner = _make_pruner(tmp_path, monkeypatch)

    research = tmp_path / "research.lean"
    research.write_text("theorem deep : True := by_contra\n" * 30)  # 60 lines, 30 theorems, deep proof
    junk = tmp_path / "junk.lean"
    junk.write_text("theorem x : True := by trivial\n")  # 1 line, 1 theorem -> empty stub

    candidates = [
        {"path": "research.lean", "name": "research.lean", "domain": "D",
         "lines": 60, "sorries": False, "theorems": 30, "declarations": [],
         "deep_proof": True, "trivial_only": False, "abs_path": research, "content_preview": ""},
        {"path": "junk.lean", "name": "junk.lean", "domain": "D",
         "lines": 1, "sorries": False, "theorems": 1, "declarations": [],
         "deep_proof": False, "trivial_only": True, "abs_path": junk, "content_preview": ""},
    ]
    monkeypatch.setattr(pruner, "get_prune_candidates", lambda: candidates)

    # LLM WANTS to remove the research file — proves protection ignores LLM verdict
    pruner.pi_agent.curate_similar_groups = MagicMock(
        return_value={"remove": ["research.lean"], "keep": [], "notes": "remove it"})
    pruner.curate_individual = MagicMock(return_value=["research.lean"])
    pruner.deduplicate_catalog = MagicMock(return_value=["research.lean"])
    pruner.clean_broken_symlinks = MagicMock(return_value=0)
    pruner.rebuild_final_main = MagicMock()
    pruner.cleanup_empty_dirs = MagicMock(return_value=0)

    result = pruner.prune(target_remove_count=10)

    # Junk stub cleaned, research preserved despite LLM "remove" verdict
    assert not junk.exists(), "junk stub should be auto-removed"
    assert research.exists(), "research file must be PROTECTED even though LLM said remove"
    # LLM curation/dedup/individual steps skipped entirely (saves Pi-Agent budget)
    assert pruner.pi_agent.curate_similar_groups.call_count == 0
    assert pruner.curate_individual.call_count == 0
    assert pruner.deduplicate_catalog.call_count == 0
    assert result["removed"] == ["junk.lean"]


def test_curation_runs_when_explicitly_enabled(tmp_path, monkeypatch):
    """When AETHER_CATALOG_CURATE_DELETE=1, the LLM curation path runs (re-enables curated pruning)."""
    monkeypatch.setenv("AETHER_CATALOG_CURATE_DELETE", "1")
    monkeypatch.setattr(catalog_pruner, "CatalogAnalyzer", lambda root: MagicMock())
    pruner = catalog_pruner.CatalogPruner(
        catalog_root=tmp_path, pi_agent=MagicMock(), workspace=tmp_path
    )
    assert pruner.curate_delete_enabled is True
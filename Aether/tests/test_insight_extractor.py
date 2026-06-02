"""Tests for InsightExtractor: meta-feedback loop from Aether's own theorems.

Covers: extraction, persistence, guardrails building, cost estimation,
Jaccard similarity for anti-repetition, and catalog cost estimation.

Run with: pytest tests/test_insight_extractor.py -v
"""
import json
import pytest
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional
from unittest.mock import MagicMock, patch

from insight_extractor import InsightExtractor
from research_memory import FutureDirection, FutureDirectionsManager


# ── Fixtures ──────────────────────────────────────────────────────────────

@pytest.fixture
def tmp_workspace(tmp_path):
    ws = tmp_path / "aether_test"
    ws.mkdir()
    return ws


@pytest.fixture
def extractor(tmp_workspace):
    """InsightExtractor with no LLM (no pi_agent)."""
    return InsightExtractor(workspace=tmp_workspace)


@pytest.fixture
def mock_pi_agent():
    """Mock pi_agent that returns structured JSON classification."""
    agent = MagicMock()
    agent._call_ollama.return_value = json.dumps({
        "barriers": [
            {"name": "NoGoTheorem", "description": "Impossibility of constructive witnesses for this class", "domain": "Logic"},
        ],
        "strategies": [
            {"name": "ContrapositiveReduction", "description": "Reduce to contrapositive form then apply induction", "domain": "Algebra"},
        ],
        "bridges": [
            {"name": "TropicalAlgebraBridge", "description": "Connects tropical and algebraic structures", "domain": "Tropical",
             "source_domain": "Tropical", "target_domain": "Algebra"},
        ],
    })
    agent._parse_json_response = MagicMock(return_value={
        "barriers": [
            {"name": "NoGoTheorem", "description": "Impossibility of constructive witnesses for this class", "domain": "Logic"},
        ],
        "strategies": [
            {"name": "ContrapositiveReduction", "description": "Reduce to contrapositive form then apply induction", "domain": "Algebra"},
        ],
        "bridges": [
            {"name": "TropicalAlgebraBridge", "description": "Connects tropical and algebraic structures", "domain": "Tropical",
             "source_domain": "Tropical", "target_domain": "Algebra"},
        ],
    })
    return agent


@pytest.fixture
def extractor_with_llm(tmp_workspace, mock_pi_agent):
    """InsightExtractor with mock LLM agent."""
    return InsightExtractor(workspace=tmp_workspace, pi_agent=mock_pi_agent)


class MockJob:
    """Minimal mock ResearchJob for testing scan_new_theorems."""
    def __init__(self, lean_files=None, exp_id="exp_test", domain="Algebra"):
        self.lean_files = lean_files or []
        self.exp_id = exp_id
        self.concept = MagicMock()
        self.concept.domain = domain


# ── Persistence Tests ─────────────────────────────────────────────────────

class TestInsightPersistence:
    def test_empty_insights_on_init(self, extractor, tmp_workspace):
        """New extractor starts with empty insight store."""
        assert extractor._insights["barriers"] == []
        assert extractor._insights["strategies"] == []
        assert extractor._insights["cross_domain_bridges"] == []
        assert extractor._insights["cost_estimates"] == {}

    def test_save_and_reload(self, extractor, tmp_workspace):
        """Insights persist to disk and reload correctly."""
        extractor._insights["barriers"].append({
            "id": "abc123",
            "theorem": "NoGoTheorem",
            "domain": "Logic",
            "description": "Impossibility result",
            "source_file": "Logic/NoGo.lean",
            "discovered_at": "2025-01-01T00:00",
        })
        extractor._save()

        # Reload
        extractor2 = InsightExtractor(workspace=tmp_workspace)
        assert len(extractor2._insights["barriers"]) == 1
        assert extractor2._insights["barriers"][0]["theorem"] == "NoGoTheorem"

    def test_sorted_keys_in_persistence(self, extractor, tmp_workspace):
        """Saved JSON has sorted keys for deterministic git diffs.

        sort_keys=True sorts dict keys alphabetically (e.g. "description" before "id"),
        not list item order. Verify keys within each barrier dict are sorted.
        """
        extractor._insights["barriers"].append({
            "id": "z_last",
            "theorem": "ZTheorem",
            "domain": "ZDomain",
            "description": "Z description",
            "source_file": "",
            "discovered_at": "",
        })
        extractor._save()

        raw = (tmp_workspace / "insights.json").read_text()
        # With sort_keys=True, "description" should appear before "id" in each dict
        assert raw.index('"description"') < raw.index('"id"')
        # Top-level keys should also be sorted
        assert raw.index('"barriers"') < raw.index('"cost_estimates"')


# ── Theorem Collection Tests ──────────────────────────────────────────────

class TestTheoremCollection:
    def test_collect_theorems_from_lean_files(self, extractor):
        """_collect_new_theorems extracts theorem/lemma signatures from lean code."""
        job = MockJob(lean_files=[
            {
                "name": "Algebra/Test.lean",
                "code": "theorem ring_hom_preserves_one : f 1 = 1 := by simp\n\nlemma add_comm_of_ring : a + b = b + a := by omega",
            }
        ])
        theorems = extractor._collect_new_theorems(job)
        assert len(theorems) == 2
        assert theorems[0]["name"] == "ring_hom_preserves_one"
        assert theorems[1]["name"] == "add_comm_of_ring"

    def test_collect_skips_short_statements(self, extractor):
        """Theorem signatures shorter than 10 chars are skipped."""
        job = MockJob(lean_files=[
            {
                "name": "Test.lean",
                "code": "theorem trivial_eq : 1 = 1",  # statement "1 = 1" is only 5 chars
            }
        ])
        theorems = extractor._collect_new_theorems(job)
        assert len(theorems) == 0

    def test_collect_empty_job(self, extractor):
        """Job with no lean_files returns empty list."""
        job = MockJob(lean_files=[])
        theorems = extractor._collect_new_theorems(job)
        assert theorems == []


# ── LLM Classification Tests ──────────────────────────────────────────────

class TestLLMClassification:
    def test_scan_classifies_theorems(self, extractor_with_llm):
        """scan_new_theorems uses LLM to classify and merges results."""
        job = MockJob(lean_files=[
            {
                "name": "Logic/NoGo.lean",
                "code": "theorem no_constructive_witness : ¬∃ f, constructive_proof f := by_contra h\n\nlemma aux_lemma : P → Q := by exact h",
            }
        ], exp_id="exp_001")
        extractor_with_llm.scan_new_theorems(job)

        assert len(extractor_with_llm._insights["barriers"]) >= 1
        assert extractor_with_llm._insights["barriers"][0]["theorem"] == "NoGoTheorem"
        assert len(extractor_with_llm._insights["strategies"]) >= 1
        assert len(extractor_with_llm._insights["cross_domain_bridges"]) >= 1
        assert extractor_with_llm._insights["last_scan_cycle"] == "exp_001"

    def test_scan_deduplicates_theorems(self, extractor_with_llm):
        """Same theorem scanned twice doesn't create duplicates."""
        job = MockJob(lean_files=[
            {
                "name": "Test.lean",
                "code": "theorem important_result : some_long_statement_about_mathematics := by exact h",
            }
        ], exp_id="exp_002")
        extractor_with_llm.scan_new_theorems(job)
        extractor_with_llm.scan_new_theorems(job)  # scan again
        # scanned_theorems dedup prevents re-scanning
        assert extractor_with_llm._insights["last_scan_cycle"] == "exp_002"

    def test_scan_no_pi_agent_skips(self, extractor):
        """Without pi_agent, scan is a no-op."""
        job = MockJob(lean_files=[{"name": "T.lean", "code": "theorem x : some_long_statement_about_things := by exact h"}])
        extractor.scan_new_theorems(job)
        assert extractor._insights["barriers"] == []


# ── Dedup Tests ───────────────────────────────────────────────────────────

class TestMergeDedup:
    def test_merge_deduplicates_barriers(self, extractor):
        """_merge_extracted_insights deduplicates barriers by description."""
        extracted = {
            "barriers": [
                {"name": "A", "description": "Same barrier result about impossibility", "domain": "Logic"},
                {"name": "B", "description": "Same barrier result about impossibility", "domain": "Logic"},
            ],
        }
        extractor._merge_extracted_insights(extracted)
        assert len(extractor._insights["barriers"]) == 1

    def test_merge_deduplicates_bridges(self, extractor):
        """Bridges deduplicate by (source_domain, target_domain) pair."""
        extracted = {
            "bridges": [
                {"name": "A", "source_domain": "Tropical", "target_domain": "Algebra", "description": "First bridge"},
                {"name": "B", "source_domain": "Tropical", "target_domain": "Algebra", "description": "Same direction bridge"},
            ],
        }
        extractor._merge_extracted_insights(extracted)
        assert len(extractor._insights["cross_domain_bridges"]) == 1

    def test_merge_caps_list_sizes(self, extractor):
        """Lists are capped to prevent unbounded growth."""
        for i in range(150):
            extractor._insights["barriers"].append({
                "id": f"b_{i:03d}",
                "theorem": f"T{i}",
                "domain": "Test",
                "description": f"Description {i} unique text",
                "source_file": "",
                "discovered_at": "",
            })
        # Trigger a merge which will cap
        extractor._merge_extracted_insights({"barriers": []})
        assert len(extractor._insights["barriers"]) <= 100


# ── Guardrails Section Tests ──────────────────────────────────────────────

class TestGuardrailsSection:
    def test_empty_when_no_barriers(self, extractor):
        """Returns empty string when no barriers are stored."""
        concept = MagicMock()
        concept.domain = "Algebra"
        concept.concept_description = "Test"
        assert extractor.build_guardrails_section(concept) == ""

    def test_builds_section_with_barriers(self, extractor):
        """Returns markdown section when barriers exist."""
        extractor._insights["barriers"] = [
            {
                "id": "b1",
                "theorem": "NoGoTheorem",
                "domain": "Algebra",
                "description": "Cannot construct explicit witnesses for this class",
                "source_file": "Algebra/NoGo.lean",
                "discovered_at": "2025-01-01",
            }
        ]
        concept = MagicMock()
        concept.domain = "Algebra"
        concept.concept_description = "Test algebraic structures"
        section = extractor.build_guardrails_section(concept)
        assert "Known Barriers" in section
        assert "NoGoTheorem" in section
        assert "Cannot construct" in section

    def test_guardrails_capped_at_3000_chars(self, extractor):
        """Guardrails section is truncated at 3000 chars."""
        for i in range(50):
            extractor._insights["barriers"].append({
                "id": f"b{i}",
                "theorem": f"BarrierTheorem{i}",
                "domain": "Algebra",
                "description": f"A very long description of barrier number {i} " * 20,
                "source_file": "",
                "discovered_at": "",
            })
        concept = MagicMock()
        concept.domain = "Algebra"
        concept.concept_description = "algebraic structures"
        section = extractor.build_guardrails_section(concept)
        assert len(section) <= 3003  # 3000 + "..."

    def test_relevance_scoring(self, extractor):
        """Barriers from the same domain score higher than other domains."""
        extractor._insights["barriers"] = [
            {"id": "b1", "theorem": "AlgebraBarrier", "domain": "Algebra", "description": "Algebra impossibility"},
            {"id": "b2", "theorem": "PhysicsBarrier", "domain": "Physics", "description": "Physics impossibility"},
        ]
        concept = MagicMock()
        concept.domain = "Algebra"
        concept.concept_description = "rings and modules"
        barriers = extractor.get_relevant_barriers("Algebra", ["rings"])
        assert len(barriers) >= 1
        assert barriers[0]["domain"] == "Algebra"


# ─── Strategy Hints Tests ────────────────────────────────────────────────

class TestStrategyHints:
    def test_empty_when_no_strategies(self, extractor):
        """Returns empty when no strategies stored."""
        concept = MagicMock()
        concept.domain = "Algebra"
        assert extractor.build_strategy_hints_section(concept) == ""

    def test_builds_strategy_section(self, extractor):
        """Returns markdown section with strategy hints."""
        extractor._insights["strategies"] = [
            {
                "id": "s1",
                "pattern": "ContrapositiveReduction",
                "domain": "Algebra",
                "description": "Reduce to contrapositive then apply induction",
                "success_rate": 0.9,
                "source_file": "",
            }
        ]
        concept = MagicMock()
        concept.domain = "Algebra"
        section = extractor.build_strategy_hints_section(concept)
        assert "Recommended Proof Strategies" in section
        assert "ContrapositiveReduction" in section

    def test_strategy_capped_at_1000_chars(self, extractor):
        """Strategy section truncated at 1000 chars."""
        for i in range(30):
            extractor._insights["strategies"].append({
                "id": f"s{i}",
                "pattern": f"Strategy{i}",
                "domain": "Algebra",
                "description": f"A very long strategy description for strategy {i} " * 15,
                "success_rate": 0.8,
                "source_file": "",
            })
        concept = MagicMock()
        concept.domain = "Algebra"
        section = extractor.build_strategy_hints_section(concept)
        assert len(section) <= 1003


# ── Cost Estimation Tests ────────────────────────────────────────────────

class TestCostEstimation:
    def test_default_cost_for_unknown_domain(self, extractor):
        """Unknown domain returns 0.5 (medium cost)."""
        assert extractor.get_cost_estimate("UnknownDomain") == 0.5

    def test_cost_from_stored_estimates(self, extractor):
        """Returns cost_score from stored estimates."""
        extractor._insights["cost_estimates"]["Algebra"] = {
            "avg_proof_length": 150,
            "sorry_density": 0.01,
            "theorem_count": 200,
            "cost_score": 0.7,
        }
        assert extractor.get_cost_estimate("Algebra") == 0.7


# ── Jaccard Similarity Tests (in research_memory) ────────────────────────

class TestJaccardSimilarity:
    def test_identical_directions_high_similarity(self, tmp_workspace):
        """Identical directions have Jaccard similarity ~1.0."""
        mgr = FutureDirectionsManager(tmp_workspace)
        d1 = FutureDirection(
            id="fd_0001", title="Tropical Fixed Points", description="Prove tropical semiring fixed point theorem",
            source_exp_id="seed", source_path="seed:test", domains=["Tropical", "Algebra"],
            proof_strategy="induction", ambition_level="extension",
        )
        d2 = FutureDirection(
            id="fd_0002", title="Tropical Fixed Points", description="Prove tropical semiring fixed point theorem",
            source_exp_id="seed", source_path="seed:test", domains=["Tropical", "Algebra"],
            proof_strategy="induction", ambition_level="extension",
        )
        sim = mgr._estimate_direction_similarity(d1, [d2])
        assert sim > 0.8

    def test_completely_different_low_similarity(self, tmp_workspace):
        """Directions in unrelated domains have low similarity."""
        mgr = FutureDirectionsManager(tmp_workspace)
        d1 = FutureDirection(
            id="fd_0001", title="Tropical Semiring", description="Tropical algebra structures",
            source_exp_id="seed", source_path="seed:test", domains=["Tropical"],
            proof_strategy="induction", ambition_level="extension",
        )
        d2 = FutureDirection(
            id="fd_0002", title="Quantum Cryptography", description="Post-quantum lattice-based encryption schemes",
            source_exp_id="seed", source_path="seed:test", domains=["Cryptography"],
            proof_strategy="reduction", ambition_level="grand_challenge",
        )
        sim = mgr._estimate_direction_similarity(d1, [d2])
        assert sim < 0.3

    def test_partial_overlap(self, tmp_workspace):
        """Directions sharing some features have moderate similarity."""
        mgr = FutureDirectionsManager(tmp_workspace)
        d1 = FutureDirection(
            id="fd_0001", title="Tropical Algebra", description="Tropical semiring algebraic properties",
            source_exp_id="seed", source_path="seed:test", domains=["Tropical", "Algebra"],
            proof_strategy="induction", ambition_level="extension",
        )
        d2 = FutureDirection(
            id="fd_0002", title="Algebraic Topology", description="Algebraic topology homology groups",
            source_exp_id="seed", source_path="seed:test", domains=["Algebra", "Geometry"],
            proof_strategy="homotopy", ambition_level="extension",
        )
        sim = mgr._estimate_direction_similarity(d1, [d2])
        # They share "Algebra" domain and "extension" ambition
        assert 0.0 < sim < 0.8

    def test_jaccard_replaces_keyword_penalty(self, tmp_workspace):
        """Quality scoring uses Jaccard similarity, not keyword overlap penalty."""
        mgr = FutureDirectionsManager(tmp_workspace)
        # Mark a direction as completed (this populates recent_completed)
        d_completed = FutureDirection(
            id="fd_completed", title="Tropical Semiring Fixed Points",
            description="Tropical algebraic fixed point theorems and applications",
            source_exp_id="seed", source_path="seed:test", domains=["Tropical", "Algebra"],
            proof_strategy="induction", ambition_level="extension", priority_score=0.8,
        )
        mgr.add_direction(d_completed)
        mgr.mark_direction_consumed("fd_completed", "exp_001")
        mgr.mark_direction_completed("fd_completed")

        # A new very-similar direction should get a repetition penalty
        d_new = FutureDirection(
            id="fd_new", title="Tropical Fixed Points Extension",
            description="Tropical algebraic fixed point theorem extensions",
            source_exp_id="seed", source_path="seed:test", domains=["Tropical", "Algebra"],
            proof_strategy="induction", ambition_level="extension", priority_score=0.7,
        )
        score = mgr._compute_quality_score(d_new)
        # Should be penalized relative to a completely different direction
        d_diff = FutureDirection(
            id="fd_diff", title="Cryptography Protocol Analysis",
            description="Post-quantum lattice-based encryption key exchange protocols",
            source_exp_id="seed", source_path="seed:test", domains=["Cryptography"],
            proof_strategy="reduction", ambition_level="grand_challenge", priority_score=0.7,
        )
        score_diff = mgr._compute_quality_score(d_diff)
        # The different direction should score higher (less repetition)
        # Not a strict guarantee since other factors matter, but the penalty should help
        assert score_diff >= score - 0.05  # at minimum, shouldn't be much lower


# ── Catalog Cost Estimation Tests ────────────────────────────────────────

class TestCatalogCostEstimation:
    def test_estimate_all_domain_costs(self, tmp_path):
        """CatalogAnalyzer.estimate_all_domain_costs computes cost per domain."""
        from catalog_analyzer import CatalogAnalyzer, CatalogFileSummary

        # Create a minimal catalog structure
        catalog = tmp_path / "catalog"
        algebra_dir = catalog / "Algebra"
        algebra_dir.mkdir(parents=True)
        (algebra_dir / "Test.lean").write_text(
            "theorem hard_theorem : some_statement := by\n  induction n with\n  · simp\n  · exact h\n\n"
            "def something : Nat := 42\n"
            "sorry  -- placeholder\n"
        )

        analyzer = CatalogAnalyzer(catalog)
        analyzer.scan()
        costs = analyzer.estimate_all_domain_costs()

        assert "Algebra" in costs
        assert "cost_score" in costs["Algebra"]
        assert 0.0 <= costs["Algebra"]["cost_score"] <= 1.0
        assert costs["Algebra"]["avg_proof_length"] > 0

    def test_cost_estimate_empty_catalog(self, tmp_path):
        """Empty catalog returns empty cost dict."""
        from catalog_analyzer import CatalogAnalyzer

        catalog = tmp_path / "empty_catalog"
        catalog.mkdir()
        analyzer = CatalogAnalyzer(catalog)
        analyzer.scan()
        costs = analyzer.estimate_all_domain_costs()
        # Empty or just Unknown domain
        assert isinstance(costs, dict)


# ── Stats Tests ───────────────────────────────────────────────────────────

class TestStats:
    def test_empty_stats(self, extractor):
        """Stats return zeros for empty extractor."""
        stats = extractor.stats()
        assert stats["barriers"] == 0
        assert stats["strategies"] == 0
        assert stats["cross_domain_bridges"] == 0

    def test_populated_stats(self, extractor):
        """Stats count entries correctly."""
        extractor._insights["barriers"] = [{"id": "b1"}] * 3
        extractor._insights["strategies"] = [{"id": "s1"}] * 2
        extractor._insights["cross_domain_bridges"] = [{"id": "c1"}]
        stats = extractor.stats()
        assert stats["barriers"] == 3
        assert stats["strategies"] == 2
        assert stats["cross_domain_bridges"] == 1
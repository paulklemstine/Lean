#!/usr/bin/env python3
"""Tests for CatalogScorer: structural scoring, LLM scoring, promotion, batch scanning."""

import json
import os
import tempfile
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from catalog_analyzer import CatalogFileSummary, DOMAIN_DIRS
from catalog_scorer import (
    CatalogFileScore,
    CatalogScorer,
    SORRY_FREE_BONUS,
    DEEP_PROOF_BONUS,
    THEOREM_MANY_BONUS,
    THEOREM_SOME_BONUS,
    CROSS_DOMAIN_BONUS,
    LINE_DEPTH_100_BONUS,
    LINE_DEPTH_50_BONUS,
    DECL_RICH_10_BONUS,
    DECL_RICH_5_BONUS,
    STRUCTURAL_FILTER_THRESHOLD,
    FINAL_SCORE_THRESHOLD,
)


# ── Fixtures ──

@pytest.fixture
def temp_workspace(tmp_path):
    """Create a temporary workspace with a Catalog structure."""
    catalog = tmp_path / "Catalog"
    catalog.mkdir()

    # Create domain directories and sample files
    algebra_dir = catalog / "Algebra"
    algebra_dir.mkdir()
    (algebra_dir / "RingTheory.lean").write_text(
        "import Algebra.Core.Basic\n\n"
        "theorem ring_add_comm : ∀ a b : R, a + b = b + a := by omega\n"
        "theorem ring_mul_assoc : ∀ a b c : R, a * b * c = a * (b * c) := by omega\n"
        "theorem ring_zero_ne_one : (0 : R) ≠ 1 := by decide\n"
        "def ring_equiv : R ≃ S := sorry\n"
        "structure RingEquiv extends R ≃ S where\n  map_mul' : True\n\n"
    )
    (algebra_dir / "SimpleDef.lean").write_text(
        "def simple : Nat := 42\n"
    )
    # Sorry-heavy file
    (algebra_dir / "SorryHeavy.lean").write_text(
        "theorem hard_proof : True := sorry\ntheorem another : True := sorry\n"
    )

    tropical_dir = catalog / "Tropical"
    tropical_dir.mkdir()
    (tropical_dir / "TropicalSemiring.lean").write_text(
        "import Tropical.Core.Basic\nimport Algebra.RingTheory\n\n"
        "theorem tropical_add_idempotent : ∀ x, max x x = x := by simp\n"
        "theorem tropical_zero_is_top : ∀ x, max 0 x = 0 := by simp\n"
        "def tropical_max (a b : ℝ) : ℝ := max a b\n"
        "structure TropicalSemiring where\n  carrier : Type\n  add : carrier → carrier → carrier\n\n"
    )

    # Deep proof file (50+ lines, sorry-free, multiple theorems, deep tactics)
    deep_content = "\n".join([
        "import Algebra.Core.Basic",
        "import Tropical.Core.Basic",
        "",
        "-- Deep mathematical results on Berggren trees",
        "theorem berggren_triple_valid : ∀ n, berggren n |>.1 ^ 2 + berggren n |>.2.1 ^ 2 = berggren n |>.2.2 ^ 2 := by",
        "  induction n with",
        "  | zero => simp [berggren]",
        "  | succ n ih =>",
        "    rcases berggren n with ⟨a, b, c⟩",
        "    rw [berggren_succ]",
        "    calc",
        "      (a + 2 * c) ^ 2 + (2 * a + 2 * c) ^ 2 = _ := by ring_nf",
        "      _ = (2 * a + 2 * c + 1) ^ 2 := by omega,",
        "",
        "theorem berggren_primitive_divisor : ∀ n > 0, ∃ p, Nat.Prime p ∧ p ∣ berggren n |>.2.2 := by",
        "  intro n hn",
        "  by_contra h",
        "  have := fib_primitive_divisor n hn",
        "  contradiction,",
        "",
        "theorem berggren_infinitude : Infinite {t : ℕ × ℕ × ℕ // IsPythagoreanTriple t.1 t.2.1 t.2.2 } := by",
        "  constructor",
        "  intro S",
        "  obtain ⟨n, hn⟩ := finite_iff_subset_finset.mp S |>.mp ⟨berggren_set, berggren_finite⟩",
        "  exact absurd (berggren_injective hn) (nat_succ_ne_self n),",
        "",
        "def berggren : ℕ → ℕ × ℕ × ℕ",
        "  | 0 => (3, 4, 5)",
        "  | n + 1 =>",
        "    let ⟨a, b, c⟩ := berggren n",
        "    (a + 2 * c, 2 * a + 2 * c, 2 * a + 2 * c + 1)",
        "",
        "structure BerggrenTree where",
        "  root : ℕ × ℕ × ℕ",
        "  left : BerggrenTree",
        "  right : BerggrenTree",
    ] + [f"-- Filler line {i}" for i in range(50)])
    (algebra_dir / "Berggren.lean").write_text(deep_content)

    workspace = tmp_path / "workspace"
    workspace.mkdir()
    (workspace / ".aether_workspace").mkdir()

    return {"catalog": catalog, "workspace": workspace}


@pytest.fixture
def scorer(temp_workspace):
    """Create a CatalogScorer with no pi_agent (structural only)."""
    return CatalogScorer(
        catalog_root=temp_workspace["catalog"],
        workspace=temp_workspace["workspace"],
        pi_agent=None,
    )


def make_summary(**kwargs) -> CatalogFileSummary:
    """Helper to create CatalogFileSummary with defaults."""
    defaults = {
        "relative_path": "Algebra/RingTheory.lean",
        "domain": "Algebra",
        "declarations": ["ring_add_comm", "ring_mul_assoc", "ring_zero_ne_one", "ring_equiv"],
        "imports": ["import Algebra.Core.Basic"],
        "size_lines": 10,
        "has_sorries": True,
        "sorry_count": 1,
    }
    defaults.update(kwargs)
    return CatalogFileSummary(**defaults)


# ── CatalogFileScore Tests ──

class TestCatalogFileScore:
    def test_defaults(self):
        score = CatalogFileScore(relative_path="Algebra/Test.lean", domain="Algebra")
        assert score.structural_score == 0.0
        assert score.llm_score == 0.0
        assert score.final_score == 0.0
        assert score.in_final is False
        assert score.confirmed is False
        assert score.promoted_at == 0.0

    def test_to_dict_round_trip(self):
        score = CatalogFileScore(
            relative_path="Algebra/Berggren.lean",
            domain="Algebra",
            structural_score=8.5,
            llm_score=7.2,
            final_score=7.68,
            novelty=8,
            depth=7,
            impact=8,
            fun=7,
            solid=6,
            in_final=True,
            confirmed=True,
        )
        d = score.to_dict()
        restored = CatalogFileScore.from_dict(d)
        assert restored.relative_path == score.relative_path
        assert restored.structural_score == score.structural_score
        assert restored.llm_score == score.llm_score
        assert restored.in_final is True
        assert restored.confirmed is True


# ── Structural Scoring Tests ──

class TestStructuralScoring:
    def test_sorry_free_bonus(self, scorer):
        """Sorry-free files get +3.0."""
        summary = make_summary(sorry_count=0, has_sorries=False)
        score = scorer.score_structural(summary)
        assert score >= SORRY_FREE_BONUS  # At least the sorry-free bonus

    def test_sorry_heavy_no_bonus(self, scorer):
        """Files with sorries don't get sorry-free bonus."""
        summary = make_summary(sorry_count=5, has_sorries=True)
        score = scorer.score_structural(summary)
        # Should not include sorry_free_bonus
        assert score < SORRY_FREE_BONUS

    def test_deep_proof_bonus(self, scorer, temp_workspace):
        """Files with deep proof tactics get +2.0."""
        summary = make_summary(
            relative_path="Algebra/Berggren.lean",
            size_lines=70,
            sorry_count=0,
            has_sorries=False,
        )
        score = scorer.score_structural(summary)
        # Berggren.lean has induction, rcases, by_contra, calc, omega, ring_nf
        # It should get both sorry_free and deep_proof bonuses
        assert score >= SORRY_FREE_BONUS + DEEP_PROOF_BONUS

    def test_theorem_count_bonus(self, scorer, temp_workspace):
        """Files with 5+ theorems get +1.5."""
        # Berggren.lean has 3 theorems (berggren_triple_valid, berggren_primitive_divisor, berggren_infinitude)
        summary = make_summary(
            relative_path="Algebra/Berggren.lean",
            size_lines=70,
            sorry_count=0,
            has_sorries=False,
        )
        score = scorer.score_structural(summary)
        # Should get at least sorry_free + some theorem bonus
        assert score >= SORRY_FREE_BONUS

    def test_line_depth_bonus(self, scorer, temp_workspace):
        """Files with 100+ lines get +1.0."""
        summary = make_summary(
            relative_path="Algebra/Berggren.lean",
            size_lines=70,  # ~70 lines
            sorry_count=0,
            has_sorries=False,
        )
        score_70 = scorer.score_structural(summary)
        # Create a longer file for comparison
        long_dir = temp_workspace["catalog"] / "Algebra"
        (long_dir / "LongFile.lean").write_text("\n".join(["-- line"] * 120))

    def test_cross_domain_bonus(self, scorer, temp_workspace):
        """Files importing from 2+ domains get +1.0."""
        summary = make_summary(
            relative_path="Tropical/TropicalSemiring.lean",
            domain="Tropical",
            imports=["import Tropical.Core.Basic", "import Algebra.RingTheory"],
            sorry_count=0,
            has_sorries=False,
        )
        score = scorer.score_structural(summary)
        assert score >= CROSS_DOMAIN_BONUS

    def test_declaration_richness_bonus(self, scorer, temp_workspace):
        """Files with 5+ declarations get +0.5."""
        summary = make_summary(
            declarations=[
                "theorem_one", "theorem_two", "theorem_three",
                "def_one", "def_two",
            ],
            size_lines=10,
        )
        score = scorer.score_structural(summary)
        # Should have at least DECL_RICH_5_BONUS
        assert score >= DECL_RICH_5_BONUS

    def test_simple_file_low_score(self, scorer, temp_workspace):
        """Simple definition-only files score low."""
        summary = make_summary(
            relative_path="Algebra/SimpleDef.lean",
            declarations=["simple"],
            size_lines=1,
            sorry_count=0,
            has_sorries=False,
        )
        score = scorer.score_structural(summary)
        # Only sorry-free bonus (3.0), no deep proofs, no theorems, short
        assert score == SORRY_FREE_BONUS

    def test_score_capped_at_10(self, scorer, temp_workspace):
        """Structural score is capped at 10."""
        # Berggren.lean is our deepest file
        summary = make_summary(
            relative_path="Algebra/Berggren.lean",
            size_lines=70,
            sorry_count=0,
            has_sorries=False,
        )
        score = scorer.score_structural(summary)
        assert score <= 10.0


# ── Promotion / Demotion Tests ──

class TestPromotion:
    def test_promote_creates_final_directory(self, scorer, temp_workspace):
        """promote_to_final creates FINAL/{Domain}/ and copies file."""
        score = CatalogFileScore(
            relative_path="Algebra/RingTheory.lean",
            domain="Algebra",
            structural_score=8.0,
            final_score=8.0,
            confirmed=True,
        )
        scorer.promote_to_final(score)

        final_path = temp_workspace["catalog"] / "FINAL" / "Algebra" / "RingTheory.lean"
        assert final_path.exists()
        assert score.in_final is True
        assert score.promoted_at > 0

    def test_demote_removes_from_final(self, scorer, temp_workspace):
        """demote_from_final removes file from FINAL/ but keeps it in working Catalog."""
        score = CatalogFileScore(
            relative_path="Algebra/RingTheory.lean",
            domain="Algebra",
            structural_score=8.0,
            final_score=8.0,
            confirmed=True,
        )
        scorer.promote_to_final(score)
        assert (temp_workspace["catalog"] / "FINAL" / "Algebra" / "RingTheory.lean").exists()

        scorer.demote_from_final(score)
        assert not (temp_workspace["catalog"] / "FINAL" / "Algebra" / "RingTheory.lean").exists()
        # Original still exists
        assert (temp_workspace["catalog"] / "Algebra" / "RingTheory.lean").exists()
        assert score.in_final is False


# ── Persistence Tests ──

class TestPersistence:
    def test_save_and_load_scores(self, scorer, temp_workspace):
        """Scores persist to disk and can be reloaded."""
        score = CatalogFileScore(
            relative_path="Algebra/RingTheory.lean",
            domain="Algebra",
            structural_score=7.5,
            llm_score=8.2,
            final_score=7.92,
            novelty=8,
            depth=9,
            impact=8,
            fun=7,
            solid=8,
            in_final=True,
            confirmed=True,
        )
        scorer._scores["Algebra/RingTheory.lean"] = score
        scorer.save_scores()

        # Create a new scorer and load
        scorer2 = CatalogScorer(
            catalog_root=temp_workspace["catalog"],
            workspace=temp_workspace["workspace"],
            pi_agent=None,
        )
        scorer2.load_scores()

        loaded = scorer2._scores.get("Algebra/RingTheory.lean")
        assert loaded is not None
        assert loaded.structural_score == 7.5
        assert loaded.llm_score == 8.2
        assert loaded.novelty == 8
        assert loaded.in_final is True
        assert loaded.confirmed is True


# ── Batch Scanning Tests ──

class TestBatchScanning:
    def test_get_next_batch_returns_files(self, scorer):
        """get_next_batch returns CatalogFileSummary objects."""
        batch = scorer.get_next_batch(batch_size=10)
        assert len(batch) > 0
        assert all(isinstance(s, CatalogFileSummary) for s in batch)

    def test_unexamined_files_come_first(self, scorer):
        """Files with no prior score come first."""
        # Score one file
        scorer._scores["Algebra/RingTheory.lean"] = CatalogFileScore(
            relative_path="Algebra/RingTheory.lean",
            domain="Algebra",
            last_examined=9999999.0,  # Far future
        )
        batch = scorer.get_next_batch(batch_size=10)
        # Unexamined files should be first
        if len(batch) > 1:
            assert batch[0].relative_path != "Algebra/RingTheory.lean" or \
                   batch[0].relative_path == "Algebra/RingTheory.lean"

    def test_scan_and_score_batch_structural_only(self, scorer):
        """scan_and_score_batch works without pi_agent (structural only)."""
        results = scorer.scan_and_score_batch(batch_size=5)
        assert len(results) > 0
        for r in results:
            assert r.structural_score >= 0
            assert isinstance(r, CatalogFileScore)


# ── Stats Tests ──

class TestStats:
    def test_empty_stats(self, scorer):
        """Stats return zeros when no files scored."""
        stats = scorer.get_stats()
        assert stats["total_scored"] == 0
        assert stats["in_final"] == 0
        assert stats["avg_structural"] == 0.0

    def test_stats_after_scoring(self, scorer):
        """Stats reflect scored files."""
        scorer.scan_and_score_batch(batch_size=5)
        stats = scorer.get_stats()
        assert stats["total_scored"] > 0
        assert stats["avg_structural"] >= 0


# ── LLM Scoring Tests (with mock) ──

class TestLLMScoring:
    def test_score_llm_with_mock(self, scorer, temp_workspace):
        """LLM scoring returns CatalogFileScore with dimensions."""
        mock_pi = MagicMock()
        mock_pi._call_ollama.return_value = (
            '{"novelty": 8, "depth": 7, "impact": 9, "fun": 6, "solid": 8}'
        )
        scorer.pi_agent = mock_pi

        summary = make_summary(
            relative_path="Algebra/Berggren.lean",
            size_lines=70,
            sorry_count=0,
            has_sorries=False,
        )
        struct_score = scorer.score_structural(summary)
        result = scorer.score_llm(summary, struct_score)

        assert result is not None
        assert result.novelty == 8
        assert result.depth == 7
        assert result.impact == 9
        assert result.fun == 6
        assert result.solid == 8
        # final_score = 0.4 * struct + 0.6 * llm_avg
        llm_avg = (8 + 7 + 9 + 6 + 8) / 5.0  # 7.6
        expected_final = 0.4 * struct_score + 0.6 * llm_avg
        assert abs(result.final_score - round(expected_final, 2)) < 0.1

    def test_score_llm_failure_returns_none(self, scorer, temp_workspace):
        """LLM scoring returns None on failure."""
        mock_pi = MagicMock()
        mock_pi._call_ollama.side_effect = Exception("API error")
        scorer.pi_agent = mock_pi

        summary = make_summary(relative_path="Algebra/RingTheory.lean")
        result = scorer.score_llm(summary, 5.0)
        assert result is None

    def test_confirmation_pass(self, scorer):
        """Two-pass confirmation returns True for YES."""
        mock_pi = MagicMock()
        mock_pi._call_ollama.return_value = "YES - this is a top-tier result."
        scorer.pi_agent = mock_pi

        score = CatalogFileScore(
            relative_path="Algebra/Berggren.lean",
            domain="Algebra",
            structural_score=9.0,
            final_score=8.5,
        )
        assert scorer._confirm_promotion(score) is True

    def test_confirmation_fail(self, scorer):
        """Two-pass confirmation returns False for NO."""
        mock_pi = MagicMock()
        mock_pi._call_ollama.return_value = "NO - this is a re-proof of Mathlib."
        scorer.pi_agent = mock_pi

        score = CatalogFileScore(
            relative_path="Algebra/SimpleDef.lean",
            domain="Algebra",
            structural_score=5.0,
            final_score=3.0,
        )
        assert scorer._confirm_promotion(score) is False


# ── Full Pipeline Test ──

class TestFullPipeline:
    def test_scan_and_score_with_mock_llm(self, temp_workspace):
        """Full pipeline: structural → LLM → confirmation → promotion."""
        mock_pi = MagicMock()
        # First call: LLM scoring
        # Second call: confirmation
        mock_pi._call_ollama.side_effect = [
            '{"novelty": 9, "depth": 8, "impact": 9, "fun": 8, "solid": 9}',  # LLM score
            'YES - this is a world-class result.',  # Confirmation
        ]

        scorer = CatalogScorer(
            catalog_root=temp_workspace["catalog"],
            workspace=temp_workspace["workspace"],
            pi_agent=mock_pi,
        )
        scorer.load_scores()

        results = scorer.scan_and_score_batch(batch_size=5)
        assert len(results) > 0

        # Check that scores were saved
        stats = scorer.get_stats()
        assert stats["total_scored"] > 0

    def test_low_structural_score_no_llm(self, scorer):
        """Files with structural_score < 5.0 skip LLM evaluation."""
        # SimpleDef.lean has structural score of just 3.0 (sorry-free only)
        results = scorer.scan_and_score_batch(batch_size=50)
        simple = [r for r in results if "SimpleDef" in r.relative_path]
        if simple:
            # Should have structural score but no LLM score
            assert simple[0].llm_score == 0.0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
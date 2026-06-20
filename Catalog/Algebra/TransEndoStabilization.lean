/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Stabilization of the Transition-Rank Sequence

Building on `Catalog.Algebra.TransEndo`, this file packages the cardinal rank of a
transition endomorphism as a *natural-number* sequence

  `rankSeq f i j = (transEndo f i j).rank.toNat`

over a finite-dimensional space, and proves the resulting structural facts:

* the sequence is bounded by `finrank K V`;
* widening the window cannot increase it (`rankSeq_antitone`);
* hence the window-from-`0` sequence `m ↦ rankSeq f 0 m` is antitone and therefore
  **eventually constant** (`rankSeq_eventually_const`).

The eventual-constancy step is isolated as a reusable order-theoretic lemma about
antitone `ℕ → ℕ` sequences (`antitone_nat_eventually_const`).
-/
import Mathlib
import Algebra.TransEndo

namespace Catalog.Algebra.TransEndo

open LinearMap Module Cardinal

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): over a finite-dimensional space the transition rank,
--   read as a natural number, is a bounded antitone sequence and so must stabilize.
-- Experiment (Experimenter): convert the cardinal inequality `rank_transEndo_antitone`
--   to `ℕ` with `Cardinal.toNat_le_toNat` (legal since `rank < ℵ₀`), then apply a
--   well-foundedness argument for antitone `ℕ → ℕ` sequences.
-- !-- End Lab Notes -- !--

/-- The transition rank read as a natural number. -/
noncomputable def rankSeq (f : ℕ → V →ₗ[K] V) (i j : ℕ) : ℕ :=
  (transEndo f i j).rank.toNat

/-- Widening the window cannot increase the (natural-number) transition rank. -/
theorem rankSeq_antitone [FiniteDimensional K V] (f : ℕ → V →ₗ[K] V) {i j k : ℕ}
    (hij : i ≤ j) (hjk : j ≤ k) :
    rankSeq f i k ≤ rankSeq f i j := by
  refine Cardinal.toNat_le_toNat (rank_transEndo_antitone f hij hjk) ?_
  exact rank_lt_aleph0 K _

/-- The transition rank never exceeds the dimension of the space. -/
theorem rankSeq_le_finrank [FiniteDimensional K V] (f : ℕ → V →ₗ[K] V) (i j : ℕ) :
    rankSeq f i j ≤ finrank K V := by
  have h := (transEndo f i j).rank_le_domain
  calc rankSeq f i j ≤ (Module.rank K V).toNat :=
        Cardinal.toNat_le_toNat h (rank_lt_aleph0 K V)
    _ = finrank K V := by rw [Module.finrank]

/-- The window-from-`0` rank sequence is antitone. -/
theorem rankSeq_zero_antitone [FiniteDimensional K V] (f : ℕ → V →ₗ[K] V) :
    Antitone (rankSeq f 0) := by
  intro j k hjk
  exact rankSeq_antitone f (Nat.zero_le j) hjk

/-- Reusable order fact: an antitone sequence of natural numbers is eventually
constant. -/
theorem antitone_nat_eventually_const (a : ℕ → ℕ) (ha : Antitone a) :
    ∃ N, ∀ m, N ≤ m → a m = a N := by
  obtain ⟨x, ⟨N, rfl⟩, H⟩ := Nat.lt_wfRel.wf.has_min (Set.range a) (Set.range_nonempty a)
  refine ⟨N, fun m hm => ?_⟩
  have h1 : a m ≤ a N := ha hm
  have h2 : ¬ a m < a N := H _ (Set.mem_range_self _)
  omega

/-- The window-from-`0` transition-rank sequence eventually stabilizes. -/
theorem rankSeq_eventually_const [FiniteDimensional K V] (f : ℕ → V →ₗ[K] V) :
    ∃ N, ∀ m, N ≤ m → rankSeq f 0 m = rankSeq f 0 N :=
  antitone_nat_eventually_const _ (rankSeq_zero_antitone f)

-- !-- Lab Notes -- !--
-- Analysis (Analyst): the only new mathematical content beyond the catalog file is
--   the cardinal→ℕ transfer and the well-foundedness of antitone `ℕ → ℕ` chains;
--   everything else is inherited from `transEndo_comp` via `rank_transEndo_antitone`.
-- Critique (Critic): `rankSeq_eventually_const` is non-vacuous and not provable by
--   `decide`/`simp` alone — it requires the antitone-chain stabilization lemma. The
--   finiteness hypothesis is genuinely used (it justifies `toNat` and the bound).
-- Synthesis (PI): the transition operator's rank profile is a finite, non-increasing,
--   eventually-constant signature — a clean invariant of an endomorphism stream.
-- !-- End Lab Notes -- !--

end Catalog.Algebra.TransEndo
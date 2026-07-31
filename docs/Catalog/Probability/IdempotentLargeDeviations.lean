/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Idempotent probability and max-plus large deviations

This file gives a finite-state max-plus analogue of the exponential upper
bound in Cramér's theorem.  An idempotent law assigns a score at most zero to
each possible increment, with best score zero.  The max-plus cumulant is the
maximum of `weight + θ * value`.  For every finite i.i.d. path, its normalized
score is bounded above by minus the Legendre--Fenchel transform of this
cumulant at the empirical velocity.
-/

import Bridges.LargeDeviationPrinciple

open scoped BigOperators
open Finset

namespace IdempotentProbability

/-- A normalized, finite max-plus probability law.  `weight i` is the
logarithmic/idempotent probability of outcome `i`; max-plus normalization is
`max_i weight i = 0`. -/
structure MaxPlusLaw (ι : Type*) [Fintype ι] [Nonempty ι] where
  value : ι → ℝ
  weight : ι → ℝ
  weight_nonpos : ∀ i, weight i ≤ 0
  exists_weight_zero : ∃ i, weight i = 0

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The max-plus cumulant (idempotent logarithmic moment generating function). -/
noncomputable def MaxPlusLaw.cumulant (μ : MaxPlusLaw ι) (θ : ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => μ.weight i + θ * μ.value i)

/-- The rate function is the existing catalog Legendre--Fenchel transform of
    the max-plus cumulant. -/
noncomputable def MaxPlusLaw.rate (μ : MaxPlusLaw ι) : ℝ → ℝ :=
  ArithLDP.rateFunction μ.cumulant

/-- Max-plus normalization implies that the cumulant vanishes at zero. -/
theorem MaxPlusLaw.cumulant_zero (μ : MaxPlusLaw ι) : μ.cumulant 0 = 0 := by
  apply le_antisymm
  · rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    intro i _
    simpa using μ.weight_nonpos i
  · obtain ⟨i, hi⟩ := μ.exists_weight_zero
    have h := Finset.le_sup' (fun j : ι => μ.weight j + 0 * μ.value j)
      (Finset.mem_univ i)
    simpa [MaxPlusLaw.cumulant, hi] using h

/-- Every tilted one-step score lies below the max-plus cumulant. -/
theorem MaxPlusLaw.tilted_score_le_cumulant (μ : MaxPlusLaw ι) (θ : ℝ) (i : ι) :
    μ.weight i + θ * μ.value i ≤ μ.cumulant θ := by
  exact Finset.le_sup' (fun j : ι => μ.weight j + θ * μ.value j)
    (Finset.mem_univ i)

/-- The affine expression defining the Legendre transform is bounded by
minus the normalized score of every path realizing the given velocity. -/
theorem MaxPlusLaw.legendre_value_le_neg_path_score
    (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n) (p : Fin n → ι) (θ : ℝ) :
    θ * ((∑ k, μ.value (p k)) / (n : ℝ)) - μ.cumulant θ ≤
      -((∑ k, μ.weight (p k)) / (n : ℝ)) := by
  have hsum : ∑ k, (μ.weight (p k) + θ * μ.value (p k)) ≤
      ∑ _k : Fin n, μ.cumulant θ :=
    Finset.sum_le_sum fun k _ => μ.tilted_score_le_cumulant θ (p k)
  have hnreal : (0 : ℝ) < n := by exact_mod_cast hn
  simp only [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul] at hsum
  rw [← Finset.mul_sum] at hsum
  have hnne : (n : ℝ) ≠ 0 := ne_of_gt hnreal
  field_simp [hnne]
  nlinarith

/-- The value defining the Legendre transform is bounded above at every
empirical velocity.  The bound is supplied by the score of the realizing
path, and is the key finiteness fact needed for a real-valued transform. -/
theorem MaxPlusLaw.legendreSet_bddAbove_of_path
    (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n) (p : Fin n → ι) :
    BddAbove {r : ℝ | ∃ θ : ℝ,
      r = θ * ((∑ k, μ.value (p k)) / (n : ℝ)) - μ.cumulant θ} := by
  refine ⟨-((∑ k, μ.weight (p k)) / (n : ℝ)), ?_⟩
  rintro r ⟨θ, rfl⟩
  exact μ.legendre_value_le_neg_path_score hn p θ

/-- The normalized max-plus score of an `n`-step path. -/
noncomputable def MaxPlusLaw.pathScore (μ : MaxPlusLaw ι) {n : ℕ}
    (p : Fin n → ι) : ℝ :=
  (∑ k, μ.weight (p k)) / (n : ℝ)

/-- The empirical velocity of an `n`-step path. -/
noncomputable def MaxPlusLaw.empiricalVelocity (μ : MaxPlusLaw ι) {n : ℕ}
    (p : Fin n → ι) : ℝ :=
  (∑ k, μ.value (p k)) / (n : ℝ)

/-- The max-plus probability (maximum normalized score) of a nonempty finite
path event. -/
noncomputable def MaxPlusLaw.eventWeight (μ : MaxPlusLaw ι) {n : ℕ}
    (A : Finset (Fin n → ι)) (hA : A.Nonempty) : ℝ :=
  A.sup' hA μ.pathScore

/-- **Max-plus random-walk large-deviation bound.**  For every nonempty i.i.d.
path, its normalized max-plus score is at most minus the
Legendre--Fenchel rate at its empirical velocity.  This is the pathwise form
of the LDP upper bound; taking a maximum over paths in an event preserves it. -/
theorem maxPlus_randomWalk_LDP
    (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n) (p : Fin n → ι) :
    (∑ k, μ.weight (p k)) / (n : ℝ) ≤
      - μ.rate ((∑ k, μ.value (p k)) / (n : ℝ)) := by
  let x : ℝ := (∑ k, μ.value (p k)) / (n : ℝ)
  let w : ℝ := (∑ k, μ.weight (p k)) / (n : ℝ)
  have hupper : μ.rate x ≤ -w := by
    apply csSup_le
    · exact ⟨-μ.cumulant 0, ⟨0, by ring⟩⟩
    · rintro r ⟨θ, rfl⟩
      simpa [x, w] using μ.legendre_value_le_neg_path_score hn p θ
  dsimp [x, w] at hupper ⊢
  linarith

/-- **Finite-event LDP upper bound.**  If every path in a nonempty event has
the same empirical velocity `x`, then the event's max-plus probability has
exponential rate at most `-I(x)`. -/
theorem maxPlus_randomWalk_event_LDP
    (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n)
    (A : Finset (Fin n → ι)) (hA : A.Nonempty) (x : ℝ)
    (hx : ∀ p ∈ A, μ.empiricalVelocity p = x) :
    μ.eventWeight A hA ≤ -μ.rate x := by
  rw [MaxPlusLaw.eventWeight, Finset.sup'_le_iff]
  intro p hp
  have hpath := maxPlus_randomWalk_LDP μ hn p
  rw [show (∑ k, μ.weight (p k)) / (n : ℝ) = μ.pathScore p by rfl,
    show (∑ k, μ.value (p k)) / (n : ℝ) = μ.empiricalVelocity p by rfl,
    hx p hp] at hpath
  exact hpath

/-- The Legendre--Fenchel rate of a normalized max-plus law is nonnegative at
any velocity realized by a finite path. -/
theorem MaxPlusLaw.rate_nonneg_at_empiricalVelocity
    (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n) (p : Fin n → ι) :
    0 ≤ μ.rate ((∑ k, μ.value (p k)) / (n : ℝ)) := by
  apply ArithLDP.rateFunction_nonneg μ.cumulant μ.cumulant_zero
  exact μ.legendreSet_bddAbove_of_path hn p

/-- Consequently every path with zero normalized idempotent score has rate
zero at its empirical velocity. -/
theorem MaxPlusLaw.rate_eq_zero_of_path_score_zero
    (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n) (p : Fin n → ι)
    (hscore : (∑ k, μ.weight (p k)) / (n : ℝ) = 0) :
    μ.rate ((∑ k, μ.value (p k)) / (n : ℝ)) = 0 := by
  apply le_antisymm
  · have h := maxPlus_randomWalk_LDP μ hn p
    rw [hscore] at h
    linarith
  · exact μ.rate_nonneg_at_empiricalVelocity hn p

end IdempotentProbability
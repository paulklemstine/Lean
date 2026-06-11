/-
Copyright (c) 2025. Released under Apache 2.0 license.

# Empirical Rademacher Complexity of Finite Function Classes

This file gives a fully rigorous, self-contained development of the *empirical
Rademacher complexity* of a finite class of real-valued functions evaluated on a
fixed sample of size `m`.  Rademacher complexity is the central data-dependent
capacity measure of statistical learning theory; it controls uniform deviation
bounds and hence generalization error.

We represent a hypothesis evaluated on a sample of size `m` by its vector of
values `f : Fin m → ℝ`.  A Rademacher sign assignment is `σ : Fin m → Bool`,
interpreted via `radSign` as `±1`.  The empirical Rademacher complexity averages
the best-correlating member of the class over *all* `2^m` sign assignments.

This complements the algebraic capacity theory in `Foundations.lean`
(VC dimension, `spectralComplexityBound`, `algebraicSampleComplexityBound`,
whose `8/3` constant arises from the Rademacher-to-PAC conversion) by giving the
*analytic* object those bounds approximate, with exact computations rather than
inequalities.

## Main results

* `sum_radSign`            — the signed indicator of any coordinate cancels over all sign vectors
* `radSum_sum_zero`        — the Rademacher correlation of a fixed function averages to zero
* `radSum_neg`             — Rademacher correlation is odd in the function
* `empRad_singleton`       — the empirical Rademacher complexity of a singleton class is `0`
* `empRad_mono`            — monotonicity of complexity under class inclusion
* `empRad_nonneg`          — complexity is nonnegative for any class containing the zero function
* `empRad_symmetric_pair`  — *exact* formula for the symmetric pair `{f, -f}` (the building block)
-/

import Mathlib

open BigOperators

/-! ## Rademacher signs and correlations -/

/-- The `±1` Rademacher sign attached to a Boolean sign vector at coordinate `i`. -/
def radSign {m : ℕ} (σ : Fin m → Bool) (i : Fin m) : ℝ := if σ i then 1 else -1

/-- The Rademacher correlation of a sample-value vector `f` with sign vector `σ`,
i.e. `∑ i, σ_i f_i`. -/
def radSum {m : ℕ} (f : Fin m → ℝ) (σ : Fin m → Bool) : ℝ := ∑ i, radSign σ i * f i

/-- The **empirical Rademacher complexity** of a nonempty finite function class `F`
on a sample of size `m`: the sample-normalized average over all `2^m` sign vectors
of the best-correlating member of the class. -/
noncomputable def empRad {m : ℕ} (F : Finset (Fin m → ℝ)) (hF : F.Nonempty) : ℝ :=
  (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) * ∑ σ : Fin m → Bool, F.sup' hF (fun f => radSum f σ)

/-! ## Core cancellation identity -/

-- !-- The signed indicator of a fixed coordinate sums to zero over all sign
-- vectors: pair each `σ` with the one obtained by flipping coordinate `i`; the
-- two values `+1` and `-1` cancel, giving a fixed-point-free involution. -- !--
/-- **Core combinatorial cancellation.** For any fixed coordinate `i`, the
Rademacher sign summed over all `2^m` sign vectors is zero. -/
theorem sum_radSign {m : ℕ} (i : Fin m) : ∑ σ : Fin m → Bool, radSign σ i = 0 := by
  apply Finset.sum_involution (fun σ _ => Function.update σ i (!(σ i)))
  · intro σ _; unfold radSign; simp only [Function.update_self]; cases σ i <;> simp
  · intro σ _ _ h; have := congrFun h i; simp [Function.update_self] at this
  · intro σ _; funext j; by_cases hj : j = i
    · subst hj; simp
    · simp [Function.update_of_ne hj]
  · intro σ _; exact Finset.mem_univ _

-- !-- Expand `radSum`, swap the order of summation, and factor each coordinate's
-- contribution through `sum_radSign`. -- !--
/-- The Rademacher correlation of a *fixed* function averages to zero over all
sign vectors.  This is the precise statement that a single hypothesis carries no
Rademacher complexity. -/
theorem radSum_sum_zero {m : ℕ} (f : Fin m → ℝ) :
    ∑ σ : Fin m → Bool, radSum f σ = 0 := by
  unfold radSum
  rw [Finset.sum_comm]
  have h : ∀ i, ∑ σ : Fin m → Bool, radSign σ i * f i = 0 := by
    intro i; rw [← Finset.sum_mul, sum_radSign]; ring
  simp [h]

-- !-- Distribute negation through the sum defining `radSum`. -- !--
/-- The Rademacher correlation is an odd function of its argument. -/
theorem radSum_neg {m : ℕ} (f : Fin m → ℝ) (σ : Fin m → Bool) :
    radSum (-f) σ = - radSum f σ := by
  unfold radSum
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro i _; simp

/-! ## Structural properties of empirical Rademacher complexity -/

-- !-- The supremum over a singleton collapses to the single value, and
-- `radSum_sum_zero` makes the resulting average vanish. -- !--
/-- **Singletons have zero complexity.** A function class consisting of a single
hypothesis has empirical Rademacher complexity zero. -/
theorem empRad_singleton {m : ℕ} (f : Fin m → ℝ) :
    empRad ({f} : Finset (Fin m → ℝ)) (by simp) = 0 := by
  unfold empRad
  have h : ∀ σ, ({f} : Finset (Fin m → ℝ)).sup' (by simp) (fun g => radSum g σ) = radSum f σ := by
    intro σ; simp
  simp_rw [h]
  rw [radSum_sum_zero]; ring

-- !-- The supremum over a subclass is dominated by the supremum over the larger
-- class for every sign vector; summing and multiplying by the nonnegative
-- normalization constant preserves the inequality. -- !--
/-- **Monotonicity.** Enlarging the function class can only increase its empirical
Rademacher complexity. -/
theorem empRad_mono {m : ℕ} (F G : Finset (Fin m → ℝ)) (hF : F.Nonempty)
    (hFG : F ⊆ G) : empRad F hF ≤ empRad G (hF.mono hFG) := by
  unfold empRad
  have hconst : (0 : ℝ) ≤ (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) := by positivity
  apply mul_le_mul_of_nonneg_left _ hconst
  apply Finset.sum_le_sum
  intro σ _
  exact Finset.sup'_mono _ hFG hF

-- !-- For every sign vector the supremum dominates the value at the zero
-- function, which is `0`; hence each summand is nonnegative. -- !--
/-- **Nonnegativity.** Any function class containing the zero hypothesis has
nonnegative empirical Rademacher complexity. -/
theorem empRad_nonneg {m : ℕ} (F : Finset (Fin m → ℝ)) (hF : F.Nonempty)
    (h0 : (0 : Fin m → ℝ) ∈ F) : 0 ≤ empRad F hF := by
  unfold empRad
  have hconst : (0 : ℝ) ≤ (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) := by positivity
  apply mul_nonneg hconst
  apply Finset.sum_nonneg
  intro σ _
  have hle : radSum (0 : Fin m → ℝ) σ ≤ F.sup' hF (fun g => radSum g σ) :=
    Finset.le_sup' (fun g => radSum g σ) h0
  have hz : radSum (0 : Fin m → ℝ) σ = 0 := by unfold radSum; simp
  rwa [hz] at hle

/-! ## The symmetric pair: an exact formula -/

-- !-- For each sign vector the supremum over `{f, -f}` is `max (radSum f σ)
-- (-radSum f σ) = |radSum f σ|` by `radSum_neg` and `abs_eq_max_neg`. -- !--
/-- **Exact formula for the symmetric pair `{f, -f}`.** This is the fundamental
building block of Rademacher analysis: the complexity of the symmetrized
two-point class is exactly the sample-normalized average *absolute* correlation,
making the role of absorption-into-the-supremum completely explicit. -/
theorem empRad_symmetric_pair {m : ℕ} (f : Fin m → ℝ) :
    empRad ({f, -f} : Finset (Fin m → ℝ)) (by simp) =
      (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) * ∑ σ : Fin m → Bool, |radSum f σ| := by
  unfold empRad
  congr 1
  apply Finset.sum_congr rfl
  intro σ _
  have hsup : ({f, -f} : Finset (Fin m → ℝ)).sup' (by simp) (fun g => radSum g σ)
      = max (radSum f σ) (radSum (-f) σ) := by
    rw [Finset.sup'_insert (by simp), Finset.sup'_singleton]
  rw [hsup, radSum_neg, ← abs_eq_max_neg]

-- !-- Immediate from the exact formula since each `|radSum f σ|` is nonnegative
-- and the normalization constant is nonnegative. -- !--
/-- **Corollary / strengthening of `empRad_nonneg` for the symmetric pair.** The
symmetric pair always has nonnegative complexity, with no need for the class to
contain the zero function. -/
theorem empRad_symmetric_pair_nonneg {m : ℕ} (f : Fin m → ℝ) :
    0 ≤ empRad ({f, -f} : Finset (Fin m → ℝ)) (by simp) := by
  rw [empRad_symmetric_pair]
  have hconst : (0 : ℝ) ≤ (1 / (m : ℝ)) * (1 / (2 : ℝ) ^ m) := by positivity
  apply mul_nonneg hconst
  exact Finset.sum_nonneg (fun σ _ => abs_nonneg _)
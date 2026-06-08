/-
# Finite-Dimensional Optimization Core of the Maynard Sieve

This file formalizes the exact extremal inequality S₂(w) ≤ k · S₁(w) where
S₁(w) = ∑ wᵢ² and S₂(w) = (∑ wᵢ)², and characterizes equality as holding
iff all weights are equal. This is the finite-dimensional positivity backbone
of the Maynard–Tao bounded gaps argument.

## Main results

* `sum_sq_le_card_mul_sq_sum` — The Cauchy–Schwarz inequality S₂ ≤ k·S₁
* `rayleigh_quotient_bound` — S₂/S₁ ≤ k with division
* `rayleigh_quotient_eq_iff_constant` — Equality iff all weights are equal
* `positiveWeightProfile_exists_iff` — The threshold existence theorem:
    ∃ w with S₂/S₁ > τ ⟺ τ < k
-/

import Mathlib

open Finset BigOperators

/-- Sum of squares of weights. -/
def S1 {k : ℕ} (w : Fin k → ℝ) : ℝ := ∑ i, (w i) ^ 2

/-- Square of sum of weights. -/
def S2 {k : ℕ} (w : Fin k → ℝ) : ℝ := (∑ i, w i) ^ 2

/-
**Cauchy–Schwarz in finite dimension.** The square of the sum is at most
`k` times the sum of squares. This is the sharp finite-dimensional inequality
underlying Maynard-type weight optimization.
-/
theorem sum_sq_le_card_mul_sq_sum {k : ℕ} (w : Fin k → ℝ) :
    S2 w ≤ k * S1 w := by
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$ of equal length, $(∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2)$.
  have h_cauchy_schwarz : ∀ (u v : Fin k → ℝ), (∑ i, u i * v i)^2 ≤ (∑ i, (u i)^2) * (∑ i, (v i)^2) := by
    exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v;
  convert h_cauchy_schwarz 1 w using 1 <;> norm_num [ S1, S2 ]

/-
The Rayleigh quotient S₂/S₁ is bounded by k.
-/
theorem rayleigh_quotient_bound {k : ℕ} (w : Fin k → ℝ) (hk : 0 < k)
    (hw : S1 w ≠ 0) :
    S2 w / S1 w ≤ k := by
  -- From the hypothesis sum_sq_le_card_mul_sq_sum, we know that $S2 w ≤ k * S1 w$.
  have h_sum_sq_le_card_mul_sq_sum : S2 w ≤ k * S1 w := by
    convert sum_sq_le_card_mul_sq_sum w using 1;
  rwa [ div_le_iff₀ ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ( Ne.symm hw ) ) ]

/-
**Equality characterization.** S₂ = k·S₁ if and only if all weights are equal.
-/
theorem rayleigh_quotient_eq_iff_constant {k : ℕ} (hk : 0 < k) (w : Fin k → ℝ) :
    S2 w = k * S1 w ↔ ∃ c : ℝ, ∀ i, w i = c := by
  constructor <;> intro h;
  · -- By definition of $S2$ and $S1$, we can rewrite the equality as $\sum (w_i - \mu)^2 = 0$, where $\mu = \frac{\sum w_i}{k}$.
    set μ : ℝ := (∑ i, w i) / k
    have h_var : ∑ i, (w i - μ) ^ 2 = 0 := by
      unfold S2 S1 at h;
      simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, h, hk.ne' ];
      norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, h, hk.ne', μ ];
      field_simp;
      linarith;
    exact ⟨ μ, fun i => sub_eq_zero.mp ( by rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => sq_nonneg _ ] at h_var; aesop ) ⟩;
  · unfold S2 S1; obtain ⟨ c, hc ⟩ := h; norm_num [ hc ] ; ring;

/-- A weight profile beats threshold τ if S₂/S₁ > τ. -/
def PositiveWeightProfile {k : ℕ} (τ : ℝ) (w : Fin k → ℝ) : Prop :=
  S2 w / S1 w > τ

/-
**Threshold existence theorem.** There exists a weight vector with
S₂/S₁ > τ if and only if τ < k. This is the exact finite-dimensional
optimization threshold for the Maynard sieve.
-/
theorem positiveWeightProfile_exists_iff {k : ℕ} (hk : 0 < k) (τ : ℝ) :
    (∃ w : Fin k → ℝ, 0 < S1 w ∧ PositiveWeightProfile τ w) ↔ τ < k := by
  constructor <;> intro h;
  · obtain ⟨ w, hw₁, hw₂ ⟩ := h; exact hw₂.trans_le ( rayleigh_quotient_bound w hk ( ne_of_gt hw₁ ) ) ;
  · refine' ⟨ fun _ => 1, _, _ ⟩ <;> norm_num [ S1, S2, PositiveWeightProfile ];
    · linarith;
    · rwa [ sq, mul_div_cancel_left₀ _ ( by positivity ) ]
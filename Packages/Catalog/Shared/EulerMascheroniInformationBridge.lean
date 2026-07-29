import Mathlib

/-!
# Euler–Mascheroni constant as accumulated information divergence

This file connects analytic number theory with information theory.  For positive
rates `λ` and `μ`, the Kullback–Leibler divergence from an exponential law of rate
`λ` to one of rate `μ` has the closed form

`log (λ / μ) + μ / λ - 1`.

At the consecutive integer rates `λ = k+1`, `μ = k+2`, this is exactly the
`k`-th nonnegative summand in the classical series for the Euler–Mascheroni
constant.  Consequently, `γ` is the accumulated KL divergence along the chain
of exponential distributions with rates `1, 2, 3, ...`.
-/

open Real Filter Finset Topology

namespace EulerMascheroniInformationBridge

/-- The classical nonnegative summand whose sum is `γ`. -/
noncomputable def gammaTerm (k : ℕ) : ℝ :=
  1 / (k + 1 : ℝ) - Real.log ((k + 2) / (k + 1))

lemma gammaTerm_nonneg (k : ℕ) : 0 ≤ gammaTerm k := by
  have hx : (0 : ℝ) < (k + 2) / (k + 1) := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  have hsub : ((k : ℝ) + 2) / (k + 1) - 1 = 1 / (k + 1) := by
    field_simp
    ring
  rw [hsub] at h
  simpa [gammaTerm] using sub_nonneg.mpr h

lemma harmonic_cast (n : ℕ) :
    (harmonic n : ℝ) = ∑ k ∈ range n, 1 / (k + 1 : ℝ) := by
  rw [harmonic]
  push_cast
  simp [one_div]

lemma sum_log_telescope (n : ℕ) :
    ∑ k ∈ range n, Real.log ((k + 2) / (k + 1) : ℝ) = Real.log (n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, ih, ← Real.log_mul (by positivity) (by positivity)]
    congr 1
    push_cast
    field_simp
    ring

lemma gammaTerm_partial_sum (n : ℕ) :
    ∑ k ∈ range n, gammaTerm k = Real.eulerMascheroniSeq n := by
  unfold gammaTerm Real.eulerMascheroniSeq
  rw [Finset.sum_sub_distrib, sum_log_telescope, ← harmonic_cast]

lemma hasSum_gammaTerm : HasSum gammaTerm Real.eulerMascheroniConstant := by
  refine (hasSum_iff_tendsto_nat_of_nonneg gammaTerm_nonneg _).mpr ?_
  simp_rw [gammaTerm_partial_sum]
  exact Real.tendsto_eulerMascheroniSeq

/-- Closed form of `D_KL(Exp(λ) ‖ Exp(μ))` for exponential distributions.
The definition is algebraic so the bridge does not depend on a particular
measure-theoretic encoding of probability distributions. -/
noncomputable def exponentialKL (rate₁ rate₂ : ℝ) : ℝ :=
  Real.log (rate₁ / rate₂) + rate₂ / rate₁ - 1

/-- Gibbs' inequality for the closed-form exponential divergence. -/
theorem exponentialKL_nonneg {rate₁ rate₂ : ℝ}
    (h₁ : 0 < rate₁) (h₂ : 0 < rate₂) :
    0 ≤ exponentialKL rate₁ rate₂ := by
  have hr : 0 < rate₂ / rate₁ := div_pos h₂ h₁
  have hlog := Real.log_le_sub_one_of_pos hr
  rw [Real.log_div h₂.ne' h₁.ne'] at hlog
  unfold exponentialKL
  rw [Real.log_div h₁.ne' h₂.ne']
  linarith

/-- The information divergence between consecutive exponential rates is exactly
one summand of the Euler–Mascheroni series. -/
theorem consecutive_exponentialKL_eq_term (k : ℕ) :
    exponentialKL (k + 1 : ℝ) (k + 2 : ℝ) = gammaTerm k := by
  unfold exponentialKL gammaTerm
  have hk1 : (0 : ℝ) < k + 1 := by positivity
  have hk2 : (0 : ℝ) < k + 2 := by positivity
  rw [Real.log_div hk1.ne' hk2.ne', Real.log_div hk2.ne' hk1.ne']
  field_simp
  ring

/-- **Cross-domain connector.** The Euler–Mascheroni constant is the infinite
sum of KL divergences between successive exponential distributions:

`γ = Σ k, D_KL(Exp(k+1) ‖ Exp(k+2))`.
-/
theorem hasSum_consecutive_exponentialKL :
    HasSum (fun k : ℕ => exponentialKL (k + 1 : ℝ) (k + 2 : ℝ))
      Real.eulerMascheroniConstant := by
  simpa only [consecutive_exponentialKL_eq_term] using hasSum_gammaTerm

/-- `tsum` form of the information-theoretic representation of `γ`. -/
theorem tsum_consecutive_exponentialKL :
    ∑' k : ℕ, exponentialKL (k + 1 : ℝ) (k + 2 : ℝ) =
      Real.eulerMascheroniConstant :=
  hasSum_consecutive_exponentialKL.tsum_eq

/-- The cumulative divergence through rate `n+1` is the usual harmonic-logarithm
approximation `Hₙ - log(n+1)`. -/
theorem partial_sum_consecutive_exponentialKL (n : ℕ) :
    ∑ k ∈ range n, exponentialKL (k + 1 : ℝ) (k + 2 : ℝ) =
      Real.eulerMascheroniSeq n := by
  simp_rw [consecutive_exponentialKL_eq_term]
  exact gammaTerm_partial_sum n

/-- The cumulative information divergence converges to `γ`. -/
theorem tendsto_partial_sum_consecutive_exponentialKL :
    Tendsto
      (fun n : ℕ => ∑ k ∈ range n,
        exponentialKL (k + 1 : ℝ) (k + 2 : ℝ))
      atTop (𝓝 Real.eulerMascheroniConstant) := by
  simpa only [partial_sum_consecutive_exponentialKL] using
    Real.tendsto_eulerMascheroniSeq

end EulerMascheroniInformationBridge
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


/-- Every summand in the nonnegative series for `γ` is in fact strictly positive. -/
theorem gammaTerm_pos (k : ℕ) : 0 < gammaTerm k := by
  unfold gammaTerm
  have hx : (0 : ℝ) < (k + 2) / (k + 1) := by positivity
  have hne : (k + 2 : ℝ) / (k + 1) ≠ 1 := by
    rw [ne_eq, div_eq_one_iff_eq (by positivity)]; intro h; linarith
  have hlog := Real.log_lt_sub_one_of_pos hx hne
  have hsub : ((k : ℝ) + 2) / (k + 1) - 1 = 1 / (k + 1) := by field_simp; ring
  rw [hsub] at hlog; linarith

/-- A rational `O(k⁻²)` majorant for the `k`-th Euler–Mascheroni summand. -/
theorem gammaTerm_le_rational (k : ℕ) :
    gammaTerm k ≤ 1 / ((k + 1 : ℝ) * (2 * k + 3)) := by
  unfold gammaTerm
  -- Need: 1/(k+1) - log((k+2)/(k+1)) ≤ 1/((k+1)(2k+3))
  -- Equiv: log((k+2)/(k+1)) ≥ 1/(k+1) - 1/((k+1)(2k+3)) = 2/(2k+3)
  have hk1 : (0 : ℝ) < k + 1 := by positivity
  have hk2 : (0 : ℝ) < k + 2 := by positivity
  have hk23 : (0 : ℝ) < 2 * k + 3 := by positivity
  have h1 : (k + 2 : ℝ) / (k + 1) = 1 + 1 / (k + 1) := by field_simp; ring
  -- Inequality: log(1 + x) ≥ 2x/(2+x) for x > 0
  have x_pos : (0 : ℝ) < 1 / (k + 1) := by positivity
  have log_bound : 2 / (2 * (k : ℝ) + 3) ≤ Real.log ((k + 2) / (k + 1)) := by
    rw [h1]
    have hx : (1 : ℝ) / (k + 1) = 1 / (k + 1) := rfl
    have h2x : 2 / (2 * (k : ℝ) + 3) = 2 * (1 / (k + 1)) / (2 + 1 / (k + 1)) := by
      field_simp
      ring
    rw [h2x]
    -- Prove: 2x/(2+x) ≤ log(1+x) for x > 0
    have padé_lower_bound : ∀ x : ℝ, 0 < x → 2 * x / (2 + x) ≤ Real.log (1 + x) := by
      intro x hx
      by_contra h_neg
      have h_cont : ContinuousOn (fun t => Real.log (1 + t) - 2 * t / (2 + t)) (Set.Icc 0 x) := by
        refine ContinuousOn.sub ?_ ?_
        · exact ContinuousOn.log (continuousOn_const.add continuousOn_id) (by intro t ht; linarith [ht.1])
        · exact (continuousOn_const.mul continuousOn_id).div (continuousOn_const.add continuousOn_id)
            (by intro t ht; linarith [ht.1])
      have h_diff : ∀ y ∈ Set.Ioo 0 x, DifferentiableAt ℝ (fun t => Real.log (1 + t) - 2 * t / (2 + t)) y := by
        intro y hy
        have hy0 : 0 < y := hy.1
        apply DifferentiableAt.sub
        · have h1y : (1 : ℝ) + y ≠ 0 := by linarith
          exact DifferentiableAt.log (differentiableAt_id.const_add _) h1y
        · have h2y : (2 : ℝ) + y ≠ 0 := by linarith
          exact ((differentiableAt_id.const_mul _).div (differentiableAt_id.const_add _) h2y)
      have hderiv_pos : ∀ y ∈ Set.Ioo 0 x, 0 < deriv (fun t => Real.log (1 + t) - 2 * t / (2 + t)) y := by
        intro y hy
        have hy0 : 0 < y := hy.1
        have h1 : (1 : ℝ) + y ≠ 0 := by linarith
        have h2 : (2 : ℝ) + y ≠ 0 := by linarith
        have key : deriv (fun t => Real.log (1 + t) - 2 * t / (2 + t)) y =
            (1 * (2 + y)^2 - (1 + y) * 4) / ((1 + y) * (2 + y)^2) := by
          have := HasDerivAt.sub (Real.hasDerivAt_log h1 |>.comp y (hasDerivAt_id' y |>.const_add 1))
            (HasDerivAt.div ((hasDerivAt_id' y |>.const_mul 2))
              (hasDerivAt_id' y |>.const_add 2) h2)
          convert this.deriv using 1
          field_simp
          ring
        rw [key]
        apply div_pos
        · nlinarith [sq_nonneg y]
        · apply mul_pos (by linarith) (sq_pos_of_pos (by linarith))
      have hf0 : (fun t => Real.log (1 + t) - 2 * t / (2 + t)) 0 = 0 := by simp
      have hf_x_neg : (fun t => Real.log (1 + t) - 2 * t / (2 + t)) x < 0 := by simpa [hf0] using h_neg
      obtain ⟨c, hc_mem, hc_eq⟩ := exists_deriv_eq_slope (fun t => Real.log (1 + t) - 2 * t / (2 + t)) hx
        h_cont (fun y hy => (h_diff y hy).differentiableWithinAt)
      have hderiv_eq : deriv (fun t => Real.log (1 + t) - 2 * t / (2 + t)) c =
          ((fun t => Real.log (1 + t) - 2 * t / (2 + t)) x - 0) / (x - 0) := by
        simpa [hf0] using hc_eq
      have hc_pos : 0 < deriv (fun t => Real.log (1 + t) - 2 * t / (2 + t)) c := hderiv_pos c hc_mem
      rw [hderiv_eq] at hc_pos
      simp only [sub_zero] at hc_pos
      have h_neg_div : (Real.log (1 + x) - 2 * x / (2 + x)) / x < 0 := by
        rw [div_lt_iff₀ hx]
        linarith [hf_x_neg]
      linarith
    exact padé_lower_bound _ x_pos
  have rhs_simp : 1 / ((k + 1 : ℝ)) - 1 / ((k + 1) * (2 * k + 3)) = 2 / (2 * (k : ℝ) + 3) := by
    field_simp
    ring
  linarith

/-- A simpler square-denominator majorant. -/
theorem gammaTerm_le_half_inv_sq (k : ℕ) :
    gammaTerm k ≤ 1 / (2 * (k + 1 : ℝ) ^ 2) := by
  calc gammaTerm k ≤ 1 / ((k + 1 : ℝ) * (2 * k + 3)) := gammaTerm_le_rational k
    _ ≤ 1 / (2 * (k + 1 : ℝ) ^ 2) := by
        apply one_div_le_one_div_of_le
        · positivity
        · have : (2 * (k : ℝ) + 3) ≥ (2 * (k : ℝ) + 2) := by linarith
          nlinarith [sq_nonneg (k : ℝ)]

/-- Exponential KL divergence is unchanged by a common nonzero rescaling. -/
theorem exponentialKL_scale_invariant {c rate₁ rate₂ : ℝ} (hc : c ≠ 0) :
    exponentialKL (c * rate₁) (c * rate₂) = exponentialKL rate₁ rate₂ := by
  simp [exponentialKL, mul_div_mul_left _ _ hc]

/-- Equality case of Gibbs' inequality for positive exponential rates. -/
theorem exponentialKL_eq_zero_iff {rate₁ rate₂ : ℝ}
    (h₁ : 0 < rate₁) (h₂ : 0 < rate₂) :
    exponentialKL rate₁ rate₂ = 0 ↔ rate₁ = rate₂ := by
  constructor
  · intro heq
    unfold exponentialKL at heq
    have hr : 0 < rate₂ / rate₁ := div_pos h₂ h₁
    by_contra hne
    have hne' : rate₂ / rate₁ ≠ 1 := by
      intro h
      field_simp at h
      exact hne h.symm
    have hlog_strict := Real.log_lt_sub_one_of_pos hr hne'
    have hlog_eq : Real.log (rate₁ / rate₂) = -Real.log (rate₂ / rate₁) := by
      rw [← Real.log_inv, inv_div]
    linarith
  · intro heq
    rw [heq]
    unfold exponentialKL
    simp [div_self h₂.ne']

/-- Distinct positive exponential rates have strictly positive divergence. -/
theorem exponentialKL_pos {rate₁ rate₂ : ℝ}
    (h₁ : 0 < rate₁) (h₂ : 0 < rate₂) (hne : rate₁ ≠ rate₂) :
    0 < exponentialKL rate₁ rate₂ := by
  have hne' := mt (exponentialKL_eq_zero_iff h₁ h₂ |>.mp) hne
  exact lt_of_le_of_ne (exponentialKL_nonneg h₁ h₂) (Ne.symm hne')

/-- Exact formula for the symmetrized divergence between two exponential laws. -/
theorem exponentialKL_add_reverse (rate₁ rate₂ : ℝ) :
    exponentialKL rate₁ rate₂ + exponentialKL rate₂ rate₁ =
      rate₁ / rate₂ + rate₂ / rate₁ - 2 := by
  unfold exponentialKL
  have hlog : Real.log (rate₂ / rate₁) = -Real.log (rate₁ / rate₂) := by
    rw [← Real.log_inv, inv_div]
  linarith

/-- The symmetrized divergence has a manifest square form. -/
theorem exponentialKL_add_reverse_eq_sq {rate₁ rate₂ : ℝ}
    (h₁ : rate₁ ≠ 0) (h₂ : rate₂ ≠ 0) :
    exponentialKL rate₁ rate₂ + exponentialKL rate₂ rate₁ =
      (rate₁ - rate₂) ^ 2 / (rate₁ * rate₂) := by
  rw [exponentialKL_add_reverse]
  field_simp
  ring

end EulerMascheroniInformationBridge
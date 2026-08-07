import Novelty.BekensteinHawkingHagedornPole

/-!
# No logarithmic correction in the unconstrained ensemble: the exact subleading constant

The area law proved in `Novelty.BekensteinHawkingAreaLaw` controls the horizon entropy
`S(A) = log W(A)` only up to a bounded correction (`entropy_sub_area_law_abs_le`).  The
sharpest open conjecture of the thread (`FUTURE_DIRECTIONS.md`, Conjecture 1) asks for the
*exact* form of that correction, and Conjecture 5 predicts that in the **unconstrained**
ensemble no polynomial (in particular no `log A`) correction survives at all — in contrast with
the `-(1/2) log A` expected once the projection constraint is imposed.

This file settles the unconstrained half of that dichotomy, with an explicit exponential error
term.  Writing `θ = (2-√2)/(2+√2) < 1` for the ratio of the two eigenvalues of the renewal
recursion:

* `hStates_div_pow_eq` : `W(A)/(2+√2)^A = specA + specB·θ^A` exactly, for `A ≥ 1`;
* `hStates_div_pow_sub_abs_le` : `|W(A)/(2+√2)^A - (1+√2)/4| ≤ ((√2-1)/4)·θ^A`;
* `hStates_div_pow_tendsto` : `W(A)/(2+√2)^A → (1+√2)/4`;
* `entropy_sub_area_law_tendsto` : `S(A) - A·log(2+√2) → log((1+√2)/4)`.

The last statement is the precise sense in which the unconstrained horizon entropy has **no
logarithmic correction**: the subleading term is an explicit constant, `log((1+√2)/4)`, which is
approached exponentially fast.  Any `-(1/2) log A` correction must therefore come from the
projection constraint, not from the microstate counting itself.
-/

open Filter Topology

namespace BekensteinHawking

/-- The ratio of the subdominant to the dominant eigenvalue of the renewal recursion. -/
noncomputable def subRatio : ℝ := growth' / growth

lemma subRatio_pos : 0 < subRatio := div_pos growth'_pos growth_pos

lemma subRatio_lt_one : subRatio < 1 := by
  have h : growth' < growth := by
    unfold growth growth'
    nlinarith [one_lt_sqrt_two]
  rw [subRatio, div_lt_one growth_pos]
  exact h

lemma specA_pos : 0 < specA := by
  unfold specA
  nlinarith [one_lt_sqrt_two]

lemma specB_abs : |specB| = (Real.sqrt 2 - 1) / 4 := by
  unfold specB
  rw [abs_of_nonpos (by nlinarith [one_lt_sqrt_two])]
  ring

/-- **The exact two-term expansion of the normalised microstate count.**  There is no
polynomial correction: the deviation from the constant `specA = (1+√2)/4` is a pure
exponential `specB·θ^A`. -/
theorem hStates_div_pow_eq (n : ℕ) (hn : 1 ≤ n) :
    (hStates n : ℝ) / growth ^ n = specA + specB * subRatio ^ n := by
  have hg : (0:ℝ) < growth ^ n := pow_pos growth_pos n
  rw [hStates_spectral n hn, subRatio, div_pow]
  field_simp

/-- **An explicit exponential error bound for the normalised microstate count.** -/
theorem hStates_div_pow_sub_abs_le (n : ℕ) (hn : 1 ≤ n) :
    |(hStates n : ℝ) / growth ^ n - specA| ≤ ((Real.sqrt 2 - 1) / 4) * subRatio ^ n := by
  rw [hStates_div_pow_eq n hn]
  have h : specA + specB * subRatio ^ n - specA = specB * subRatio ^ n := by ring
  rw [h, abs_mul, specB_abs, abs_of_nonneg (le_of_lt (pow_pos subRatio_pos n))]

/-- **Convergence of the normalised microstate count to the exact spectral constant.** -/
theorem hStates_div_pow_tendsto :
    Tendsto (fun n : ℕ => (hStates n : ℝ) / growth ^ n) atTop (𝓝 specA) := by
  have hpow : Tendsto (fun n : ℕ => subRatio ^ n) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt subRatio_pos) subRatio_lt_one
  have h : Tendsto (fun n : ℕ => specA + specB * subRatio ^ n) atTop (𝓝 (specA + specB * 0)) :=
    tendsto_const_nhds.add (hpow.const_mul specB)
  rw [mul_zero, add_zero] at h
  refine h.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  exact (hStates_div_pow_eq n hn).symm

/-- **The horizon entropy has no logarithmic correction in the unconstrained ensemble.**
`S(A) - A·log(2+√2)` converges to the explicit constant `log((1+√2)/4)`; by
`hStates_div_pow_sub_abs_le` the convergence is exponentially fast.  Hence any `log A`
correction to the Bekenstein–Hawking law in this model must originate from the projection
(Gauss) constraint, not from the raw microstate count. -/
theorem entropy_sub_area_law_tendsto :
    Tendsto (fun n : ℕ => Real.log (hStates n) - n * Real.log growth) atTop
      (𝓝 (Real.log ((1 + Real.sqrt 2) / 4))) := by
  have hcont : Tendsto (fun n : ℕ => Real.log ((hStates n : ℝ) / growth ^ n)) atTop
      (𝓝 (Real.log specA)) :=
    (Real.continuousAt_log (ne_of_gt specA_pos)).tendsto.comp hStates_div_pow_tendsto
  have hspec : Real.log specA = Real.log ((1 + Real.sqrt 2) / 4) := by rw [specA]
  rw [hspec] at hcont
  refine hcont.congr ?_
  intro n
  have hW : (0:ℝ) < (hStates n : ℝ) := hStates_pos n
  have hg : (0:ℝ) < growth ^ n := pow_pos growth_pos n
  rw [Real.log_div (ne_of_gt hW) (ne_of_gt hg), Real.log_pow]

end BekensteinHawking
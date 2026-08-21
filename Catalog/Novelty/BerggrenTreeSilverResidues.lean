import Novelty.BerggrenTreeCriticalLine

/-!
# Simple poles with a uniform residue: the explicit-formula constant of the Berggren tree

`Novelty.BerggrenTreeCriticalLine` locates the poles of the silver Ihara zeta
`Z(s) = (1 − 3ε^{-2s})^{-1}`, `ε = 1 + √2`, on the single vertical line `Re s = σ₀`.
This file completes the analytic picture of that critical line.

* `silverZeta_ne_zero` — `Z` has **no zeros** off its polar set: all of its critical
  structure is polar, so the "Riemann hypothesis" for this zeta is a statement about poles,
  not zeros;
* `silverZeta_period` — the exact functional equation `Z(s + iπ/log ε) = Z(s)`: the critical
  line is invariant under the translation by the pole spacing;
* `silverZeta_residue` — every pole is **simple** and all residues are equal to the same
  constant `1/(2 log ε)`, the analogue of the constant appearing in an explicit formula.
  Quantitatively `1/(2 log(1+√2)) = 0.5673…`.

The uniformity of the residues is the analytic shadow of the fact that the tree is exactly
`3`-regular at every depth, with every step scaling the silver length by exactly `ε²`.
-/

namespace BerggrenZeta

open Complex Filter Topology

/-- The denominator of the silver Ihara zeta. -/
noncomputable def silverDenom (s : ℂ) : ℂ := 1 - 3 * (silverUnit : ℂ) ^ (-2 * s)

theorem silverZeta_eq_inv_denom (s : ℂ) : silverZeta s = (silverDenom s)⁻¹ := rfl

/-- **No zeros.**  Off its polar divisor the silver zeta never vanishes. -/
theorem silverZeta_ne_zero {s : ℂ} (hs : silverDenom s ≠ 0) : silverZeta s ≠ 0 :=
  inv_ne_zero hs

/-- **Functional equation / periodicity.**  Translation by the pole spacing `iπ/log ε`
leaves the silver zeta invariant. -/
theorem silverZeta_period (s : ℂ) :
    silverZeta (s + Complex.I * (Real.pi / Real.log silverUnit)) = silverZeta s := by
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  have hLC : (Real.log silverUnit : ℂ) ≠ 0 := by exact_mod_cast hL.ne'
  have key : (silverUnit : ℂ) ^ (-2 * (s + Complex.I * (Real.pi / Real.log silverUnit)))
      = (silverUnit : ℂ) ^ (-2 * s) := by
    rw [silver_cpow_eq_exp, silver_cpow_eq_exp]
    have hsplit : (-2 * (s + Complex.I * ((Real.pi : ℂ) / (Real.log silverUnit : ℂ))))
        * (Real.log silverUnit : ℂ)
        = (-2 * s) * (Real.log silverUnit : ℂ) + (-(2 * Real.pi)) * Complex.I := by
      field_simp
      ring
    push_cast at hsplit ⊢
    rw [hsplit, Complex.exp_add]
    have : Complex.exp ((-(2 * (Real.pi : ℂ))) * Complex.I) = 1 := by
      rw [show (-(2 * (Real.pi : ℂ))) * Complex.I = -(2 * Real.pi * Complex.I) by ring,
        Complex.exp_neg, Complex.exp_two_pi_mul_I]
      norm_num
    rw [this, mul_one]
  simp only [silverZeta, key]

/-- The derivative of the denominator. -/
theorem hasDerivAt_silverDenom (s : ℂ) :
    HasDerivAt silverDenom
      (6 * (Real.log silverUnit : ℂ) * (silverUnit : ℂ) ^ (-2 * s)) s := by
  have hfun : silverDenom
      = fun z : ℂ => 1 - 3 * Complex.exp ((-2 * z) * (Real.log silverUnit : ℂ)) := by
    funext z
    rw [silverDenom, silver_cpow_eq_exp]
  have hlin : HasDerivAt (fun z : ℂ => (-2 * z) * (Real.log silverUnit : ℂ))
      (-2 * (Real.log silverUnit : ℂ)) s := by
    simpa using (((hasDerivAt_id s).const_mul (-2 : ℂ)).mul_const
      ((Real.log silverUnit : ℂ)))
  have hexp := hlin.cexp
  have hmul := (hexp.const_mul (3 : ℂ))
  have hsub := (hasDerivAt_const s (1 : ℂ)).sub hmul
  rw [hfun]
  convert hsub using 1
  rw [silver_cpow_eq_exp]
  ring

/-- **Simple poles with uniform residue.**  At every pole `s₀` of the silver zeta the limit
`lim_{s → s₀} (s − s₀) Z(s)` exists and equals `1/(2 log ε)`, independently of the pole.
Hence all poles on the critical line are simple with one and the same residue. -/
theorem silverZeta_residue {s₀ : ℂ} (h0 : silverDenom s₀ = 0) :
    Tendsto (fun s => (s - s₀) * silverZeta s) (𝓝[≠] s₀)
      (𝓝 (1 / (2 * (Real.log silverUnit : ℂ)))) := by
  have hL : 0 < Real.log silverUnit := log_silverUnit_pos
  have hLC : (Real.log silverUnit : ℂ) ≠ 0 := by exact_mod_cast hL.ne'
  -- at a pole, `ε^{-2s₀} = 1/3`, so the derivative of the denominator is `2 log ε`
  have hval : (silverUnit : ℂ) ^ (-2 * s₀) = 1 / 3 := by
    rw [silverDenom, sub_eq_zero] at h0
    linear_combination (-1 / 3 : ℂ) * h0
  have hderiv : HasDerivAt silverDenom (2 * (Real.log silverUnit : ℂ)) s₀ := by
    have := hasDerivAt_silverDenom s₀
    rw [hval] at this
    convert this using 1
    ring
  have hne : (2 : ℂ) * (Real.log silverUnit : ℂ) ≠ 0 := by
    simp [hLC]
  rw [hasDerivAt_iff_tendsto_slope] at hderiv
  have hinv := hderiv.inv₀ hne
  have heq : (fun s => (slope silverDenom s₀ s)⁻¹) =ᶠ[𝓝[≠] s₀]
      fun s => (s - s₀) * silverZeta s := by
    filter_upwards [self_mem_nhdsWithin] with s _
    rw [slope_def_field, h0, sub_zero, div_eq_mul_inv, mul_inv, inv_inv, silverZeta,
      ← silverDenom]
    ring
  simpa [one_div] using hinv.congr' heq

/-- The `k`-th point of the critical line. -/
noncomputable def silverPole (k : ℤ) : ℂ :=
  (silverAbscissa : ℂ) + ((k * Real.pi / Real.log silverUnit : ℝ) : ℂ) * Complex.I

theorem silverDenom_silverPole (k : ℤ) : silverDenom (silverPole k) = 0 := by
  rw [silverDenom]
  refine (silver_denom_eq_zero_iff _).2 ⟨?_, k, ?_⟩ <;>
    simp only [silverPole, Complex.add_re, Complex.add_im, Complex.ofReal_re,
      Complex.ofReal_im, Complex.mul_re, Complex.mul_im, Complex.I_re, Complex.I_im,
      mul_zero, mul_one, sub_zero, zero_add, add_zero]

/-- **Uniform residues along the critical line.**  At the `k`-th pole
`s_k = σ₀ + i kπ/log ε` the silver zeta has a simple pole with residue `1/(2 log ε)`, the
same constant for every `k`. -/
theorem silverZeta_residue_on_critical_line (k : ℤ) :
    Tendsto (fun s => (s - silverPole k) * silverZeta s) (𝓝[≠] silverPole k)
      (𝓝 (1 / (2 * (Real.log silverUnit : ℂ)))) :=
  silverZeta_residue (silverDenom_silverPole k)

end BerggrenZeta
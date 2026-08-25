import Mathlib
import Catalog.NumberTheory.ProfileFormHumpLocation
import Catalog.NumberTheory.ProfileFormUniformMixturePeak

/-!
# Profile form IX: a critical exponent for the mixture hump

`ProfileFormUniformMixturePeak` proved that the residual of the power law
`T(x) = (1+x)^{-b}` against the uniform Dickman surrogate
`M(x) = (1 - e^{-x})/x` really does hump, for the measured exponent
`b = 11/10`, at `x ≈ 10`.  `ProfileFormHumpLocation` then explained the location
via the exact maximiser `x* = 1/(b-1)` of the elementary factor
`x (1+x)^{-b}`.

Both results leave open whether the hump is a *universal* feature of this
profile/baseline pair.  It is not.  The exact logarithmic derivative is

  `d/dx log (T/M)(x) = 1/x - b/(1+x) - 1/(e^x - 1)`,

so the hump is a competition between the algebraic term `1/x - b/(1+x)`, which
is positive up to `x* = 1/(b-1)`, and the exponential correction `1/(e^x - 1)`,
which is large exactly where `x` is small.  As `b` increases, `x*` shrinks into
the region where the correction dominates and the hump is destroyed.

Here we prove the destruction side rigorously:

* `exp_lt_pade` — the Padé bound `e^x < (2+x)/(2-x)` on `(0,2)`;
* `one_div_exp_sub_one_gt` — hence `1/x - 1/2 < 1/(e^x - 1)` for all `x > 0`;
* `uniformMixtureResidual_strictAntiOn` — **for every `b ≥ 3/2` the residual
  `T/M` is strictly decreasing on all of `(0,∞)`: no hump anywhere**;
* `uniform_hump_regime_bracket` — combined with the proved hump at `b = 11/10`,
  the humping regime is bracketed: it holds at `11/10` and fails from `3/2` on,
  so a critical exponent lies in `(11/10, 3/2)`.  Numerically it is
  `b_c ≈ 1.1605`, and the reported bootstrap interval `[0.991, 1.218]` straddles
  it — a second, independent way in which the experiment does not settle the
  qualitative shape.

The constant `3/2` is exactly what the two elementary bounds give: the argument
needs `1/(b-1) ≤ 2 ≤ 2b - 1`, i.e. `2b² - 3b ≥ 0`.
-/

namespace ProfileForm

open Set Filter Topology

/-- **Padé bound.**  `e^x < (2+x)/(2-x)` for `0 < x < 2`. -/
theorem exp_lt_pade {x : ℝ} (hx : 0 < x) (hx2 : x < 2) : Real.exp x < (2 + x) / (2 - x) := by
  set h : ℝ → ℝ := fun t => (2 + t) * Real.exp (-t) - (2 - t) with hh
  have hderiv : ∀ t : ℝ, HasDerivAt h (1 - (1 + t) * Real.exp (-t)) t := by
    intro t
    have h1 : HasDerivAt (fun s : ℝ => 2 + s) 1 t := by simpa using (hasDerivAt_id t).const_add 2
    have h2 : HasDerivAt (fun s : ℝ => Real.exp (-s)) (-Real.exp (-t)) t := by
      simpa using (Real.hasDerivAt_exp (-t)).comp t ((hasDerivAt_id t).neg)
    have h3 : HasDerivAt (fun s : ℝ => 2 - s) (-1) t := by
      simpa using (hasDerivAt_id t).const_sub 2
    have hsum := (h1.mul h2).sub h3
    convert hsum using 1
    ring
  have hmono : StrictMonoOn h (Ici (0:ℝ)) := by
    refine strictMonoOn_of_deriv_pos (convex_Ici _)
      (fun t _ => (hderiv t).continuousAt.continuousWithinAt) ?_
    intro t ht
    rw [interior_Ici] at ht
    rw [(hderiv t).deriv]
    have hlt : (1 + t) * Real.exp (-t) < 1 := by
      have hpos : (0:ℝ) < Real.exp t := Real.exp_pos t
      have h1t : 1 + t < Real.exp t := by
        have := Real.add_one_lt_exp (x := t) (by simp only [mem_Ioi] at ht; linarith)
        linarith
      rw [Real.exp_neg, mul_inv_lt_iff₀ hpos]
      linarith
    linarith
  have h0 : h 0 = 0 := by simp [hh]
  have hpos : 0 < h x := by
    have := hmono (mem_Ici.mpr (le_refl (0:ℝ))) (mem_Ici.mpr hx.le) hx
    rw [h0] at this; exact this
  have hexp : (2 - x) < (2 + x) * Real.exp (-x) := by simpa [hh] using hpos
  rw [lt_div_iff₀ (by linarith), mul_comm]
  rw [Real.exp_neg] at hexp
  calc (2 - x) * Real.exp x < ((2 + x) * (Real.exp x)⁻¹) * Real.exp x :=
        mul_lt_mul_of_pos_right hexp (Real.exp_pos x)
    _ = 2 + x := by field_simp

theorem exp_sub_one_pos {x : ℝ} (hx : 0 < x) : 0 < Real.exp x - 1 := by
  have := Real.add_one_lt_exp (x := x) (ne_of_gt hx)
  linarith

/-- The exponential correction dominates near the origin: `1/x - 1/2 < 1/(e^x-1)`. -/
theorem one_div_exp_sub_one_gt {x : ℝ} (hx : 0 < x) :
    1 / x - 1 / 2 < 1 / (Real.exp x - 1) := by
  have hd : 0 < Real.exp x - 1 := exp_sub_one_pos hx
  rcases lt_or_ge x 2 with hx2 | hx2
  · have hp := exp_lt_pade hx hx2
    have h2x : (0:ℝ) < 2 - x := by linarith
    have heq : (2 + x) / (2 - x) - 1 = 2 * x / (2 - x) := by field_simp; ring
    have hstep : Real.exp x - 1 < 2 * x / (2 - x) := by rw [← heq]; linarith
    have hlt : 1 / (2 * x / (2 - x)) < 1 / (Real.exp x - 1) :=
      one_div_lt_one_div_of_lt hd hstep
    have hEq : 1 / (2 * x / (2 - x)) = 1 / x - 1 / 2 := by
      rw [one_div_div]; field_simp
    linarith [hEq ▸ hlt]
  · have h1 : 1 / x - 1 / 2 ≤ 0 := by
      have : 1 / x ≤ 1 / 2 := by
        apply one_div_le_one_div_of_le (by norm_num) hx2
      linarith
    have h2 : 0 < 1 / (Real.exp x - 1) := by positivity
    linarith

/-! ### The log-residual and its derivative -/

/-- Logarithm of the uniform-mixture residual `T/M`. -/
noncomputable def uniformLogResidual (b x : ℝ) : ℝ :=
  Real.log x - b * Real.log (1 + x) - Real.log (1 - Real.exp (-x))

theorem uniformResidual_pos {b x : ℝ} (hx : 0 < x) :
    0 < powerProfile 1 b x / dickmanMixtureBaseline x := by
  have h1 : (0:ℝ) < 1 + x := by linarith
  have hnum : 0 < powerProfile 1 b x := by
    simp only [powerProfile, one_mul]; exact Real.rpow_pos_of_pos h1 _
  exact div_pos hnum (dickmanMixtureBaseline_pos hx)

theorem log_uniformResidual {b x : ℝ} (hx : 0 < x) :
    Real.log (powerProfile 1 b x / dickmanMixtureBaseline x) = uniformLogResidual b x := by
  have h1 : (0:ℝ) < 1 + x := by linarith
  have hden : 0 < 1 - Real.exp (-x) := one_sub_exp_neg_pos hx
  rw [powerProfile, dickmanMixtureBaseline, uniformLogResidual, one_mul]
  rw [div_div_eq_mul_div, Real.log_div (by positivity) (ne_of_gt hden),
    Real.log_mul (by positivity) (ne_of_gt hx), Real.log_rpow h1]
  ring

theorem uniformLogResidual_hasDerivAt (b : ℝ) {x : ℝ} (hx : 0 < x) :
    HasDerivAt (uniformLogResidual b)
      (1 / x - b / (1 + x) - 1 / (Real.exp x - 1)) x := by
  have h1 : (0:ℝ) < 1 + x := by linarith
  have hden : 0 < 1 - Real.exp (-x) := one_sub_exp_neg_pos hx
  have hd : 0 < Real.exp x - 1 := exp_sub_one_pos hx
  have hL1 : HasDerivAt Real.log (1 / x) x := by
    simpa [one_div] using Real.hasDerivAt_log (ne_of_gt hx)
  have hL2 : HasDerivAt (fun t : ℝ => b * Real.log (1 + t)) (b * (1 / (1 + x))) x := by
    have hg : HasDerivAt (fun t : ℝ => 1 + t) 1 x := by
      simpa using (hasDerivAt_id x).const_add 1
    have := (Real.hasDerivAt_log (ne_of_gt h1)).comp x hg
    simpa [one_div] using this.const_mul b
  have hL3 : HasDerivAt (fun t : ℝ => Real.log (1 - Real.exp (-t)))
      (Real.exp (-x) / (1 - Real.exp (-x))) x := by
    have hg : HasDerivAt (fun t : ℝ => 1 - Real.exp (-t)) (Real.exp (-x)) x := by
      have h2 : HasDerivAt (fun s : ℝ => Real.exp (-s)) (-Real.exp (-x)) x := by
        simpa using (Real.hasDerivAt_exp (-x)).comp x ((hasDerivAt_id x).neg)
      simpa using h2.const_sub 1
    have := (Real.hasDerivAt_log (ne_of_gt hden)).comp x hg
    simpa [div_eq_mul_inv, mul_comm] using this
  have hcorr : Real.exp (-x) / (1 - Real.exp (-x)) = 1 / (Real.exp x - 1) := by
    have h11 : Real.exp (-x) * Real.exp x = 1 := by
      rw [← Real.exp_add]; simp
    rw [div_eq_div_iff (ne_of_gt hden) (ne_of_gt hd)]
    linear_combination h11
  have := (hL1.sub hL2).sub hL3
  rw [hcorr] at this
  convert this using 1
  ring

/-- **No hump for large exponents.**  For every `b ≥ 3/2` the uniform-mixture
residual `T/M` is strictly decreasing on the whole of `(0, ∞)`. -/
theorem uniformMixtureResidual_strictAntiOn {b : ℝ} (hb : 3/2 ≤ b) :
    StrictAntiOn (fun x => powerProfile 1 b x / dickmanMixtureBaseline x) (Ioi (0:ℝ)) := by
  have hlog : StrictAntiOn (uniformLogResidual b) (Ioi (0:ℝ)) := by
    refine strictAntiOn_of_deriv_neg (convex_Ioi _)
      (fun t ht => (uniformLogResidual_hasDerivAt b ht).continuousAt.continuousWithinAt) ?_
    intro x hx
    rw [interior_Ioi] at hx
    have hx0 : 0 < x := hx
    rw [(uniformLogResidual_hasDerivAt b hx0).deriv]
    have hcorr := one_div_exp_sub_one_gt hx0
    have h1 : (0:ℝ) < 1 + x := by linarith
    rcases le_or_gt x 2 with hle | hgt
    · -- small `x`: the exponential correction already beats the algebraic term
      have hb3 : (1:ℝ)/2 ≤ b / (1 + x) := by
        rw [le_div_iff₀ h1]; linarith
      linarith
    · -- large `x`: the algebraic term is itself non-positive
      have halg : 1 / x - b / (1 + x) ≤ 0 := by
        rw [sub_nonpos, div_le_div_iff₀ hx0 h1]
        nlinarith
      have hpos : 0 < 1 / (Real.exp x - 1) := by
        have := exp_sub_one_pos hx0; positivity
      linarith
  intro x hx y hy hxy
  have hx0 : 0 < x := hx
  have hy0 : 0 < y := hy
  have hRx : 0 < powerProfile 1 b x / dickmanMixtureBaseline x := uniformResidual_pos hx0
  have hRy : 0 < powerProfile 1 b y / dickmanMixtureBaseline y := uniformResidual_pos hy0
  have hlt := hlog hx hy hxy
  rw [← log_uniformResidual hx0, ← log_uniformResidual hy0] at hlt
  exact (Real.log_lt_log_iff hRy hRx).mp hlt

/-- **Bracketing the humping regime.**  The uniform-mixture residual humps at the
measured exponent `b = 11/10` but is strictly monotone for every `b ≥ 3/2`; so
the qualitative shape of the residual changes at some critical exponent in
`(11/10, 3/2)`. -/
theorem uniform_hump_regime_bracket :
    (∃ m ∈ Ioo (3:ℝ) 100,
        IsMaxOn (fun x => powerProfile 1 (11/10) x / dickmanMixtureBaseline x)
          (Icc (3:ℝ) 100) m) ∧
      (∀ b : ℝ, 3/2 ≤ b →
        StrictAntiOn (fun x => powerProfile 1 b x / dickmanMixtureBaseline x) (Ioi (0:ℝ))) := by
  refine ⟨?_, fun b hb => uniformMixtureResidual_strictAntiOn hb⟩
  exact uniformResidual_peak.1

/-- Consequence for the interpretation of the experiment: the hump is *not* a
structural property of the profile/baseline pair, since a monotone regime exists
for the very same pair at a different exponent. -/
theorem hump_is_exponent_dependent :
    ∃ b₁ b₂ : ℝ, 1 < b₁ ∧ b₁ < b₂ ∧
      (¬ AntitoneOn (fun x => powerProfile 1 b₁ x / dickmanMixtureBaseline x) (Icc (3:ℝ) 100)) ∧
      StrictAntiOn (fun x => powerProfile 1 b₂ x / dickmanMixtureBaseline x) (Ioi (0:ℝ)) := by
  refine ⟨11/10, 3/2, by norm_num, by norm_num, ?_,
    uniformMixtureResidual_strictAntiOn (le_refl _)⟩
  exact uniformResidual_peak.2.2

end ProfileForm
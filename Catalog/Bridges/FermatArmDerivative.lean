import Mathlib
import Bridges.FactorLocalExponentPlane

/-!
# Arm-(non)invariance as a derivative, and exponent rigidity for Fermat

`Bridges.FactorLocalExponentPlane` proved the invariance dichotomy in discrete form:
trial division returns literally the same cost when the second prime moves, while
Fermat's gap strictly increases.  This file gives the analytic version measured by the
experiment: arm-invariance is the size of the derivative in the second prime.

* `hasDerivAt_fermatGapReal`, `deriv_fermatGapReal` — the Fermat gap, viewed as a
  smooth function of the second prime `x`, has derivative `1/2 - √p/(2√x)`.
* `deriv_fermatGapReal_ge` — on any arm with `x ≥ 2p` the derivative is at least
  `1/2 - 1/(2√2) > 0.146`: a *uniformly positive* sensitivity, which is exactly the
  measured "Fermat strongly non-invariant".
* `deriv_tdCostReal` — trial division's cost, as a function of the second prime, is
  constant, so its derivative vanishes identically: exact arm-invariance.
* `arm_derivative_dichotomy` — the two facts side by side.
* `fermat_logb_tendsto_one` — **exponent rigidity**: along the arm `q = 2p` the fitted
  exponent `log_p(cost)` converges to `1`.  The measured `0.9932` is a finite-size
  effect of the additive constant `log(3/2 - √2)`, not a different exponent.
-/

namespace FactorPlane

open Filter Topology

/-- The Fermat gap as a function of a *real* second prime. -/
noncomputable def fermatGapReal (p x : ℝ) : ℝ := (p + x) / 2 - Real.sqrt (p * x)

theorem fermatGapReal_natCast (p q : ℕ) : fermatGapReal p q = fermatGap p q := rfl

/-- The Fermat gap is differentiable in the second prime, with derivative
`1/2 - √p/(2√x)`. -/
theorem hasDerivAt_fermatGapReal {p x : ℝ} (hp : 0 < p) (hx : 0 < x) :
    HasDerivAt (fun t => fermatGapReal p t) (1 / 2 - Real.sqrt p / (2 * Real.sqrt x)) x := by
  have hlin : HasDerivAt (fun t : ℝ => (p + t) / 2) (1 / 2) x := by
    simpa using ((hasDerivAt_id x).const_add p).div_const 2
  have hmul : HasDerivAt (fun t : ℝ => p * t) p x := by
    simpa using (hasDerivAt_id x).const_mul p
  have hne : p * x ≠ 0 := by positivity
  have hsqrt : HasDerivAt (fun t : ℝ => Real.sqrt (p * t)) (p / (2 * Real.sqrt (p * x))) x :=
    hmul.sqrt hne
  have hrew : p / (2 * Real.sqrt (p * x)) = Real.sqrt p / (2 * Real.sqrt x) := by
    rw [Real.sqrt_mul hp.le]
    have hsp : 0 < Real.sqrt p := Real.sqrt_pos.mpr hp
    have hsx : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx
    have hpp : Real.sqrt p * Real.sqrt p = p := Real.mul_self_sqrt hp.le
    field_simp
    nlinarith [hpp, hsp, hsx]
  rw [hrew] at hsqrt
  exact hlin.sub hsqrt

theorem deriv_fermatGapReal {p x : ℝ} (hp : 0 < p) (hx : 0 < x) :
    deriv (fun t => fermatGapReal p t) x = 1 / 2 - Real.sqrt p / (2 * Real.sqrt x) :=
  (hasDerivAt_fermatGapReal hp hx).deriv

/-- **Fermat is uniformly arm-sensitive.**  On any arm with `x ≥ 2p` the derivative of
the cost in the second prime is at least `1/2 - 1/(2√2) > 0.146`; it never degenerates,
so a change of arm always moves the fitted constant. -/
theorem deriv_fermatGapReal_ge {p x : ℝ} (hp : 0 < p) (hx : 2 * p ≤ x) :
    1 / 2 - 1 / (2 * Real.sqrt 2) ≤ deriv (fun t => fermatGapReal p t) x := by
  have hx0 : 0 < x := lt_of_lt_of_le (by linarith) hx
  rw [deriv_fermatGapReal hp hx0]
  have hsp : 0 < Real.sqrt p := Real.sqrt_pos.mpr hp
  have hs2 : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  have hsx : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx0
  have hmono : Real.sqrt (2 * p) ≤ Real.sqrt x := Real.sqrt_le_sqrt hx
  have hsplit : Real.sqrt (2 * p) = Real.sqrt 2 * Real.sqrt p := Real.sqrt_mul (by norm_num) p
  have hkey : Real.sqrt p / (2 * Real.sqrt x) ≤ 1 / (2 * Real.sqrt 2) := by
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hmono, hsplit, hsp, hs2, hsx]
  linarith

/-- Trial division's cost as a function of the second prime is constant. -/
theorem deriv_tdCostReal (p : ℕ) (x : ℝ) :
    deriv (fun _ : ℝ => (tdCost p : ℝ)) x = 0 := deriv_const x _

/-- **The dichotomy, in derivative form.**  The `q`-derivative of the trial-division
cost is identically `0`; the `q`-derivative of the Fermat cost is bounded below by a
positive absolute constant on every arm with `q ≥ 2p`. -/
theorem arm_derivative_dichotomy {p x : ℝ} (hp : 0 < p) (hx : 2 * p ≤ x) (N : ℕ) :
    deriv (fun _ : ℝ => (tdCost N : ℝ)) x = 0 ∧
      0 < deriv (fun t => fermatGapReal p t) x := by
  refine ⟨deriv_const x _, ?_⟩
  have hge := deriv_fermatGapReal_ge hp hx
  have h2 : Real.sqrt 2 > 1 := by
    have : Real.sqrt 1 < Real.sqrt 2 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    simpa using this
  have : 1 / (2 * Real.sqrt 2) < 1 / 2 := by
    rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
    linarith
  linarith

/-! ## Exponent rigidity along the arm `q = 2p` -/

/-- On the arm `q = 2p` the Fermat gap is exactly `(3/2 - √2)·p`. -/
theorem fermatGapReal_two_mul {p : ℝ} (hp : 0 < p) :
    fermatGapReal p (2 * p) = (3 / 2 - Real.sqrt 2) * p := by
  have hsplit : Real.sqrt (p * (2 * p)) = Real.sqrt 2 * p := by
    have h : p * (2 * p) = 2 * p ^ 2 := by ring
    rw [h, Real.sqrt_mul (by norm_num), Real.sqrt_sq hp.le]
  rw [fermatGapReal, hsplit]
  ring

theorem three_halves_sub_sqrt_two_pos : 0 < 3 / 2 - Real.sqrt 2 := by
  have h : Real.sqrt 2 < 3 / 2 := by
    have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    nlinarith [Real.sqrt_nonneg 2, h2]
  linarith

/-- **Exponent rigidity.**  Along the bounded-ratio arm `q = 2p`, the fitted exponent
`log_p (cost)` tends to `1`.  Any measured value below `1` (such as `0.9932`) is the
finite-`p` effect of the multiplicative constant `3/2 - √2 ≈ 0.0858`, not evidence of a
different exponent. -/
theorem fermat_logb_tendsto_one :
    Tendsto (fun p : ℕ => Real.logb p (fermatGapReal p (2 * p))) atTop (𝓝 1) := by
  set c : ℝ := 3 / 2 - Real.sqrt 2 with hc
  have hcpos : 0 < c := three_halves_sub_sqrt_two_pos
  have hlog : Tendsto (fun p : ℕ => Real.log p) atTop atTop :=
    Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop
  have hzero : Tendsto (fun p : ℕ => Real.log c / Real.log p) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hlog
  have hone : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
  have hsum : Tendsto (fun p : ℕ => Real.log c / Real.log p + 1) atTop (𝓝 (0 + 1)) :=
    hzero.add hone
  rw [zero_add] at hsum
  refine hsum.congr' ?_
  filter_upwards [eventually_gt_atTop 1] with p hp
  have hp0 : (0 : ℝ) < p := by positivity
  have hlogp : Real.log p ≠ 0 := by
    have : (1 : ℝ) < p := by exact_mod_cast hp
    exact ne_of_gt (Real.log_pos this)
  rw [fermatGapReal_two_mul hp0, Real.logb, Real.log_mul (ne_of_gt hcpos) (ne_of_gt hp0)]
  field_simp

end FactorPlane
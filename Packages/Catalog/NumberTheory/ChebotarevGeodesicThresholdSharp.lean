/-
# Sharpness of the effective (Linnik-type) threshold

Continuation of `Shared.ChebotarevGeodesicEffective`, which proves

  `effective_lower_bound` : `π x ≥ (c/2)·x^β` for every `x ≥ max X₁ ((2C/c)^{2/(β-θ)})`

from the two hypotheses `|π - M| ≤ C x^{(θ+β)/2}` and `M x ≥ c x^β`.  Conjecture C3 of
`FUTURE_DIRECTIONS.md` asks whether the explicit threshold `(2C/c)^{2/(β-θ)}` is the true one.
It is: this file exhibits, for arbitrary admissible data `(c, C, θ, β)`, the extremal counting
function

  `criticalCount c C θ β x = c·x^β - C·x^{(θ+β)/2}`

for which the hypotheses hold with *equality*, and shows

* `criticalCount_error` : the error is exactly `C·x^{(θ+β)/2}`, so the data are admissible;
* `criticalCount_lt_half_of_lt_threshold` : *below* the threshold the conclusion **fails**
  everywhere, `π x < (c/2)·x^β`;
* `criticalCount_at_threshold` : *at* the threshold the conclusion holds with equality;
* `effective_threshold_sharp` : the packaged statement — the threshold of
  `effective_lower_bound` is attained and cannot be decreased;
* `effective_threshold_sharp_25_36` : the numerical instance of the paper, in which the
  least-geodesic threshold has the exact shape `(2C/c)^{72/11}`.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicEffective

open Filter
open scoped Topology

namespace ChebotarevGeodesic

/-- The extremal counting function for the effective threshold: main term `c x^β` minus the
largest admissible error `C x^{(θ+β)/2}`. -/
noncomputable def criticalCount (c C θ β x : ℝ) : ℝ := c * x ^ β - C * x ^ ((θ + β) / 2)

/-- `criticalCount` realises the error bound with equality, so it is admissible data for
`effective_lower_bound`. -/
theorem criticalCount_error {c C θ β x : ℝ} (hC : 0 < C) (hx : 0 < x) :
    |criticalCount c C θ β x - c * x ^ β| = C * x ^ ((θ + β) / 2) := by
  have hpos : (0 : ℝ) < x ^ ((θ + β) / 2) := Real.rpow_pos_of_pos hx _
  rw [criticalCount, show c * x ^ β - C * x ^ ((θ + β) / 2) - c * x ^ β
      = -(C * x ^ ((θ + β) / 2)) by ring, abs_neg, abs_of_pos (by positivity)]

/-- The threshold value `(2C/c)^{2/(β-θ)}` raised to the power `(β-θ)/2` is exactly `2C/c`. -/
theorem threshold_rpow {c C θ β : ℝ} (hc : 0 < c) (hC : 0 < C) (hθβ : θ < β) :
    ((2 * C / c) ^ (2 / (β - θ))) ^ ((β - θ) / 2) = 2 * C / c := by
  have hA : (0 : ℝ) < 2 * C / c := by positivity
  have hne : β - θ ≠ 0 := ne_of_gt (by linarith)
  rw [← Real.rpow_mul hA.le]
  rw [show 2 / (β - θ) * ((β - θ) / 2) = 1 by field_simp]
  exact Real.rpow_one _

/-- **Below the threshold the effective lower bound fails.**  For every `x` strictly between
`0` and `(2C/c)^{2/(β-θ)}` the extremal counting function satisfies `π x < (c/2)·x^β`. -/
theorem criticalCount_lt_half_of_lt_threshold {c C θ β x : ℝ} (hc : 0 < c) (hC : 0 < C)
    (hθβ : θ < β) (hx : 0 < x) (hlt : x < (2 * C / c) ^ (2 / (β - θ))) :
    criticalCount c C θ β x < (c / 2) * x ^ β := by
  set δ : ℝ := (β - θ) / 2 with hδdef
  have hδ : 0 < δ := by simp only [hδdef]; linarith
  have hmid : (0 : ℝ) < x ^ ((θ + β) / 2) := Real.rpow_pos_of_pos hx _
  have hsplit : x ^ β = x ^ ((θ + β) / 2) * x ^ δ := by
    rw [← Real.rpow_add hx]
    congr 1
    simp only [hδdef]; ring
  have hxδ : x ^ δ < 2 * C / c := by
    have h := Real.rpow_lt_rpow hx.le hlt hδ
    rwa [threshold_rpow hc hC hθβ] at h
  have hkey : (c / 2) * x ^ β < C * x ^ ((θ + β) / 2) := by
    rw [hsplit]
    calc (c / 2) * (x ^ ((θ + β) / 2) * x ^ δ)
        = (c / 2) * x ^ δ * x ^ ((θ + β) / 2) := by ring
      _ < (c / 2) * (2 * C / c) * x ^ ((θ + β) / 2) := by
          have hmul : (c / 2) * x ^ δ < (c / 2) * (2 * C / c) :=
            mul_lt_mul_of_pos_left hxδ (by positivity)
          exact mul_lt_mul_of_pos_right hmul hmid
      _ = C * x ^ ((θ + β) / 2) := by field_simp
  rw [criticalCount]
  linarith

/-- **At the threshold the effective lower bound holds, with equality.** -/
theorem criticalCount_at_threshold {c C θ β : ℝ} (hc : 0 < c) (hC : 0 < C) (hθβ : θ < β) :
    criticalCount c C θ β ((2 * C / c) ^ (2 / (β - θ)))
      = (c / 2) * ((2 * C / c) ^ (2 / (β - θ))) ^ β := by
  set T : ℝ := (2 * C / c) ^ (2 / (β - θ)) with hTdef
  have hT : 0 < T := Real.rpow_pos_of_pos (by positivity) _
  set δ : ℝ := (β - θ) / 2 with hδdef
  have hδ : 0 < δ := by simp only [hδdef]; linarith
  have hsplit : T ^ β = T ^ ((θ + β) / 2) * T ^ δ := by
    rw [← Real.rpow_add hT]
    congr 1
    simp only [hδdef]; ring
  have hTδ : T ^ δ = 2 * C / c := by rw [hTdef, hδdef]; exact threshold_rpow hc hC hθβ
  have hmid : (0 : ℝ) < T ^ ((θ + β) / 2) := Real.rpow_pos_of_pos hT _
  rw [criticalCount, hsplit, hTδ]
  field_simp
  ring

/-- **The effective threshold is sharp.**  For all admissible data there is a counting function
with main term `c x^β` and error exactly `C x^{(θ+β)/2}` for which

* the conclusion `π x ≥ (c/2) x^β` of `effective_lower_bound` fails for **every**
  `0 < x < (2C/c)^{2/(β-θ)}`, and
* holds with equality at `x = (2C/c)^{2/(β-θ)}`.

So the exponent `2/(β-θ)` in the Linnik-type threshold cannot be lowered. -/
theorem effective_threshold_sharp {c C θ β : ℝ} (hc : 0 < c) (hC : 0 < C) (hθβ : θ < β) :
    (∀ x > 0, |criticalCount c C θ β x - c * x ^ β| = C * x ^ ((θ + β) / 2)) ∧
      (∀ x, 0 < x → x < (2 * C / c) ^ (2 / (β - θ)) →
        criticalCount c C θ β x < (c / 2) * x ^ β) ∧
      criticalCount c C θ β ((2 * C / c) ^ (2 / (β - θ)))
        = (c / 2) * ((2 * C / c) ^ (2 / (β - θ))) ^ β :=
  ⟨fun _ hx => criticalCount_error hC hx,
   fun _ hx hlt => criticalCount_lt_half_of_lt_threshold hc hC hθβ hx hlt,
   criticalCount_at_threshold hc hC hθβ⟩

/-- The numerical instance of the paper (`θ = 25/36`, `β = 1`): the least-geodesic threshold
`(2C/c)^{72/11}` of `effective_lower_bound_25_36` is exactly attained. -/
theorem effective_threshold_sharp_25_36 {c C : ℝ} (hc : 0 < c) (hC : 0 < C) :
    (∀ x, 0 < x → x < (2 * C / c) ^ ((72 : ℝ) / 11) →
        criticalCount c C (25 / 36) 1 x < (c / 2) * x ^ (1 : ℝ)) ∧
      criticalCount c C (25 / 36) 1 ((2 * C / c) ^ ((72 : ℝ) / 11))
        = (c / 2) * ((2 * C / c) ^ ((72 : ℝ) / 11)) ^ (1 : ℝ) := by
  have e₂ : (2 : ℝ) / (1 - 25 / 36) = 72 / 11 := by norm_num
  constructor
  · intro x hx hlt
    exact criticalCount_lt_half_of_lt_threshold hc hC (by norm_num) hx (by rwa [e₂])
  · have h := criticalCount_at_threshold (c := c) (C := C) (θ := 25 / 36) (β := 1)
      hc hC (by norm_num)
    rwa [e₂] at h

end ChebotarevGeodesic
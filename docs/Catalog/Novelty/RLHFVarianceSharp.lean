import Novelty.RLHFVarianceDrift

/-!
# The standard-deviation drift law is exact

Domain: Novelty (information theory × asymptotic analysis × alignment theory).

`Novelty.RLHFVarianceDrift` proves the upper bound
`‖π_β − p‖₁ ≤ √(2 e^{range r/β} Var_p(r))/β`, i.e. a drift of order `σ_p(r)/β` where
`σ_p(r) = √(Var_p r)` is the reference standard deviation of the reward.  Two things
could still go wrong: the *variance* could be the wrong functional (some smaller
quantity might control the drift), or the `β⁻¹` rate could be an artifact.

This file rules both out on a one-parameter family, by *computing* the drift exactly:

* `RLHF.l1Dist_scaledSpike` — for the uniform reference on `Bool` and the reward
  `a · 1_{true}`, the drift is exactly `tanh(a/(2β)) = (e^{a/β} − 1)/(e^{a/β} + 1)`;
* `RLHF.variance_scaledSpike` — the reference variance of that reward is `a²/4`,
  so `σ = a/2`;
* `RLHF.variance_constant_optimal` — hence for `0 < a ≤ β` the drift is sandwiched:
  `σ/(2β) ≤ ‖π_β − p‖₁ ≤ 3σ/β`.

So the drift law is `Θ(σ_p(r)/β)`: both the functional `σ_p(r)` and the rate `β⁻¹`
of the previous cycle are correct, and only the absolute constant is open.
-/

namespace RLHF

open Finset

/-- The one-bit reward of amplitude `a`: `r = a · 1_{true}`. -/
noncomputable def scaledSpike (a : ℝ) : Bool → ℝ := fun b => if b then a else 0

theorem variance_scaledSpike (a : ℝ) : variance unifBool (scaledSpike a) = a ^ 2 / 4 := by
  have hmean : mean unifBool (scaledSpike a) = a / 2 := by
    simp [mean, unifBool, scaledSpike]
    ring
  simp [variance, hmean, unifBool, scaledSpike]
  ring

theorem sqrt_variance_scaledSpike {a : ℝ} (ha : 0 ≤ a) :
    Real.sqrt (variance unifBool (scaledSpike a)) = a / 2 := by
  rw [variance_scaledSpike]
  rw [show a ^ 2 / 4 = (a / 2) ^ 2 by ring]
  exact Real.sqrt_sq (by positivity)

theorem rewardRange_scaledSpike {a : ℝ} (ha : 0 ≤ a) : rewardRange (scaledSpike a) = a := by
  simp [rewardRange, scaledSpike, max_eq_left ha, min_eq_right ha]

theorem partition_scaledSpike {β a : ℝ} :
    partition β (scaledSpike a) unifBool = (Real.exp (a / β) + 1) / 2 := by
  simp [partition, unifBool, scaledSpike]
  ring

/-- **Exact drift in the scaled two-point model**: `‖π_β − p‖₁ = tanh(a/(2β))`. -/
theorem l1Dist_scaledSpike {β a : ℝ} (ha : 0 ≤ a) (hβ : 0 < β) :
    l1Dist (gibbsPolicy β (scaledSpike a) unifBool) unifBool
      = (Real.exp (a / β) - 1) / (Real.exp (a / β) + 1) := by
  have hE : (1 : ℝ) ≤ Real.exp (a / β) := Real.one_le_exp (by positivity)
  have hden : (0 : ℝ) < Real.exp (a / β) + 1 := by linarith
  have ht : gibbsPolicy β (scaledSpike a) unifBool true
      = Real.exp (a / β) / (Real.exp (a / β) + 1) := by
    simp [gibbsPolicy, partition_scaledSpike, unifBool, scaledSpike]
    field_simp
  have hf : gibbsPolicy β (scaledSpike a) unifBool false = 1 / (Real.exp (a / β) + 1) := by
    simp [gibbsPolicy, partition_scaledSpike, unifBool, scaledSpike]
    field_simp
  have h1 : Real.exp (a / β) / (Real.exp (a / β) + 1) - 1 / 2
      = (Real.exp (a / β) - 1) / (2 * (Real.exp (a / β) + 1)) := by
    field_simp; ring
  have h2 : 1 / (Real.exp (a / β) + 1) - 1 / 2
      = -((Real.exp (a / β) - 1) / (2 * (Real.exp (a / β) + 1))) := by
    field_simp; ring
  have hnn : 0 ≤ (Real.exp (a / β) - 1) / (2 * (Real.exp (a / β) + 1)) :=
    div_nonneg (by linarith) (by linarith)
  simp only [l1Dist, Fintype.sum_bool, ht, hf, unifBool]
  rw [h1, h2, abs_of_nonneg hnn, abs_neg, abs_of_nonneg hnn]
  field_simp
  ring

theorem exp_le_three {x : ℝ} (hx : x ≤ 1) : Real.exp x ≤ 3 :=
  le_trans (Real.exp_le_exp.2 hx) (by linarith [Real.exp_one_lt_d9])

/-- **The standard deviation is the right drift constant: matching bounds.**
For the two-point model with reward amplitude `0 < a ≤ β` (so the temperature is at
least the reward scale), the drift obeys
`σ/(2β) ≤ ‖π_β − p‖₁ ≤ 3σ/β` with `σ = √(Var_p r) = a/2`.
Together with `RLHF.gibbs_l1_le_variance` this shows the drift law is exactly
`Θ(σ_p(r)/β)`: not `Θ(range(r)/β)`, and not `Θ(β^{-1/2})`. -/
theorem variance_constant_optimal {β a : ℝ} (ha : 0 < a) (hab : a ≤ β) :
    Real.sqrt (variance unifBool (scaledSpike a)) / (2 * β)
        ≤ l1Dist (gibbsPolicy β (scaledSpike a) unifBool) unifBool ∧
      l1Dist (gibbsPolicy β (scaledSpike a) unifBool) unifBool
        ≤ 3 * Real.sqrt (variance unifBool (scaledSpike a)) / β := by
  have hβ : 0 < β := lt_of_lt_of_le ha hab
  have hx : a / β ≤ 1 := by
    rw [div_le_one hβ]; exact hab
  have hx0 : 0 < a / β := by positivity
  have hσ : Real.sqrt (variance unifBool (scaledSpike a)) = a / 2 :=
    sqrt_variance_scaledSpike ha.le
  have hexp3 : Real.exp (a / β) ≤ 3 := exp_le_three hx
  have hexp1 : a / β + 1 ≤ Real.exp (a / β) := by
    linarith [Real.add_one_le_exp (a / β)]
  have hden : (0 : ℝ) < Real.exp (a / β) + 1 := by positivity
  constructor
  · rw [l1Dist_scaledSpike ha.le hβ, hσ]
    rw [div_le_div_iff₀ (by positivity) hden]
    have h1 : a / β ≤ Real.exp (a / β) - 1 := by linarith
    have h2 : Real.exp (a / β) + 1 ≤ 4 := by linarith
    have h3 : a / 2 * (Real.exp (a / β) + 1) ≤ a / 2 * 4 :=
      mul_le_mul_of_nonneg_left h2 (by positivity)
    have h4 : a / 2 * 4 = 2 * β * (a / β) := by field_simp; ring
    have h5 : 2 * β * (a / β) ≤ 2 * β * (Real.exp (a / β) - 1) :=
      mul_le_mul_of_nonneg_left h1 (by positivity)
    linarith
  · have hupper := gibbs_l1_le_variance (r := scaledSpike a) (p := unifBool) hβ
      unifBool_isPosDist
    refine hupper.trans ?_
    rw [rewardRange_scaledSpike ha.le, hσ, variance_scaledSpike]
    have hnum : 2 * Real.exp (a / β) * (a ^ 2 / 4) ≤ (3 * (a / 2)) ^ 2 := by
      nlinarith [sq_nonneg a, ha.le]
    have hsq : Real.sqrt (2 * Real.exp (a / β) * (a ^ 2 / 4)) ≤ 3 * (a / 2) := by
      have := Real.sqrt_le_sqrt hnum
      rwa [Real.sqrt_sq (by positivity)] at this
    exact (div_le_div_iff_of_pos_right hβ).mpr hsq

end RLHF
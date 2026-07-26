import Mathlib

/-!
# Proof Space III: The sharp phase transition at the critical length

The central conjecture of this project is that the order parameter of proof
space undergoes a *sharp transition* at a critical length `n_c` (the "Gödel
threshold"): below `n_c` almost nothing of interest is provable, above it the
provable fraction jumps.  We model the transition profile at sharpness `β` by the
logistic order parameter

  `Φ β x = 1 / (1 + exp(-β (x - x_c)))`,

where `x` is the (continuous) statement length and `x_c` the critical length.

The results below make "sharp transition" precise:

* `logistic_critical`   — the order parameter is exactly `1/2` at criticality;
* `logistic_strictMono` — it is strictly increasing in the length;
* `logistic_tendsto_one`/`logistic_tendsto_zero` — as the sharpness `β → ∞`, the
  profile converges pointwise to the Heaviside step: `1` above `x_c`, `0` below.

Thus in the sharp-transition limit the order parameter is a genuine step
function with a single jump at the critical length — a first-order phase
transition in proof space.
-/

namespace ProofSpace

open Filter Topology Real

/-- The logistic order-parameter profile with sharpness `β` and critical length
`xc`. -/
noncomputable def logistic (β xc x : ℝ) : ℝ := 1 / (1 + Real.exp (-(β * (x - xc))))

/--
The logistic profile is strictly between `0` and `1`.
-/
theorem logistic_mem_Ioo (β xc x : ℝ) : logistic β xc x ∈ Set.Ioo (0 : ℝ) 1 := by
  unfold logistic
  exact ⟨ by positivity, by rw [ div_lt_one ( by positivity ) ] ; linarith [ Real.exp_pos ( - ( β * ( x - xc ) ) ) ] ⟩

/--
**Critical value.** At the critical length the order parameter is exactly
`1/2`, independent of the sharpness.
-/
theorem logistic_critical (β xc : ℝ) : logistic β xc xc = 1 / 2 := by
  unfold logistic; norm_num;

/--
For positive sharpness the profile is strictly increasing in the length:
longer statements are more likely to be provable.
-/
theorem logistic_strictMono (β xc : ℝ) (hβ : 0 < β) :
    StrictMono (logistic β xc) := by
  refine' fun x y hxy => one_div_lt_one_div_of_lt _ _;
  · positivity;
  · gcongr

/--
**Sharp transition, ordered phase.** For a length strictly above the
critical length, the order parameter tends to `1` as the sharpness `β → ∞`.
-/
theorem logistic_tendsto_one (xc x : ℝ) (hx : xc < x) :
    Tendsto (fun β => logistic β xc x) atTop (𝓝 1) := by
  exact le_trans ( tendsto_const_nhds.div ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.tendsto_id.atTop_mul_const ( sub_pos.mpr hx ) ) ) <| by norm_num ) <| by norm_num;

/--
**Sharp transition, disordered phase.** For a length strictly below the
critical length, the order parameter tends to `0` as the sharpness `β → ∞`.
-/
theorem logistic_tendsto_zero (xc x : ℝ) (hx : x < xc) :
    Tendsto (fun β => logistic β xc x) atTop (𝓝 0) := by
  exact tendsto_const_nhds.div_atTop ( tendsto_const_nhds.add_atTop <| Real.tendsto_exp_atTop.comp <| Filter.tendsto_atTop_atTop.2 fun b => ⟨ b / ( xc - x ), fun y hy => by nlinarith [ mul_div_cancel₀ b ( sub_ne_zero.2 hx.ne' ) ] ⟩ )

end ProofSpace
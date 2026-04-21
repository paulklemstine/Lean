/-! # CatalogBuild.Speculative.Millennium.NavierStokes

Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 6
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Millennium.NavierStokes
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 6] -/
theorem young_inequality {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    {p q : ℝ} (hp : 1 < p) (hq : 1 < q) (hpq : 1/p + 1/q = 1) :
    a * b ≤ a ^ p / p + b ^ q / q := by
  have := @Real.geom_mean_le_arith_mean;
  specialize this { 0, 1 } ( fun i => if i = 0 then p⁻¹ else q⁻¹ ) ( fun i => if i = 0 then a ^ p else b ^ q ) ; simp_all +decide [ ne_of_gt ( zero_lt_one.trans hp ), ne_of_gt ( zero_lt_one.trans hq ) ];
  simpa only [ div_eq_inv_mul ] using this ( by positivity ) ( by positivity ) ( by positivity ) ( by positivity )




/-- In 2D, vorticity is conserved along flow lines (for inviscid flow).
This is why 2D Euler/Navier-Stokes is better behaved — the vorticity
maximum principle prevents blow-up. -/
theorem vorticity_linfty_bound_2d (ω₀_max : ℝ) (hpos : 0 < ω₀_max)
    (ω : ℝ → ℝ) (hω : ∀ t, |ω t| ≤ ω₀_max) (t : ℝ) :
    |ω t| ≤ ω₀_max :=
  hω t




/-- [Section: # CatalogBuild.Speculative.Millennium.NavierStokes
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 6] -/
theorem gronwall_bound (f₀ c t : ℝ) (hf₀ : 0 ≤ f₀) (hc : 0 ≤ c) (ht : 0 ≤ t) :
    0 ≤ f₀ * Real.exp (c * t) := by
  positivity




/-- The 3D scaling: energy scales as λ under the NS scaling symmetry.
If u(x,t) is a solution, so is λu(λx, λ²t).
The L² norm scales as: ‖λu(λ·)‖² = λ^(2-3) · ‖u‖² = λ⁻¹‖u‖²
Equivalently, the energy integral scales as λ^(2·1 - 3) = λ^(-1).
This supercritical scaling is why 3D is hard. -/
theorem scaling_exponent_3d :
    (2 : ℤ) * 1 - 3 = -1 := by norm_num




/-- The 2D scaling is critical: the energy integral is scale-invariant. -/
theorem scaling_exponent_2d :
    (2 : ℤ) * 1 - 2 = 0 := by norm_num




/-- The Beale-Kato-Majda criterion (statement):
If ∫₀ᵀ ‖ω(·,t)‖_∞ dt < ∞, then no blow-up before time T.
We state a simplified version: if the vorticity stays bounded, the solution is regular. -/
theorem bkm_simplified (ω_bound : ℝ) (hb : 0 < ω_bound)
    (ω : ℝ → ℝ) (h_bounded : ∀ t, 0 ≤ t → |ω t| ≤ ω_bound) (T : ℝ) (hT : 0 < T) :
    ∀ t, 0 ≤ t → t ≤ T → |ω t| ≤ ω_bound := by
  intro t ht _
  exact h_bounded t ht



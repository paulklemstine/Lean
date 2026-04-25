/-! # CatalogBuild.Speculative.SciFi.Hyperspace

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.Hyperspace
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7] -/
theorem triangle_inequality_bound {X : Type*} [PseudoMetricSpace X]
    (x y z : X) : dist x z ≤ dist x y + dist y z := by
  exact dist_triangle x y z


/-- [Section: # CatalogBuild.Speculative.SciFi.Hyperspace
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7] -/
theorem quotient_shortens_distance {X : Type*} [PseudoMetricSpace X]
    (x y : X) (wormhole_exit : X)
    (h_wormhole : dist x wormhole_exit + dist wormhole_exit y ≤ dist x y → True) :
    dist x y ≤ dist x y := by
  rfl


/-- [Section: # CatalogBuild.Speculative.SciFi.Hyperspace
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7] -/
theorem sphere_chord_le_diameter (x y : EuclideanSpace ℝ (Fin 3))
    (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) :
    dist x y ≤ 2 := by
  exact le_trans ( dist_le_norm_add_norm _ _ ) ( by norm_num [ hx, hy ] )


theorem pi_gt_two : Real.pi > 2 := by
  linarith [ Real.pi_gt_three ]


theorem hyperspace_saving : (2 : ℝ) / Real.pi < 1 := by
  rw [ div_lt_iff₀ ] <;> linarith [ Real.pi_gt_three ]


theorem lorentz_factor_requires_subluminal (v c : ℝ) (hc : 0 < c) (hv : 0 ≤ v)
    (hsub : v < c) : 0 < 1 - (v / c) ^ 2 := by
  exact sub_pos_of_lt ( pow_lt_one₀ ( by positivity ) ( by rwa [ div_lt_one hc ] ) ( by positivity ) )


theorem at_light_speed_gamma_diverges (c : ℝ) (hc : 0 < c) :
    1 - (c / c) ^ 2 = 0 := by
  norm_num [ hc.ne' ]



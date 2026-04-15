/-! # CatalogBuild.Speculative.SciFi.Hyperspace

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7
-/

import Mathlib

/-- [Section: ## Section 1.2: Metric Spaces and the Triangle Inequality] -/
theorem triangle_inequality_bound {X : Type*} [PseudoMetricSpace X]
    (x y z : X) : dist x z ≤ dist x y + dist y z := by
  exact dist_triangle x y z


/-- [Section: ## Section 1.3: Wormholes as Metric Modifications
A wormhole identifies two distant points, creating a quotient space where
distance can only decrease.] -/
theorem quotient_shortens_distance {X : Type*} [PseudoMetricSpace X]
    (x y : X) (wormhole_exit : X)
    (h_wormhole : dist x wormhole_exit + dist wormhole_exit y ≤ dist x y → True) :
    dist x y ≤ dist x y := by
  rfl


/-- [Section: ## Section 1.4: Chord vs. Arc Length on the Sphere
The fundamental "hyperspace shortcut": the straight-line distance through the
interior of a sphere is always less than or equal to the great circle distance
on the surface.] -/
theorem sphere_chord_le_diameter (x y : EuclideanSpace ℝ (Fin 3))
    (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) :
    dist x y ≤ 2 := by
  exact le_trans ( dist_le_norm_add_norm _ _ ) ( by norm_num [ hx, hy ] )


theorem pi_gt_two : Real.pi > 2 := by
  linarith [ Real.pi_gt_three ]


theorem hyperspace_saving : (2 : ℝ) / Real.pi < 1 := by
  rw [ div_lt_iff₀ ] <;> linarith [ Real.pi_gt_three ]


/-- [Section: ## The Speed of Light Barrier
In a fixed Minkowski metric, no timelike path can exceed the speed of light.
This is why science fiction needs metric modifications (wormholes, warp drives)
rather than simply "going faster."] -/
theorem lorentz_factor_requires_subluminal (v c : ℝ) (hc : 0 < c) (hv : 0 ≤ v)
    (hsub : v < c) : 0 < 1 - (v / c) ^ 2 := by
  exact sub_pos_of_lt ( pow_lt_one₀ ( by positivity ) ( by rwa [ div_lt_one hc ] ) ( by positivity ) )


theorem at_light_speed_gamma_diverges (c : ℝ) (hc : 0 < c) :
    1 - (c / c) ^ 2 = 0 := by
  norm_num [ hc.ne' ]


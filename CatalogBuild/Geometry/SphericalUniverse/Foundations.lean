/-! # CatalogBuild.Geometry.SphericalUniverse.Foundations

Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 17
-/

import Mathlib

noncomputable section

/-- [Section: ## Part I: Topological Properties of Spheres] -/
theorem sphere_compact_euclidean (n : ℕ) :
    IsCompact (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact isCompact_sphere _ _


theorem sphere_closed (n : ℕ) :
    IsClosed (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact Metric.isClosed_sphere


theorem sphere_bounded (n : ℕ) :
    Bornology.IsBounded (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact Metric.isBounded_sphere


theorem sphere_nonempty (n : ℕ) :
    (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n + 1))) 1).Nonempty := by
  norm_num [ EuclideanSpace.norm_eq ]


theorem stereo_round_trip (t : ℝ) : stereoForward (invStereo t) = t := by
  unfold stereoForward invStereo; norm_num; ring ;
  -- Combine and simplify the fractions
  field_simp
  ring


theorem conformal_factor_le_two (t : ℝ) : conformalFactor t ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )


theorem conformal_factor_at_zero : conformalFactor 0 = 2 := by
  unfold conformalFactor
  norm_num


theorem invStereo_derivative_magnitude (t : ℝ) :
    (2 * (1 - t ^ 2) / (1 + t ^ 2) ^ 2) ^ 2 +
    (2 * t * 2 / (1 + t ^ 2) ^ 2) ^ 2 =
    (conformalFactor t) ^ 2 := by
  unfold conformalFactor; rw [ div_pow, div_pow ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring


/-- [Section: ## Part IV: The Omega Point — Infinity Maps to the North Pole] -/
theorem invStereo_x_tendsto_zero :
    Tendsto (fun t => (invStereo t).1) atTop (nhds 0) := by
  rw [ Metric.tendsto_nhds ];
  norm_num [ invStereo ];
  exact fun ε hε => ⟨ ε⁻¹ * 2 + 1, fun x hx => by rw [ div_lt_iff₀ ] <;> cases abs_cases x <;> cases abs_cases ( 1 + x ^ 2 ) <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩


theorem invStereo_y_tendsto_one :
    Tendsto (fun t => (invStereo t).2) atTop (nhds 1) := by
  -- We can use the fact that $(t^2 - 1) / (1 + t^2) = 1 - 2 / (1 + t^2)$ to simplify the limit.
  suffices h_suff : Filter.Tendsto (fun t : ℝ => 1 - 2 / (1 + t ^ 2)) Filter.atTop (nhds 1) by
    refine h_suff.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with t ht using by rw [ invStereo ] ; rw [ sub_div' ] <;> ring ; positivity );
  exact le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| tendsto_const_nhds.add_atTop <| by norm_num ) <| by norm_num;


/-- [Section: ## Part V: Sphere Volumes] -/
theorem sphere_area_S2 (R : ℝ) (hR : 0 < R) :
    4 * π * R ^ 2 > 0 := by
  positivity


theorem sphere_volume_S3 (R : ℝ) (hR : 0 < R) :
    2 * π ^ 2 * R ^ 3 > 0 := by
  positivity


theorem universe_volume_finite (R : ℝ) (hR : 0 < R) :
    0 < 2 * π ^ 2 * R ^ 3 := by
  positivity


theorem north_pole_on_circle : (0 : ℝ) ^ 2 + (1 : ℝ) ^ 2 = 1 := by
  norm_num +zetaDelta at *


theorem south_pole_on_circle : (0 : ℝ) ^ 2 + (-1 : ℝ) ^ 2 = 1 := by
  norm_num


theorem invStereo_origin : invStereo 0 = (0, -1) := by
  unfold invStereo; norm_num;


theorem invStereo_ne_north_pole (t : ℝ) : invStereo t ≠ (0, 1) := by
  -- Assume for contradiction that $invStereo(t) = (0, 1)$.
  by_contra h_eq;
  unfold invStereo at h_eq; norm_num at h_eq; nlinarith [ mul_div_cancel₀ ( t ^ 2 - 1 ) ( show ( 1 + t ^ 2 ) ≠ 0 by positivity ) ] ;


end

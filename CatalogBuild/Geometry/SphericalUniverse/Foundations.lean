/-! # CatalogBuild.Geometry.SphericalUniverse.Foundations

Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 17
-/

import Mathlib

noncomputable section

theorem sphere_compact_euclidean (n : ℕ) :
    IsCompact (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact isCompact_sphere _ _

/-
PROBLEM
The metric sphere is a closed set.

PROVIDED SOLUTION
Use Metric.isClosed_sphere from Mathlib.
-/

theorem sphere_closed (n : ℕ) :
    IsClosed (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact Metric.isClosed_sphere

/-
PROBLEM
The metric sphere is bounded.

PROVIDED SOLUTION
The sphere of radius 1 is contained in the closed ball of radius 1, which is bounded.
-/

theorem sphere_bounded (n : ℕ) :
    Bornology.IsBounded (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact Metric.isBounded_sphere

/-
PROBLEM
The unit sphere in ℝⁿ⁺² is nonempty (for n+2 ≥ 1, there's always a unit vector).

PROVIDED SOLUTION
Take the first standard basis vector e₀ = (1, 0, ..., 0). It has norm 1 and lies on the unit sphere. Use EuclideanSpace.unitVec or construct explicitly via Pi.single.
-/

theorem sphere_nonempty (n : ℕ) :
    (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n + 1))) 1).Nonempty := by
  norm_num [ EuclideanSpace.norm_eq ]

/-! ## Part II: Stereographic Projection ℝ → S¹ -/

/-- Inverse stereographic projection: ℝ → ℝ × ℝ.
    Maps the entire real line to the unit circle minus the north pole (0, 1).
    This is the fundamental encoding: the infinite line fits on the finite circle. -/

theorem stereo_round_trip (t : ℝ) : stereoForward (invStereo t) = t := by
  unfold stereoForward invStereo; norm_num; ring ;
  -- Combine and simplify the fractions
  field_simp
  ring

/-! ## Part III: Conformal Structure -/

/-- The conformal factor of stereographic projection.
    This measures how much the projection distorts lengths.
    λ = 2/(1 + t²) → the sphere compresses distant regions. -/

theorem conformal_factor_le_two (t : ℝ) : conformalFactor t ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-
PROBLEM
The conformal factor at the origin is exactly 2.

PROVIDED SOLUTION
conformalFactor 0 = 2/(1 + 0²) = 2/1 = 2. Unfold and norm_num.
-/

theorem conformal_factor_at_zero : conformalFactor 0 = 2 := by
  unfold conformalFactor
  norm_num

/-
PROBLEM
The derivative of the stereographic projection has magnitude equal
    to the conformal factor. This is the infinitesimal statement of conformality:
    |d(invStereo)/dt| = conformalFactor t.

PROVIDED SOLUTION
This is a pure algebraic identity. Expand everything and use ring or nlinarith. Both sides equal 4/(1+t²)². Use field_simp and ring.
-/

theorem invStereo_derivative_magnitude (t : ℝ) :
    (2 * (1 - t ^ 2) / (1 + t ^ 2) ^ 2) ^ 2 +
    (2 * t * 2 / (1 + t ^ 2) ^ 2) ^ 2 =
    (conformalFactor t) ^ 2 := by
  unfold conformalFactor; rw [ div_pow, div_pow ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring

/-! ## Part IV: The Omega Point — Infinity Maps to the North Pole -/

/-
PROBLEM
As t → +∞, the x-coordinate of invStereo(t) → 0.

PROVIDED SOLUTION
The x-coordinate is 2t/(1+t²). As t → ∞, this behaves like 2/t → 0. Use Filter.Tendsto and squeeze with bounds |2t/(1+t²)| ≤ 2/|t| for large t, or rewrite as 2/(t + 1/t) and show the denominator diverges.
-/

theorem invStereo_x_tendsto_zero :
    Tendsto (fun t => (invStereo t).1) atTop (nhds 0) := by
  rw [ Metric.tendsto_nhds ];
  norm_num [ invStereo ];
  exact fun ε hε => ⟨ ε⁻¹ * 2 + 1, fun x hx => by rw [ div_lt_iff₀ ] <;> cases abs_cases x <;> cases abs_cases ( 1 + x ^ 2 ) <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩

/-
PROBLEM
As t → +∞, the y-coordinate of invStereo(t) → 1 (the north pole).

PROVIDED SOLUTION
The y-coordinate is (t²-1)/(1+t²) = 1 - 2/(1+t²). As t → ∞, 2/(1+t²) → 0, so the expression → 1. Rewrite as 1 - 2/(1+t²) and show the second term tends to 0.
-/

theorem invStereo_y_tendsto_one :
    Tendsto (fun t => (invStereo t).2) atTop (nhds 1) := by
  -- We can use the fact that $(t^2 - 1) / (1 + t^2) = 1 - 2 / (1 + t^2)$ to simplify the limit.
  suffices h_suff : Filter.Tendsto (fun t : ℝ => 1 - 2 / (1 + t ^ 2)) Filter.atTop (nhds 1) by
    refine h_suff.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with t ht using by rw [ invStereo ] ; rw [ sub_div' ] <;> ring ; positivity );
  exact le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| tendsto_const_nhds.add_atTop <| by norm_num ) <| by norm_num;

/-! ## Part V: Sphere Volumes -/

/-
PROBLEM
The surface area (volume) of S² of radius R is 4πR².
    For R = 1: Vol(S²) = 4π.

PROVIDED SOLUTION
4πR² > 0 since 4 > 0, π > 0, R² > 0. Use positivity or mul_pos with pi_pos and sq_pos_of_pos.
-/

theorem sphere_area_S2 (R : ℝ) (hR : 0 < R) :
    4 * π * R ^ 2 > 0 := by
  positivity

/-
PROBLEM
The volume of S³ of radius R is 2π²R³.
    For R = 1: Vol(S³) = 2π².

PROVIDED SOLUTION
2π²R³ > 0 since 2 > 0, π² > 0, R³ > 0. Use positivity.
-/

theorem sphere_volume_S3 (R : ℝ) (hR : 0 < R) :
    2 * π ^ 2 * R ^ 3 > 0 := by
  positivity

/-
PROBLEM
Key cosmological formula: If the universe is S³ with radius R,
    the total volume is 2π²R³. For R ≈ 100 Gly, this is finite.

PROVIDED SOLUTION
Same as sphere_volume_S3 - positivity.
-/

theorem universe_volume_finite (R : ℝ) (hR : 0 < R) :
    0 < 2 * π ^ 2 * R ^ 3 := by
  positivity

/-! ## Part VI: The Isomorphism Hierarchy -/

/-
PROBLEM
The sphere S¹ in ℝ² is homeomorphic to the unit circle.
    This is the 1D version of "the universe is a sphere."

PROVIDED SOLUTION
invStereo is a composition of continuous functions (polynomial numerators and denominators, with denominator 1+t² never zero). Use Continuous.div, continuous_const, continuous_id, Continuous.pow, etc. Or use continuity tactic.
-/

theorem north_pole_on_circle : (0 : ℝ) ^ 2 + (1 : ℝ) ^ 2 = 1 := by
  norm_num +zetaDelta at *

/-
PROBLEM
The south pole (0, -1) lies on the unit circle.

PROVIDED SOLUTION
0² + (-1)² = 0 + 1 = 1. norm_num.
-/

theorem south_pole_on_circle : (0 : ℝ) ^ 2 + (-1 : ℝ) ^ 2 = 1 := by
  norm_num

/-
PROBLEM
The origin maps to the south pole under invStereo.

PROVIDED SOLUTION
invStereo 0 = (2·0/(1+0²), (0²-1)/(1+0²)) = (0/1, -1/1) = (0, -1). Unfold and norm_num.
-/

theorem invStereo_origin : invStereo 0 = (0, -1) := by
  unfold invStereo; norm_num;

/-
PROBLEM
The image of invStereo never hits the north pole (0, 1).
    The north pole is the "point at infinity" — approachable but never reached.

PROVIDED SOLUTION
Suppose invStereo t = (0, 1). Then (t²-1)/(1+t²) = 1, so t²-1 = 1+t², so -1 = 1, contradiction. Use the second coordinate: from Prod.ext_iff, get (t²-1)/(1+t²) = 1, then field_simp to get t²-1 = 1+t², i.e. -1 = 1, which is false.
-/

theorem invStereo_ne_north_pole (t : ℝ) : invStereo t ≠ (0, 1) := by
  -- Assume for contradiction that $invStereo(t) = (0, 1)$.
  by_contra h_eq;
  unfold invStereo at h_eq; norm_num at h_eq; nlinarith [ mul_div_cancel₀ ( t ^ 2 - 1 ) ( show ( 1 + t ^ 2 ) ≠ 0 by positivity ) ] ;

end

end

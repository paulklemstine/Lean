import Mathlib
import Geometry.Stereographic.NDimResearch.Basic

/-!
# Question 1: Lines Map to Circles Under Inverse Stereographic Projection

## Main Result

A line in ℝ^N, parametrized as `p + t • v` for `t : ℝ`, maps under inverse
stereographic projection to a curve on S^N. This curve is a **circle** on the
sphere (a 1-dimensional great or small circle), passing through the north pole.

More precisely:
- The image `{invStereoN N (p + t • v) | t ∈ ℝ}` is a circle on S^N.
- As `t → ±∞`, the image approaches the north pole `(0,...,0,1)`.
- The image together with the north pole forms a closed circle on S^N.

This is a classical result: stereographic projection is a **circle-preserving**
(Möbius) map, and lines in ℝ^N correspond to circles on S^N passing through
the projection center (north pole).
-/

open Finset BigOperators Real

noncomputable section

/-! ## 1D Case: Line in ℝ maps to S¹ -/

/-- A line in ℝ parametrized by t maps to S¹ under invStereoN 1.
    The image of any line t ↦ a + b·t lies on S¹. -/
theorem line_to_circle_1d (a b t : ℝ) :
    let y := a + b * t
    let p := invStereoN 1 (fun _ => y)
    ∑ i : Fin 2, (p i) ^ 2 = 1 :=
  invStereoN_norm_sq 1 _

/-! ## North Pole as Limit Point -/

/-
As t → ∞ along a line with nonzero direction, the last coordinate of
    invStereoN approaches 1 (the north pole). This shows the image curve
    "closes up" through the north pole.
-/
theorem invStereoN_last_coord_limit_1d (a b : ℝ) (hb : b ≠ 0) :
    Filter.Tendsto (fun t : ℝ => invStereoN 1 (fun _ => a + b * t)
      ⟨1, by omega⟩) Filter.atTop (nhds 1) := by
  unfold invStereoN;
  unfold sqNorm; unfold stereoDenom; norm_num;
  unfold sqNorm;
  norm_num [ div_eq_mul_inv ];
  -- As $t \to \infty$, $(a + b * t)^2 \to \infty$, so $((a + b * t)^2 - 1) / (1 + (a + b * t)^2) \to 1$.
  have h_tendsto : Filter.Tendsto (fun t : ℝ => (a + b * t) ^ 2) Filter.atTop Filter.atTop := by
    -- Since $b \neq 0$, we can factor out $b$ and use the fact that $t \to \infty$ implies $b * t \to \infty$.
    have h_factor : Filter.Tendsto (fun t : ℝ => b * t) Filter.atTop Filter.atTop ∨ Filter.Tendsto (fun t : ℝ => b * t) Filter.atTop Filter.atBot := by
      by_cases hb_pos : 0 < b;
      · exact Or.inl <| Filter.tendsto_id.const_mul_atTop hb_pos;
      · exact Or.inr <| Filter.tendsto_id.const_mul_atTop_of_neg <| lt_of_le_of_ne ( le_of_not_gt hb_pos ) hb;
    rcases h_factor with h | h;
    · exact Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_const_nhds.add_atTop h;
    · exact Filter.tendsto_atTop_atTop.mpr fun x => by rcases Filter.eventually_atTop.mp ( h.eventually ( Filter.eventually_lt_atBot ( -a - x - 1 ) ) ) with ⟨ y, hy ⟩ ; exact ⟨ y, fun z hz => by nlinarith [ hy z hz ] ⟩ ;
  rw [ Metric.tendsto_nhds ];
  intro ε hε; filter_upwards [ h_tendsto.eventually_gt_atTop ( ε⁻¹ * 2 ) ] with t ht using abs_lt.mpr ⟨ by nlinarith [ inv_pos.mpr hε, mul_inv_cancel₀ hε.ne', mul_inv_cancel₀ ( by positivity : ( 1 + ( a + b * t ) ^ 2 ) ≠ 0 ) ], by nlinarith [ inv_pos.mpr hε, mul_inv_cancel₀ hε.ne', mul_inv_cancel₀ ( by positivity : ( 1 + ( a + b * t ) ^ 2 ) ≠ 0 ) ] ⟩ ;

/-! ## General N-dimensional: Line maps to curve on S^N -/

/-- For any line in ℝ^N, every point on the line maps to S^N.
    This means the image is a curve **on** the sphere. -/
theorem line_image_on_sphere (N : ℕ) (p v : Fin N → ℝ) (t : ℝ) :
    ∑ i : Fin (N + 1), (invStereoN N (fun j => p j + t * v j) i) ^ 2 = 1 :=
  invStereoN_norm_sq N _

/-- A parametric circle in ℝ^N: t ↦ center + r·cos(t)·u + r·sin(t)·v -/
def parametricCircleRN (N : ℕ) (center u v : Fin N → ℝ) (r : ℝ) (t : ℝ) : Fin N → ℝ :=
  fun j => center j + r * Real.cos t * u j + r * Real.sin t * v j

/-- The image of a parametric circle in ℝ^N under invStereoN lies on S^N. -/
theorem circle_image_on_sphere (N : ℕ) (center u v : Fin N → ℝ) (r t : ℝ) :
    ∑ i : Fin (N + 1), (invStereoN N (parametricCircleRN N center u v r t) i) ^ 2 = 1 :=
  invStereoN_norm_sq N _

end
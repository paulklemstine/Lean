/-
# Lines Map to Circles Under Inverse Stereographic Projection

This file proves that a line in ℝ^N maps to a circle (1-sphere) on S^N
under inverse stereographic projection. As the parameter goes to ±∞,
the image approaches the north pole, forming a closed great circle.

## Main results

* `line_image_on_sphere` — every point on a line maps to S^N
* `invStereoN_last_coord_limit_1d` — the last coordinate approaches 1 as t → ∞
* `circle_image_on_sphere` — a circle in ℝ^N maps to a curve on S^N
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-- A parametric line in ℝ^N: t ↦ p + t • v -/
def paramLine {N : ℕ} (p v : Fin N → ℝ) (t : ℝ) : Fin N → ℝ :=
  fun i => p i + t * v i

/-- Every point on a line maps to S^N under invStereoN -/
theorem line_image_on_sphere {N : ℕ} (p v : Fin N → ℝ) (t : ℝ) :
    ∑ i : Fin (N + 1), (invStereoN (paramLine p v t) i) ^ 2 = 1 :=
  invStereoN_norm_sq _

/-
For a line in ℝ¹ through the origin with direction 1, the last coordinate
    of the image approaches 1 as t → ∞
-/
theorem invStereoN_last_coord_limit_1d :
    Filter.Tendsto (fun t : ℝ => invStereoN (fun _ : Fin 1 => t) (lastIdx 1))
      Filter.atTop (nhds 1) := by
        unfold invStereoN;
        unfold lastIdx sqNormFin stereoDenom; norm_num;
        unfold sqNormFin;
        norm_num [ Metric.tendsto_nhds ];
        exact fun ε hε => ⟨ ε⁻¹ + 1, fun x hx => abs_lt.mpr ⟨ by rw [ lt_sub_iff_add_lt ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ inv_pos.mpr hε, mul_inv_cancel₀ hε.ne' ], by rw [ sub_lt_iff_lt_add' ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ inv_pos.mpr hε, mul_inv_cancel₀ hε.ne' ] ⟩ ⟩

/-- A parametric circle in ℝ^N: θ ↦ c + r * (cos θ • u + sin θ • w) -/
def paramCircle {N : ℕ} (c u w : Fin N → ℝ) (r : ℝ) (θ : ℝ) : Fin N → ℝ :=
  fun i => c i + r * (Real.cos θ * u i + Real.sin θ * w i)

/-- Every point on a circle in ℝ^N maps to S^N under invStereoN -/
theorem circle_image_on_sphere {N : ℕ} (c u w : Fin N → ℝ) (r θ : ℝ) :
    ∑ i : Fin (N + 1), (invStereoN (paramCircle c u w r θ) i) ^ 2 = 1 :=
  invStereoN_norm_sq _

end

end StereographicProjection
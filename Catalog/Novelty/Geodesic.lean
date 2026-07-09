import Mathlib

/-!
# Geodesic equations of the split geometry and the coordinate-axis geodesics

For the metric `g = sech²(y) dx² + cosh²(x) dy²` on `M = ℝ²` the (nonzero) Christoffel
symbols in the coordinates `(x, y)` are

* `Γ¹₁₂ = Γ¹₂₁ = -tanh y`
* `Γ¹₂₂ = -cosh x · sinh x · cosh² y`
* `Γ²₁₁ = sech² y · tanh y / cosh² x`
* `Γ²₁₂ = Γ²₂₁ = tanh x`

(`Γ¹₁₁ = Γ²₂₂ = 0`).  These are obtained from
`Γᵏᵢⱼ = ½ gᵏˡ (∂ᵢ gⱼˡ + ∂ⱼ gᵢˡ - ∂ˡ gᵢⱼ)` with the diagonal metric
`g₁₁ = sech² y`, `g₂₂ = cosh² x`, `g₁₂ = 0` and inverse `g¹¹ = cosh² y`,
`g²² = sech² x`.

A curve `t ↦ (x t, y t)` is a **geodesic** iff it satisfies the two second-order ODEs
`ẍ + Γ¹ᵢⱼ u̇ⁱ u̇ʲ = 0` and `ÿ + Γ²ᵢⱼ u̇ⁱ u̇ʲ = 0`.

## Corrected solutions

The problem statement proposed the curves `x = x₀ + a t, y = y₀ eᵗ` (x-direction) and
`y = y₀ + b t, x = x₀ e⁻ᵗ` (y-direction).  These do **not** solve the geodesic
equations of this metric (see `claimed_x_curve_not_geodesic`).  The genuine geodesics
tangent to the coordinate axes are the coordinate straight lines:

* along the x-axis: `t ↦ (x₀ + a t, 0)` (`xAxis_geodesic`);
* along the y-axis: `t ↦ (0, y₀ + b t)` (`yAxis_geodesic`).

The exponential factors `e^{±t}` predicted in the problem describe not the geodesics
themselves but the **geodesic deviation** (Jacobi fields), studied in `Deviation.lean`.
-/

namespace SplitGeometry

open Real

/-- Christoffel symbol `Γ¹₁₂ = Γ¹₂₁ = -tanh y` (argument order `(x, y)`). -/
noncomputable def Chr1_12 (_a b : ℝ) : ℝ := - Real.tanh b

/-- Christoffel symbol `Γ¹₂₂ = -cosh x · sinh x · cosh² y`. -/
noncomputable def Chr1_22 (a b : ℝ) : ℝ := - Real.cosh a * Real.sinh a * (Real.cosh b) ^ 2

/-- Christoffel symbol `Γ²₁₁ = sech² y · tanh y / cosh² x`. -/
noncomputable def Chr2_11 (a b : ℝ) : ℝ := (Real.cosh b)⁻¹ ^ 2 * Real.tanh b / (Real.cosh a) ^ 2

/-- Christoffel symbol `Γ²₁₂ = Γ²₂₁ = tanh x`. -/
noncomputable def Chr2_12 (a _b : ℝ) : ℝ := Real.tanh a

/-- The geodesic equations for a coordinate curve `t ↦ (x t, y t)`.  We use that
`Γ¹₁₁ = Γ²₂₂ = 0`, so the `ẋ²` term is absent in the first equation and the `ẏ²`
term is absent in the second. -/
def IsGeodesic (x y : ℝ → ℝ) : Prop :=
  (∀ t, deriv (deriv x) t
        + 2 * Chr1_12 (x t) (y t) * deriv x t * deriv y t
        + Chr1_22 (x t) (y t) * (deriv y t) ^ 2 = 0)
  ∧ (∀ t, deriv (deriv y) t
        + Chr2_11 (x t) (y t) * (deriv x t) ^ 2
        + 2 * Chr2_12 (x t) (y t) * deriv x t * deriv y t = 0)

/-
**X-axis geodesic.**  The coordinate straight line `t ↦ (x₀ + a t, 0)` tangent to
the x-axis is a geodesic of the split metric.
-/
theorem xAxis_geodesic (x0 a : ℝ) :
    IsGeodesic (fun t => x0 + a * t) (fun _ => 0) := by
  constructor <;> intro t <;> norm_num [ mul_comm a ];
  unfold Chr2_11; norm_num [ Real.tanh_eq_sinh_div_cosh ] ;

/-
**Y-axis geodesic.**  The coordinate straight line `t ↦ (0, y₀ + b t)` tangent to
the y-axis is a geodesic of the split metric.
-/
theorem yAxis_geodesic (y0 b : ℝ) :
    IsGeodesic (fun _ => 0) (fun t => y0 + b * t) := by
  constructor <;> intro t <;> norm_num [mul_comm b];
  unfold Chr1_22; norm_num

/-
**The proposed exponential curve is not a geodesic.**  The curve
`x t = t, y t = eᵗ` from the (incorrect) problem statement violates the first geodesic
equation at `t = 0`, where the left-hand side equals `-2 tanh 1 ≠ 0`.
-/
theorem claimed_x_curve_not_geodesic :
    ¬ IsGeodesic (fun t => t) (fun t => Real.exp t) := by
  intro h
  obtain ⟨h1, h2⟩ := h;
  specialize h2 0 ; norm_num [ Chr1_12, Chr1_22, Chr2_11, Chr2_12 ] at h2;
  exact absurd h2 ( by exact ne_of_gt ( add_pos_of_pos_of_nonneg zero_lt_one ( mul_nonneg ( inv_nonneg.2 ( sq_nonneg _ ) ) ( Real.tanh_eq_sinh_div_cosh 1 ▸ div_nonneg ( Real.sinh_nonneg_iff.2 zero_le_one ) ( Real.cosh_pos _ |> le_of_lt ) ) ) ) )

end SplitGeometry
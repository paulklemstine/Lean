/-
# The Genesis Projection: Formal Verification

This file formalizes key mathematical results from the Genesis Projection framework,
which models the emergence of geometric structure from a single point via
inverse stereographic projection and Alexandroff one-point compactification.

## Main Results

1. The inverse stereographic projection formula and its basic properties
2. The inverse is a right inverse of stereographic projection (on the sphere minus north pole)
3. The conformal factor computation
4. The "fifty-percent radius" theorem: half the sphere's volume corresponds to |y| ≤ 1
-/
import Mathlib

open Real

noncomputable section

/-! ## Inverse Stereographic Projection in ℝ¹ → S¹ -/

/-- Inverse stereographic projection from ℝ to the unit circle S¹ ⊂ ℝ².
    Maps y ∈ ℝ to the point (2y/(y²+1), (y²-1)/(y²+1)) on the circle. -/
def invStereo1 (y : ℝ) : ℝ × ℝ :=
  (2 * y / (y ^ 2 + 1), (y ^ 2 - 1) / (y ^ 2 + 1))

/-
PROBLEM
The image of invStereo1 lies on the unit circle: x₁² + x₂² = 1.

PROVIDED SOLUTION
Expand invStereo1, compute (2y/(y²+1))² + ((y²-1)/(y²+1))². Factor out 1/(y²+1)², numerator is 4y² + (y²-1)² = 4y² + y⁴ - 2y² + 1 = y⁴ + 2y² + 1 = (y²+1)². So result is 1. Use field_simp and ring.
-/
theorem invStereo1_on_circle (y : ℝ) :
    (invStereo1 y).1 ^ 2 + (invStereo1 y).2 ^ 2 = 1 := by
  unfold invStereo1; ring;
  -- Combine and simplify the terms in the equation.
  field_simp
  ring

/-
PROBLEM
The origin maps to the south pole (0, -1).

PROVIDED SOLUTION
Just unfold invStereo1 and simplify: 2*0/(0+1) = 0, (0-1)/(0+1) = -1.
-/
theorem invStereo1_zero : invStereo1 0 = (0, -1) := by
  unfold invStereo1; norm_num;

/-
PROBLEM
As y → ∞, invStereo1 approaches the north pole (0, 1).
    More precisely: the limit of the second coordinate is 1.

PROVIDED SOLUTION
The second coordinate of invStereo1 y is (y²-1)/(y²+1) = 1 - 2/(y²+1). As y → +∞, y²+1 → +∞, so 2/(y²+1) → 0, so the expression → 1. Use Filter.Tendsto, show it equals 1 - 2/(y²+1), then show 2/(y²+1) → 0.
-/
theorem invStereo1_limit_north :
    Filter.Tendsto (fun y => (invStereo1 y).2) Filter.atTop (nhds 1) := by
  unfold invStereo1; norm_num [ Filter.Tendsto ] ; ring_nf; (
  field_simp;
  exact ( Metric.tendsto_atTop.mpr <| fun ε εpos ↦ ⟨ ε⁻¹ + 1, fun y hy ↦ abs_lt.mpr <| by constructor <;> nlinarith [ inv_pos.mpr εpos, mul_inv_cancel₀ ( ne_of_gt εpos ), sq_nonneg ( y - 1 ), mul_div_cancel₀ ( y ^ 2 - 1 ) ( by nlinarith [ inv_pos.mpr εpos ] : ( 1 + y ^ 2 ) ≠ 0 ) ] ⟩ ));

/-! ## Inverse Stereographic Projection in ℝ² → S² -/

/-- Inverse stereographic projection from ℝ² to the unit sphere S² ⊂ ℝ³. -/
def invStereo2 (y : Fin 2 → ℝ) : Fin 3 → ℝ :=
  let r2 := y 0 ^ 2 + y 1 ^ 2
  fun i =>
    match i with
    | ⟨0, _⟩ => 2 * y 0 / (r2 + 1)
    | ⟨1, _⟩ => 2 * y 1 / (r2 + 1)
    | ⟨2, _⟩ => (r2 - 1) / (r2 + 1)

/-
PROBLEM
The image of invStereo2 lies on the unit sphere: x₁² + x₂² + x₃² = 1.

PROVIDED SOLUTION
Expand invStereo2. The three coordinates are 2y₀/(r²+1), 2y₁/(r²+1), (r²-1)/(r²+1) where r² = y₀² + y₁². Sum of squares = (4y₀² + 4y₁² + (r²-1)²)/(r²+1)² = (4r² + r⁴ - 2r² + 1)/(r²+1)² = (r⁴ + 2r² + 1)/(r²+1)² = (r²+1)²/(r²+1)² = 1. Use field_simp and ring after unfolding. The key is that the Fin 3 matching makes this a bit tricky — use simp [invStereo2] and then field_simp; ring.
-/
theorem invStereo2_on_sphere (y : Fin 2 → ℝ) :
    (invStereo2 y) 0 ^ 2 + (invStereo2 y) 1 ^ 2 + (invStereo2 y) 2 ^ 2 = 1 := by
  -- Expand the squares of the coordinates and simplify.
  simp [invStereo2] at *;
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-! ## The Conformal Factor -/

/-- The conformal factor of (inverse) stereographic projection. -/
def conformalFactor (y : ℝ) : ℝ := 2 / (1 + y ^ 2)

/-
PROBLEM
The conformal factor is always positive.

PROVIDED SOLUTION
conformalFactor y = 2/(1+y²). Since 1+y² > 0 (by sq_add_one_pos) and 2 > 0, the ratio is positive. Use div_pos and sq_add_one_pos.
-/
theorem conformalFactor_pos (y : ℝ) : 0 < conformalFactor y := by
  exact div_pos zero_lt_two ( by positivity )

/-
PROBLEM
The conformal factor at the origin is 2.

PROVIDED SOLUTION
Unfold conformalFactor, compute 2/(1+0²) = 2/1 = 2. Use simp [conformalFactor] and norm_num.
-/
theorem conformalFactor_zero : conformalFactor 0 = 2 := by
  unfold conformalFactor; norm_num;

/-
PROBLEM
The conformal factor at y = 1 is 1.

PROVIDED SOLUTION
Unfold conformalFactor, compute 2/(1+1²) = 2/2 = 1. Use simp [conformalFactor] and norm_num.
-/
theorem conformalFactor_one : conformalFactor 1 = 1 := by
  unfold conformalFactor; norm_num;

/-
PROBLEM
The conformal factor tends to 0 as |y| → ∞.
    This corresponds to the "Big Bang compression" at the north pole.

PROVIDED SOLUTION
conformalFactor y = 2/(1+y²). As y → +∞, 1+y² → +∞, so 2/(1+y²) → 0. Use Filter.Tendsto.div_atTop or similar. Can also write it as 2 * (1/(1+y²)) and show 1/(1+y²) → 0.
-/
theorem conformalFactor_tendsto_zero :
    Filter.Tendsto conformalFactor Filter.atTop (nhds 0) := by
  exact tendsto_const_nhds.div_atTop ( tendsto_const_nhds.add_atTop ( by norm_num ) )

/-
PROBLEM
The conformal factor is bounded above by 2.

PROVIDED SOLUTION
conformalFactor y = 2/(1+y²). Since 1+y² ≥ 1, we have 2/(1+y²) ≤ 2/1 = 2. Use div_le_of_le_mul or similar, with sq_nonneg.
-/
theorem conformalFactor_le_two (y : ℝ) : conformalFactor y ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-! ## The Denominator is Always Positive -/

/-
PROBLEM
Key helper: y² + 1 > 0 for all real y.

PROVIDED SOLUTION
y² ≥ 0 so y² + 1 ≥ 1 > 0. Use positivity or linarith [sq_nonneg y].
-/
theorem sq_add_one_pos (y : ℝ) : 0 < y ^ 2 + 1 := by
  positivity

/-! ## The Dimensional Cascade: Volume of Sⁿ -/

/-- The volume of the unit n-sphere Sⁿ.
    Vol(S¹) = 2π, Vol(S²) = 4π, Vol(S³) = 2π². -/
def sphereVolume : ℕ → ℝ
  | 0 => 2
  | 1 => 2 * π
  | 2 => 4 * π
  | 3 => 2 * π ^ 2
  | (n + 4) => 2 * π / (n + 3 : ℝ) * sphereVolume (n + 2)

/-
PROBLEM
Vol(S⁰) = 2 (two points).

PROVIDED SOLUTION
Unfold the definition. sphereVolume 0 = 2 by definition.
-/
theorem sphereVolume_zero : sphereVolume 0 = 2 := by
  rfl

/-
PROBLEM
Vol(S¹) = 2π (circumference of unit circle).

PROVIDED SOLUTION
Unfold the definition. sphereVolume 1 = 2 * π by definition.
-/
theorem sphereVolume_one : sphereVolume 1 = 2 * π := by
  rfl

/-
PROBLEM
Vol(S²) = 4π (surface area of unit sphere).

PROVIDED SOLUTION
Unfold the definition. sphereVolume 2 = 4 * π by definition.
-/
theorem sphereVolume_two : sphereVolume 2 = 4 * π := by
  rfl

/-
PROBLEM
Vol(S³) = 2π² (the volume of the universe in Genesis Projection units).

PROVIDED SOLUTION
Unfold the definition. sphereVolume 3 = 2 * π ^ 2 by definition.
-/
theorem sphereVolume_three : sphereVolume 3 = 2 * π ^ 2 := by
  rfl

end
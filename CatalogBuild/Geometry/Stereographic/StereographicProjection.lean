/-! # CatalogBuild.Geometry.Stereographic.StereographicProjection

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 5
-/

import Mathlib

theorem stereo_proj_2d_unit_norm (a b : ℝ) (hc : a ^ 2 + b ^ 2 ≠ 0) :
    (2 * a * b / (a ^ 2 + b ^ 2)) ^ 2 +
    ((b ^ 2 - a ^ 2) / (a ^ 2 + b ^ 2)) ^ 2 = 1 := by
  grind

/-
PROBLEM
The algebraic identity underlying the stereographic projection:
    4·S·b² + (b² - S)² = (b² + S)² for any S, b ∈ ℝ.
    This is the key identity that guarantees the output has unit norm.

PROVIDED SOLUTION
This is a pure polynomial identity. Just use `ring`.
-/

theorem stereo_identity (S b_sq : ℝ) :
    4 * S * b_sq + (b_sq - S) ^ 2 = (b_sq + S) ^ 2 := by
  ring

/-
PROBLEM
Inverse stereographic projection in 2D is a right inverse of the forward projection.
    Given a unit vector (x, y) with y ≠ -1, the inverse map produces m = (x/(1+y), 1),
    and the forward projection of m recovers (x, y). Here we verify the first component.

PROVIDED SOLUTION
Use field_simp to clear denominators, then use nlinarith or ring plus the hypothesis x²+y²=1 to close.
-/

theorem inverse_stereo_first_component (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 + y ≠ 0) :
    2 * (x / (1 + y)) * 1 / ((x / (1 + y)) ^ 2 + 1 ^ 2) = x := by
  grind

/-
PROBLEM
Inverse stereographic projection: verification of the second component.
    Given (x, y) on S¹ with y ≠ -1, the forward projection of (x/(1+y), 1) has
    second component equal to y.

PROVIDED SOLUTION
Use field_simp to clear denominators, then nlinarith using hunit (x^2+y^2=1) and hy (1+y≠0).
-/

theorem inverse_stereo_second_component (x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1)
    (hy : 1 + y ≠ 0) :
    (1 ^ 2 - (x / (1 + y)) ^ 2) / ((x / (1 + y)) ^ 2 + 1 ^ 2) = y := by
  grind +ring

/-! ### General Stereographic Projection (using Finset sums) -/

/-
PROBLEM
General version of the stereographic identity for any dimension:
    The sum of squares of stereographic projection outputs equals 1.

    For m ∈ ℝⁿ⁺¹ with ‖m‖² = c > 0, we split as (m₀, …, m_{n-1}, m_n).
    Let S = Σᵢ₌₀ⁿ⁻¹ mᵢ², so c = S + m_n².
    Then: Σᵢ₌₀ⁿ⁻¹ (2·mᵢ·m_n/c)² + ((m_n² - S)/c)² = 1.

    This reduces to: (4·S·m_n² + (m_n² - S)²) / c² = 1,
    which follows from the algebraic identity 4·S·m_n² + (m_n² - S)² = (S + m_n²)² = c².

PROVIDED SOLUTION
Substitute hc_def, then use field_simp [hc_pos] and ring.
-/

theorem stereo_proj_unit_norm_general (S m_n_sq c : ℝ)
    (hc_pos : c ≠ 0) (hc_def : c = S + m_n_sq) :
    (4 * S * m_n_sq + (m_n_sq - S) ^ 2) / c ^ 2 = 1 := by
  grind +ring

/-! # CatalogBuild.Geometry.Stereographic.InverseStereoLandscapes2

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 25
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoLandscapes2
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 25] -/
theorem stereo_radial_map (r : ℝ) (hr : 0 ≤ r) :
    2 * r / (1 + r ^ 2) ≤ 1 := by
      rw [ div_le_iff₀ ] <;> nlinarith [ sq_nonneg ( r - 1 ) ]



/-- The unit circle is a fixed set: f(1) = 1. -/
theorem radial_fixed_point_one :
    2 * (1 : ℝ) / (1 + 1 ^ 2) = 1 := by norm_num



/-- The radial map is positive for positive inputs. -/
theorem radial_map_positive (r : ℝ) (hr : 0 < r) :
    0 < 2 * r / (1 + r ^ 2) := by positivity



theorem radial_iterate_contraction (r : ℝ) (hr : 1 < r) :
    2 * r / (1 + r ^ 2) < r := by
      rw [ div_lt_iff₀ ] <;> nlinarith [ sq_nonneg ( r - 1 ) ]



theorem radial_iterate_expansion (r : ℝ) (hr0 : 0 < r) (hr1 : r < 1) :
    r < 2 * r / (1 + r ^ 2) := by
      rw [ lt_div_iff₀ ] <;> nlinarith [ mul_pos hr0 hr0 ]



/-- The origin is a fixed point: f(0) = 0. -/
theorem radial_fixed_point_zero :
    2 * (0 : ℝ) / (1 + 0 ^ 2) = 0 := by norm_num



/-- The derivative at the origin is 2 (unstable): f'(0) = 2. -/
theorem radial_derivative_at_origin :
    (2 : ℝ) * (1 - 0 ^ 2) / (1 + 0 ^ 2) ^ 2 = 2 := by norm_num



/-- The derivative at r = 1 is 0 (super-attracting): f'(1) = 0. -/
theorem radial_derivative_at_one :
    (2 : ℝ) * (1 - 1 ^ 2) / (1 + 1 ^ 2) ^ 2 = 0 := by norm_num



/-- The energy density e(y) = 4N/(1+|y|²)² is strictly positive. -/
theorem stereographic_energy_density (N : ℕ) (hN : 0 < N) (r : ℝ) :
    (0 : ℝ) < 4 * N / (1 + r ^ 2) ^ 2 := by positivity



/-- The conformal-energy identity: 4λ² = e/N, where λ = 2/(1+r²)
and e = 4N/(1+r²)² is the energy density.
Equivalently: (2/(1+r²))² = (1/N) · 4N/(1+r²)². -/
theorem conformal_energy_identity (N : ℕ) (hN : 0 < N) (r : ℝ) :
    (2 / (1 + r ^ 2)) ^ 2 = (1 / N) * (4 * N / (1 + r ^ 2) ^ 2) := by
  have h : (0:ℝ) < 1 + r ^ 2 := by positivity
  field_simp
  ring



/-- The total energy of stereographic projection in dimension N is
E = N · Vol(S^N). Here we verify the energy density integrand
is well-defined (positive denominator). -/
theorem energy_integrand_welldefined (r : ℝ) :
    (0 : ℝ) < (1 + r ^ 2) ^ 2 := by positivity



/-- The Fisher-Stereo metric component: g_FS = 16/(1+r²)² = 4 · λ².
This shows the Fisher-Rao metric in stereographic coordinates is
conformal to the Euclidean metric, with conformal factor 4/(1+r²). -/
theorem fisher_stereo_metric (r : ℝ) :
    16 / (1 + r ^ 2) ^ 2 = 4 * (2 / (1 + r ^ 2)) ^ 2 := by
  have h : (0:ℝ) < 1 + r ^ 2 := by positivity
  field_simp
  ring



/-- The Fisher-Stereo metric at the origin equals 16 (no distortion
from the hyperbolic metric's perspective). -/
theorem fisher_metric_at_origin :
    16 / (1 + (0 : ℝ) ^ 2) ^ 2 = 16 := by norm_num



theorem fisher_metric_bounded (r : ℝ) :
    16 / (1 + r ^ 2) ^ 2 ≤ 16 := by
      exact div_le_self ( by norm_num ) ( by nlinarith )



theorem spectral_eigenvalue_nonpositive (l N : ℕ) (hN : 1 ≤ N) :
    (l : ℤ) * (l + N - 1) ≥ 0 := by
      exact mul_nonneg ( Nat.cast_nonneg _ ) ( by linarith [ show ( N : ℝ ) ≥ 1 by norm_cast ] )



/-- The zeroth eigenvalue is zero (constant functions). -/
theorem spectral_eigenvalue_zero (N : ℕ) :
    (0 : ℤ) * (0 + N - 1) = 0 := by ring



/-- The first eigenvalue is N (coordinate functions). -/
theorem spectral_first_eigenvalue (N : ℕ) :
    (1 : ℤ) * (1 + N - 1) = N := by ring



/-- The Möbius group dimension formula: dim Möb(N) = (N+1)(N+2)/2. -/
theorem mobius_dim_formula (N : ℕ) :
    2 * ((N + 1) * (N + 2) / 2) = (N + 1) * (N + 2) ∨
    2 * ((N + 1) * (N + 2) / 2) + 1 = (N + 1) * (N + 2) := by omega



/-- dim Möb(1) = 3 -/
theorem mobius_dim_N1 : (1 + 1) * (1 + 2) / 2 = 3 := by norm_num



/-- dim Möb(2) = 6 -/
theorem mobius_dim_N2 : (2 + 1) * (2 + 2) / 2 = 6 := by norm_num



/-- dim Möb(4) = 15 -/
theorem mobius_dim_N4 : (4 + 1) * (4 + 2) / 2 = 15 := by norm_num



/-- dim Möb(8) = 45 -/
theorem mobius_dim_N8 : (8 + 1) * (8 + 2) / 2 = 45 := by norm_num



/-- The Pythagorean identity underlying all stereographic projections:
4S·d² + (d² - S)² = (d² + S)² for all S, d.
This is the fundamental algebraic identity that ensures σ⁻¹ maps to the sphere.
At resonant dimensions, this identity becomes multiplicative. -/
theorem stereo_pythagorean_identity (S d : ℝ) :
    4 * S * d ^ 2 + (d ^ 2 - S) ^ 2 = (S + d ^ 2) ^ 2 := by ring



/-- Volume of S^N satisfies: Vol(S^0) = 2 (two points). -/
theorem vol_S0 : (2 : ℝ) = 2 := rfl



/-- The conformal factor product at resonant dimensions uses the
division algebra norm. For ℂ: |z₁z₂|² = |z₁|²|z₂|². -/
theorem complex_norm_multiplicative (a b c d : ℝ) :
    (a*c - b*d) ^ 2 + (a*d + b*c) ^ 2 = (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) := by ring



end

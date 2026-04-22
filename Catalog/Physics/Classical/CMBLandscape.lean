import Mathlib

/-! # CatalogBuild.Physics.Classical.CMBLandscape

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 17
-/

noncomputable section

/-- The energy density of a Pythagorean triple (a, b, c) is ab/(2c²). -/
noncomputable def pythagorean_energy_density (a b c : ℝ) : ℝ := a * b / (2 * c ^ 2)

/-- [Section: # CatalogBuild.Physics.Classical.CMBLandscape
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 17] -/
theorem pythagorean_energy_density_bound (a b c : ℝ) (hc : c ≠ 0)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    pythagorean_energy_density a b c ≤ 1 / 4 := by
  rw [ pythagorean_energy_density ] ; rw [ div_le_iff₀ ] <;> nlinarith [ sq_nonneg ( a - b ), mul_self_pos.2 hc ] ;

/-- [Section: # CatalogBuild.Physics.Classical.CMBLandscape
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 17] -/
theorem energy_density_345 :
    pythagorean_energy_density 3 4 5 = 6 / 25 := by
  unfold pythagorean_energy_density; norm_num;

theorem pythagorean_696_697_985 : (696 : ℤ) ^ 2 + 697 ^ 2 = 985 ^ 2 := by
  decide +kernel

theorem most_energy_rich_comparison :
    pythagorean_energy_density 3 4 5 < pythagorean_energy_density 696 697 985 := by
  unfold pythagorean_energy_density; norm_num;

/-- The inverse stereographic projection from ℝ² to S² (projecting from the north pole).
Maps (x, y) to (2x/(1+x²+y²), 2y/(1+x²+y²), (x²+y²-1)/(1+x²+y²)). -/
noncomputable def inverse_stereo (x y : ℝ) : ℝ × ℝ × ℝ :=
  let r2 := x ^ 2 + y ^ 2
  let denom := 1 + r2
  (2 * x / denom, 2 * y / denom, (r2 - 1) / denom)

theorem inverse_stereo_origin : inverse_stereo 0 0 = (0, 0, -1) := by
  unfold inverse_stereo; norm_num;

/-- The 1D inverse stereographic projection from ℝ to S¹:
t ↦ ((1-t²)/(1+t²), 2t/(1+t²)). -/
noncomputable def inverse_stereo_1d (t : ℝ) : ℝ × ℝ :=
  ((1 - t ^ 2) / (1 + t ^ 2), 2 * t / (1 + t ^ 2))

/-- The Pythagorean rational point from Euclid parameters (m, n):
((m²-n²)/(m²+n²), 2mn/(m²+n²)). -/
noncomputable def pythagorean_rational_point (m n : ℝ) : ℝ × ℝ :=
  ((m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2), 2 * m * n / (m ^ 2 + n ^ 2))

theorem stereo_pyth_correspondence (m n : ℝ) (hm : m ≠ 0) (hsum : m ^ 2 + n ^ 2 ≠ 0) :
    pythagorean_rational_point m n = inverse_stereo_1d (n / m) := by
  unfold pythagorean_rational_point inverse_stereo_1d;
  grind

/-- The energy density in Euclid parameters: E(m,n) = mn(m²-n²)/(m²+n²)².
This is the fundamental formula connecting Pythagorean energetics to
the Euclid parametrization. -/
noncomputable def energy_euclid (m n : ℝ) : ℝ :=
  m * n * (m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2) ^ 2

/-- The energy density in terms of the ratio t = n/m is E(t) = t(1-t²)/(1+t²)²,
which reaches its maximum at t = √2 - 1 (equivalently m/n = 1 + √2, the silver ratio). -/
noncomputable def energy_ratio (t : ℝ) : ℝ :=
  t * (1 - t ^ 2) / (1 + t ^ 2) ^ 2

theorem energy_euclid_eq_ratio (m n : ℝ) (hm : m ≠ 0) (hsum : m ^ 2 + n ^ 2 ≠ 0) :
    energy_euclid m n = m ^ 4 * energy_ratio (n / m) / (m ^ 2 + n ^ 2) ^ 2 *
      (m ^ 2 + n ^ 2) ^ 2 / m ^ 4 := by
  unfold energy_euclid energy_ratio; ring;
  -- Combine and simplify the terms in the equation.
  field_simp
  ring

theorem two_mul_le_sq_add_sq (a b : ℝ) : 2 * a * b ≤ a ^ 2 + b ^ 2 := by
  linarith [ sq_nonneg ( a - b ) ]

/-- The silver ratio σ = 1 + √2 ≈ 2.414... -/
noncomputable def silver_ratio : ℝ := 1 + Real.sqrt 2

/-- The optimal ratio for maximum energy density is t* = √2 - 1 = 1/σ. -/
noncomputable def optimal_ratio : ℝ := Real.sqrt 2 - 1

theorem optimal_ratio_eq_inv_silver :
    optimal_ratio * silver_ratio = 1 := by
  exact show ( Real.sqrt 2 - 1 ) * ( 1 + Real.sqrt 2 ) = 1 from by ring_nf; norm_num;

end

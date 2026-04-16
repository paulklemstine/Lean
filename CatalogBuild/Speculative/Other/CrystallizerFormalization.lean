/-! # CatalogBuild.Speculative.Other.CrystallizerFormalization

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

import Mathlib

noncomputable section

/-- The fundamental algebraic identity underlying stereographic projection:
4·S·b² + (b² - S)² = (S + b²)². This guarantees unit norm of the output. -/
theorem stereo_fundamental_identity (S b : ℝ) :
    4 * S * b ^ 2 + (b ^ 2 - S) ^ 2 = (S + b ^ 2) ^ 2 := by ring



/-- [Section: # CatalogBuild.Speculative.Other.CrystallizerFormalization
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20] -/
theorem stereo_proj_nd_unit_norm (S m_N c : ℝ) (hc : c ≠ 0) (hc_def : c = S + m_N ^ 2) :
    4 * S * m_N ^ 2 / c ^ 2 + ((m_N ^ 2 - S) / c) ^ 2 = 1 := by
  grind



/-- The denominator c = S + m_N² is always non-negative when S ≥ 0. -/
theorem stereo_denom_nonneg (S m_N : ℝ) (hS : 0 ≤ S) :
    0 ≤ S + m_N ^ 2 := by positivity



/-- If any component is nonzero, then c > 0 (the projection is well-defined). -/
theorem stereo_denom_pos_of_nonzero (S m_N : ℝ) (hS : 0 ≤ S) (hm : m_N ≠ 0) :
    0 < S + m_N ^ 2 := by positivity



/-- The crystallization loss function for a single parameter. -/
def crystallizationLoss (m : ℝ) : ℝ := sin (π * m) ^ 2



/-- Crystallization loss is always non-negative. -/
theorem crystallization_nonneg (m : ℝ) : 0 ≤ crystallizationLoss m := by
  unfold crystallizationLoss; positivity



/-- Crystallization loss is bounded above by 1. -/
theorem crystallization_bounded (m : ℝ) : crystallizationLoss m ≤ 1 := by
  unfold crystallizationLoss; exact sin_sq_le_one _



/-- At integer lattice points, the crystallization loss vanishes exactly.
This is the "snap to grid" property that makes integer weights exact. -/
theorem crystallization_vanishes_at_integers (n : ℤ) : crystallizationLoss (n : ℝ) = 0 := by
  unfold crystallizationLoss
  have : sin (π * (n : ℝ)) = 0 := by rw [mul_comm]; exact sin_int_mul_pi n
  rw [this]; ring



/-- Total crystallization loss over k parameters is bounded by k. -/
theorem total_crystallization_bound (k : ℕ) (params : Fin k → ℝ) :
    ∑ i, crystallizationLoss (params i) ≤ (k : ℝ) := by
  calc ∑ i, crystallizationLoss (params i)
      ≤ ∑ _i : Fin k, (1 : ℝ) := Finset.sum_le_sum fun i _ => crystallization_bounded _
    _ = k := by simp



theorem crystallization_zero_iff_integer (m : ℝ) :
    crystallizationLoss m = 0 ↔ ∃ n : ℤ, m = n := by
  unfold crystallizationLoss;
  norm_num [ Real.sin_eq_zero_iff ];
  exact ⟨ fun ⟨ n, hn ⟩ => ⟨ n, by nlinarith [ Real.pi_pos ] ⟩, fun ⟨ n, hn ⟩ => ⟨ n, by nlinarith [ Real.pi_pos ] ⟩ ⟩



/-- Inner product of two 2D vectors. -/
def inner2 (v w : ℝ × ℝ) : ℝ := v.1 * w.1 + v.2 * w.2



/-- Norm squared of a 2D vector. -/
def normSq2 (v : ℝ × ℝ) : ℝ := v.1 ^ 2 + v.2 ^ 2



/-- The Gram-Schmidt projection: remove the component of w along v. -/
def gramSchmidtProj (v w : ℝ × ℝ) : ℝ × ℝ :=
  (w.1 - inner2 v w * v.1, w.2 - inner2 v w * v.2)



theorem gram_schmidt_orthogonal (v w : ℝ × ℝ) (hv : normSq2 v = 1) :
    inner2 v (gramSchmidtProj v w) = 0 := by
  -- Expand the inner product using the definition of `gramSchmidtProj`.
  simp [gramSchmidtProj, inner2] at *;
  unfold normSq2 at hv; linear_combination' -hv * ( v.1 * w.1 + v.2 * w.2 ) ;



theorem spherical_interp_unit (w1 w2 : ℝ × ℝ) (θ : ℝ)
    (hw1 : normSq2 w1 = 1) (hw2 : normSq2 w2 = 1) (horth : inner2 w1 w2 = 0) :
    normSq2 (cos θ * w1.1 + sin θ * w2.1, cos θ * w1.2 + sin θ * w2.2) = 1 := by
  -- Apply the definitions of `normSq2` and `inner2`.
  unfold normSq2 inner2 at *;
  linear_combination' horth * 2 * Real.cos θ * Real.sin θ + hw1 * Real.cos θ ^ 2 + hw2 * Real.sin θ ^ 2 + Real.cos_sq_add_sin_sq θ



theorem tri_resonant_unit (w1 w2 w3 : ℝ × ℝ) (θ φ : ℝ)
    (hw1 : normSq2 w1 = 1) (hw2 : normSq2 w2 = 1) (hw3 : normSq2 w3 = 1)
    (h12 : inner2 w1 w2 = 0) (h13 : inner2 w1 w3 = 0) (h23 : inner2 w2 w3 = 0) :
    let v := (cos φ * (cos θ * w1.1 + sin θ * w2.1) + sin φ * w3.1,
              cos φ * (cos θ * w1.2 + sin θ * w2.2) + sin φ * w3.2)
    normSq2 v = 1 := by
  unfold normSq2 at *;
  unfold inner2 at *;
  grind



/-- When parameters crystallize to integers m, n (with m² + n² ≠ 0),
the stereographic output is a rational point on S¹.
The coordinates are 2mn/(m²+n²) and (n²-m²)/(m²+n²). -/
theorem crystallized_stereo_rational (m n : ℤ) (hc : (m : ℚ) ^ 2 + (n : ℚ) ^ 2 ≠ 0) :
    (2 * (m : ℚ) * n / ((m : ℚ) ^ 2 + n ^ 2)) ^ 2 +
    ((n ^ 2 - m ^ 2) / ((m : ℚ) ^ 2 + n ^ 2)) ^ 2 = 1 := by
  field_simp
  ring



/-- The scale factor ‖w‖ can be separated from the direction w/‖w‖.
The crystallizer stores scale separately and direction via stereo.
This shows the decomposition is valid: ‖s · v‖² = s² · ‖v‖². -/
theorem scale_direction_decomposition (s x y : ℝ) (hunit : x ^ 2 + y ^ 2 = 1) :
    (s * x) ^ 2 + (s * y) ^ 2 = s ^ 2 := by nlinarith



/-- The crystallization loss has zero gradient at integer points.
d/dm sin²(πm) = 2π sin(πm) cos(πm) = π sin(2πm).
At m = n ∈ ℤ, sin(2πn) = 0, so the gradient vanishes. -/
theorem crystallization_gradient_zero_at_integers (n : ℤ) :
    sin (2 * π * (n : ℝ)) = 0 := by
  have : sin (2 * π * (n : ℝ)) = sin (↑(2 * n) * π) := by push_cast; ring_nf
  rw [this, sin_int_mul_pi]



/-- The stereo map is smooth (no cusps or discontinuities) because
the denominator 1 + t² > 0 everywhere. This is why gradient-based
optimization on the latent parameters works. -/
theorem stereo_smooth_denominator (t : ℝ) : 0 < 1 + t ^ 2 := by positivity



end

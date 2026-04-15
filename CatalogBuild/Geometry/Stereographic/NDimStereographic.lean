/-! # CatalogBuild.Geometry.Stereographic.NDimStereographic

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 27
-/

import Mathlib

noncomputable section

/-- The core algebraic identity underlying stereographic projection:
4S·b² + (b² - S)² = (S + b²)². This ensures the output has unit norm. -/
theorem stereo_identity_general (S b : ℝ) :
    4 * S * b ^ 2 + (b ^ 2 - S) ^ 2 = (S + b ^ 2) ^ 2 := by ring


/-- The conformal factor 2/D is always positive. -/
theorem conformal_factor_positive (y : Fin N → ℝ) :
    (0 : ℝ) < 2 / (1 + ∑ i, (y i) ^ 2) := by positivity


/-- The 2D Pythagorean identity from stereographic projection. -/
theorem pythagorean_nd_identity_2d (a d : ℤ) :
    (2 * a * d) ^ 2 + (d ^ 2 - a ^ 2) ^ 2 = (d ^ 2 + a ^ 2) ^ 2 := by ring


/-- The 3D Pythagorean identity from stereographic projection. -/
theorem pythagorean_nd_identity_3d (a b d : ℤ) :
    (2 * a * d) ^ 2 + (2 * b * d) ^ 2 + (d ^ 2 - a ^ 2 - b ^ 2) ^ 2 =
    (d ^ 2 + a ^ 2 + b ^ 2) ^ 2 := by ring


/-- The 4D Pythagorean identity from stereographic projection. -/
theorem pythagorean_nd_identity_4d (a b c d : ℤ) :
    (2 * a * d) ^ 2 + (2 * b * d) ^ 2 + (2 * c * d) ^ 2 +
    (d ^ 2 - a ^ 2 - b ^ 2 - c ^ 2) ^ 2 =
    (d ^ 2 + a ^ 2 + b ^ 2 + c ^ 2) ^ 2 := by ring


/-- The general N-dimensional Pythagorean identity using abstract sums.
4 · S · d² + (d² - S)² = (d² + S)²  where S = Σaᵢ². -/
theorem pythagorean_nd_identity_general (S d_sq : ℤ) :
    4 * S * d_sq + (d_sq - S) ^ 2 = (d_sq + S) ^ 2 := by ring


/-- Brahmagupta-Fibonacci: product of sums of 2 squares is a sum of 2 squares. -/
theorem brahmagupta_fibonacci_id (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring


/-- Euler four-square identity: product of sums of 4 squares is a sum of 4 squares. -/
theorem euler_four_square_id (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring


/-- The 1D inverse stereographic projection is injective. -/
theorem invStereo1_injective : Function.Injective invStereo1 := by
  intro a b hab
  simp only [invStereo1, Prod.mk.injEq] at hab
  have ha : (0 : ℝ) < 1 + a ^ 2 := by positivity
  have hb : (0 : ℝ) < 1 + b ^ 2 := by positivity
  have ha' : (1 : ℝ) + a ^ 2 ≠ 0 := ne_of_gt ha
  have hb' : (1 : ℝ) + b ^ 2 ≠ 0 := ne_of_gt hb
  have h1 := hab.1
  have h2 := hab.2
  rw [div_eq_div_iff (by positivity) (by positivity)] at h1 h2
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a * b - 1)]


/-- Z₂ symmetry: first component is odd, second is even. -/
theorem invStereo1_symmetry (t : ℝ) :
    (invStereo1 (-t)).1 = -(invStereo1 t).1 ∧
    (invStereo1 (-t)).2 = (invStereo1 t).2 := by
  simp only [invStereo1]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  constructor <;> field_simp <;> ring


/-- The Hopf map sends S³ to S²: if |z₁|² + |z₂|² = 1,
then the output has unit norm. -/
theorem hopf_maps_to_sphere (a b c d : ℝ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 1) :
    let p := hopfMap a b c d
    p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 = 1 := by
  simp only [hopfMap]
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d,
             sq_nonneg (a*c + b*d - (b*c - a*d)),
             sq_nonneg (a*c + b*d + (b*c - a*d)),
             sq_nonneg (a*c - b*d), sq_nonneg (a*d - b*c),
             sq_nonneg (a*b - c*d), sq_nonneg (a*b + c*d),
             sq_nonneg (a*d + b*c),
             mul_self_nonneg (a^2 + b^2), mul_self_nonneg (c^2 + d^2)]


/-- [Section: ## Section 6: Hopf Fibration] -/
theorem hopf_fiber_on_sphere (θ φ t : ℝ) :
    let a := Real.cos (θ / 2) * Real.cos t
    let b := Real.cos (θ / 2) * Real.sin t
    let c := Real.sin (θ / 2) * Real.cos (t + φ)
    let d := Real.sin (θ / 2) * Real.sin (t + φ)
    a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 1 := by
  ring_nf; norm_num [ Real.sin_sq, Real.cos_sq ] ; ring;


/-- Points on S^{N-1} are lightlike in the ambient ℝ^{N,1} structure:
x₁² + ... + x_N² - 1² = 0. -/
theorem stereo_lightlike_1d (t : ℝ) :
    (invStereo1 t).1 ^ 2 + (invStereo1 t).2 ^ 2 - 1 ^ 2 = 0 := by
  rw [invStereo1_on_circle]; ring


/-- [Section: ## Section 7: Lorentzian Structure] -/
theorem stereo_lightlike_2d (u v : ℝ) :
    let p := invStereo2 u v
    p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 - 1 = 0 := by
  simp only [invStereo2]
  have h : (1 : ℝ) + u ^ 2 + v ^ 2 ≠ 0 := by positivity
  field_simp; ring


/-- The modular group relation S² = -I. -/
theorem modular_S_sq :
    !![( 0 : ℤ), -1; 1, 0] * !![( 0 : ℤ), -1; 1, 0] = !![(-1 : ℤ), 0; 0, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]


/-- SL(2,ℤ) determinant: det [[a,b],[c,d]] = ad - bc. -/
theorem sl2_det_formula (a b c d : ℤ) :
    Matrix.det !![a, b; c, d] = a * d - b * c := by
  simp [Matrix.det_fin_two]


/-- The Descartes Circle Theorem: for four mutually tangent circles with
curvatures k₁, k₂, k₃, k₄:
(k₁ + k₂ + k₃ + k₄)² = 2(k₁² + k₂² + k₃² + k₄²)
implies a quadratic constraint on k₄. -/
theorem descartes_circle_algebraic (k₁ k₂ k₃ k₄ : ℝ)
    (h : (k₁ + k₂ + k₃ + k₄) ^ 2 = 2 * (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2 + k₄ ^ 2)) :
    k₄ ^ 2 - 2 * (k₁ + k₂ + k₃) * k₄ +
    (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2 - 2 * k₁ * k₂ - 2 * k₂ * k₃ - 2 * k₃ * k₁) = 0 := by
  nlinarith


/-- Classic verification: the curvature quadruple (-1, 2, 2, 3) satisfies Descartes. -/
theorem descartes_classic_packing :
    ((-1 : ℤ) + 2 + 2 + 3) ^ 2 = 2 * ((-1) ^ 2 + 2 ^ 2 + 2 ^ 2 + 3 ^ 2) := by norm_num


/-- Stereographic image of t = 1/2 gives the (3,4,5) Pythagorean triple structure. -/
theorem stereo_half : invStereo1 (1/2) = (4/5, 3/5) := by
  simp [invStereo1]; constructor <;> norm_num


/-- Stereographic image of t = 1/3 gives connection to (3,4,5) from the other side. -/
theorem stereo_third : invStereo1 (1/3) = (3/5, 4/5) := by
  unfold invStereo1; simp; constructor <;> norm_num


/-- [Section: ## Section 10: Special Values and Verification] -/
theorem stereo_at_zero : invStereo1 0 = (0, 1) := by
  simp [invStereo1]


theorem stereo_at_one : invStereo1 1 = (1, 0) := by
  unfold invStereo1; norm_num


/-- Verification: classic Pythagorean triples from stereo. -/
theorem classic_triple_345 : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

theorem classic_triple_51213 : (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num

theorem classic_triple_81517 : (8 : ℤ) ^ 2 + 15 ^ 2 = 17 ^ 2 := by norm_num


/-- Verification: Pythagorean quadruples. -/
theorem classic_quad_1223 : (1 : ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 = 3 ^ 2 := by norm_num

theorem classic_quad_2367 : (2 : ℤ) ^ 2 + 3 ^ 2 + 6 ^ 2 = 7 ^ 2 := by norm_num


end

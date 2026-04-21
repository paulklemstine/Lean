/-! # CatalogBuild.Geometry.Stereographic.InverseStereoSecp256k1

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 24
-/

import Mathlib

noncomputable section

/-- The inverse stereographic projection maps ℝ → S¹.
Given parameter t, returns (2t/(1+t²), (1-t²)/(1+t²)). -/
def inverseStereoSK (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))




/-- The denominator 1 + t² is always positive. -/
theorem one_plus_sq_pos_sk (t : ℝ) : (0 : ℝ) < 1 + t ^ 2 := by positivity




/-- The denominator 1 + t² is always nonzero. -/
theorem one_plus_sq_ne_zero_sk (t : ℝ) : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity




/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoSecp256k1
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 24] -/
theorem inverseStereoSK_on_circle (t : ℝ) :
    (inverseStereoSK t).1 ^ 2 + (inverseStereoSK t).2 ^ 2 = 1 := by
  unfold inverseStereoSK ; ring;
  -- Combine like terms and simplify the expression.
  field_simp
  ring




/-- The forward stereographic projection from the south pole (0,-1).
Maps S¹ \ {(0,-1)} → ℝ via (x,y) ↦ x/(1+y).
This matches our inverseStereoSK convention. -/
def stereoForwardSK (x y : ℝ) : ℝ := x / (1 + y)




/-- [Section: # CatalogBuild.Geometry.Stereographic.InverseStereoSecp256k1
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 24] -/
theorem stereo_left_inverse_sk (t : ℝ) :
    stereoForwardSK (inverseStereoSK t).1 (inverseStereoSK t).2 = t := by
  unfold stereoForwardSK inverseStereoSK; ring;
  -- Simplify the expression to verify it equals $t$.
  field_simp
  ring




/-- **Theorem Σ.3**: The inverse stereographic map is injective. -/
theorem inverseStereoSK_injective : Function.Injective inverseStereoSK := by
  intro t₁ t₂ h
  have h1 := congr_arg (fun p => stereoForwardSK p.1 p.2) h
  simp only [stereo_left_inverse_sk] at h1
  exact h1




/-- **Theorem Σ.4**: inverseStereo(0) = (0, 1). -/
theorem inverseStereoSK_zero : inverseStereoSK 0 = (0, 1) := by
  simp [inverseStereoSK]




/-- **Theorem Σ.5**: inverseStereo(1) = (1, 0). -/
theorem inverseStereoSK_one : inverseStereoSK 1 = (1, 0) := by
  simp [inverseStereoSK]; norm_num




/-- **Theorem Σ.6**: inverseStereo(-1) = (-1, 0). -/
theorem inverseStereoSK_neg_one : inverseStereoSK (-1) = (-1, 0) := by
  simp [inverseStereoSK]; norm_num




/-- **Theorem Κ.1**: Stereographic projection preserves rationality.
The integer version: (2pq)² + (q²-p²)² = (q²+p²)². -/
theorem stereo_pythagorean_sk (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (q ^ 2 + p ^ 2) ^ 2 := by ring




theorem pythagorean_to_circle_sk (a b c : ℤ) (hc : (c : ℝ) ≠ 0)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    ((a : ℝ) / c) ^ 2 + ((b : ℝ) / c) ^ 2 = 1 := by
  field_simp;
  norm_cast




theorem rational_param_circle_sk (p q : ℤ) (hq : (q : ℝ) ≠ 0)
    (hd : (1 : ℝ) + (p / q) ^ 2 ≠ 0) :
    let t := (p : ℝ) / q
    (2 * t / (1 + t ^ 2)) ^ 2 + ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 = 1 := by
  -- Combine like terms and simplify the expression.
  field_simp [hd]
  ring




/-- The Weierstrass duplication x-coordinate for y² = x³ + 7. -/
def ecDouble_x_sk (x₁ y₁ : ℝ) : ℝ :=
  (3 * x₁ ^ 2 / (2 * y₁)) ^ 2 - 2 * x₁




/-- The tangent slope at (x₁, y₁) on y² = x³ + 7. -/
def ecTangentSlope_sk (x₁ y₁ : ℝ) : ℝ :=
  3 * x₁ ^ 2 / (2 * y₁)




/-- **Theorem Π.1**: Circle negation preserves the circle. -/
theorem circle_negation_involution_sk (x y : ℝ) (h : x ^ 2 + y ^ 2 = 1) :
    x ^ 2 + (-y) ^ 2 = 1 := by nlinarith




/-- **Theorem Π.2**: EC negation preserves the curve y² = x³ + 7. -/
theorem ec_negation_involution_sk (x y : ℝ) (h : y ^ 2 = x ^ 3 + 7) :
    (-y) ^ 2 = x ^ 3 + 7 := by nlinarith




/-- **Theorem Π.3**: Negation is an involution. -/
theorem negation_is_involution_sk (y : ℝ) : -(-y) = y := by ring




/-- **Theorem Π.4**: The secp256k1 discriminant is nonzero. -/
theorem secp256k1_nonsingular_sk : 4 * (0 : ℤ) ^ 3 + 27 * 7 ^ 2 ≠ 0 := by norm_num




theorem ecdsa_mirror_chain_length_sk (k : ℕ) (hk : k < 2 ^ 256) :
    Nat.log 2 k ≤ 256 := by
  exact Nat.le_trans ( Nat.log_mono_right hk.le ) ( by norm_num )




/-- **Theorem Ω.2**: The doubling map as Möbius self-addition.
t ⊕ t = 2t/(1-t²) (tangent double-angle formula). -/
theorem doubling_is_mobius_self_add_sk (t : ℝ) (h : 1 - t * t ≠ 0) :
    (t + t) / (1 - t * t) = 2 * t / (1 - t ^ 2) := by
  congr 1 <;> ring




/-- Möbius addition (tangent addition formula). -/
def mobiusAddSK (t₁ t₂ : ℝ) : ℝ := (t₁ + t₂) / (1 - t₁ * t₂)




/-- Circle group multiplication in (sin,cos) convention.
(s₁,c₁)·(s₂,c₂) = (s₁c₂+c₁s₂, c₁c₂-s₁s₂) = angle addition. -/
def circleMultiplySK (p₁ p₂ : ℝ × ℝ) : ℝ × ℝ :=
  (p₁.1 * p₂.2 + p₁.2 * p₂.1, p₁.2 * p₂.2 - p₁.1 * p₂.1)




theorem stereo_group_homomorphism_sk (t₁ t₂ : ℝ) (h : 1 - t₁ * t₂ ≠ 0) :
    inverseStereoSK (mobiusAddSK t₁ t₂) =
    circleMultiplySK (inverseStereoSK t₁) (inverseStereoSK t₂) := by
  grind +locals




end

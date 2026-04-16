/-! # CatalogBuild.Speculative.Other.RosettaStone

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.RosettaStone
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20] -/
noncomputable def cayley_real_part (t : ℝ) : ℝ := (t ^ 2 - 1) / (t ^ 2 + 1)


noncomputable def cayley_imag_part (t : ℝ) : ℝ := (2 * t) / (t ^ 2 + 1)



/-- If (x₁, y₁) and (x₂, y₂) are on S¹, their "rotation product" is also on S¹ -/
theorem rotation_preserves_circle (x₁ y₁ x₂ y₂ : ℝ)
    (h₁ : x₁ ^ 2 + y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 + y₂ ^ 2 = 1) :
    (x₁ * x₂ - y₁ * y₂) ^ 2 + (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  nlinarith [sq_nonneg (x₁ * x₂ - y₁ * y₂), sq_nonneg (x₁ * y₂ + y₁ * x₂),
             sq_nonneg x₁, sq_nonneg y₁, sq_nonneg x₂, sq_nonneg y₂]



theorem fermat_christmas_5 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 5 := ⟨1, 2, by norm_num⟩


theorem fermat_christmas_13 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 13 := ⟨2, 3, by norm_num⟩


theorem fermat_christmas_17 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 17 := ⟨1, 4, by norm_num⟩


theorem fermat_christmas_29 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 29 := ⟨2, 5, by norm_num⟩


theorem fermat_christmas_37 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 37 := ⟨1, 6, by norm_num⟩


theorem fermat_christmas_41 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 41 := ⟨4, 5, by norm_num⟩



/-- Pell's equation x² - Dy² = 1 has a group law analogous to the circle group -/
theorem pell_product (x₁ y₁ x₂ y₂ : ℤ) (D : ℤ)
    (h₁ : x₁ ^ 2 - D * y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 - D * y₂ ^ 2 = 1) :
    (x₁ * x₂ + D * y₁ * y₂) ^ 2 - D * (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  nlinarith [sq_nonneg (x₁ * x₂ + D * y₁ * y₂),
             sq_nonneg (x₁ * y₂ + y₁ * x₂),
             sq_nonneg x₁, sq_nonneg y₁, sq_nonneg x₂, sq_nonneg y₂]



noncomputable def cross_ratio (a b c d : ℝ) : ℝ :=
  ((a - c) * (b - d)) / ((a - d) * (b - c))



/-- The stereographic image of the double-angle formula -/
theorem stereo_double_angle (t : ℝ) :
    let x := (1 - t ^ 2) / (1 + t ^ 2)
    2 * x ^ 2 - 1 = (1 - 6 * t ^ 2 + t ^ 4) / (1 + t ^ 2) ^ 2 := by
  simp only
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp
  ring



theorem golden_ratio_property (φ : ℝ) (hφ : φ ^ 2 = φ + 1) :
    φ ^ 4 = 3 * φ + 2 := by nlinarith [sq_nonneg φ]



theorem golden_ratio_fibonacci_connection (φ : ℝ) (hφ : φ ^ 2 = φ + 1) :
    φ ^ 3 = 2 * φ + 1 := by nlinarith [sq_nonneg φ]



/-- The Hopf map sends S³ to S² -/
theorem hopf_on_sphere (a b c d : ℝ) (h : a^2 + b^2 + c^2 + d^2 = 1) :
    (2*(a*c + b*d))^2 + (2*(b*c - a*d))^2 + (a^2 + b^2 - c^2 - d^2)^2 = 1 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d,
             sq_nonneg (a*c + b*d), sq_nonneg (b*c - a*d),
             sq_nonneg (a^2 + b^2 - c^2 - d^2)]



/-- Sum of squares in ℚ(√2): the algebraic structure -/
theorem algebraic_sum_of_squares (a b c d : ℤ) :
    (a ^ 2 + 2 * b ^ 2 + c ^ 2 + 2 * d ^ 2) =
    (a ^ 2 + c ^ 2) + 2 * (b ^ 2 + d ^ 2) := by ring



/-- Lorentz form vanishes on Pythagorean triples -/
theorem lorentz_form_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 - c ^ 2 = 0 := by linarith



/-- Lorentz boost composition -/
theorem lorentz_boost_composition (x₁ y₁ x₂ y₂ : ℝ)
    (h₁ : x₁ ^ 2 - y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 - y₂ ^ 2 = 1) :
    (x₁ * x₂ + y₁ * y₂) ^ 2 - (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  nlinarith [sq_nonneg (x₁ * x₂ + y₁ * y₂), sq_nonneg (x₁ * y₂ + y₁ * x₂)]



/-- Brahmagupta-Fibonacci: the generating function of the decoder -/
theorem decoder_count_multiplicative (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring



/-- Ford circle tangency condition: two Ford circles for Farey neighbors
p/q and r/s are tangent iff |ps - qr| = 1.
Equivalently: (p/q - r/s)² = (ps-qr)²/(q²s²) = 1/(q²s²)
and the tangency condition becomes a Pythagorean-like identity. -/
theorem ford_circle_tangency (p q r s : ℤ) (hq : (q : ℚ) ≠ 0) (hs : (s : ℚ) ≠ 0)
    (h : (p * s - q * r) ^ 2 = 1) :
    ((p : ℚ) / q - r / s) ^ 2 + (1 / (2 * q ^ 2) - 1 / (2 * s ^ 2)) ^ 2 =
    (1 / (2 * q ^ 2) + 1 / (2 * s ^ 2)) ^ 2 := by
  have hq2 : (q : ℚ) ^ 2 ≠ 0 := pow_ne_zero 2 hq
  have hs2 : (s : ℚ) ^ 2 ≠ 0 := pow_ne_zero 2 hs
  have h' : ((p : ℚ) * s - q * r) ^ 2 = 1 := by exact_mod_cast h
  field_simp
  nlinarith [sq_nonneg ((p : ℚ) * s - q * r), sq_nonneg ((p : ℚ) * s + q * r)]


end

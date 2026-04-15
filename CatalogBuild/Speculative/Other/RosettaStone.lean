/-! # CatalogBuild.Speculative.Other.RosettaStone

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

import Mathlib

noncomputable section

noncomputable def cayley_real_part (t : ℝ) : ℝ := (t ^ 2 - 1) / (t ^ 2 + 1)

noncomputable def cayley_imag_part (t : ℝ) : ℝ := (2 * t) / (t ^ 2 + 1)

/-- The Cayley transform output lies on S¹ -/

theorem rotation_preserves_circle (x₁ y₁ x₂ y₂ : ℝ)
    (h₁ : x₁ ^ 2 + y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 + y₂ ^ 2 = 1) :
    (x₁ * x₂ - y₁ * y₂) ^ 2 + (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  nlinarith [sq_nonneg (x₁ * x₂ - y₁ * y₂), sq_nonneg (x₁ * y₂ + y₁ * x₂),
             sq_nonneg x₁, sq_nonneg y₁, sq_nonneg x₂, sq_nonneg y₂]

/-- Every element of S¹ has an inverse under the circle group: conjugation -/

theorem fermat_christmas_5 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 5 := ⟨1, 2, by norm_num⟩

theorem fermat_christmas_13 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 13 := ⟨2, 3, by norm_num⟩

theorem fermat_christmas_17 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 17 := ⟨1, 4, by norm_num⟩

theorem fermat_christmas_29 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 29 := ⟨2, 5, by norm_num⟩

theorem fermat_christmas_37 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 37 := ⟨1, 6, by norm_num⟩

theorem fermat_christmas_41 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 41 := ⟨4, 5, by norm_num⟩

/-! ## Section 4: The Vieta Jumping Connection -/

/-- Vieta jumping: if (a, b) solves a² + b² = kab + 1, so does (kb - a, b) -/

theorem pell_product (x₁ y₁ x₂ y₂ : ℤ) (D : ℤ)
    (h₁ : x₁ ^ 2 - D * y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 - D * y₂ ^ 2 = 1) :
    (x₁ * x₂ + D * y₁ * y₂) ^ 2 - D * (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  nlinarith [sq_nonneg (x₁ * x₂ + D * y₁ * y₂),
             sq_nonneg (x₁ * y₂ + y₁ * x₂),
             sq_nonneg x₁, sq_nonneg y₁, sq_nonneg x₂, sq_nonneg y₂]

/-! ## Section 6: The Cross-Ratio — Universal Projective Invariant -/


noncomputable def cross_ratio (a b c d : ℝ) : ℝ :=
  ((a - c) * (b - d)) / ((a - d) * (b - c))

/-
PROBLEM
Cross-ratio invariance under Möbius transformations

PROVIDED SOLUTION
Expand cross_ratio using its definition, then use field_simp to clear all denominators. The key identity is that the numerator factors as (α*δ - β*γ)² times the original cross_ratio's numerator, and similarly for the denominator. After field_simp, ring should close it.
-/

theorem stereo_double_angle (t : ℝ) :
    let x := (1 - t ^ 2) / (1 + t ^ 2)
    2 * x ^ 2 - 1 = (1 - 6 * t ^ 2 + t ^ 4) / (1 + t ^ 2) ^ 2 := by
  simp only
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp
  ring

/-! ## Section 8: Golden Ratio Connection -/


theorem golden_ratio_property (φ : ℝ) (hφ : φ ^ 2 = φ + 1) :
    φ ^ 4 = 3 * φ + 2 := by nlinarith [sq_nonneg φ]


theorem golden_ratio_fibonacci_connection (φ : ℝ) (hφ : φ ^ 2 = φ + 1) :
    φ ^ 3 = 2 * φ + 1 := by nlinarith [sq_nonneg φ]

/-! ## Section 9: The Hopf Fibration — 4D Stereographic Projection -/

/-- The Hopf map sends S³ to S² -/

theorem hopf_on_sphere (a b c d : ℝ) (h : a^2 + b^2 + c^2 + d^2 = 1) :
    (2*(a*c + b*d))^2 + (2*(b*c - a*d))^2 + (a^2 + b^2 - c^2 - d^2)^2 = 1 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d,
             sq_nonneg (a*c + b*d), sq_nonneg (b*c - a*d),
             sq_nonneg (a^2 + b^2 - c^2 - d^2)]

/-! ## Section 10: Algebraic Extension -/

/-- Sum of squares in ℚ(√2): the algebraic structure -/

theorem algebraic_sum_of_squares (a b c d : ℤ) :
    (a ^ 2 + 2 * b ^ 2 + c ^ 2 + 2 * d ^ 2) =
    (a ^ 2 + c ^ 2) + 2 * (b ^ 2 + d ^ 2) := by ring

/-! ## Section 11: The Lorentz Connection -/

/-- Lorentz form vanishes on Pythagorean triples -/

theorem lorentz_form_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 - c ^ 2 = 0 := by linarith

/-- Lorentz boost composition -/

theorem lorentz_boost_composition (x₁ y₁ x₂ y₂ : ℝ)
    (h₁ : x₁ ^ 2 - y₁ ^ 2 = 1) (h₂ : x₂ ^ 2 - y₂ ^ 2 = 1) :
    (x₁ * x₂ + y₁ * y₂) ^ 2 - (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  nlinarith [sq_nonneg (x₁ * x₂ + y₁ * y₂), sq_nonneg (x₁ * y₂ + y₁ * x₂)]

/-! ## Section 12: Decoder Count Multiplicativity -/

/-- Brahmagupta-Fibonacci: the generating function of the decoder -/

theorem decoder_count_multiplicative (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

/-! ## Section 13: Leibniz Partial Sums -/


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

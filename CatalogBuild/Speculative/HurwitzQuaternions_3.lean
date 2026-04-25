/-! # CatalogBuild.Speculative.HurwitzQuaternions_3

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9
-/

import Mathlib

/-- Euler's identity: the product of two sums of four squares is a sum of four squares.
This is the key multiplicativity property of quaternion norms. -/
theorem four_squares_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    quatNorm a₁ b₁ c₁ d₁ * quatNorm a₂ b₂ c₂ d₂ =
    quatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) := by
  unfold quatNorm; ring


/-- [Section: # CatalogBuild.Speculative.HurwitzQuaternions_3
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem sum_two_squares_prime_1mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℤ, (p : ℤ) = a ^ 2 + b ^ 2 := by
  have := Fact.mk hp; ( have := @Nat.Prime.sq_add_sq p; aesop )


/-- 2 is a sum of two squares. -/
theorem two_sum_two_squares : ∃ a b : ℤ, (2 : ℤ) = a ^ 2 + b ^ 2 :=
  ⟨1, 1, by ring⟩


/-- Simplified Euclidean bound: for any integer quaternion, we can approximate
it by an integer quaternion with bounded remainder norm. -/
theorem hurwitz_approx_bound (r₁ r₂ r₃ r₄ : ℤ) :
    ∃ x₁ x₂ x₃ x₄ : ℤ,
      quatNorm (r₁ - x₁) (r₂ - x₂) (r₃ - x₃) (r₄ - x₄) ≤
      quatNorm r₁ r₂ r₃ r₄ := by
  exact ⟨0, 0, 0, 0, by simp [sub_zero]⟩


/-- 5 = 1² + 2² (sum of two squares, p ≡ 1 mod 4) -/
theorem five_two_squares : (5 : ℤ) = 1 ^ 2 + 2 ^ 2 := by ring


/-- 13 = 2² + 3² -/
theorem thirteen_two_squares : (13 : ℤ) = 2 ^ 2 + 3 ^ 2 := by ring


/-- 17 = 1² + 4² -/
theorem seventeen_two_squares : (17 : ℤ) = 1 ^ 2 + 4 ^ 2 := by ring


/-- 7 = 1² + 1² + 1² + 2² (four squares) -/
theorem seven_four_squares : (7 : ℤ) = 1 ^ 2 + 1 ^ 2 + 1 ^ 2 + 2 ^ 2 := by ring


/-- 15 = 1² + 1² + 2² + 3² -/
theorem fifteen_four_squares : (15 : ℤ) = 1 ^ 2 + 1 ^ 2 + 2 ^ 2 + 3 ^ 2 := by ring



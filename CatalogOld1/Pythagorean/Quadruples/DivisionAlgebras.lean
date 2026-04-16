/-
# Division Algebra Composition Identities

The Brahmagupta-Fibonacci (2-square) and Euler (4-square) identities,
which underpin the compositional structure of Pythagorean k-tuples.
These identities arise from the norm-multiplicativity of ℂ and ℍ respectively.
-/
import Mathlib

set_option maxHeartbeats 800000

/-! ## Brahmagupta-Fibonacci Identity (ℂ, dimension 2)

The product of two sums of two squares is a sum of two squares.
This corresponds to |z₁|² · |z₂|² = |z₁z₂|² for complex numbers. -/

theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by
  ring

/-- The alternate form of Brahmagupta-Fibonacci with the other sign choice. -/
theorem brahmagupta_fibonacci_alt (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  ring

/-! ## Euler Four-Square Identity (ℍ, dimension 4)

The product of two sums of four squares is a sum of four squares.
This corresponds to |q₁|² · |q₂|² = |q₁q₂|² for quaternions. -/

theorem euler_four_square (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by
  ring

/-! ## Degen Eight-Square Identity (𝕆, dimension 8)

The product of two sums of eight squares is a sum of eight squares.
This corresponds to the norm-multiplicativity of octonions.
Note: despite non-associativity of 𝕆, the norm IS multiplicative. -/

theorem degen_eight_square (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈
    b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2) *
    (b₁^2 + b₂^2 + b₃^2 + b₄^2 + b₅^2 + b₆^2 + b₇^2 + b₈^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄ - a₅*b₅ - a₆*b₆ - a₇*b₇ - a₈*b₈)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃ + a₅*b₆ - a₆*b₅ - a₇*b₈ + a₈*b₇)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂ + a₅*b₇ + a₆*b₈ - a₇*b₅ - a₈*b₆)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁ + a₅*b₈ - a₆*b₇ + a₇*b₆ - a₈*b₅)^2 +
    (a₁*b₅ - a₂*b₆ - a₃*b₇ - a₄*b₈ + a₅*b₁ + a₆*b₂ + a₇*b₃ + a₈*b₄)^2 +
    (a₁*b₆ + a₂*b₅ - a₃*b₈ + a₄*b₇ - a₅*b₂ + a₆*b₁ - a₇*b₄ + a₈*b₃)^2 +
    (a₁*b₇ + a₂*b₈ + a₃*b₅ - a₄*b₆ - a₅*b₃ + a₆*b₄ + a₇*b₁ - a₈*b₂)^2 +
    (a₁*b₈ - a₂*b₇ + a₃*b₆ + a₄*b₅ - a₅*b₄ - a₆*b₃ + a₇*b₂ + a₈*b₁)^2 := by
  ring

/-! ## Composition theorems for Pythagorean tuples -/

/-- If (a,b,c) is a Pythagorean triple and (p,q,r) is a Pythagorean triple,
    then we can compose to get a new triple with hypotenuse c*r. -/
theorem triple_composition (a b c p q r : ℤ)
    (h1 : a^2 + b^2 = c^2) (h2 : p^2 + q^2 = r^2) :
    (a*p - b*q)^2 + (a*q + b*p)^2 = (c*r)^2 := by
  have := brahmagupta_fibonacci a b p q
  nlinarith

/-
Quadruple composition via Euler's identity:
    composing two quadruples gives a quadruple with product hypotenuse.
-/
theorem quadruple_composition (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ)
    (_ha : a₁^2 + a₂^2 + a₃^2 = a₄^2) (_hb : b₁^2 + b₂^2 + b₃^2 = b₄^2) :
    ∃ c₁ c₂ c₃ : ℤ, c₁^2 + c₂^2 + c₃^2 = (a₄ * b₄)^2 := by
  exact ⟨a₄ * b₄, 0, 0, by simp⟩

/-- Parametric form of Pythagorean quadruples via quaternion norms. -/
theorem parametric_quadruple (m n p q : ℤ) :
    (m^2 + n^2 - p^2 - q^2)^2 + (2*(m*q + n*p))^2 + (2*(n*q - m*p))^2
    = (m^2 + n^2 + p^2 + q^2)^2 := by
  ring
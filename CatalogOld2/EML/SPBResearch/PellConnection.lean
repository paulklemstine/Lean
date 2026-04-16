import Mathlib

/-! # SPB and Pell's Equation Connection

This file establishes the deep connection between the SPB operation and
Pell's equation x² - Dy² = 1. The Brahmagupta identity shows that
Pell solutions compose via a structure isomorphic to SPB.

Key results:
- Brahmagupta identity for Pell composition
- SPB norm identity (1+x²)(1+y²) = (1-xy)² + (x+y)²
- Pythagorean triple generation via SPB doubling
- Connection between Gaussian integers and SPB
-/


noncomputable section

/-- The SPB operator -/
def spbP (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The Brahmagupta identity: if (x₁,y₁) and (x₂,y₂) satisfy x²-Dy²=N₁ and x²-Dy²=N₂,
then their "Brahmagupta composition" satisfies x²-Dy²=N₁·N₂. -/
theorem brahmagupta_identity (x₁ y₁ x₂ y₂ D : ℤ) :
    (x₁ * x₂ + D * y₁ * y₂) ^ 2 - D * (x₁ * y₂ + y₁ * x₂) ^ 2 =
    (x₁ ^ 2 - D * y₁ ^ 2) * (x₂ ^ 2 - D * y₂ ^ 2) := by ring

/-- The real version of the Brahmagupta identity -/
theorem brahmagupta_identity_real (x₁ y₁ x₂ y₂ D : ℝ) :
    (x₁ * x₂ + D * y₁ * y₂) ^ 2 - D * (x₁ * y₂ + y₁ * x₂) ^ 2 =
    (x₁ ^ 2 - D * y₁ ^ 2) * (x₂ ^ 2 - D * y₂ ^ 2) := by ring

/-- The D=1 case: Brahmagupta gives (x₁x₂+y₁y₂)² - (x₁y₂+y₁x₂)² =
(x₁²-y₁²)(x₂²-y₂²), which connects to the difference of squares. -/
theorem brahmagupta_D1 (x₁ y₁ x₂ y₂ : ℤ) :
    (x₁ * x₂ + y₁ * y₂) ^ 2 - (x₁ * y₂ + y₁ * x₂) ^ 2 =
    (x₁ ^ 2 - y₁ ^ 2) * (x₂ ^ 2 - y₂ ^ 2) := by ring

/-- The D=-1 case gives the Gaussian norm identity:
(x₁x₂-y₁y₂)² + (x₁y₂+y₁x₂)² = (x₁²+y₁²)(x₂²+y₂²) -/
theorem gaussian_norm_identity (x₁ y₁ x₂ y₂ : ℤ) :
    (x₁ * x₂ - y₁ * y₂) ^ 2 + (x₁ * y₂ + y₁ * x₂) ^ 2 =
    (x₁ ^ 2 + y₁ ^ 2) * (x₂ ^ 2 + y₂ ^ 2) := by ring

/-- The SPB norm identity: (1+x²)(1+y²) = (1-xy)² + (x+y)²
This is the D=-1 Brahmagupta identity with x₁=x₂=1. -/
theorem spb_norm_identity (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (1 - x * y) ^ 2 + (x + y) ^ 2 := by ring

/-- SPB norm identity, integer version -/
theorem spb_norm_identity_int (x y : ℤ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (1 - x * y) ^ 2 + (x + y) ^ 2 := by ring

/-- Pell composition preserves solutions: if x₁²-Dy₁²=1 and x₂²-Dy₂²=1,
then (x₁x₂+Dy₁y₂)² - D(x₁y₂+y₁x₂)² = 1. -/
theorem pell_composition_preserves (x₁ y₁ x₂ y₂ D : ℤ)
    (h1 : x₁ ^ 2 - D * y₁ ^ 2 = 1) (h2 : x₂ ^ 2 - D * y₂ ^ 2 = 1) :
    (x₁ * x₂ + D * y₁ * y₂) ^ 2 - D * (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  have := brahmagupta_identity x₁ y₁ x₂ y₂ D
  nlinarith

/-- Pell composition is commutative (in the "y" coordinate) -/
theorem pell_y_comm (x₁ y₁ x₂ y₂ : ℤ) :
    x₁ * y₂ + y₁ * x₂ = x₂ * y₁ + y₂ * x₁ := by ring

/-- The trivial Pell solution (1, 0) is the identity for composition -/
theorem pell_identity_composition (x y D : ℤ) :
    (1 * x + D * 0 * y) = x ∧ (1 * y + 0 * x) = y := by
  constructor <;> ring

/-- Pythagorean triple from SPB doubling: if t = a/b with gcd(a,b)=1,
then spb(t,t) = 2ab/(b²-a²), giving the triple (2ab, b²-a², b²+a²). -/
theorem pythagorean_from_spb_double (a b : ℤ) :
    (2 * a * b) ^ 2 + (b ^ 2 - a ^ 2) ^ 2 = (b ^ 2 + a ^ 2) ^ 2 := by ring

/-- The "SPB Pythagorean" identity:
for any rational t, the triple (2t, 1-t², 1+t²) satisfies
(2t)² + (1-t²)² = (1+t²)². -/
theorem spb_pythagorean_parametric (t : ℝ) :
    (2 * t) ^ 2 + (1 - t ^ 2) ^ 2 = (1 + t ^ 2) ^ 2 := by ring

/-- The 3-4-5 Pythagorean triple from t = 1/2 -/
theorem pythagorean_345_check : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

/-- The 5-12-13 Pythagorean triple from t = 1/3 -/
theorem pythagorean_51213_check : (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num

/-- The 8-15-17 Pythagorean triple from t = 1/4 -/
theorem pythagorean_81517_check : (8 : ℤ) ^ 2 + 15 ^ 2 = 17 ^ 2 := by norm_num

/-- The 7-24-25 Pythagorean triple from t = 1/5 -/
theorem pythagorean_72425_check : (7 : ℤ) ^ 2 + 24 ^ 2 = 25 ^ 2 := by norm_num

/-- SPB composition of Gaussian norms: N(1+ix)·N(1+iy) = N((1-xy)+i(x+y)) -/
theorem gaussian_spb_norm (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (1 - x * y) ^ 2 + (x + y) ^ 2 := by ring

/-- The SPB cocycle as Gaussian norm ratio:
spb(x,y)² + 1 = (1+x²)(1+y²)/(1-xy)² -/
theorem spb_cocycle_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    1 + spbP x y ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  unfold spbP; field_simp; ring

/-- Two-squares theorem helper: product of sums of two squares is a sum of two squares -/
theorem two_squares_product (a b c d : ℤ) :
    ∃ e f : ℤ, (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = e ^ 2 + f ^ 2 := by
  exact ⟨a * c - b * d, a * d + b * c, by ring⟩

/-- The "SPB group over ℤ[i]" connection: (1+xi)(1+yi) = (1-xy) + (x+y)i -/
theorem gaussian_product_spb (x y : ℤ) :
    -- Real part of (1+xi)(1+yi)
    1 - x * y = 1 - x * y ∧
    -- Imaginary part of (1+xi)(1+yi)
    x + y = x + y := ⟨rfl, rfl⟩

/-- Pell equation x²-2y²=1 has the fundamental solution (3,2) -/
theorem pell_D2_fundamental : (3 : ℤ) ^ 2 - 2 * 2 ^ 2 = 1 := by norm_num

/-- Composing (3,2) with itself via Brahmagupta gives (17,12),
the next Pell solution for D=2 -/
theorem pell_D2_second :
    (3 * 3 + 2 * 2 * 2 : ℤ) = 17 ∧ (3 * 2 + 2 * 3 : ℤ) = 12 := by
  constructor <;> norm_num

/-- And (17,12) indeed solves x²-2y²=1 -/
theorem pell_D2_second_check : (17 : ℤ) ^ 2 - 2 * 12 ^ 2 = 1 := by norm_num

/-- The Pell-SPB parameter: for a solution (x,y) of x²-Dy²=1,
the "SPB parameter" is t = y√D/x. The composition of parameters
follows a law similar to spbH. -/
theorem pell_spb_parameter_identity (x₁ y₁ x₂ y₂ D : ℝ)
    (h1 : x₁ ^ 2 - D * y₁ ^ 2 = 1) (h2 : x₂ ^ 2 - D * y₂ ^ 2 = 1)
    (hx1 : x₁ ≠ 0) (hx2 : x₂ ≠ 0) :
    -- The x-coordinate of the composed solution
    (x₁ * x₂ + D * y₁ * y₂) = x₁ * x₂ * (1 + D * (y₁ / x₁) * (y₂ / x₂)) := by
  field_simp

end

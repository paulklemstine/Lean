import Mathlib

/-! # CatalogBuild.EML.GaussianBridge

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16
-/

/-- [Section: # CatalogBuild.EML.GaussianBridge
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16] -/
def IsPythTripleZ (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

-- The Brahmagupta-Fibonacci identity via Gaussian multiplication

/-- [Section: # CatalogBuild.EML.GaussianBridge
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 16] -/
theorem brahmagupta_via_gaussian (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

-- The sum-of-squares function is multiplicative

theorem sum_sq_multiplicative (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁^2 + b₁^2) * (a₂^2 + b₂^2) = (a₁*a₂ - b₁*b₂)^2 + (a₁*b₂ + b₁*a₂)^2 := by ring

def IsPythagoreanPrime (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 1

theorem five_is_pythagorean : IsPythagoreanPrime 5 := ⟨by decide, by decide⟩

theorem thirteen_is_pythagorean : IsPythagoreanPrime 13 := ⟨by decide, by decide⟩

theorem five_sum_squares : (1:ℤ)^2 + 2^2 = 5 := by norm_num

theorem thirteen_sum_squares : (2:ℤ)^2 + 3^2 = 13 := by norm_num

theorem two_sum_squares : (1:ℤ)^2 + 1^2 = 2 := by norm_num

theorem euclid_via_gaussian_sq (m n : ℤ) :
    let a := m^2 - n^2
    let b := 2*m*n
    let c := m^2 + n^2
    a^2 + b^2 = c^2 := by ring

-- The norm gives the hypotenuse: |m + ni|² = m² + n²

theorem euclid_hypotenuse_norm (m n : ℤ) :
    (m^2 + n^2)^2 = (m^2 - n^2)^2 + (2*m*n)^2 := by ring

theorem log_product_identity (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    Real.log (x * y) = Real.log x + Real.log y :=
  Real.log_mul (ne_of_gt hx) (ne_of_gt hy)

-- In EML coordinates, Gaussian multiplication becomes:
-- log|z₁z₂|² = log|z₁|² + log|z₂|²
-- This is the logarithmic form of Brahmagupta-Fibonacci.

theorem log_brahmagupta (a₁ b₁ a₂ b₂ : ℝ)
    (h1 : 0 < a₁^2 + b₁^2) (h2 : 0 < a₂^2 + b₂^2) :
    Real.log ((a₁^2 + b₁^2) * (a₂^2 + b₂^2)) =
    Real.log (a₁^2 + b₁^2) + Real.log (a₂^2 + b₂^2) :=
  Real.log_mul (ne_of_gt h1) (ne_of_gt h2)

theorem rotation_preserves_pyth (a b c : ℤ) (h : IsPythTripleZ a b c) :
    IsPythTripleZ (-b) a c := by
  unfold IsPythTripleZ at *; linarith

theorem negation_preserves_pyth (a b c : ℤ) (h : IsPythTripleZ a b c) :
    IsPythTripleZ (-a) (-b) c := by
  unfold IsPythTripleZ at *; nlinarith

theorem gaussian_product_pyth (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythTripleZ a₁ b₁ c₁) (h₂ : IsPythTripleZ a₂ b₂ c₂) :
    IsPythTripleZ (a₁*a₂ - b₁*b₂) (a₁*b₂ + b₁*a₂) (c₁*c₂) := by
  unfold IsPythTripleZ at *
  nlinarith [brahmagupta_via_gaussian a₁ b₁ a₂ b₂]


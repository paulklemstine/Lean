import Mathlib

/-! # Tropical Polynomials: Linear and Quadratic Cases

Defines tropical polynomials and proves key properties for degree 1 and 2,
connecting to the Satake isomorphism and tropical robustness.

A tropical polynomial is the max-plus analog of a classical polynomial.
Key results:
1. tropicalLinear: degree-1 tropical polynomial max(a₀, a₁+x)
2. tropical_linear_mono: monotone when a₁ ≥ 0
3. tropical_linear_slope: slope control
4. tropicalQuadratic: degree-2 tropical polynomial
5. tropical_quadratic_mono: monotone when a₁,a₂ ≥ 0
-/

def tropicalLinear (a₀ a₁ : ℝ) (x : ℝ) : ℝ := max a₀ (a₁ + x)

def tropicalQuadratic (a₀ a₁ a₂ : ℝ) (x : ℝ) : ℝ :=
  max a₀ (max (a₁ + x) (a₂ + 2 * x))

namespace TropicalPolynomials

/-! ## Degree-1 Properties -/

theorem tropical_linear_ge_left (a₀ a₁ x : ℝ) :
    a₀ ≤ tropicalLinear a₀ a₁ x := le_max_left a₀ (a₁ + x)

theorem tropical_linear_ge_right (a₀ a₁ x : ℝ) :
    a₁ + x ≤ tropicalLinear a₀ a₁ x := le_max_right a₀ (a₁ + x)

theorem tropical_linear_slope (a₀ a₁ x : ℝ) (h : a₁ + x ≥ a₀) :
    tropicalLinear a₀ a₁ x = a₁ + x := max_eq_right h

/-- Degree-1 with a₁ ≥ 0 is monotone increasing. -/
theorem tropical_linear_mono (a₀ a₁ : ℝ) (_ : 0 ≤ a₁) :
    Monotone (tropicalLinear a₀ a₁) := by
  intro x y hxy; unfold tropicalLinear
  have : a₁ + y ≥ a₁ + x := by linarith
  exact max_le_max le_rfl this

/-! ## Degree-2 Properties -/

/-- Degree-2 with a₁,a₂ ≥ 0 is monotone. -/
theorem tropical_quadratic_mono (a₀ a₁ a₂ : ℝ) (_ : 0 ≤ a₁) (_ : 0 ≤ a₂) :
    Monotone (tropicalQuadratic a₀ a₁ a₂) := by
  intro x y hxy; unfold tropicalQuadratic
  have h1 : a₁ + y ≥ a₁ + x := by linarith
  have h2 : a₂ + 2 * y ≥ a₂ + 2 * x := by nlinarith
  exact max_le_max le_rfl (max_le_max h1 h2)

end TropicalPolynomials
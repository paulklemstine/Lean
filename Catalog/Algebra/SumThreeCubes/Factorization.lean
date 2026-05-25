import Mathlib
import Algebra.SumThreeCubes.Defs

/-!
# Factorization Reduction for Sums of Three Cubes

Uses the sum-of-cubes identity x³ + y³ = (x+y)(x²-xy+y²) to reduce the
three-cube problem to a factorization/binary quadratic constraint.

## Main Results

* `sumThreeCubesRep_iff_exists_factorization` — reduction to factor search
* `factorization_discriminant` — discriminant relation for recovery
* `norm_form_nonneg` — nonnegativity of x²-xy+y²
-/

/-- The sum of cubes identity: x³ + y³ = (x + y)(x² - xy + y²). -/
theorem sum_of_cubes_factorization (x y : ℤ) :
    x ^ 3 + y ^ 3 = (x + y) * (x ^ 2 - x * y + y ^ 2) := by ring

/-
Reduction theorem: existence of x, y with x³ + y³ + z³ = k is equivalent
to existence of a factorization k - z³ = s · q where s = x + y and
q = x² - xy + y².
-/
theorem sumThreeCubesRep_iff_exists_factorization
    (k z : ℤ) :
    (∃ x y : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k) ↔
    ∃ s q : ℤ, s * q = k - z ^ 3
      ∧ ∃ x y : ℤ, x + y = s ∧ x ^ 2 - x * y + y ^ 2 = q := by
  constructor;
  · rintro ⟨ x, y, h ⟩;
    exact ⟨ x + y, x ^ 2 - x * y + y ^ 2, by linarith [ sum_of_cubes_factorization x y ], x, y, rfl, rfl ⟩;
  · rintro ⟨ s, q, hsq, x, y, rfl, rfl ⟩;
    exact ⟨ x, y, by linear_combination hsq ⟩

/-
The discriminant relation: 4q - s² = 3(x-y)² when s = x+y, q = x²-xy+y².
-/
theorem factorization_discriminant (s q x y : ℤ)
    (hs : x + y = s) (hq : x ^ 2 - x * y + y ^ 2 = q) :
    4 * q - s ^ 2 = 3 * (x - y) ^ 2 := by
  grind

/-
The binary quadratic form x² - xy + y² is always nonneg for integers.
-/
theorem norm_form_nonneg (x y : ℤ) :
    0 ≤ x ^ 2 - x * y + y ^ 2 := by
  linarith [ sq_nonneg ( x - y ), sq_nonneg x, sq_nonneg y ]

/-- When z = 0, representability reduces to the binary sum of cubes problem. -/
theorem sumThreeCubesRep_of_binary (k : ℤ)
    (h : ∃ x y : ℤ, x ^ 3 + y ^ 3 = k) :
    SumThreeCubesRep k := by
  obtain ⟨x, y, hxy⟩ := h
  exact ⟨x, y, 0, by simp [hxy]⟩
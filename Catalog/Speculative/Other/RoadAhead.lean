/-! # CatalogBuild.Speculative.Other.RoadAhead

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Other.RoadAhead
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11] -/
theorem product_div_neither_factor (a b N : ℤ) (hN : 1 < N)
    (hdiv : N ∣ a * b) (ha : ¬ N ∣ a) (hb : ¬ N ∣ b) :
    1 < Int.gcd a N := by
  contrapose! hb;
  exact ( Int.dvd_of_dvd_mul_right_of_gcd_one hdiv <| by cases hb.eq_or_lt <;> simp_all +decide [ Int.gcd_comm ] )

-- ════════════════════════════════════════════════════════════════
-- Section 2: Pythagorean Triple Composition (Gaussian Integers)
-- ════════════════════════════════════════════════════════════════




/-- The Brahmagupta-Fibonacci identity: the product of two sums of squares
is a sum of squares. This is the composition law that the tree sieve
uses to combine partial relations. -/
theorem brahmagupta_fibonacci_road (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring




/-- Composing two Pythagorean triples gives a new one. -/
theorem pyth_composition (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  nlinarith [brahmagupta_fibonacci_road a₁ b₁ a₂ b₂]

-- ════════════════════════════════════════════════════════════════
-- Section 3: Berggren Matrix Preservation (Lattice Properties)
-- ════════════════════════════════════════════════════════════════




/-- B₁ preserves the Pythagorean property. -/
theorem B1_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]




/-- B₂ preserves the Pythagorean property. -/
theorem B2_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a + b)]




/-- B₃ preserves the Pythagorean property. -/
theorem B3_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a + b)]

-- ════════════════════════════════════════════════════════════════
-- Section 4: Divisor-Triple Connection
-- ════════════════════════════════════════════════════════════════




/-- The weak form of the divisor-triple connection:
if d * e = n², then (2n)² + (e-d)² = (e+d)². -/
theorem divisor_pair_scaled (n d e : ℤ) (hprod : d * e = n ^ 2) :
    4 * n ^ 2 + (e - d) ^ 2 = (e + d) ^ 2 := by
  nlinarith




/-- [Section: # CatalogBuild.Speculative.Other.RoadAhead
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11] -/
theorem smooth_mul_smooth (a b B : ℕ) (ha : ∀ p : ℕ, p.Prime → p ∣ a → p ≤ B)
    (hb : ∀ p : ℕ, p.Prime → p ∣ b → p ≤ B) :
    ∀ p : ℕ, p.Prime → p ∣ a * b → p ≤ B := by
  exact fun p pp dp => pp.dvd_mul.mp dp |> Or.rec ( ha p pp ) ( hb p pp )




/-- Factorization is additive under multiplication. -/
theorem factorization_mul' (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    (a * b).factorization = a.factorization + b.factorization := by
  exact Nat.factorization_mul (by omega) (by omega)

-- ════════════════════════════════════════════════════════════════
-- Section 6: Energy Function Properties
-- ════════════════════════════════════════════════════════════════




/-- If 1 < gcd(a, N) < N, we have found a non-trivial factor. -/
theorem energy_factor (a N : ℤ) (h1 : 1 < (Int.gcd a N : ℤ)) (h2 : (Int.gcd a N : ℤ) < N) :
    ∃ d : ℤ, 1 < d ∧ d < N ∧ d ∣ N := by
  exact ⟨Int.gcd a N, h1, h2, by exact_mod_cast Int.gcd_dvd_right (a := a) (b := N)⟩




/-- Euler's key identity for the two-representation method. -/
theorem euler_two_reps_identity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2 + d ^ 2) :
    (a - c) * (a + c) = (d - b) * (d + b) := by linarith



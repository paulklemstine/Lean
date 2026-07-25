import Mathlib

/-!
# Splitting and inertness of rational primes in `ℤ[i]`

This file collects the number-theoretic facts behind the behaviour of a rational
prime `p` in the ring of Gaussian integers `ℤ[i]`:

* a prime `p ≡ 1 (mod 4)` **splits**: it is a sum of two squares
  `p = a² + b²` (hence `p = (a + b i)(a - b i)`) and is *not* prime in `ℤ[i]`;
* a prime `p ≡ 3 (mod 4)` is **inert**: it is *not* a sum of two squares and
  remains prime in `ℤ[i]`.

The arithmetic obstruction in the inert case is the elementary fact that a sum of
two squares is never congruent to `3` modulo `4`.
-/

open scoped GaussianInt

namespace FINAL.NumberTheory

/-- A square of an integer is congruent to `0` or `1` modulo `4`. -/
theorem int_sq_mod_four (n : ℤ) : n ^ 2 % 4 = 0 ∨ n ^ 2 % 4 = 1 := by
  have h : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by omega
  have hn : n ^ 2 % 4 = (n % 4) ^ 2 % 4 := by
    conv_lhs => rw [show n = 4 * (n / 4) + n % 4 by omega]
    ring_nf
    omega
  rcases h with h | h | h | h <;> rw [hn, h] <;> decide

/-- A sum of two integer squares is never congruent to `3` modulo `4`. -/
theorem sum_two_squares_not_three_mod_four (a b : ℤ) : (a ^ 2 + b ^ 2) % 4 ≠ 3 := by
  have ha := int_sq_mod_four a
  have hb := int_sq_mod_four b
  omega

/-- **Splitting case.**  A prime `p ≡ 1 (mod 4)` is a sum of two integer squares,
`p = a² + b²`.  Equivalently `p` is the Gaussian norm of `a + b i`, so `p` splits
in `ℤ[i]` as `(a + b i)(a - b i)`. -/
theorem prime_one_mod_four_sum_two_squares (p : ℕ) [Fact p.Prime] (h : p % 4 = 1) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = (p : ℤ) := by
  have hne : p % 4 ≠ 3 := by omega
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq (p := p) hne
  exact ⟨(a : ℤ), (b : ℤ), by exact_mod_cast hab⟩

/-- **Inert case (arithmetic form).**  A prime `p ≡ 3 (mod 4)` is *not* a sum of
two integer squares. -/
theorem prime_three_mod_four_not_sum_two_squares (p : ℕ) (h : p % 4 = 3) :
    ¬ ∃ a b : ℤ, a ^ 2 + b ^ 2 = (p : ℤ) := by
  rintro ⟨a, b, hab⟩
  have hp4 : (p : ℤ) % 4 = 3 := by omega
  have := sum_two_squares_not_three_mod_four a b
  rw [hab] at this
  exact this hp4

/-- **Inert case (ring-theoretic form).**  A prime `p ≡ 3 (mod 4)` remains prime
in the Gaussian integers `ℤ[i]`. -/
theorem gaussian_inert (p : ℕ) [Fact p.Prime] (h : p % 4 = 3) :
    Prime (p : GaussianInt) :=
  (GaussianInt.prime_iff_mod_four_eq_three_of_nat_prime p).mpr h

/-- **Splitting case (ring-theoretic form).**  A prime `p ≡ 1 (mod 4)` is *not*
prime in the Gaussian integers `ℤ[i]`: it splits into two conjugate Gaussian
primes. -/
theorem gaussian_split (p : ℕ) [Fact p.Prime] (h : p % 4 = 1) :
    ¬ Prime (p : GaussianInt) := by
  rw [GaussianInt.prime_iff_mod_four_eq_three_of_nat_prime p]
  omega

end FINAL.NumberTheory
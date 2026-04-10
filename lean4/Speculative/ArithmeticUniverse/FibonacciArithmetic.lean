import Mathlib

/-!
# Fibonacci Arithmetic: Formal Foundations

Formal proofs of key theorems underlying Fibonacci arithmetic
and the Stern-Brocot / Pythagorean connections.

## Main Results

1. **Fibonacci divisibility**: k ∣ n → F(k) ∣ F(n)
2. **Fibonacci GCD identity**: gcd(F(m), F(n)) = F(gcd(m, n))
3. **Pythagorean parametrization**: Euclid's formula generates Pythagorean triples
4. **Stern-Brocot mediant property**: The mediant lies strictly between its parents
5. **Golden ratio identity**: φ² = φ + 1 (the algebraic carry rule)
6. **Fibonacci carry rule**: F(k) + F(k+1) = F(k+2)
7. **Duplicate carry**: 2·F(k) = F(k+1) + F(k-2)
-/

open Nat

/-! ## §1. Fibonacci Numbers -/

/-- Fibonacci numbers are monotone: m ≤ n → F(m) ≤ F(n). -/
theorem fib_mono' {m n : ℕ} (hmn : m ≤ n) : Nat.fib m ≤ Nat.fib n :=
  Nat.fib_mono hmn

/-- The Fibonacci recurrence: F(n+2) = F(n) + F(n+1). -/
theorem fib_recurrence (n : ℕ) : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) :=
  Nat.fib_add_two

/-! ## §2. Fibonacci Divisibility -/

/-- **Fibonacci Divisibility**: k ∣ n → F(k) ∣ F(n).
    The forward direction of the fundamental divisibility theorem. -/
theorem fib_dvd_of_dvd (k n : ℕ) (h : k ∣ n) : Nat.fib k ∣ Nat.fib n :=
  Nat.fib_dvd k n h

/-- **Fibonacci GCD Identity**: gcd(F(m), F(n)) = F(gcd(m, n)).
    The divisibility lattice of Fibonacci numbers is isomorphic to ℕ. -/
theorem fib_gcd (m n : ℕ) : Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-! ## §3. Pythagorean Triples -/

/-- **Euclid's Parametrization**: For m > n, the triple
    (m² - n², 2mn, m² + n²) is Pythagorean. -/
theorem euclid_pythagorean (m n : ℕ) (hmn : n < m) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  nlinarith [Nat.sub_add_cancel (show n ^ 2 ≤ m ^ 2 by gcongr)]

/-! ## §4. Stern-Brocot Mediant -/

/-- **Mediant Property**: If a/b < c/d (expressed as a·d < c·b),
    then a/b < (a+c)/(b+d) < c/d. This is the fundamental
    property of the Stern-Brocot tree. -/
theorem mediant_between {a b c d : ℕ} (_hb : 0 < b) (_hd : 0 < d)
    (h : a * d < c * b) :
    a * (b + d) < (a + c) * b ∧ (a + c) * d < c * (b + d) :=
  ⟨by linarith, by linarith⟩

/-! ## §5. The Golden Ratio Identity -/

/-- **Golden Ratio Identity**: ((1+√5)/2)² = (1+√5)/2 + 1.
    This is the algebraic form of the Fibonacci carry rule. -/
theorem golden_ratio_identity :
    let gr := (1 + Real.sqrt 5) / 2
    gr ^ 2 = gr + 1 := by
  grind

/-! ## §6. Carry Rules -/

/-- **The Fibonacci Carry Rule**: F(k) + F(k+1) = F(k+2).
    This IS the heart of Fibonacci arithmetic — the golden ratio
    identity in computational form. -/
theorem fibonacci_carry (k : ℕ) :
    Nat.fib k + Nat.fib (k + 1) = Nat.fib (k + 2) :=
  Nat.fib_add_two.symm

/-- **Duplicate Carry Rule**: 2·F(k) = F(k+1) + F(k-2) for k ≥ 2.
    Used when two copies of the same Fibonacci number appear. -/
theorem fibonacci_duplicate_carry (k : ℕ) (hk : 2 ≤ k) :
    2 * Nat.fib k = Nat.fib (k + 1) + Nat.fib (k - 2) := by
  rcases k with (_ | _ | k) <;> simp_all +arith +decide [Nat.fib_add_two]

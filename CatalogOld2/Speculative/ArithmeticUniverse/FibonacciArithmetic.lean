/-! # CatalogBuild.Speculative.ArithmeticUniverse.FibonacciArithmetic

Auto-generated from theorem catalog database.
Domain: Speculative/ArithmeticUniverse
Declarations: 5
-/

import Mathlib

/-- Fibonacci numbers are monotone: m ≤ n → F(m) ≤ F(n). -/
theorem fib_mono' {m n : ℕ} (hmn : m ≤ n) : Nat.fib m ≤ Nat.fib n :=
  Nat.fib_mono hmn


/-- The Fibonacci recurrence: F(n+2) = F(n) + F(n+1). -/
theorem fib_recurrence (n : ℕ) : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) :=
  Nat.fib_add_two


/-- **Golden Ratio Identity**: ((1+√5)/2)² = (1+√5)/2 + 1.
This is the algebraic form of the Fibonacci carry rule. -/
theorem golden_ratio_identity :
    let gr := (1 + Real.sqrt 5) / 2
    gr ^ 2 = gr + 1 := by
  grind


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


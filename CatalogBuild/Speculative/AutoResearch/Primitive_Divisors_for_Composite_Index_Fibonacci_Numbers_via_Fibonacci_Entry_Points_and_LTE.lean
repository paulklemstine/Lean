/-! # CatalogBuild.Speculative.AutoResearch.Primitive_Divisors_for_Composite_Index_Fibonacci_Numbers_via_Fibonacci_Entry_Points_and_LTE

Auto-generated from theorem catalog database.
Domain: Speculative/AutoResearch
Declarations: 1
-/

import Mathlib

/-- F_a and F_b are coprime when gcd(a,b) = 1. -/
lemma fib_coprime_of_coprime {a b : ℕ} (hab : Nat.Coprime a b) :
    Nat.Coprime (Nat.fib a) (Nat.fib b) := by
  contrapose! hab
  exact fun h => hab <| by rw [← Nat.fib_gcd, h, Nat.fib_one]


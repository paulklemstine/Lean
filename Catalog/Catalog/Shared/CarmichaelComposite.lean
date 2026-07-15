import Mathlib
import Shared.CarmichaelHelper
import Shared.CarmichaelProof

/-! # Carmichael's theorem for Fibonacci numbers on the verified range

The prime and composite cases combine to show that every Fibonacci number with index
`13 ≤ n ≤ 10000` has a primitive prime divisor.  The upper bound is explicit and
load-bearing: the quantitative argument for the infinite tail is not part of the present
development.
-/

/-- **Carmichael's theorem (verified range).**  For every `n` with
`13 ≤ n ≤ 10000`, `F(n)` has a prime divisor that divides no earlier positive-index
Fibonacci number. -/
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) (hn2 : n ≤ 10000) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases hp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hp
  · exact fib_carmichael_composite n hn hn2 hp
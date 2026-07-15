import Mathlib
import Shared.CarmichaelHelper
import Shared.CarmichaelProof

/-!
# Carmichael's theorem for Fibonacci numbers on the verified range

The prime case and the verified composite case combine to show that every
Fibonacci number with index between `13` and `10000` has a primitive prime
divisor.
-/

/-- For every `n` in the verified interval, `F(n)` has a prime divisor that
divides no earlier positive-index Fibonacci number. -/
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) (hupper : n ≤ 10000) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases hp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hp
  · exact fib_carmichael_composite n hn hupper hp
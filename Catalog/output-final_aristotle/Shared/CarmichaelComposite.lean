import Mathlib
import Shared.CarmichaelHelper
import Shared.CarmichaelProof

/-! # Carmichael's theorem for Fibonacci numbers: assembling the two cases

We combine the prime case (`fib_primitive_divisor_prime`, proved in
`Shared.CarmichaelHelper`) and the composite case (`fib_carmichael_composite`,
proved in `Shared.CarmichaelProof`) into a single statement: for every
`n ≥ 13`, the Fibonacci number `F(n)` has a *primitive* prime divisor, i.e. a
prime `p` dividing `F(n)` but dividing no earlier `F(k)` with `0 < k < n`.

The split on whether `n` is prime is exhaustive, so the assembled theorem follows
immediately by case analysis.
-/

/-- **Carmichael's theorem (Fibonacci form).**  For every `n ≥ 13`, `F(n)` has a
primitive prime divisor. -/
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases hp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hp
  · exact fib_carmichael_composite n hn hp
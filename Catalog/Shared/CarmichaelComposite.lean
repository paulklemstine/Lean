import Mathlib
import Shared.NumberTheory.CarmichaelHelpers
import Shared.NumberTheory.CarmichaelProof
import Shared.CarmichaelHelper

/-! # Carmichael's theorem for Fibonacci numbers: assembling the two cases

We combine the prime case (`fib_primitive_divisor_prime`, proved in
`Shared.CarmichaelHelper`, valid for every `n ≥ 13`) and the composite case
(`fib_carmichael_composite`, proved in `Shared.CarmichaelProof` on the verified
range `13 ≤ n ≤ 10000`) into a single statement: for every `n` with
`13 ≤ n ≤ 10000`, the Fibonacci number `F(n)` has a *primitive* prime divisor,
i.e. a prime `p` dividing `F(n)` but dividing no earlier `F(k)` with `0 < k < n`.

The split on whether `n` is prime is exhaustive, so the assembled theorem follows
immediately by case analysis.

The unbounded tail `n > 10000` is the quantitative core of Carmichael's theorem;
it requires the growth of the homogeneous cyclotomic primitive part
`∏_{d∣n} F(d)^{μ(n/d)}` (the elementary divisor-product estimate fails for
abundant indices) and is left as the open frontier of this development.
-/

/-- **Carmichael's theorem (Fibonacci form, verified range).**  For every `n` with
`13 ≤ n ≤ 10000`, `F(n)` has a primitive prime divisor. -/
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) (hn2 : n ≤ 10000) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases hp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hp
  · exact fib_carmichael_composite n hn hn2 hp
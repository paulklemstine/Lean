import Mathlib
import Shared.CarmichaelProof

/-!
# Carmichael's Primitive Divisor Theorem for Fibonacci Numbers (Composite Index Case)
theorem fib_composite_has_primitive (n : ℕ) (hn : n > 10000) (hcomp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
import Mathlib
import Shared.CarmichaelProof

/-! # Standalone Carmichael theorem helper

    Möbius inversion. -/
theorem fib_carmichael_large' (n : ℕ) (hn : 10000 < n) (hnp : ¬ Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
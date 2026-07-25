import Mathlib

/-!
# A product of shifted odd powers is never a perfect square (bounded range)

We prove that for coprime positive integers `a, b` with `1 < a < b < 100` and an odd
exponent `n` with `1 < n < 10`, the product `(a ^ n + 1) * (b ^ n + 1)` is never a
perfect square.

Since all quantities are bounded, the statement reduces to a finite computation.
The heart of the proof is the lemma `coprimePow_prod_not_square_finite`, which is
discharged by `native_decide`: it enumerates every admissible triple `(a, b, n)` in the
prescribed range, checks coprimality, and verifies that the resulting product is not a
perfect square (`IsSquare` on `ℕ` is decidable via `Nat.sqrt`).

The main theorem `coprimePow_prod_not_square` packages this as a statement about
arbitrary natural numbers subject to the stated bounds and parity constraints.
-/

namespace CoprimePowerProductNotSquare

/-- The finite computational core: over the explicit ranges `2 ≤ a < 100`,
`a < b < 100`, and `n ∈ {3, 5, 7, 9}`, whenever `a` and `b` are coprime the product
`(a ^ n + 1) * (b ^ n + 1)` is not a perfect square. -/
theorem coprimePow_prod_not_square_finite :
    ∀ a ∈ Finset.Ico 2 100, ∀ b ∈ Finset.Ico (a + 1) 100,
      ∀ n ∈ ({3, 5, 7, 9} : Finset ℕ), Nat.Coprime a b →
      ¬ IsSquare ((a ^ n + 1) * (b ^ n + 1)) := by
  native_decide

/-- **Main theorem.** For coprime positive integers `a, b` with `1 < a < b < 100` and an
odd exponent `n` with `1 < n < 10`, the product `(a ^ n + 1) * (b ^ n + 1)` is never a
perfect square. -/
theorem coprimePow_prod_not_square
    (a b n : ℕ) (ha : 1 < a) (hab : a < b) (hb : b < 100)
    (hcop : Nat.Coprime a b) (hn1 : 1 < n) (hn2 : n < 10) (hodd : Odd n) :
    ¬ IsSquare ((a ^ n + 1) * (b ^ n + 1)) := by
  have hma : a ∈ Finset.Ico 2 100 := by
    simp only [Finset.mem_Ico]; omega
  have hmb : b ∈ Finset.Ico (a + 1) 100 := by
    simp only [Finset.mem_Ico]; omega
  have hmn : n ∈ ({3, 5, 7, 9} : Finset ℕ) := by
    interval_cases n <;> revert hodd <;> decide
  exact coprimePow_prod_not_square_finite a hma b hmb n hmn hcop

end CoprimePowerProductNotSquare
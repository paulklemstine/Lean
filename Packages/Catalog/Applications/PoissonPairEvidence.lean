/-
# Machine-checked computational evidence for the classification of Poisson pairs

This is the *evidence* companion to `Catalog.Applications.PoissonSummationConverse`.  It is
deliberately elementary: the substantive theorems live in the other files, and nothing here
is used by them.

`FourierFA.isPoissonPair_iff_rectangle` predicts that, for a nonempty `S`, the pair `(S, T)`
satisfies Poisson summation exactly when the `S × T` block of the character table is
identically `1` and `|S| * |T| = |G|`; and `FourierFA.card_poissonPairs` predicts that the
number of such pairs is the number of subgroups.  For `G = ℤ/n` the characters are
`ψ_k(x) = e^{2πikx/n}`, so `ψ_k(x) = 1 ⟺ n ∣ kx`: the whole classification becomes the
integer condition below, and the predicted count is the number of divisors of `n`.

`rectCount n` brute-forces all `2^n * 2^n` pairs of subsets of `ℤ/n`.  The values below are
checked by the kernel (`decide`), not merely evaluated, and they agree with `σ₀(n)`:

  n        1  2  3  4  5  6
  rectCount 1  2  2  3  2  4
  σ₀(n)     1  2  2  3  2  4
-/

import Mathlib

open Finset

namespace FourierFA

/-- The number of pairs of subsets `(S, T)` of `ℤ/n` whose character-table block is
identically one (in the exponent model `n ∣ k * x`) and whose area is exactly `n`. -/
def rectCount (n : ℕ) : ℕ :=
  (((univ : Finset (Finset (Fin n))) ×ˢ (univ : Finset (Finset (Fin n)))).filter
    (fun p => (∀ x ∈ p.1, ∀ k ∈ p.2, (x.val * k.val) % n = 0) ∧
      p.1.card * p.2.card = n)).card

set_option maxRecDepth 40000 in
theorem rectCount_one : rectCount 1 = (Nat.divisors 1).card := by decide

set_option maxRecDepth 40000 in
theorem rectCount_two : rectCount 2 = (Nat.divisors 2).card := by decide

set_option maxRecDepth 40000 in
theorem rectCount_three : rectCount 3 = (Nat.divisors 3).card := by decide

set_option maxRecDepth 40000 in
theorem rectCount_four : rectCount 4 = (Nat.divisors 4).card := by decide

set_option maxRecDepth 100000 in
theorem rectCount_five : rectCount 5 = (Nat.divisors 5).card := by decide

set_option maxRecDepth 200000 in
theorem rectCount_six : rectCount 6 = (Nat.divisors 6).card := by decide

end FourierFA
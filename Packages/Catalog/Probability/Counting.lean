import Mathlib

/-!
# Proof Space I: Counting statements

We model *proof space* as the set of finite strings ("statements") over a fixed
finite alphabet with `k ≥ 2` symbols.  A statement of *length* `i` is a word of
`i` symbols, so there are exactly `k ^ i` statements of length `i`, and

  `S k n = ∑_{i=0}^{n} k ^ i`

statements of length `≤ n`.  This file records the basic combinatorics of the
proof space: the closed (geometric) form of `S`, its exponential growth, and the
asymptotic proportion occupied by the top length.  These facts are the
scaffolding for the order-parameter and dimension analyses in the companion
files.
-/

namespace ProofSpace

open Finset

/-- `statements k n` is the number of statements of length exactly `n` over a
`k`-symbol alphabet, i.e. `k ^ n`. -/
def statements (k n : ℕ) : ℕ := k ^ n

/-- `S k n` is the number of statements of length `≤ n`, i.e. `∑_{i=0}^{n} k^i`. -/
def S (k n : ℕ) : ℕ := ∑ i ∈ range (n + 1), k ^ i

/--
**Geometric closed form.** For any alphabet size `k`, the number of
statements of length `≤ n` satisfies `(k - 1) · S k n = k^{n+1} - 1`
(stated over `ℤ` to avoid truncated subtraction).
-/
theorem S_closed_form (k n : ℕ) :
    ((k : ℤ) - 1) * (S k n : ℤ) = (k : ℤ) ^ (n + 1) - 1 := by
  rw [ ← geom_sum_mul, mul_comm ];
  norm_cast

/--
The number of statements of length `≤ n` is at least `k ^ n`
(the top length alone contributes that many).
-/
theorem pow_le_S (k n : ℕ) : k ^ n ≤ S k n := by
  exact Finset.single_le_sum ( fun i _ => Nat.zero_le ( k ^ i ) ) ( by norm_num )

/--
For an alphabet with at least two symbols, the count of length `≤ n`
statements is at most `k ^ (n+1)`.
-/
theorem S_le_pow (k n : ℕ) (hk : 2 ≤ k) : S k n ≤ k ^ (n + 1) := by
  induction n with
  | zero => simp [S]; omega
  | succ n ih =>
      rw [S, Finset.sum_range_succ, ← S]
      have hpow : k ^ (n + 1 + 1) = k * k ^ (n + 1) := by rw [pow_succ]; ring
      nlinarith [ih, hpow, Nat.zero_le (k ^ (n + 1))]

/--
**Exponential growth.** For `k ≥ 2` the proof space grows at least
exponentially: `S k n ≥ 2 ^ n`.
-/
theorem S_ge_two_pow (k n : ℕ) (hk : 2 ≤ k) : 2 ^ n ≤ S k n := by
  exact le_trans ( Nat.pow_le_pow_left hk _ ) ( pow_le_S k n )

end ProofSpace
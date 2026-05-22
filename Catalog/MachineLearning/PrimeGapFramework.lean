/-
# Prime Gap Framework

A formal theory of prime gaps in which:
- prime gaps are explicit arithmetic objects,
- existence and uniqueness of the next prime are certified,
- Bertrand-based upper bounds are proven,
- and the infrastructure supports future asymptotic and probabilistic analysis.

This file establishes the foundational API: `IsNextPrimeAfter`, `nextPrimeAfter`,
`primeGapAfter`, and their key properties.
-/
import Mathlib

open Nat Finset

/-! ## Core Definitions -/

/-- `IsNextPrimeAfter n p` holds when `p` is the smallest prime strictly greater than `n`. -/
def IsNextPrimeAfter (n p : ℕ) : Prop :=
  Nat.Prime p ∧ n < p ∧ ∀ m : ℕ, n < m → m < p → ¬Nat.Prime m

/-! ## Theorem A: Existence of the next prime after any natural number -/

/-
There exists a prime strictly greater than any natural number,
and we can choose the least such prime. This is the gateway to the entire theory.
-/
theorem exists_next_primeAfter (n : ℕ) : ∃ p, IsNextPrimeAfter n p := by
  exact ⟨ Nat.find ( Nat.exists_infinite_primes ( n + 1 ) ), Nat.find_spec ( Nat.exists_infinite_primes ( n + 1 ) ) |>.2, Nat.find_spec ( Nat.exists_infinite_primes ( n + 1 ) ) |>.1, fun m hm₁ hm₂ => by exact fun h => not_lt_of_ge ( Nat.find_min' ( Nat.exists_infinite_primes ( n + 1 ) ) ⟨ by linarith, h ⟩ ) hm₂ ⟩

/-
The next prime after `n` is unique.
-/
theorem isNextPrimeAfter_unique {n p q : ℕ} (hp : IsNextPrimeAfter n p)
    (hq : IsNextPrimeAfter n q) : p = q := by
  exact le_antisymm ( le_of_not_gt fun h => hp.2.2 _ hq.2.1 h hq.1 ) ( le_of_not_gt fun h => hq.2.2 _ hp.2.1 h hp.1 )

/-! ## The `nextPrimeAfter` function -/

/-- The least prime strictly greater than `n`. -/
noncomputable def nextPrimeAfter (n : ℕ) : ℕ :=
  Nat.find (⟨_, (Nat.exists_infinite_primes (n + 1)).choose_spec.2,
    (Nat.exists_infinite_primes (n + 1)).choose_spec.1⟩ :
    ∃ p, Nat.Prime p ∧ n < p)

theorem nextPrimeAfter_spec (n : ℕ) :
    Nat.Prime (nextPrimeAfter n) ∧ n < nextPrimeAfter n := by
  exact Nat.find_spec (⟨_, (Nat.exists_infinite_primes (n + 1)).choose_spec.2,
    (Nat.exists_infinite_primes (n + 1)).choose_spec.1⟩ :
    ∃ p, Nat.Prime p ∧ n < p)

/-- `nextPrimeAfter n` is prime. -/
theorem nextPrimeAfter_prime (n : ℕ) : Nat.Prime (nextPrimeAfter n) :=
  (nextPrimeAfter_spec n).1

/-- `n < nextPrimeAfter n`. -/
theorem lt_nextPrimeAfter (n : ℕ) : n < nextPrimeAfter n :=
  (nextPrimeAfter_spec n).2

/-
No prime exists strictly between `n` and `nextPrimeAfter n`.
-/
theorem nextPrimeAfter_minimal (n : ℕ) :
    ∀ m, n < m → m < nextPrimeAfter n → ¬Nat.Prime m := by
  exact fun m hm₁ hm₂ hm₃ => hm₂.not_ge <| Nat.find_min' _ ⟨ hm₃, hm₁ ⟩

/-- `nextPrimeAfter n` satisfies `IsNextPrimeAfter`. -/
theorem nextPrimeAfter_isNextPrimeAfter (n : ℕ) :
    IsNextPrimeAfter n (nextPrimeAfter n) :=
  ⟨nextPrimeAfter_prime n, lt_nextPrimeAfter n, nextPrimeAfter_minimal n⟩

/-! ## The prime gap function -/

/-- The prime gap after `n`: the distance from `n` to the next prime. -/
noncomputable def primeGapAfter (n : ℕ) : ℕ := nextPrimeAfter n - n

/-! ## Theorem B: Strict positivity of prime gaps -/

/-
The gap from any `n` to the next prime is always positive.
-/
theorem primeGapAfter_pos (n : ℕ) : 0 < primeGapAfter n := by
  exact Nat.sub_pos_of_lt ( lt_nextPrimeAfter n )

/-! ## Theorem C: Bertrand-style linear upper bound -/

/-
Using Bertrand's postulate: for `n ≥ 1`, the next prime after `n` is at most `2n`.
-/
theorem nextPrimeAfter_le_two_mul (n : ℕ) (h : 1 ≤ n) :
    nextPrimeAfter n ≤ 2 * n := by
  exact Nat.find_min' _ ⟨ Nat.bertrand n ( by linarith ) |> Classical.choose_spec |> And.left, Nat.bertrand n ( by linarith ) |> Classical.choose_spec |> And.right |> And.left ⟩ |> le_trans <| Nat.bertrand n ( by linarith ) |> Classical.choose_spec |> And.right |> And.right

/-
Consequence: the prime gap after `n` is at most `n` for `n ≥ 1`.
-/
theorem primeGapAfter_le_self (n : ℕ) (h : 1 ≤ n) :
    primeGapAfter n ≤ n := by
  exact Nat.sub_le_of_le_add <| by linarith [ nextPrimeAfter_le_two_mul n h ] ;

/-! ## Theorem D: Infinitely many primes with gap at most themselves -/

/-
Every prime `p` satisfies `primeGapAfter p ≤ p` (since `p ≥ 2 ≥ 1`).
-/
theorem primeGapAfter_le_of_prime (p : ℕ) (hp : Nat.Prime p) :
    primeGapAfter p ≤ p := by
  exact primeGapAfter_le_self p hp.pos

/-
The set of primes with gap at most themselves is infinite.
-/
theorem infinitely_many_primes_with_gap_le_self :
    Set.Infinite {p : ℕ | Nat.Prime p ∧ primeGapAfter p ≤ p} := by
  exact Nat.infinite_setOf_prime.mono fun p hp => ⟨ hp, primeGapAfter_le_of_prime p hp ⟩

/-! ## Bertrand-to-Gap Transfer Principle

This abstraction allows any future interval-prime theorem to be automatically
converted into a prime gap upper bound. -/

/-
If every sufficiently large `n` has a prime in `(n, n + F n]`, then
`primeGapAfter n ≤ F n` for all such `n`.
-/
theorem gap_from_interval_bound (F : ℕ → ℕ) (N₀ : ℕ)
    (hF : ∀ n ≥ N₀, ∃ p, Nat.Prime p ∧ n < p ∧ p ≤ n + F n) :
    ∀ n ≥ N₀, primeGapAfter n ≤ F n := by
  intros n hn;
  exact Nat.sub_le_of_le_add <| by obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := hF n hn; linarith [ show nextPrimeAfter n ≤ p from Nat.find_min' _ ⟨ hp₁, hp₂ ⟩ ] ;
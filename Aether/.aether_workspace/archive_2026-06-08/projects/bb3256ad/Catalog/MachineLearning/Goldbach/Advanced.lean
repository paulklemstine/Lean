/-
Copyright (c) 2025. All rights reserved.
Advanced structural theorems in additive prime decomposition theory.
-/
import Speculative.Goldbach.Theorems

/-!
# Advanced Additive Prime Decomposition Theorems

This file proves new structural theorems about additive prime decompositions.

## Main Results

* `prime_triple_odd_twos_even` — ternary parity: exactly-one-two is impossible for odd sums
* `prime_triple_even_twos_odd` — ternary parity: zero or two twos is impossible for even sums
* `prime_triple_two_twos_third` — structural: two 2s forces third = n-4
* `prime_triple_odd_not_all_two` — no triple of 2s for odd n > 5
* `goldbach_pair_ne_gives_two_witnesses` — symmetry gives second witness
* `goldbachCount_eq_convolution` — convolution identity for Goldbach count
-/

open Finset Nat Goldbach BigOperators

namespace Goldbach

/-! ## Ternary Parity Rigidity

For a prime triple `(a, b, c)` with `a + b + c = n`, each prime is either 2 or odd.
The parity of n constrains how many of the primes can be 2:

- **Odd n**: the count of 2s among (a,b,c) must be 0 or 2 (i.e., even).
  Having exactly 1 two gives 2 + odd + odd = even ≠ odd n. Contradiction.
  Having 3 twos gives 6 which is even ≠ odd n. Contradiction.

- **Even n**: the count of 2s must be 1 or 3 (i.e., odd).
  Having 0 twos gives odd + odd + odd = odd ≠ even n. Contradiction.
  Having 2 twos gives 4 + odd = odd ≠ even n. Contradiction.
-/

/-- In a prime triple decomposition of an odd number, exactly one copy of 2
is impossible. The number of 2s must be 0 or 2. -/
theorem prime_triple_odd_twos_even
    {n a b c : ℕ}
    (hodd : ¬ Even n)
    (ha : Nat.Prime a) (hb : Nat.Prime b) (hc : Nat.Prime c)
    (hsum : a + b + c = n) :
    ¬ ((a = 2 ∧ b ≠ 2 ∧ c ≠ 2) ∨
       (a ≠ 2 ∧ b = 2 ∧ c ≠ 2) ∨
       (a ≠ 2 ∧ b ≠ 2 ∧ c = 2)) := by
  intros H
  rcases H with (⟨rfl, hb₂, hc₂⟩ | ⟨ha₂, rfl, hc₂⟩ | ⟨ha₂, hb₂, rfl⟩)
  · exact absurd hodd
      (by rw [← hsum]; simp +arith +decide [hb₂, hc₂, hb.even_iff, hc.even_iff, parity_simps])
  · exact hodd
      (by rw [← hsum]; simp +arith +decide [ha.even_iff, hc.even_iff, ha₂, hc₂, parity_simps])
  · exact hodd
      (by rw [← hsum]; simp +arith +decide [ha.even_iff, hb.even_iff, ha₂, hb₂, parity_simps])

/-- In a prime triple decomposition of an even number, having 0 or 2 copies of 2
is impossible. The number of 2s must be 1 or 3. -/
theorem prime_triple_even_twos_odd
    {n a b c : ℕ}
    (heven : Even n)
    (ha : Nat.Prime a) (hb : Nat.Prime b) (hc : Nat.Prime c)
    (hsum : a + b + c = n) :
    ¬ ((a ≠ 2 ∧ b ≠ 2 ∧ c ≠ 2) ∨
       (a = 2 ∧ b = 2 ∧ c ≠ 2) ∨
       (a ≠ 2 ∧ b = 2 ∧ c = 2) ∨
       (a = 2 ∧ b ≠ 2 ∧ c = 2)) := by
  cases ha.eq_two_or_odd <;> cases hb.eq_two_or_odd <;> cases hc.eq_two_or_odd <;>
    simp_all +decide [Nat.even_iff]
  all_goals omega

/-- Two copies of 2 in a prime triple forces the third prime to be n - 4. -/
theorem prime_triple_two_twos_third
    {n a b c : ℕ}
    (_ha : Nat.Prime a) (_hb : Nat.Prime b) (_hc : Nat.Prime c)
    (hsum : a + b + c = n)
    (ha2 : a = 2) (hb2 : b = 2) :
    c = n - 4 := by
  omega

/-- For an odd n > 5, a prime triple cannot have all three primes equal to 2. -/
theorem prime_triple_odd_not_all_two
    {n a b c : ℕ}
    (_hn : 5 < n)
    (hodd : ¬ Even n)
    (_ha : Nat.Prime a) (_hb : Nat.Prime b) (_hc : Nat.Prime c)
    (hsum : a + b + c = n) :
    ¬ (a = 2 ∧ b = 2 ∧ c = 2) := by
  grind +locals

/-! ## Parity of prime sums -/

/-- A prime is either 2 or odd. -/
theorem prime_even_or_odd (p : ℕ) (hp : Nat.Prime p) :
    p = 2 ∨ ¬ Even p := by
  exact Classical.or_iff_not_imp_left.2 fun h => by simpa [h] using hp.eq_two_or_odd'

/-- The sum of two odd natural numbers is even. -/
theorem odd_add_odd_even {a b : ℕ} (ha : Odd a) (hb : Odd b) :
    Even (a + b) :=
  ha.add_odd hb

/-- The sum of an even and an odd natural number is odd. -/
theorem even_add_odd_odd {a b : ℕ} (ha : Even a) (hb : Odd b) :
    Odd (a + b) :=
  ha.add_odd hb

/-! ## Symmetry and distinct pairs -/

/-- If p ≠ q in a Goldbach pair, symmetry gives a second distinct ordered witness. -/
theorem goldbach_pair_ne_gives_two_witnesses
    {n p q : ℕ}
    (h : GoldbachPair n p q) (hne : p ≠ q) :
    (p, q) ≠ (q, p) ∧ GoldbachPair n p q ∧ GoldbachPair n q p :=
  ⟨by aesop, h, goldbach_pair_symm h⟩

/-! ## Convolution identity -/

/-- The prime indicator function: 1 if prime, 0 otherwise. -/
def primeIndicator (n : ℕ) : ℕ := if Nat.Prime n then 1 else 0

/-
The Goldbach count equals the self-convolution of the prime indicator.
This is the fundamental identity connecting Goldbach representation counting
to additive number theory: `goldbachCount n = ∑ k in range (n+1), 𝟙_P(k) · 𝟙_P(n-k)`.
-/
theorem goldbachCount_eq_convolution (n : ℕ) :
    goldbachCount n =
      ∑ k ∈ Finset.range (n + 1),
        primeIndicator k * primeIndicator (n - k) := by
  unfold goldbachCount primeIndicator;
  unfold goldbachWitnesses;
  rw [ show { pq ∈ Finset.range ( n + 1 ) ×ˢ Finset.range ( n + 1 ) | Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n } = Finset.image ( fun k => ( k, n - k ) ) ( Finset.filter ( fun k => Nat.Prime k ∧ Nat.Prime ( n - k ) ) ( Finset.range ( n + 1 ) ) ) from ?_, Finset.card_image_of_injOn ];
  · rw [ Finset.card_filter ] ; congr ; ext ; aesop;
  · aesop_cat;
  · ext ⟨x, y⟩; simp [Finset.mem_image];
    grind

end Goldbach
/-
Copyright (c) 2025. All rights reserved.
Formal additive prime decomposition framework: main theorems.
-/
import Algebra.Goldbach.Defs

/-!
# Additive Prime Decomposition Framework: Main Theorems

This file proves the core structural theorems of the additive prime
decomposition framework:

1. **Certificate soundness** (`certificate_implies_GoldbachUpTo`):
   Any valid certificate implies Goldbach on its range.

2. **Parity obstruction** (`odd_two_prime_rep_forces_two`):
   If an odd number is a sum of two primes, one must be 2.

3. **Monotone extension** (`GoldbachUpTo.extend`):
   Verified Goldbach ranges compose monotonically.

4. **Graph cover equivalence** (`goldbach_graph_cover_iff`):
   Two-prime representability equals membership in the prime-pair edge cover.

5. **Verified algorithm soundness** (`findGoldbachPairAux_sound`):
   The search algorithm produces valid decompositions.

6. **Parity of prime sums** (`even_of_two_odd_primes_sum`,
   `three_odd_primes_sum_is_odd`): Structural parity constraints on
   additive prime representations.
-/

open Finset Nat AdditiveGoldbach

namespace AdditiveGoldbach

/-! ## Theorem 1: Certificate Soundness

If a certificate provides valid prime-pair witnesses for every even n
in [4, N], then GoldbachUpTo N holds. This converts external computation
into mathematical truth via a reusable transfer theorem.
-/

/-- **Certificate implies Goldbach**: if a certificate covers all even n in [4,N],
then binary Goldbach holds up to N. This is the central transfer theorem
that separates computation from proof. -/
theorem certificate_implies_GoldbachUpTo
    (N : ℕ)
    (C : AdditiveBasisCertificate)
    (hcov : ∀ n, 4 ≤ n → n ≤ N → Even n →
      ∃ p q, C.witness n = some (p, q)) :
    GoldbachUpTo N := by
  intro n h4 hN heven
  obtain ⟨p, q, hw⟩ := hcov n h4 hN heven
  exact ⟨p, q, C.sound_prime_left n p q hw, C.sound_prime_right n p q hw, C.sound_sum n p q hw⟩

/-! ## Theorem 2: Parity Obstruction

Every prime except 2 is odd. Therefore, the sum of two odd primes is even.
If an odd number is a sum of two primes, one of them must be 2.
-/

/-
A prime different from 2 is odd.
-/
theorem prime_ne_two_odd {p : ℕ} (hp : Nat.Prime p) (h2 : p ≠ 2) : Odd p := by
  exact hp.odd_of_ne_two h2

/-
The sum of two odd primes is even.
-/
theorem even_of_two_odd_primes_sum
    {p q : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpodd : p ≠ 2) (hqodd : q ≠ 2) :
    Even (p + q) := by
  simp +arith +decide [ hp.even_iff, hq.even_iff, hpodd, hqodd, parity_simps ]

/-
**Parity obstruction**: if an odd number is a sum of two primes,
one of them must be 2. This is why binary Goldbach lives on even integers.
-/
theorem odd_two_prime_rep_forces_two
    {n p q : ℕ}
    (hn : Odd n)
    (hp : Nat.Prime p)
    (hq : Nat.Prime q)
    (hsum : p + q = n) :
    p = 2 ∨ q = 2 := by
  cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;>
    simp_all +arith +decide [Nat.odd_iff, parity_simps]
  omega

/-
An odd number greater than 5 cannot be a sum of two odd primes.
-/
theorem odd_gt_five_not_sum_of_two_odd_primes
    {n p q : ℕ}
    (hn : Odd n)
    (_hgt : 5 < n)
    (hp : Nat.Prime p)
    (hq : Nat.Prime q)
    (hpodd : Odd p)
    (hqodd : Odd q) :
    p + q ≠ n := by
  exact fun h => by obtain ⟨ m, rfl ⟩ := hpodd; obtain ⟨ n, rfl ⟩ := hqodd; obtain ⟨ o, rfl ⟩ := hn; omega;

/-
The sum of three odd primes is odd. This explains why Vinogradov's
theorem naturally addresses odd integers.
-/
theorem three_odd_primes_sum_is_odd
    {p q r : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hpodd : p ≠ 2) (hqodd : q ≠ 2) (hrodd : r ≠ 2) :
    Odd (p + q + r) := by
  simp +arith +decide [ hp.even_iff, hq.even_iff, hr.even_iff, hpodd, hqodd, hrodd, parity_simps ]

/-! ## Theorem 3: Monotone Extension

GoldbachUpTo is monotonically extendable: if we've verified [4,N] and
then verify (N,M], the full range [4,M] is covered.
-/

/-
**Monotone extension**: GoldbachUpTo composes. If Goldbach holds up to N,
and we have witnesses for even numbers in (N, M], then Goldbach holds up to M.
This is the foundation for incremental/modular verification campaigns.
-/
theorem GoldbachUpTo.extend
    {N M : ℕ}
    (_hNM : N ≤ M)
    (hN : GoldbachUpTo N)
    (hnew : ∀ n, N < n → n ≤ M → Even n →
      ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n) :
    GoldbachUpTo M := by
  exact fun n hn₁ hn₂ hn₃ => if hn₄ : n ≤ N then hN n hn₁ hn₄ hn₃ else hnew n ( not_le.mp hn₄ ) hn₂ hn₃

/-
Base case: GoldbachUpTo 3 holds vacuously.
-/
theorem GoldbachUpTo.base : GoldbachUpTo 3 := by
  exact fun n hn₁ hn₂ hn₃ => by interval_cases n ;

/-
GoldbachUpTo is monotone: if N ≤ M and GoldbachUpTo M, then GoldbachUpTo N.
-/
theorem GoldbachUpTo.mono {N M : ℕ} (h : N ≤ M) (hM : GoldbachUpTo M) :
    GoldbachUpTo N := by
  exact fun n hn₁ hn₂ hn₃ => hM n hn₁ ( by linarith ) hn₃

/-! ## Theorem 4: Graph Cover Equivalence

We reformulate two-prime representability as membership in the edge-sum cover
of the "Goldbach graph" on primes up to N. This connects additive number theory
to finite combinatorics/graph theory.
-/

/-
**Graph cover equivalence**: a number n ≤ N is two-prime representable iff
it lies in the edge-sum cover of the prime graph up to N.
-/
theorem goldbach_graph_cover_iff
    {N n : ℕ} (h4 : 4 ≤ n) (hnN : n ≤ N) (he : Even n) :
    TwoPrimeRepresentable n ↔ n ∈ CoveredEvens N := by
  constructor;
  · rintro ⟨ p, q, hp, hq, rfl ⟩;
    exact ⟨ p, q, Finset.mem_filter.mpr ⟨ Finset.mem_product.mpr ⟨ Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith ), hp ⟩, Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith ), hq ⟩ ⟩, by linarith ⟩, rfl ⟩;
  · rintro ⟨ p, q, hpq, rfl ⟩;
    exact ⟨ p, q, Finset.mem_filter.mp ( Finset.mem_product.mp ( Finset.mem_filter.mp hpq |>.1 ) |>.1 ) |>.2, Finset.mem_filter.mp ( Finset.mem_product.mp ( Finset.mem_filter.mp hpq |>.1 ) |>.2 ) |>.2, rfl ⟩

/-! ## Verified Algorithm: Soundness

The `findGoldbachPairAux` search is sound: any returned pair consists of
primes that sum to n.
-/

/-
Soundness of the auxiliary search: if it returns (p, q), then p and q are
prime and p + q = n.
-/
theorem findGoldbachPairAux_sound
    {n fuel k p q : ℕ}
    (h : findGoldbachPairAux n fuel k = some (p, q)) :
    Nat.Prime p ∧ Nat.Prime q ∧ p + q = n := by
  induction' fuel with fuel ih generalizing k p q <;> simp_all +decide [ findGoldbachPairAux ];
  grind

/-
**Verified search soundness**: if `findGoldbachPair n` returns a pair,
it is a valid Goldbach decomposition.
-/
theorem findGoldbachPair_sound
    {n p q : ℕ}
    (h : findGoldbachPair n = some (p, q)) :
    Nat.Prime p ∧ Nat.Prime q ∧ p + q = n := by
  exact findGoldbachPairAux_sound h

/-! ## Transfer: binary Goldbach implies ternary for odd > 5 -/

/-
If binary Goldbach holds universally for even numbers ≥ 4, then every
odd number > 5 is three-prime representable (via 3 + even decomposition).
-/
theorem binary_implies_ternary_goldbach
    (hG : ∀ n, 4 ≤ n → Even n → TwoPrimeRepresentable n) :
    ∀ n, 5 < n → Odd n → ThreePrimeRepresentable n := by
  intro n hn h_odd
  obtain ⟨k, hk⟩ : ∃ k, n = 3 + k ∧ 4 ≤ k ∧ Even k := by
    exact ⟨ n - 3, by rw [ Nat.add_sub_cancel' ( by linarith ) ], Nat.le_sub_of_add_le ( by contrapose! hn; interval_cases n <;> trivial ), by rw [ Nat.even_sub ( by linarith ) ] ; simp_all +decide [ parity_simps ] ⟩;
  rcases hG k hk.2.1 hk.2.2 with ⟨ p, q, hp, hq, hpq ⟩ ; exact ⟨ 3, p, q, by norm_num, hp, hq, by linarith ⟩

/-! ## Two-prime representability of small evens -/

/-
4 = 2 + 2 is two-prime representable.
-/
theorem twoPrimeRepresentable_four : TwoPrimeRepresentable 4 := by
  exists 2, 2

/-
6 = 3 + 3 is two-prime representable.
-/
theorem twoPrimeRepresentable_six : TwoPrimeRepresentable 6 := by
  exists 3, 3

end AdditiveGoldbach
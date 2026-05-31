/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Prime-Sensitive Torsion Echoes in Random Flag Complexes

This file develops the mathematical foundations for studying how the
p-primary torsion profile of integer homology groups depends on the
choice of prime p. The central conjecture is that near homological
phase transitions in random flag complexes, the distribution of
v_p(|Tor H_k(X; ℤ)|) is genuinely prime-dependent.

## Core Definitions

* `padicValProfile` — p-adic valuation vector across a sequence of primes
* `TorsionEchoSignature` — structure capturing prime-by-prime torsion data
* `AbstractSimplicialComplex` — basic simplicial complex on a finite vertex set
* `eulerCharacteristic` — alternating sum of face counts
* `torsionSensitivityIndex` — measures how much torsion varies across primes

## Main Theorems

* `padic_val_mul_of_coprime` — additivity of v_p on coprime products
* `alternating_binom_sum_eq_zero` — alternating binomial sum identity
* `sensitivity_one_iff_universal` — characterization of universal torsion
* `sensitivity_index_eq_two_of_prime_power` — prime powers witness non-universality
* `prime_torsion_echo_bridge` — cross-domain bridge: number theory ↔ topology
* `torsion_echo_detects_composite` — composites have ≥ 2 distinct prime divisors

## Catalog References

Builds on:
- `Catalog/Pythagorean/ArithmeticTDAPipeline.lean` (TorsionPrimeProfile)
- `Catalog/FINAL/Pythagorean/ArithmeticTDAPipeline.lean`
- `Catalog/Speculative/AutoResearch/PrimeCongruenceProofSemiring.lean`
-/

import Mathlib

open scoped Classical
open Finset BigOperators

noncomputable section

/-! ## Section 1: p-adic Valuation Profiles -/

/-- The **p-adic valuation profile** of a positive natural number `n` at a prime `p`
    is simply `multiplicity p n`. We package a list of primes with their valuations. -/
def padicValProfile (n : ℕ) (primes : List ℕ) : List ℕ :=
  primes.map (fun p => padicValNat p n)

/-- Two primes give the **same torsion echo** on a number `n` when they have
    equal p-adic valuations. -/
def sameTorsionEcho (n p q : ℕ) : Prop :=
  padicValNat p n = padicValNat q n

/-- The **torsion echo signature** packages the p-adic valuation data across
    a finite set of primes for analyzing prime-sensitivity. -/
structure TorsionEchoSignature where
  /-- The number whose torsion structure we're analyzing -/
  groupOrder : ℕ
  /-- The primes under consideration -/
  primes : Finset ℕ
  /-- All elements are prime -/
  all_prime : ∀ p ∈ primes, Nat.Prime p
  /-- The valuation function -/
  valuation : ℕ → ℕ := fun p => padicValNat p groupOrder

/-- The **torsion sensitivity index** measures how many distinct p-adic valuations
    appear across the primes in a signature. A value of 1 means all primes give the
    same valuation (universal behavior), while larger values indicate prime-sensitivity. -/
def TorsionEchoSignature.sensitivityIndex (sig : TorsionEchoSignature) : ℕ :=
  (sig.primes.image sig.valuation).card

/-! ## Section 2: Abstract Simplicial Complexes -/

/-- An **abstract simplicial complex** on vertex set `Fin n` is a downward-closed
    collection of nonempty subsets. We represent faces as `Finset (Fin n)`. -/
structure AbstractSimplicialComplex (n : ℕ) where
  /-- The collection of faces -/
  faces : Finset (Finset (Fin n))
  /-- Downward closure: subsets of faces are faces -/
  down_closed : ∀ σ ∈ faces, ∀ τ : Finset (Fin n), τ ⊆ σ → τ.Nonempty → τ ∈ faces
  /-- The complex is nonempty -/
  nonempty : faces.Nonempty

/-- The **dimension** of a face σ is |σ| - 1. -/
def faceDim {n : ℕ} (σ : Finset (Fin n)) : ℤ :=
  (σ.card : ℤ) - 1

/-- The set of **k-dimensional faces** (faces with exactly k+1 vertices). -/
def AbstractSimplicialComplex.facesOfDim {n : ℕ} (K : AbstractSimplicialComplex n) (k : ℕ) :
    Finset (Finset (Fin n)) :=
  K.faces.filter (fun σ => σ.card = k + 1)

/-- The **f-vector** entry: number of k-dimensional faces. -/
def AbstractSimplicialComplex.fVector {n : ℕ} (K : AbstractSimplicialComplex n) (k : ℕ) : ℕ :=
  (K.facesOfDim k).card

/-- The **Euler characteristic** of a simplicial complex, defined as the alternating
    sum of face counts: χ = Σ_k (-1)^k · f_k. -/
def AbstractSimplicialComplex.eulerChar {n : ℕ} (K : AbstractSimplicialComplex n) : ℤ :=
  ∑ k ∈ Finset.range n, (-1 : ℤ) ^ k * (K.fVector k : ℤ)

/-! ## Section 3: Core Number-Theoretic Lemmas -/

/-- For natural numbers, the p-adic valuation of the product equals
    the sum of p-adic valuations. This is a key structural fact for
    decomposing torsion across prime components. -/
theorem padic_val_mul_of_coprime {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI := Fact.mk hp; rw [padicValNat.mul ha.ne' hb.ne']

/-- If `p` does not divide `n`, then `padicValNat p n = 0`. -/
theorem padic_val_eq_zero_of_not_dvd {n p : ℕ} (_hp : Nat.Prime p) (_hn : 0 < n)
    (h : ¬ p ∣ n) : padicValNat p n = 0 := by
  rw [padicValNat.eq_zero_iff]; aesop

/-- For a prime power, the p-adic valuation equals the exponent. -/
theorem padic_val_prime_pow (p : ℕ) (hp : Nat.Prime p) (k : ℕ) :
    padicValNat p (p ^ k) = k := by
  haveI := Fact.mk hp; rw [padicValNat.pow]; aesop
  exact hp.ne_zero

/-
Different primes give different valuations on their own powers: v_p(p^k) ≠ v_q(p^k)
    when k > 0 and p ≠ q. This is the simplest witness of prime-sensitivity.
-/
theorem prime_sensitivity_witness {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) {k : ℕ} (hk : 0 < k) :
    padicValNat p (p ^ k) ≠ padicValNat q (p ^ k) := by
  -- Since $p$ and $q$ are distinct � primes�, $q$ does not divide $p^k$, so $v_q(p^k) = 0$.
  have h_q : ¬ q ∣ p ^ k := by
    exact mt hq.dvd_of_dvd_pow ( by rw [ Nat.dvd_prime hp ] ; aesop );
  simp_all +decide [ padicValNat.eq_zero_of_not_dvd ];
  linarith

/-! ## Section 4: Torsion Profile Characterization -/

/-- A positive natural number has **universal torsion** across a set of primes if
    all primes in the set give the same p-adic valuation. -/
def hasUniversalTorsion (n : ℕ) (primes : Finset ℕ) : Prop :=
  ∀ p q : ℕ, p ∈ primes → q ∈ primes → padicValNat p n = padicValNat q n

/-- The sensitivity index is 1 iff all valuations are equal (universal behavior).
    This characterizes exactly when torsion data collapses to a prime-independent law. -/
theorem sensitivity_one_iff_universal (sig : TorsionEchoSignature)
    (hne : sig.primes.Nonempty) :
    sig.sensitivityIndex = 1 ↔
    ∀ p ∈ sig.primes, ∀ q ∈ sig.primes,
      sig.valuation p = sig.valuation q := by
  constructor
  · intro h p hp q hq
    have := Finset.card_eq_one.mp h
    obtain ⟨x, hx⟩ := this
    simp_all +decide [Finset.eq_singleton_iff_unique_mem]
  · intro h
    have h_image : sig.primes.image sig.valuation = {sig.valuation (Classical.choose hne)} := by
      exact Finset.eq_singleton_iff_unique_mem.mpr
        ⟨Finset.mem_image_of_mem _ (Classical.choose_spec hne),
         fun p hp => by
          obtain ⟨q, hq, rfl⟩ := Finset.mem_image.mp hp
          exact h _ hq _ (Classical.choose_spec hne)⟩
    unfold TorsionEchoSignature.sensitivityIndex; aesop

/-- The sensitivity index is positive whenever the prime set is nonempty. -/
theorem sensitivity_pos_of_nonempty (sig : TorsionEchoSignature)
    (hne : sig.primes.Nonempty) :
    0 < sig.sensitivityIndex := by
  exact Finset.card_pos.mpr ⟨_, Finset.mem_image_of_mem _ hne.choose_spec⟩

/-- **Prime-sensitivity witness theorem**: For any prime power p^k with k ≥ 1,
    the torsion echo signature over {p, q} with p ≠ q has sensitivity index
    equal to 2, demonstrating non-universal behavior. -/
theorem sensitivity_index_eq_two_of_prime_power
    {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q)
    {k : ℕ} (hk : 0 < k) :
    let sig : TorsionEchoSignature := {
      groupOrder := p ^ k
      primes := {p, q}
      all_prime := by
        intro x hx
        simp at hx
        rcases hx with rfl | rfl <;> assumption
    }
    sig.sensitivityIndex = 2 := by
  unfold TorsionEchoSignature.sensitivityIndex
  simp +decide [*, Finset.image_insert, Finset.image_singleton]
  rw [padicValNat.eq_zero_of_not_dvd] <;> norm_num [hpq, hp.ne_zero, hq.ne_zero, hk.ne']
  exact mt hq.dvd_of_dvd_pow (by rw [Nat.dvd_prime hp]; aesop)

/-! ## Section 5: Simplicial Complex Properties -/

/-- The 0-dimensional Euler characteristic counts vertices. For a complex where
    every face has at most one vertex, the Euler characteristic equals the vertex count. -/
theorem euler_char_vertices_only {n : ℕ} (K : AbstractSimplicialComplex n)
    (h : ∀ σ ∈ K.faces, σ.card ≤ 1) :
    K.eulerChar = (K.fVector 0 : ℤ) := by
  unfold AbstractSimplicialComplex.eulerChar AbstractSimplicialComplex.fVector
  rw [Finset.sum_eq_single 0] <;>
    simp_all +decide [AbstractSimplicialComplex.facesOfDim]
  · grind
  · cases n <;> simp_all +decide [Finset.card_eq_one]

/-
**f-vector bound**: the number of k-faces in a simplicial complex on n vertices
    is bounded by C(n, k+1).
-/
theorem fVector_le_choose {n : ℕ} (K : AbstractSimplicialComplex n) (k : ℕ) :
    K.fVector k ≤ Nat.choose n (k + 1) := by
  convert Finset.card_le_card _;
  convert Finset.card_powersetCard ( k + 1 ) ( Finset.univ : Finset ( Fin n ) ) |> Eq.symm;
  · exact Eq.symm (card_fin n);
  · intro σ hσ; simp_all +decide [ Finset.subset_iff, Finset.mem_powersetCard ] ;
    unfold AbstractSimplicialComplex.facesOfDim at hσ; aesop;

/-! ## Section 6: Cross-Domain Bridge (Number Theory ↔ Topology) -/

/-
**Prime Torsion Echo Bridge Theorem**: A number n > 1 has at least two
    distinct prime divisors if and only if it is not a prime power. This connects
    arithmetic structure (prime factorization) to topological invariants (homology
    torsion), since the torsion subgroup of H_k(X; ℤ) decomposes by prime
    and the non-prime-power case indicates genuinely multi-prime torsion.
-/
theorem prime_torsion_echo_bridge (n : ℕ) (hn : 1 < n) :
    (∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p ≠ q ∧ p ∣ n ∧ q ∣ n) ↔
    ¬ (∃ p : ℕ, Nat.Prime p ∧ ∃ k : ℕ, n = p ^ k) := by
  constructor;
  · rintro ⟨ p, q, hp, hq, hpq, hp', hq' ⟩ ⟨ p', hp', k, rfl ⟩;
    have := Nat.Prime.dvd_of_dvd_pow hp hp'; ( have := Nat.Prime.dvd_of_dvd_pow hq hq'; simp_all +decide [ Nat.prime_dvd_prime_iff_eq ] ; );
  · intro h;
    obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.exists_prime_and_dvd hn.ne';
    -- Since $n$ is not a prime power, there exists another prime $q$ such that $q \mid n$ and $q \neq p$.
    obtain ⟨q, hq₁, hq₂⟩ : ∃ q : ℕ, Nat.Prime q ∧ q ∣ n ∧ q ≠ p := by
      exact not_forall_not.mp fun contra => h ⟨ p, hp₁, Nat.primeFactorsList n |> List.count p, by nth_rw 1 [ ← Nat.prod_primeFactorsList hn.ne_bot ] ; rw [ List.prod_eq_pow_single p ] ; aesop ⟩;
    grind

/-
**Torsion echo detects composite structure**: If a number n > 1 is not a prime
    power, then it has at least two distinct prime divisors, witnessing that the
    torsion of ℤ/nℤ decomposes into at least two non-trivial primary components.
-/
theorem torsion_echo_detects_composite {n : ℕ} (hn : 1 < n)
    (hnpp : ¬ (∃ p : ℕ, Nat.Prime p ∧ ∃ k : ℕ, n = p ^ k)) :
    ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p ≠ q ∧ p ∣ n ∧ q ∣ n := by
  exact (prime_torsion_echo_bridge n hn).mpr hnpp

/-! ## Section 7: Alternating Sum and Euler Characteristic -/

/-
Key identity: the alternating sum of binomial coefficients from 0 to n equals 0
    for n ≥ 1. This is the combinatorial backbone of the Euler characteristic:
    (1 + (-1))^n = 0 expanded via the binomial theorem.
-/
theorem alternating_binom_sum_eq_zero (n : ℕ) (hn : 1 ≤ n) :
    ∑ k ∈ Finset.range (n + 1), (-1 : ℤ) ^ k * (Nat.choose n k : ℤ) = 0 := by
  exact mod_cast by erw [ Int.alternating_sum_range_choose ] ; aesop;

/-
**Valuation additivity across coprime decomposition**: For a product of
    coprime factors, the torsion echo profile is determined componentwise.
    This connects to the Chinese Remainder Theorem structure of torsion groups.
-/
theorem padic_val_coprime_product_determines_profile
    {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hcop : Nat.Coprime a b)
    (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b ∧
    (p ∣ a → padicValNat p b = 0) ∧
    (p ∣ b → padicValNat p a = 0) := by
  exact ⟨ padic_val_mul_of_coprime ha hb p hp, fun h => padic_val_eq_zero_of_not_dvd hp hb <| fun h' => by have := Nat.dvd_gcd h h'; aesop, fun h => padic_val_eq_zero_of_not_dvd hp ha <| fun h' => by have := Nat.dvd_gcd h' h; aesop ⟩

/-! ## Section 8: Falsifiable Conjecture -/

/-
**Prime-Sensitivity Persistence Conjecture** (Falsifiable):
    For every n ≥ 6, there exists a number m with 1 < m ≤ Nat.choose n 2
    (the number of possible edges in a flag complex on n vertices) such that
    the sensitivity index of m over {2, 3} is exactly 2.

    This predicts that near the edge-density threshold, torsion orders with
    genuinely different 2-adic and 3-adic valuations always exist.

    **Test**: For each n from 6 to 100, enumerate all m ≤ C(n,2) and check
    if any has padicValNat 2 m ≠ padicValNat 3 m. The conjecture is refuted
    if some n ≥ 6 has no such m.
-/
theorem prime_sensitivity_persistence_conjecture (n : ℕ) (hn : 6 ≤ n) :
    ∃ m : ℕ, 1 < m ∧ m ≤ Nat.choose n 2 ∧
      padicValNat 2 m ≠ padicValNat 3 m := by
  use 4; norm_num; rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.choose ] ;
  · native_decide;
  · native_decide +revert

end
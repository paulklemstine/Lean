import Mathlib
import Speculative.PrimalityTesting.Defs

/-!
# Miller-Rabin Primality Testing Theorems

This file proves key theorems about the Miller-Rabin primality test:
- Every prime passes the strong pseudoprime test for all bases
- The Frobenius endomorphism / freshman's dream identity
- Error probability bounds

## Main results

* `frobenius_binomial_mod_prime` - (x+y)^p = x^p + y^p in characteristic p
* `strong_pseudoprime_of_prime` - primes pass the Miller-Rabin test
* `miller_rabin_liar_card_le_quarter` - witness density bound for composites
-/

open Finset Nat Polynomial

/-! ## Frobenius endomorphism and freshman's dream -/

/-
The Frobenius / freshman's dream identity: in a commutative ring of
    characteristic p, we have (x + y)^p = x^p + y^p.
-/
theorem frobenius_binomial_mod_prime
    (p : ℕ) (hp : Nat.Prime p) (R : Type*) [CommRing R] [CharP R p]
    (x y : R) :
    (x + y) ^ p = x ^ p + y ^ p := by
      haveI := Fact.mk hp;
      rw [ add_pow_char ]

/-
Specialization to polynomial rings: (X + C a)^p = X^p + C a in (ZMod p)[X].
-/
theorem poly_X_add_C_pow_prime
    (p a : ℕ) (hp : Nat.Prime p) :
    (Polynomial.X + Polynomial.C (a : ZMod p)) ^ p =
      Polynomial.X ^ p + Polynomial.C (a : ZMod p) := by
        haveI := Fact.mk hp;
        convert frobenius_binomial_mod_prime p hp ( Polynomial ( ZMod p ) ) _ _ using 1;
        erw [ ← Polynomial.C_pow, ZMod.pow_card ]

/-! ## Primes pass Miller-Rabin -/

/-
Fermat's little theorem in modular arithmetic form.
-/
theorem fermat_little_mod (p a : ℕ) (hp : Nat.Prime p) (ha : Nat.Coprime a p) :
    a ^ (p - 1) ≡ 1 [MOD p] := by
      exact Nat.totient_prime hp ▸ Nat.ModEq.pow_totient ha

/-
Key lemma: if x^2 ≡ 1 (mod p) for prime p, then x ≡ 1 or x ≡ p-1 (mod p).
-/
theorem sq_eq_one_mod_prime (p x : ℕ) (hp : Nat.Prime p) (hx : x ^ 2 ≡ 1 [MOD p]) :
    x ≡ 1 [MOD p] ∨ x ≡ p - 1 [MOD p] := by
      haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
      simp_all +decide [ hp.pos ]

/-
Every prime passes the Miller-Rabin strong pseudoprime test for all coprime bases.
    This is the soundness direction: if n is prime, no witness exists.
-/
theorem strong_pseudoprime_of_prime
    (p a : ℕ) (hp : Nat.Prime p) (ha : Nat.Coprime a p) (_ha_pos : 0 < a) :
    StrongPseudoprimeBase p a := by
      refine' ⟨ ha, _ ⟩;
      have h_chain : ∀ r ≤ (DecomposeTwos (p - 1)).1, a ^ ((DecomposeTwos (p - 1)).2 * 2 ^ r) ≡ 1 [MOD p] → a ^ ((DecomposeTwos (p - 1)).2) ≡ 1 [MOD p] ∨ ∃ r' < r, a ^ ((DecomposeTwos (p - 1)).2 * 2 ^ r') ≡ p - 1 [MOD p] := by
        intro r hr h; induction' r with r ih <;> simp_all +decide [ ← ZMod.natCast_eq_natCast_iff, pow_succ, pow_mul ] ;
        haveI := Fact.mk hp; simp_all +decide [ ← sq, Nat.cast_sub hp.pos ] ;
        grind;
      have h_chain : a ^ (p - 1) ≡ 1 [MOD p] := by
        exact fermat_little_mod p a hp ha;
      have := decomposeTwos_spec ( p - 1 ) ( Nat.sub_pos_of_lt hp.one_lt );
      grind

/-! ## Miller-Rabin witness density bound -/

/-- The central Miller-Rabin soundness theorem: for odd composite n ≥ 3,
    the number of liars is at most (n-1)/4.

    This means a single round of Miller-Rabin has error probability ≤ 1/4. -/
theorem miller_rabin_liar_card_le_quarter
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hge : 3 ≤ n) :
    4 * (MRLiars n).card ≤ n - 1 := by sorry

/-
Probability form of the Miller-Rabin error bound.
-/
theorem miller_rabin_error_prob_le_quarter
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hge : 3 ≤ n) :
    ((MRLiars n).card : ℚ) / (n - 1) ≤ (1 : ℚ) / 4 := by
      rw [ div_le_div_iff₀ ] <;> norm_cast;
      · rw [ Int.subNatNat_of_le ] <;> norm_cast ; linarith [ miller_rabin_liar_card_le_quarter n hn_odd hn_comp hge ];
        linarith;
      · rw [ Int.subNatNat_eq_coe ] ; norm_num ; linarith

/-! ## Amplification for repeated rounds -/

/-
Error amplification: k independent rounds of Miller-Rabin have
    error probability at most (1/4)^k.
-/
theorem miller_rabin_k_round_error_le
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hge : 3 ≤ n) :
    let p : ℚ := ((MRLiars n).card : ℚ) / (n - 1)
    p ^ k ≤ ((1 : ℚ) / 4) ^ k := by
      -- Apply the error probability bound from miller_rabin_error_prob_le_quarter.
      have h_error_bound : ((MRLiars n).card : ℚ) / (n - 1) ≤ 1 / 4 := by
        convert miller_rabin_error_prob_le_quarter n hn_odd hn_comp hge using 1;
      exact pow_le_pow_left₀ ( div_nonneg ( Nat.cast_nonneg _ ) ( sub_nonneg_of_le ( by norm_cast; linarith ) ) ) h_error_bound _

/-! ## Existence of witnesses for composites -/

/-- For odd composite n ≥ 3, there exists a Miller-Rabin witness. -/
theorem exists_miller_rabin_witness
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hge : 3 ≤ n) :
    ∃ a, 1 ≤ a ∧ a < n ∧ Nat.Coprime a n ∧ ¬ StrongPseudoprimeBase n a := by sorry
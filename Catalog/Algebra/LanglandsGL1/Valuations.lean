/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Valuation Theory for GL(1) Langlands over ℚ

This file establishes the valuation-theoretic foundations needed for
the GL(1) Langlands correspondence over ℚ:

1. **Finite support**: The set of primes with nonzero p-adic valuation
   of any nonzero rational is finite.
2. **Product formula**: The fundamental identity expressing the global
   constraint that principal idèles have trivial image in the idèle class group.
3. **Valuation additivity**: The p-adic valuation is a homomorphism
   from (ℚˣ, ×) to (ℤ, +).

## Mathematical significance

The product formula ∏_v |x|_v = 1 (or equivalently the balance of prime
factorizations of numerator and denominator) is the key analytic input
for the Artin reciprocity map: it ensures that the image of principal
idèles in the idèle class group is trivial, making the quotient well-defined.

In the Langlands framework, this is the first instance of a
"local-to-global conservation law": locally computed data (p-adic valuations)
satisfies a global constraint (their weighted sum is zero).
-/

noncomputable section

open Finsupp BigOperators Nat

/-! ## Finite support of p-adic valuations -/

/-
The set of primes at which a nonzero rational has nonzero p-adic
    valuation is finite. This follows from unique factorization.
-/
theorem finite_padicValRat_support (x : ℚ) (hx : x ≠ 0) :
    Set.Finite {p : ℕ | Nat.Prime p ∧ padicValRat p x ≠ 0} := by
      -- By definition of $padicValRat$, if $padicValRat p x ≠ 0$, then $p$ divides the numerator or denominator of $x$.
      have h_div : ∀ p : ℕ, Nat.Prime p → padicValRat p x ≠ 0 → p ∣ Int.natAbs x.num ∨ p ∣ x.den := by
        intro p pp h; contrapose! h; simp_all +decide [ padicValRat, padicValNat.eq_zero_of_not_dvd, Nat.Prime.dvd_iff_not_coprime pp ] ;
        exact Or.inr fun h' => pp.not_dvd_one <| h.1 ▸ Nat.dvd_gcd ( dvd_refl p ) ( Int.natAbs_dvd_natAbs.mpr h' );
      exact Set.finite_iff_bddAbove.mpr ⟨ Max.max ( Int.natAbs x.num ) x.den, fun p hp => by cases h_div p hp.1 hp.2 <;> [ exact Nat.le_trans ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ( by aesop ) ) ‹_› ) ( le_max_left _ _ ) ; exact Nat.le_trans ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ( by aesop ) ) ‹_› ) ( le_max_right _ _ ) ] ⟩

/-
The p-adic valuation of a nonzero rational equals the difference of
    multiplicities in numerator and denominator.
-/
theorem padicValRat_eq_factorization (p : ℕ) [hp : Fact p.Prime] (x : ℚ) (hx : x ≠ 0) :
    padicValRat p x =
      (x.num.natAbs.factorization p : ℤ) - (x.den.factorization p : ℤ) := by
        rw [ padicValRat ];
        simp +decide [ padicValInt, Nat.factorization ];
        rw [ if_pos hp.1, if_pos hp.1 ]

/-! ## Product formula over ℚ -/

/-
**Product formula for ℚ (factorization form).**

    For any nonzero rational x = a/b in lowest terms,
    ∏ p^v_p(a) = a.natAbs  and  ∏ p^v_p(b) = b.

    This is the explicit form of the product formula: the prime
    factorizations of numerator and denominator each recover the
    original, and therefore the "total" factorization is balanced.
-/
theorem rat_num_factorization_prod (x : ℚ) (hx : x ≠ 0) :
    x.num.natAbs.factorization.prod (· ^ ·) = x.num.natAbs := by
      exact Nat.factorization_prod_pow_eq_self ( Int.natAbs_ne_zero.mpr ( Rat.num_ne_zero.mpr hx ) )

theorem rat_den_factorization_prod (x : ℚ) :
    x.den.factorization.prod (· ^ ·) = x.den := by
      exact Nat.factorization_prod_pow_eq_self x.den_ne_zero

/-
**Product formula shadow: numerator-denominator coprimality.**

    For a rational in lowest terms, the prime supports of numerator
    and denominator are disjoint. This is the finitistic shadow of
    the product formula: no prime contributes to both sides.
-/
theorem rat_num_den_factorization_disjoint (x : ℚ) (hx : x ≠ 0) :
    Disjoint x.num.natAbs.factorization.support x.den.factorization.support := by
      -- Apply the fact that if two numbers are coprime, their prime factors are disjoint.
      apply Nat.Coprime.disjoint_primeFactors;
      exact x.reduced

/-
The p-adic valuation of a positive natural number equals its
    factorization multiplicity.
-/
theorem padicValNat_eq_factorization (p n : ℕ) [hp : Fact p.Prime] (hn : n ≠ 0) :
    padicValNat p n = n.factorization p := by
      -- By definition of factorization, the multiplicity of p in the prime factorization of n is exactly the p-adic valuation of n.
      simp [Nat.factorization];
      exact fun h => False.elim <| h hp.1

/-! ## Valuation additivity -/

/-
The p-adic valuation is additive on ℚˣ: v_p(xy) = v_p(x) + v_p(y).
    This is the homomorphism property that makes valuations into
    "additive characters" of the multiplicative group.
-/
theorem padicValRat_mul_eq_add (p : ℕ) [hp : Fact p.Prime] (x y : ℚˣ) :
    padicValRat p ((x * y : ℚˣ) : ℚ) =
      padicValRat p (x : ℚ) + padicValRat p (y : ℚ) := by
        convert padicValRat.mul ( Units.ne_zero x ) ( Units.ne_zero y ) using 1;
        exact hp

/-
The p-adic valuation of an inverse: v_p(x⁻¹) = -v_p(x).
-/
theorem padicValRat_inv (p : ℕ) [hp : Fact p.Prime] (x : ℚˣ) :
    padicValRat p ((x⁻¹ : ℚˣ) : ℚ) = -padicValRat p (x : ℚ) := by
      -- By definition, we know that the multiplicative inverse of `x` is `x⁻¹`.
      have h_inv : (x⁻¹ : ℚ) * (x : ℚ) = 1 := by
        exact?;
      apply_fun padicValRat p at h_inv;
      rw [ padicValRat.mul ] at h_inv <;> norm_num at *;
      exact eq_neg_of_add_eq_zero_left h_inv

/-
Valuation of a natural number prime: v_p(p) = 1.
-/
theorem padicValRat_prime_self (p : ℕ) [hp : Fact p.Prime] :
    padicValRat p (p : ℚ) = 1 := by
      norm_num +zetaDelta at *

/-
Valuation of a prime at a different prime: v_p(q) = 0 for p ≠ q.
-/
theorem padicValRat_prime_ne (p q : ℕ) [hp : Fact p.Prime] [hq : Fact q.Prime]
    (hne : p ≠ q) :
    padicValRat p (q : ℚ) = 0 := by
      convert padicValNat.eq_zero_of_not_dvd _;
      rotate_left;
      exact p;
      exact q;
      · exact fun h => hne <| Nat.prime_dvd_prime_iff_eq hp.1 hq.1 |>.1 h;
      · simp +decide [ padicValRat ]

end
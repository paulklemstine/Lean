/-
Copyright (c) 2025. All rights reserved.

# Beal Conjecture: Primitive Reduction Theorem

## Main result

If `A^x + B^y = C^z` and no prime divides all three of `A, B, C`,
then `A, B, C` are automatically pairwise coprime.

This is the decisive formal reduction: it shows that any counterexample
to Beal must be "primitive" (pairwise coprime). Once formalized, every
future attack on Beal can assume pairwise coprimality without loss of generality.

## Key insight

If `p | A` and `p | B`, then `p | A^x` and `p | B^y`, so `p | (A^x + B^y) = C^z`,
hence `p | C`. Thus any common prime factor of two bases must divide all three.
The contrapositive gives: no common prime of all three ⟹ pairwise coprime.
-/
import Mathlib
import Speculative.Beal.Defs

open Nat

/-! ## Core factorization lemma -/

/-
If `p` divides two of `A, B` and `A^x + B^y = C^z` with positive exponents,
then `p` divides `C`. This is the engine of the primitive reduction.
-/
theorem prime_dvd_pair_implies_dvd_third
    {p A B C x y z : ℕ}
    (hp : Nat.Prime p)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hpA : p ∣ A) (hpB : p ∣ B) : p ∣ C := by
  exact hp.dvd_of_dvd_pow ( hEq ▸ dvd_add ( dvd_pow hpA hx.ne' ) ( dvd_pow hpB hy.ne' ) )

/-
Symmetric variant: if `p | A` and `p | C`, then `p | B`.
-/
theorem prime_dvd_AC_implies_dvd_B
    {p A B C x y z : ℕ}
    (hp : Nat.Prime p)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hpA : p ∣ A) (hpC : p ∣ C) : p ∣ B := by
  exact hp.dvd_of_dvd_pow ( Nat.dvd_of_mod_eq_zero <| by simpa [ Nat.add_mod, Nat.pow_mod, Nat.mod_eq_zero_of_dvd hpA, Nat.mod_eq_zero_of_dvd hpC, hx.ne', hy.ne', hz.ne' ] using congr_arg ( fun n => n % p ) hEq )

/-
Symmetric variant: if `p | B` and `p | C`, then `p | A`.
-/
theorem prime_dvd_BC_implies_dvd_A
    {p A B C x y z : ℕ}
    (hp : Nat.Prime p)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hpB : p ∣ B) (hpC : p ∣ C) : p ∣ A := by
  exact hp.dvd_of_dvd_pow <| Nat.dvd_of_mod_eq_zero <| by simpa [ Nat.add_mod, Nat.pow_mod, Nat.mod_eq_zero_of_dvd hpB, Nat.mod_eq_zero_of_dvd hpC, hx.ne', hy.ne', hz.ne' ] using congr_arg ( · % p ) hEq;

/-! ## No-common-prime implies pairwise coprime -/

/-
If `A^x + B^y = C^z` (positive exponents) and no prime divides all three,
then `A` and `B` are coprime.
-/
theorem coprime_AB_of_no_common_prime
    {A B C x y z : ℕ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hNoCommon : ¬∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C) :
    Nat.Coprime A B := by
  refine' Nat.coprime_of_dvd' _;
  intro k hk hkA hkB; exact False.elim <| hNoCommon ⟨ k, hk, hkA, hkB, hk.dvd_of_dvd_pow <| hEq ▸ dvd_add ( dvd_pow hkA hx.ne' ) ( dvd_pow hkB hy.ne' ) ⟩ ;

/-
If `A^x + B^y = C^z` (positive exponents) and no prime divides all three,
then `A` and `C` are coprime.
-/
theorem coprime_AC_of_no_common_prime
    {A B C x y z : ℕ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hNoCommon : ¬∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C) :
    Nat.Coprime A C := by
  refine' Nat.coprime_of_dvd' _;
  intro k hk hkA hkC; exact absurd ( prime_dvd_AC_implies_dvd_B hk ( by positivity ) ( by positivity ) ( by positivity ) hEq hkA hkC ) ( fun hk' => hNoCommon ⟨ k, hk, hkA, hk', hkC ⟩ ) ;

/-
If `A^x + B^y = C^z` (positive exponents) and no prime divides all three,
then `B` and `C` are coprime.
-/
theorem coprime_BC_of_no_common_prime
    {A B C x y z : ℕ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hNoCommon : ¬∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C) :
    Nat.Coprime B C := by
  refine' Nat.coprime_of_dvd' _;
  intro k hk hkB hkC; exact absurd ( prime_dvd_BC_implies_dvd_A hk ( by positivity ) ( by positivity ) ( by positivity ) hEq hkB hkC ) fun hkA ↦ hNoCommon ⟨ k, hk, hkA, hkB, hkC ⟩ ;

/-! ## Main theorem: Primitive Reduction -/

/-- **Primitive Reduction Theorem for Beal's Conjecture.**

Any counterexample to Beal (i.e., a solution `A^x + B^y = C^z` with
`x, y, z > 2` and no common prime factor) is automatically pairwise coprime.
In particular, `A, B, C` themselves form a primitive counterexample. -/
theorem beal_counterexample_has_pairwise_coprime_model
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 2 < x) (hy : 2 < y) (hz : 2 < z)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hNoCommon :
      ¬∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C) :
    ∃ A' B' C' : ℕ,
      0 < A' ∧ 0 < B' ∧ 0 < C' ∧
      A' ^ x + B' ^ y = C' ^ z ∧
      Nat.Coprime A' B' ∧ Nat.Coprime A' C' ∧ Nat.Coprime B' C' := by
  exact ⟨A, B, C, hA, hB, hC, hEq,
    coprime_AB_of_no_common_prime (by omega) (by omega) (by omega) hEq hNoCommon,
    coprime_AC_of_no_common_prime (by omega) (by omega) (by omega) hEq hNoCommon,
    coprime_BC_of_no_common_prime (by omega) (by omega) (by omega) hEq hNoCommon⟩

/-
**Beal's conjecture is equivalent to its primitive form.**

Beal's conjecture holds if and only if no pairwise coprime solution
to `A^x + B^y = C^z` with `x, y, z > 2` exists.
-/
theorem beal_iff_no_primitive_solution :
    BealConjecture ↔
    ¬∃ (A B C x y z : ℕ),
      0 < A ∧ 0 < B ∧ 0 < C ∧
      2 < x ∧ 2 < y ∧ 2 < z ∧
      A ^ x + B ^ y = C ^ z ∧
      Nat.Coprime A B ∧ Nat.Coprime A C ∧ Nat.Coprime B C := by
  constructor;
  · intro h
    rintro ⟨A, B, C, x, y, z, hA, hB, hC, hx, hy, hz, hEq, hCoprime⟩
    obtain ⟨p, hp⟩ := h A B C x y z hA hB hC hx hy hz hEq
    have hCommonPrime : p ∣ A ∧ p ∣ B ∧ p ∣ C := by
      tauto;
    exact Nat.Prime.not_dvd_one hp.1 ( hCoprime.1.gcd_eq_one ▸ Nat.dvd_gcd hCommonPrime.1 hCommonPrime.2.1 );
  · intro H!;
    intro A B C x y z hA hB hC hx hy hz hEq;
    -- By contradiction, assume there exists a prime $p$ that divides $A$, $B$, and $C$.
    by_contra h_contra;
    exact H! <| by obtain ⟨ A', B', C', hA', hB', hC', hEq', hCoprime ⟩ := beal_counterexample_has_pairwise_coprime_model hA hB hC hx hy hz hEq h_contra; exact ⟨ A', B', C', x, y, z, hA', hB', hC', hx, hy, hz, hEq', hCoprime ⟩ ;
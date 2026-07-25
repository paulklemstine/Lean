import Mathlib

/-!
# Fermat's Little Theorem and the divisibility `5 ∣ a ^ 5 - a`

This file records Fermat's little theorem over the integers together with several
proofs of the special case `5 ∣ a ^ 5 - a`.
-/

open scoped BigOperators

set_option checkBinderAnnotations false in
/-- **Fermat's little theorem** (integer form): for a prime `p`, we have
`p ∣ a ^ p - a` for every integer `a`.  The proof passes to `ZMod p` and uses
`ZMod.pow_card` together with `ZMod.card`.

The binder `[hm : Nat.Prime p]` is written as an instance binder as requested; this
requires disabling the binder-annotation check since `Nat.Prime` is a plain `Prop`
rather than a class. -/
theorem fermatLittle_int (p : ℕ) [hm : Nat.Prime p] (a : ℤ) : (p : ℤ) ∣ a ^ p - a := by
  haveI : Fact p.Prime := ⟨hm⟩
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  have hpow : ((a : ZMod p)) ^ p = (a : ZMod p) := by
    have hc := FiniteField.pow_card (a : ZMod p)
    rwa [hcard] at hc
  rw [hpow]
  ring

/-- The Frobenius endomorphism is the identity on `ZMod 5`. -/
theorem frobenius_id_zmod5 (x : ZMod 5) : x ^ 5 = x := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have : x ^ (Fintype.card (ZMod 5)) = x := ZMod.pow_card x
  simp only [ZMod.card] at this
  exact this

/-- The special case `5 ∣ a ^ 5 - a` derived from `fermatLittle_int`. -/
theorem five_dvd_pow_five_sub_self (a : ℤ) : 5 ∣ a ^ 5 - a := by
  exact_mod_cast fermatLittle_int 5 (hm := by norm_num) a

/-- The special case `5 ∣ a ^ 5 - a` via the factorisation
`a ^ 5 - a = (a - 1) * a * (a + 1) * (a ^ 2 + 1)` and a case analysis on `a % 5`. -/
theorem five_dvd_pow_five_sub_self_elementary (a : ℤ) : 5 ∣ a ^ 5 - a := by
  have hfact : a ^ 5 - a = (a - 1) * a * (a + 1) * (a ^ 2 + 1) := by ring
  rw [hfact]
  have h5 : a % 5 = 0 ∨ a % 5 = 1 ∨ a % 5 = 2 ∨ a % 5 = 3 ∨ a % 5 = 4 := by omega
  rcases h5 with h | h | h | h | h
  · -- 5 ∣ a
    exact dvd_mul_of_dvd_left (dvd_mul_of_dvd_left (dvd_mul_of_dvd_right (by omega) _) _) _
  · -- 5 ∣ a - 1
    exact dvd_mul_of_dvd_left (dvd_mul_of_dvd_left (dvd_mul_of_dvd_left (by omega) _) _) _
  · -- 5 ∣ a ^ 2 + 1
    have h2 : (5 : ℤ) ∣ a ^ 2 + 1 := by
      have : (a ^ 2 + 1) % 5 = 0 := by rw [pow_two, Int.add_emod, Int.mul_emod, h]; decide
      omega
    exact dvd_mul_of_dvd_right h2 _
  · -- 5 ∣ a ^ 2 + 1
    have h2 : (5 : ℤ) ∣ a ^ 2 + 1 := by
      have : (a ^ 2 + 1) % 5 = 0 := by rw [pow_two, Int.add_emod, Int.mul_emod, h]; decide
      omega
    exact dvd_mul_of_dvd_right h2 _
  · -- 5 ∣ a + 1
    exact dvd_mul_of_dvd_left (dvd_mul_of_dvd_right (by omega) _) _
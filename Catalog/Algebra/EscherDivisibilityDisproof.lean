/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The divisibility construction runs down, not up

The proposed rungs consisting of functions whose values are divisible by `2^n`
form a strictly descending chain.  This file proves the reversal directly in the
function ring `ℤ → ℤ`; the same elementary inclusion argument applies to any
subring of functions, including integer-valued polynomials whenever that ring is
constructed.
-/
import Mathlib

namespace Escher

/-- Functions all of whose values are divisible by `2^n`. -/
def powerDivIdeal (n : ℕ) : Ideal (ℤ → ℤ) where
  carrier := {f | ∀ z, (2 : ℤ) ^ n ∣ f z}
  zero_mem' := by
    intro z
    exact dvd_zero _
  add_mem' := by
    intro f g hf hg z
    exact dvd_add (hf z) (hg z)
  smul_mem' := by
    intro c f hf z
    exact dvd_mul_of_dvd_right (hf z) (c z)

@[simp] theorem mem_powerDivIdeal {n : ℕ} {f : ℤ → ℤ} :
    f ∈ powerDivIdeal n ↔ ∀ z, (2 : ℤ) ^ n ∣ f z := Iff.rfl

/-
Increasing the exponent makes the divisibility ideal smaller.
-/
theorem powerDivIdeal_antitone : Antitone powerDivIdeal := by
  intro m n hmn f hf;
  exact fun z => dvd_trans ( pow_dvd_pow _ hmn ) ( hf z )

/-
Every containment is strict: the constant function `2^n` separates adjacent rungs.
-/
theorem powerDivIdeal_succ_lt (n : ℕ) : powerDivIdeal (n + 1) < powerDivIdeal n := by
  simp +decide [ SetLike.lt_iff_le_and_exists, SetLike.le_def ];
  refine' ⟨ fun x hx z => dvd_trans ( pow_dvd_pow _ ( Nat.le_succ _ ) ) ( hx z ), _ ⟩;
  refine' ⟨ fun _ => 2 ^ n, _, 0, _ ⟩ <;> norm_num;
  exact_mod_cast Nat.not_dvd_of_pos_of_lt ( pow_pos ( by decide ) _ ) ( pow_lt_pow_right₀ ( by decide ) ( Nat.lt_succ_self _ ) )

/-
Thus the advertised construction is a strictly descending chain, not an Escher staircase.
-/
theorem powerDivIdeal_strictAnti : StrictAnti powerDivIdeal := by
  exact strictAnti_nat_of_succ_lt fun n => powerDivIdeal_succ_lt n

/-
In particular it cannot itself witness a strictly ascending ideal chain.
-/
theorem powerDivIdeal_not_strictMono : ¬ StrictMono powerDivIdeal := by
  intro h;
  simpa using h ( Nat.lt_succ_self 0 ) |> fun h => h.not_ge <| powerDivIdeal_antitone <| Nat.le_succ 0

end Escher
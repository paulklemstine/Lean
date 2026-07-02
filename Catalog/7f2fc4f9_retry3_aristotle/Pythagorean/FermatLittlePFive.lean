import Mathlib

/-!
# Fermat's Little Theorem for `p = 5` (elementary version)

This file gives a self-contained, elementary proof that for every integer `a`,
the quantity `a ^ 5 - a` is divisible by `5`.

The proof does **not** use `ZMod` or the general form of Fermat's Little Theorem.
Instead it proceeds by an explicit case analysis on the residue `a % 5`, using only
basic integer modular arithmetic.

The referenced `sq_emod_five` lemma from `Pythagorean.PythagoreanTripleModFive` is not
present in the project, so we develop the argument independently here.
-/

namespace FermatLittlePFive

/-- The five possible values of `a % 5` for an integer `a`. -/
theorem emod_five_cases (a : ℤ) :
    a % 5 = 0 ∨ a % 5 = 1 ∨ a % 5 = 2 ∨ a % 5 = 3 ∨ a % 5 = 4 := by
  omega

/-- **Fermat's Little Theorem for `p = 5`.**
For every integer `a`, the number `a ^ 5 - a` is an integer multiple of `5`. -/
theorem five_dvd_pow_five_sub_self (a : ℤ) : (5 : ℤ) ∣ a ^ 5 - a := by
  have h := Int.emod_add_mul_ediv a 5
  have hc : a % 5 = 0 ∨ a % 5 = 1 ∨ a % 5 = 2 ∨ a % 5 = 3 ∨ a % 5 = 4 := by omega
  set q := a / 5 with hq
  rcases hc with hr | hr | hr | hr | hr
  · rw [hr] at h; have ha : a = 0 + 5 * q := h.symm; rw [ha]
    exact ⟨625 * q ^ 5 - q, by ring⟩
  · rw [hr] at h; have ha : a = 1 + 5 * q := h.symm; rw [ha]
    exact ⟨4*q + 50*q^2 + 250*q^3 + 625*q^4 + 625*q^5, by ring⟩
  · rw [hr] at h; have ha : a = 2 + 5 * q := h.symm; rw [ha]
    exact ⟨6 + 79*q + 400*q^2 + 1000*q^3 + 1250*q^4 + 625*q^5, by ring⟩
  · rw [hr] at h; have ha : a = 3 + 5 * q := h.symm; rw [ha]
    exact ⟨48 + 404*q + 1350*q^2 + 2250*q^3 + 1875*q^4 + 625*q^5, by ring⟩
  · rw [hr] at h; have ha : a = 4 + 5 * q := h.symm; rw [ha]
    exact ⟨204 + 1279*q + 3200*q^2 + 4000*q^3 + 2500*q^4 + 625*q^5, by ring⟩

/-- Sanity test: the divisibility holds for every integer in `[-1000, 1000]`.
This is a direct consequence of `five_dvd_pow_five_sub_self`. -/
theorem five_dvd_pow_five_sub_self_range (a : ℤ) (_ : -1000 ≤ a) (_ : a ≤ 1000) :
    (5 : ℤ) ∣ a ^ 5 - a :=
  five_dvd_pow_five_sub_self a

end FermatLittlePFive
import Mathlib
import Novelty.KleinFourTwoTorsionReciprocity

/-!
# The general twist-family 2-torsion sum, and other reciprocity inputs

`Novelty/KleinFourTwoTorsionReciprocity.lean` treats the family `y² = x³ - 3 d² x`.  Nothing in
the argument is special to `3`: the summed 2-torsion count over the twist family
`y² = x³ - a d² x`, `d ∈ 𝔽_p^×`, depends only on whether the parameter `a` is a square.
This file proves that general statement (`sum_card_V4_gen`) and instantiates it at two further
reciprocity inputs supplied by Mathlib:

* `a = 2`: the split classes are `p ≡ 1, 7 mod 8` (supplementary law for `2`);
* `a = -1`: the split classes are `p ≡ 1 mod 4` (first supplementary law).

Together with the `mod 12` law for `a = 3` this exhibits the counting law as a single
fibre-counting statement whose *arithmetic* content is entirely carried by the quadratic
character of the parameter.
-/

namespace TwistFamilyGeneralSum

open Finset KleinFourTwoTorsion

variable {p : ℕ} [Fact p.Prime]

/-- `a d²` is a square iff `a` is, for `d ≠ 0`. -/
theorem isSquare_mul_sq {a d : ZMod p} (hd : d ≠ 0) :
    IsSquare (a * d ^ 2) ↔ IsSquare a := by
  constructor
  · rintro ⟨t, ht⟩
    exact ⟨t / d, by field_simp at ht ⊢; linear_combination ht⟩
  · rintro ⟨s, hs⟩
    exact ⟨s * d, by rw [hs]; ring⟩

/-- The summed 2-torsion order over the twist family `y² = x³ - a d² x`, `d ∈ 𝔽_p^×`. -/
def sumCardTwists (a : ZMod p) : ℕ := ∑ d ∈ univ.erase (0 : ZMod p), cardV4 (a * d ^ 2)

/-- **General two-regime law.** For any nonzero parameter `a` the summed 2-torsion order over
the twist family is `4 (p-1)` if `a` is a square and `2 (p-1)` otherwise. -/
theorem sum_card_V4_gen (hp2 : p ≠ 2) {a : ZMod p} (ha : a ≠ 0) :
    sumCardTwists a = if IsSquare a then 4 * (p - 1) else 2 * (p - 1) := by
  by_cases h : IsSquare a
  · rw [if_pos h]
    have hterm : ∀ d ∈ univ.erase (0 : ZMod p), cardV4 (a * d ^ 2) = 4 := by
      intro d hd
      have hd0 : d ≠ 0 := (mem_erase.1 hd).1
      exact card_V4_of_isSquare hp2 (mul_ne_zero ha (pow_ne_zero _ hd0))
        ((isSquare_mul_sq hd0).2 h)
    rw [sumCardTwists, sum_congr rfl hterm, sum_const, card_erase_zero, smul_eq_mul, mul_comm]
  · rw [if_neg h]
    have hterm : ∀ d ∈ univ.erase (0 : ZMod p), cardV4 (a * d ^ 2) = 2 := by
      intro d hd
      have hd0 : d ≠ 0 := (mem_erase.1 hd).1
      exact card_V4_of_not_isSquare (fun hsq => h ((isSquare_mul_sq hd0).1 hsq))
    rw [sumCardTwists, sum_congr rfl hterm, sum_const, card_erase_zero, smul_eq_mul, mul_comm]

/-- Specialisation to `a = 3`: the summed count agrees with `sum_card_V4`. -/
theorem sumCardTwists_three : sumCardTwists (3 : ZMod p) = sum_card_V4 p := rfl

/-! ## Other reciprocity inputs -/

/-- **The `mod 8` law.** For the family `y² = x³ - 2 d² x` the split classes are `p ≡ 1, 7 mod 8`.
-/
theorem sum_card_V4_two (hp2 : p ≠ 2) :
    sumCardTwists (2 : ZMod p) = if p % 8 = 1 ∨ p % 8 = 7 then 4 * (p - 1) else 2 * (p - 1) := by
  have ha : (2 : ZMod p) ≠ 0 := by
    simpa using cast_prime_ne_zero (p := p) Nat.prime_two hp2
  have hcast : (2 : ZMod p) = ((2 : ℕ) : ZMod p) := by norm_num
  rw [sum_card_V4_gen hp2 ha]
  by_cases h : p % 8 = 1 ∨ p % 8 = 7
  · rw [if_pos h, if_pos (by rw [hcast]; exact (ZMod.exists_sq_eq_two_iff hp2).2 h)]
  · rw [if_neg h, if_neg (by rw [hcast]; exact fun hsq => h ((ZMod.exists_sq_eq_two_iff hp2).1 hsq))]

/-- **The `mod 4` law.** For the family `y² = x³ + d² x` the split classes are `p ≡ 1 mod 4`. -/
theorem sum_card_V4_neg_one (hp2 : p ≠ 2) :
    sumCardTwists (-1 : ZMod p) = if p % 4 = 1 then 4 * (p - 1) else 2 * (p - 1) := by
  have ha : (-1 : ZMod p) ≠ 0 := neg_ne_zero.2 one_ne_zero
  have hodd : p % 2 = 1 := Nat.odd_iff.1 ((Fact.out : p.Prime).odd_of_ne_two hp2)
  rw [sum_card_V4_gen hp2 ha]
  by_cases h : p % 4 = 1
  · rw [if_pos h, if_pos (ZMod.exists_sq_eq_neg_one_iff.2 (by omega))]
  · rw [if_neg h, if_neg (fun hsq => h (by
      have := ZMod.exists_sq_eq_neg_one_iff.1 hsq
      omega))]

end TwistFamilyGeneralSum
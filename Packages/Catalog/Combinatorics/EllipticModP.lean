/-
# Modular invariants of point counts over the prime fields `ZMod p`

This file specialises the general finite-field results of
`Combinatorics.EllipticPointCount` to the prime fields `F_p = ZMod p`, producing
*exact* point counts and divisibility ("modular") invariants that depend only on
the residue class of `p`.

Main results:

* `EllipticModCount.cardPoints_zmod_eq_of_three` : if `p % 3 = 2` then
  `y^2 = x^3 + b` has exactly `p + 1` points, so `a_p = 0` and `3 ∣ #E(F_p)`.
* `EllipticModCount.cardPoints_zmod_eq_of_four` : if `p % 4 = 3` then
  `y^2 = x^3 + a*x` has exactly `p + 1` points, so `a_p = 0` and `4 ∣ #E(F_p)`.
* `EllipticModCount.two_dvd_cardPoints_zmod_iff` : the 2-torsion parity criterion
  over `F_p`.
* `EllipticModCount.hasse_of_supersingular_three` / `..._four` : the two
  supersingular families satisfy the Hasse bound with equality `a_p = 0`.
-/
import Mathlib
import Combinatorics.EllipticPointCount
import Combinatorics.EllipticVerticalMoment

namespace EllipticModCount

open Finset

variable {p : ℕ} [Fact p.Prime]

section Basic

theorem ringChar_zmod_ne_two (hp : p ≠ 2) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]
  exact hp

theorem card_zmod_eq : Fintype.card (ZMod p) = p := by
  have : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  exact ZMod.card p

end Basic

section CubeFamily

/-- For `p % 3 = 2` cubing is a bijection of `F_p`. -/
theorem cube_bijective_zmod (h3 : p % 3 = 2) :
    Function.Bijective fun x : ZMod p => x ^ 3 := by
  apply cube_bijective_of_coprime
  rw [card_zmod_eq]
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  have hnd : ¬ (3 ∣ (p - 1)) := by omega
  exact (Nat.Prime.coprime_iff_not_dvd (by norm_num)).mpr hnd |>.symm

/-- **Exact point count.** For `p % 3 = 2` (and `p ≠ 2`) the curve `y^2 = x^3 + b` has
exactly `p + 1` points over `F_p`, for every `b`. -/
theorem cardPoints_zmod_eq_of_three (hp : p ≠ 2) (h3 : p % 3 = 2) (b : ZMod p) :
    cardPoints (0 : ZMod p) b = p + 1 := by
  have hF := ringChar_zmod_ne_two hp
  have h := cardPoints_eq hF (0 : ZMod p) b
  rw [charSum_eq_zero_of_cube_bijective hF (cube_bijective_zmod h3) b, card_zmod_eq] at h
  exact_mod_cast h

/-- The trace of Frobenius vanishes on the family `y^2 = x^3 + b` when `p % 3 = 2`. -/
theorem frobTrace_zmod_eq_zero_of_three (hp : p ≠ 2) (h3 : p % 3 = 2) (b : ZMod p) :
    frobTrace (0 : ZMod p) b = 0 := by
  rw [frobTrace_eq_neg_charSum (ringChar_zmod_ne_two hp),
    charSum_eq_zero_of_cube_bijective (ringChar_zmod_ne_two hp) (cube_bijective_zmod h3) b,
    neg_zero]

/-- **A modular invariant.** If `p % 3 = 2` then `3` always divides the number of points of
`y^2 = x^3 + b` over `F_p`. -/
theorem three_dvd_cardPoints_of_three (hp : p ≠ 2) (h3 : p % 3 = 2) (b : ZMod p) :
    3 ∣ cardPoints (0 : ZMod p) b := by
  rw [cardPoints_zmod_eq_of_three hp h3 b]
  omega

end CubeFamily

section LinearFamily

/-- For `p % 4 = 3`, `-1` is not a square in `F_p`. -/
theorem quadraticChar_neg_one_zmod (h4 : p % 4 = 3) :
    quadraticChar (ZMod p) (-1) = -1 := by
  rw [quadraticChar_neg_one_iff_not_isSquare, FiniteField.isSquare_neg_one_iff]
  rw [card_zmod_eq]
  simp [h4]

/-- **Exact point count.** For `p % 4 = 3` the curve `y^2 = x^3 + a*x` has exactly
`p + 1` points over `F_p`, for every `a`. -/
theorem cardPoints_zmod_eq_of_four (h4 : p % 4 = 3) (a : ZMod p) :
    cardPoints a (0 : ZMod p) = p + 1 := by
  have hp : p ≠ 2 := by omega
  have hF := ringChar_zmod_ne_two hp
  have h := cardPoints_eq hF a (0 : ZMod p)
  rw [charSum_eq_zero_of_neg_one_nonsquare (quadraticChar_neg_one_zmod h4) a,
    card_zmod_eq] at h
  exact_mod_cast h

/-- The trace of Frobenius vanishes on the family `y^2 = x^3 + a*x` when `p % 4 = 3`. -/
theorem frobTrace_zmod_eq_zero_of_four (h4 : p % 4 = 3) (a : ZMod p) :
    frobTrace a (0 : ZMod p) = 0 := by
  have hp : p ≠ 2 := by omega
  rw [frobTrace_eq_neg_charSum (ringChar_zmod_ne_two hp),
    charSum_eq_zero_of_neg_one_nonsquare (quadraticChar_neg_one_zmod h4) a, neg_zero]

/-- **A modular invariant.** If `p % 4 = 3` then `4` always divides the number of points of
`y^2 = x^3 + a*x` over `F_p`. -/
theorem four_dvd_cardPoints_of_four (h4 : p % 4 = 3) (a : ZMod p) :
    4 ∣ cardPoints a (0 : ZMod p) := by
  rw [cardPoints_zmod_eq_of_four h4 a]
  omega

end LinearFamily

section Torsion

/-- **2-torsion parity criterion over `F_p`.** -/
theorem two_dvd_cardPoints_zmod_iff (hp : p ≠ 2) {a b : ZMod p} (hd : disc a b ≠ 0) :
    2 ∣ cardPoints a b ↔ ∃ x : ZMod p, x ^ 3 + a * x + b = 0 :=
  two_dvd_cardPoints_iff (ringChar_zmod_ne_two hp) hd

/-- On the family `y^2 = x^3 + a*x` with `a ≠ 0` the point `(0,0)` is `2`-torsion, and
indeed the point count is even; for `p % 4 = 3` this is consistent with the exact count
`p + 1`. -/
theorem two_dvd_cardPoints_linear (hp : p ≠ 2) {a : ZMod p} (ha : a ≠ 0) :
    2 ∣ cardPoints a (0 : ZMod p) := by
  have hd : disc a (0 : ZMod p) ≠ 0 := by
    have h2 : (2 : ZMod p) ≠ 0 := Ring.two_ne_zero (ringChar_zmod_ne_two hp)
    have h4 : (4 : ZMod p) ≠ 0 := by
      have he : (4 : ZMod p) = 2 * 2 := by norm_num
      rw [he]
      exact mul_ne_zero h2 h2
    simp only [disc, ne_eq]
    intro h
    have : (4 : ZMod p) * a ^ 3 = 0 := by linear_combination h
    rcases mul_eq_zero.mp this with h' | h'
    · exact h4 h'
    · exact ha (pow_eq_zero_iff (by norm_num) |>.mp h')
  rw [two_dvd_cardPoints_zmod_iff hp hd]
  exact ⟨0, by ring⟩

end Torsion

section NegThree

theorem three_ne_zero_zmod (hp3 : p ≠ 3) : (3 : ZMod p) ≠ 0 := by
  intro h
  have hcast : ((3 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
  have hdvd : p ∣ 3 := (ZMod.natCast_eq_zero_iff 3 p).mp hcast
  exact hp3 ((Nat.prime_dvd_prime_iff_eq (Fact.out : p.Prime) (by norm_num)).mp hdvd)

/-- **Supplementary quadratic reciprocity for `-3`, obtained from point counting.**
`-3` is a nonsquare mod `p` exactly when `p ≡ 2 (mod 3)`. -/
theorem quadraticChar_neg_three_zmod (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    quadraticChar (ZMod p) (-3) = -1 ↔ p % 3 = 2 := by
  have hF := ringChar_zmod_ne_two hp2
  have h3 := three_ne_zero_zmod (p := p) hp3
  rw [← cube_bijective_iff_char_neg_three hF h3]
  constructor
  · intro hbij
    by_contra hmod
    have hprime := (Fact.out : p.Prime)
    have hp0 : p % 3 ≠ 0 := by
      intro h0
      have : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero h0
      exact hp3 (((Nat.prime_dvd_prime_iff_eq (by norm_num) hprime).mp this).symm)
    have hlt : p % 3 < 3 := Nat.mod_lt _ (by norm_num)
    have hmod1 : p % 3 = 1 := by omega
    haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
    have hcard : Fintype.card (ZMod p)ˣ = p - 1 := by
      rw [Fintype.card_units, card_zmod_eq]
    have hdvd : 3 ∣ Fintype.card (ZMod p)ˣ := by
      rw [hcard]
      have h2 : 2 ≤ p := hprime.two_le
      omega
    obtain ⟨z, hz⟩ := exists_prime_orderOf_dvd_card 3 hdvd
    have hz3 : (z : ZMod p) ^ 3 = 1 := by
      have h1 := pow_orderOf_eq_one z
      rw [hz] at h1
      have h2 := congrArg (Units.val) h1
      push_cast at h2
      exact h2
    have hzne : (z : ZMod p) ≠ 1 := by
      intro h
      have : z = 1 := Units.ext h
      rw [this] at hz
      simp at hz
    exact hzne (hbij.injective (by simpa using hz3))
  · intro hmod
    exact cube_bijective_zmod hmod

end NegThree

section Hasse

/-- The two supersingular families meet the Hasse bound `|a_p| ≤ 2 * sqrt p` in the
strongest possible way: the trace is exactly `0`, so the point count is exactly `p + 1`. -/
theorem hasse_of_supersingular_three (hp : p ≠ 2) (h3 : p % 3 = 2) (b : ZMod p) :
    (frobTrace (0 : ZMod p) b) ^ 2 ≤ 4 * (p : ℤ) := by
  rw [frobTrace_zmod_eq_zero_of_three hp h3 b]
  positivity

theorem hasse_of_supersingular_four (h4 : p % 4 = 3) (a : ZMod p) :
    (frobTrace a (0 : ZMod p)) ^ 2 ≤ 4 * (p : ℤ) := by
  rw [frobTrace_zmod_eq_zero_of_four h4 a]
  positivity

end Hasse

end EllipticModCount
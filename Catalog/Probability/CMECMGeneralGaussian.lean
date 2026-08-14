/-
# CM-ECM-GENERAL: the field-independent inert collapse (`ℚ(i)`, `j = 1728`)

The companion CM field to `ℚ(√-3)` is `ℚ(i)`, whose canonical curve is the
`j = 1728` curve

  `E_{1728} : y² = x³ + x`,  `End = ℤ[i]`,  bad prime `2`.

This file proves the `ℚ(i)` analogue of the inert collapse of
`Probability.CMECMGeneralJ0`:

* `inert_curveCard_1728` : `#E_{1728}(𝔽_p) = p + 1` exactly for `p ≡ 3 (mod 4)`,
  proved by the sign-pairing `x ↦ -x` (which negates `x³ + x`) together with the
  fact that `-1` is a non-residue, so that the two fibres over `c` and `-c`
  always contribute `2` points in total;
* `inert_trace_zero_1728` : hence `a_p = 0` on the whole inert half;
* `two_dvd_curveCard_1728` : the rational `2`-torsion point `(0,0)` makes the
  parity channel constant (via the catalogue's parity dichotomy);
* `cm_inert_collapse_field_independent` : both CM curves collapse to `p + 1` on
  their inert halves — the mechanism does not depend on the CM field, and on
  that half every ECM smoothness question is literally a `p+1` question.

Together with `Probability.CMECMGeneralJ0` this is the formal core of the
"field-independent mechanism" claim: the CM shadow on the inert half is exactly
Williams' `p+1` method, for `ℚ(√-3)` and for `ℚ(i)` alike.
-/
import Mathlib
import Algebra.ECMParityCore
import Probability.CMECMGeneralJ0

namespace CMECMGaussian

open Finset

variable {p : ℕ} [Fact p.Prime]

/-- The number of square roots of `c` in `𝔽_p`. -/
def sqrtCount (c : ZMod p) : ℕ := (univ.filter fun y : ZMod p => y ^ 2 = c).card

theorem ringChar_ne_two (hp : p % 4 = 3) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]
  omega

/-- For `p ≡ 3 (mod 4)`, `-1` is a quadratic non-residue. -/
theorem quadraticChar_neg_one_eq (hp : p % 4 = 3) :
    quadraticChar (ZMod p) (-1) = -1 := by
  rw [quadraticChar_neg_one (ringChar_ne_two hp), ZMod.card p]
  exact ZMod.χ₄_nat_three_mod_four hp

theorem sqrtCount_eq (hp : p % 4 = 3) (c : ZMod p) :
    (sqrtCount c : ℤ) = quadraticChar (ZMod p) c + 1 := by
  have h := quadraticChar_card_sqrts (ringChar_ne_two hp) c
  rw [sqrtCount]
  rw [← h]
  congr 1
  congr 1
  ext y
  simp

/-- **Sign pairing.**  For `p ≡ 3 (mod 4)` the fibres over `c` and `-c` together
always contain exactly two points. -/
theorem sqrtCount_add_neg (hp : p % 4 = 3) (c : ZMod p) :
    sqrtCount c + sqrtCount (-c) = 2 := by
  have h1 := sqrtCount_eq hp c
  have h2 := sqrtCount_eq hp (-c)
  have h3 : quadraticChar (ZMod p) (-c) = - quadraticChar (ZMod p) c := by
    rw [show (-c) = (-1) * c by ring, map_mul, quadraticChar_neg_one_eq hp, neg_one_mul]
  have : ((sqrtCount c : ℤ)) + (sqrtCount (-c) : ℤ) = 2 := by
    rw [h1, h2, h3]; ring
  exact_mod_cast this

/-- Fibrewise expression of the affine point count. -/
theorem affine_card_eq_sum (A B : ZMod p) :
    (ECMParity.affinePoints A B).card = ∑ x : ZMod p, sqrtCount (ECMParity.cubic A B x) := by
  classical
  rw [ECMParity.affinePoints, card_filter, Fintype.sum_prod_type]
  exact Finset.sum_congr rfl fun x _ => by rw [sqrtCount, card_filter]

/-- **Inert collapse for `ℚ(i)`.**  For `p ≡ 3 (mod 4)` the affine point count of
`y² = x³ + x` is exactly `p`. -/
theorem inert_affine_card_1728 (hp : p % 4 = 3) :
    (ECMParity.affinePoints (1 : ZMod p) 0).card = p := by
  classical
  have hgneg : ∀ x : ZMod p,
      ECMParity.cubic (1 : ZMod p) 0 (-x) = -(ECMParity.cubic (1 : ZMod p) 0 x) := by
    intro x; simp only [ECMParity.cubic]; ring
  set S := ∑ x : ZMod p, sqrtCount (ECMParity.cubic (1 : ZMod p) 0 x) with hS
  have hreindex : S = ∑ x : ZMod p, sqrtCount (-(ECMParity.cubic (1 : ZMod p) 0 x)) := by
    rw [hS]
    rw [← Equiv.sum_comp (Equiv.neg (ZMod p))
      (fun x => sqrtCount (ECMParity.cubic (1 : ZMod p) 0 x))]
    exact Finset.sum_congr rfl fun x _ => by rw [show (Equiv.neg (ZMod p)) x = -x from rfl, hgneg]
  have hsum : S + S = 2 * p := by
    nth_rewrite 2 [hreindex]
    rw [hS, ← Finset.sum_add_distrib]
    have : ∀ x : ZMod p,
        sqrtCount (ECMParity.cubic (1 : ZMod p) 0 x)
          + sqrtCount (-(ECMParity.cubic (1 : ZMod p) 0 x)) = 2 :=
      fun x => sqrtCount_add_neg hp _
    rw [Finset.sum_congr rfl fun x _ => this x]
    simp [Finset.card_univ, ZMod.card p, mul_comm]
  rw [affine_card_eq_sum, ← hS]
  omega

/-- **Inert collapse for `ℚ(i)`.**  `#E_{1728}(𝔽_p) = p + 1` for `p ≡ 3 (mod 4)`. -/
theorem inert_curveCard_1728 (hp : p % 4 = 3) :
    ECMParity.curveCard (1 : ZMod p) 0 = p + 1 := by
  rw [ECMParity.curveCard, inert_affine_card_1728 hp]; omega

/-- The trace of Frobenius of `E_{1728}`. -/
def trace1728 (p : ℕ) [Fact p.Prime] : ℤ :=
  (p : ℤ) + 1 - (ECMParity.curveCard (1 : ZMod p) 0 : ℤ)

/-- **Exact inert collapse of the trace** for `ℚ(i)`: `a_p = 0` on `p ≡ 3 (mod 4)`. -/
theorem inert_trace_zero_1728 (hp : p % 4 = 3) : trace1728 p = 0 := by
  rw [trace1728, inert_curveCard_1728 hp]; push_cast; ring

/-- The discriminant of `x³ + x` is `-4`, nonzero away from `p = 2`. -/
theorem disc_1728_ne_zero (hp2 : p ≠ 2) : ECMParity.disc (1 : ZMod p) 0 ≠ 0 := by
  have h2 : (2 : ZMod p) ≠ 0 := ECMParity.two_ne_zero_of_odd hp2
  rw [ECMParity.disc]
  intro hc
  have h4 : (2 : ZMod p) * 2 = 0 := by linear_combination -hc
  rcases mul_eq_zero.mp h4 with h | h <;> exact h2 h

/-- **Rational `2`-torsion degeneracy for `ℚ(i)`.**  The point `(0,0)` is a
rational `2`-torsion point of `E_{1728}`, so `2 ∣ #E_{1728}(𝔽_p)` for every odd
prime `p`. -/
theorem two_dvd_curveCard_1728 (hp2 : p ≠ 2) :
    2 ∣ ECMParity.curveCard (1 : ZMod p) 0 := by
  rw [ECMParity.two_dvd_curveCard_iff hp2 _ _ (disc_1728_ne_zero hp2)]
  exact ⟨0, by rw [ECMParity.cubic]; ring⟩

/-- **Field independence of the inert collapse.**  On the inert half of its CM
field, each of the two CM curves has exactly `p + 1` points, so every ECM
divisibility (smoothness) question there is literally the corresponding question
about `p + 1`: the CM curve adds nothing to Williams' `p+1` method, for
`ℚ(√-3)` and for `ℚ(i)` alike. -/
theorem cm_inert_collapse_field_independent
    {q r : ℕ} [Fact q.Prime] [Fact r.Prime] (hq : q % 3 = 2) (hr : r % 4 = 3) (ℓ : ℕ) :
    ECMParity.curveCard (0 : ZMod q) 1 = q + 1 ∧
    ECMParity.curveCard (1 : ZMod r) 0 = r + 1 ∧
    (ℓ ∣ ECMParity.curveCard (0 : ZMod q) 1 ↔ ℓ ∣ q + 1) ∧
    (ℓ ∣ ECMParity.curveCard (1 : ZMod r) 0 ↔ ℓ ∣ r + 1) := by
  refine ⟨CMECMGeneral.inert_curveCard hq, inert_curveCard_1728 hr, ?_, ?_⟩
  · rw [CMECMGeneral.inert_curveCard hq]
  · rw [inert_curveCard_1728 hr]

end CMECMGaussian
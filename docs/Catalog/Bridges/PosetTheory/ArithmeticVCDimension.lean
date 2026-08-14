import Mathlib

/-!
# The rational arithmetic height

This module supplies the arithmetic height used by
`Bridges/TropicalAlgebra/TropicalArithmeticUltrametric.lean`.

`ratArithHeight q = |num q| + den q` is the naive additive height of a rational number in
lowest terms.  It is the basic complexity measure attached to a rational datum: the
number of bits needed to write it down, up to a constant.  The file records its
elementary properties; the *failure* of the ultrametric inequality for this height —
the reason a genuine valuation is needed instead — is proved downstream in
`TropicalArithmeticUltrametric.ratArithHeight_not_nonarchimedean`.
-/

namespace ArithmeticVCDim

/-- The naive additive height of a rational number: `|numerator| + denominator`, both
taken from the reduced representation. -/
def ratArithHeight (q : ℚ) : ℕ := q.num.natAbs + q.den

/-- The height is always positive: the denominator of a rational is positive. -/
theorem ratArithHeight_pos (q : ℚ) : 0 < ratArithHeight q := by
  have hd : 0 < q.den := q.pos
  simp only [ratArithHeight]
  omega

/-- The height of an integer is `|n| + 1`. -/
@[simp]
theorem ratArithHeight_intCast (n : ℤ) : ratArithHeight (n : ℚ) = n.natAbs + 1 := by
  simp [ratArithHeight]

/-- The height detects `0`: it equals `1` exactly at the origin. -/
theorem ratArithHeight_eq_one_iff (q : ℚ) : ratArithHeight q = 1 ↔ q = 0 := by
  constructor
  · intro h
    have hd : 0 < q.den := q.pos
    have hnum : q.num.natAbs = 0 := by
      simp only [ratArithHeight] at h; omega
    have : q.num = 0 := Int.natAbs_eq_zero.mp hnum
    exact Rat.zero_iff_num_zero.mpr this
  · rintro rfl
    simp [ratArithHeight]

/-- The height is invariant under negation. -/
@[simp]
theorem ratArithHeight_neg (q : ℚ) : ratArithHeight (-q) = ratArithHeight q := by
  simp [ratArithHeight]

/-- The height is invariant under inversion: numerator and denominator swap roles. -/
theorem ratArithHeight_inv (q : ℚ) (hq : q ≠ 0) :
    ratArithHeight q⁻¹ = ratArithHeight q := by
  have hnum : q.num ≠ 0 := Rat.num_ne_zero.mpr hq
  have hsign : q.num.sign.natAbs = 1 := by
    rcases lt_trichotomy q.num 0 with h | h | h
    · rw [Int.sign_eq_neg_one_of_neg h]; rfl
    · exact absurd h hnum
    · rw [Int.sign_eq_one_of_pos h]; rfl
  have hnum' : (q⁻¹).num.natAbs = q.den := by
    simp [Rat.num_inv, Int.natAbs_mul, hsign]
  have hden : (q⁻¹).den = q.num.natAbs := Rat.den_inv_of_ne_zero hq
  simp only [ratArithHeight, hnum', hden]
  omega

/-- A rational of height at most `B` has numerator and denominator bounded by `B`; this
is the finiteness (Northcott) property in its elementary form. -/
theorem num_den_le_of_ratArithHeight_le {q : ℚ} {B : ℕ} (h : ratArithHeight q ≤ B) :
    q.num.natAbs ≤ B ∧ q.den ≤ B := by
  simp only [ratArithHeight] at h
  omega

end ArithmeticVCDim
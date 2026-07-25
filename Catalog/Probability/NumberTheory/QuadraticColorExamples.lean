import Mathlib

/-!
# Certified small cases for quadratic colors

These examples sample the quadratic character attached to `ℚ(√5)`.  The prime `5` is
ramified, while `7` and `13` are nonsplit and `11` and `19` are split according to their
Legendre-symbol colors.  The proofs are kernel-checked `norm_num` computations.
-/

namespace LanglandsForToddlers

/-- The discriminant prime has color zero. -/
theorem color_five_at_five :
    @legendreSym 5 ⟨by norm_num⟩ (5 : ℤ) = 0 := by
  norm_num

/-- The first sampled nonsquare color for discriminant five. -/
theorem color_five_at_seven :
    @legendreSym 7 ⟨by norm_num⟩ (5 : ℤ) = -1 := by
  norm_num

/-- The next sampled square color for discriminant five. -/
theorem color_five_at_eleven :
    @legendreSym 11 ⟨by norm_num⟩ (5 : ℤ) = 1 := by
  norm_num

/-- Another sampled nonsquare color for discriminant five. -/
theorem color_five_at_thirteen :
    @legendreSym 13 ⟨by norm_num⟩ (5 : ℤ) = -1 := by
  norm_num

/-- Another sampled square color for discriminant five. -/
theorem color_five_at_nineteen :
    @legendreSym 19 ⟨by norm_num⟩ (5 : ℤ) = 1 := by
  norm_num

end LanglandsForToddlers
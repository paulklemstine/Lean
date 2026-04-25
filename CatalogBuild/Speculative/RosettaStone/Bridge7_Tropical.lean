/-! # CatalogBuild.Speculative.RosettaStone.Bridge7_Tropical

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 9
-/

import Mathlib

/-- min doesn't increase. -/
theorem tropical_zero_property (a b : ℝ) : min a b ≤ a := min_le_left a b


/-- Tropical multiplicative identity. -/
theorem tropical_one (a : ℝ) : a + 0 = a := add_zero a


/-- Tropical linear root. -/
theorem tropical_linear_root (a b : ℝ) :
    min (a + (b - a)) b = b := by simp


/-- Tropical determinant of a 2×2 matrix. -/
def tropical_det_2x2 (a b c d : ℝ) : ℝ := min (a + d) (b + c)


/-- Tropical determinant is invariant under transposition. -/
theorem tropical_det_transpose (a b c d : ℝ) :
    tropical_det_2x2 a b c d = tropical_det_2x2 a c b d := by
  simp only [tropical_det_2x2]
  rw [add_comm c b]


/-- min(a+b, b+a) = a+b by commutativity. -/
theorem shortest_round_trip (a b : ℝ) :
    min (a + b) (b + a) = a + b := by
  rw [add_comm b a]; exact min_self _


/-- Universal tropical idempotency for integers. -/
theorem tropical_int_idempotent (a : ℤ) : min a a = a := min_self a


/-- Universal tropical idempotency for rationals. -/
theorem tropical_rat_idempotent (a : ℚ) : min a a = a := min_self a


/-- Universal tropical idempotency for naturals. -/
theorem tropical_nat_idempotent (a : ℕ) : min a a = a := min_self a



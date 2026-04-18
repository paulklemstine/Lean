/-
B3^n Closed-Form Matrix (V13 - Direction 57 RESOLVED)

B3^n has the CORRECTED closed form:
  B3^n = !![1-2n^2, 2n, 2n^2;
            -2n, 1, 2n;
            -2n^2, 2n, 1+2n^2]

Note: The V12 conjecture had the wrong formula (extra 2n terms in corners).
The correct formula is simpler and symmetric.
Proved by induction, matching the B1^n technique from V12.

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

def BN3F : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Corrected closed-form formula for B3^n -/
def BN3_pow_closed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1 - 2 * (↑n : ℤ) ^ 2, 2 * ↑n, 2 * (↑n : ℤ) ^ 2;
     -(2 * ↑n), 1, 2 * ↑n;
     -(2 * (↑n : ℤ) ^ 2), 2 * ↑n, 1 + 2 * (↑n : ℤ) ^ 2]

/-
B3^n = closed form for ALL n
-/
theorem BN3_pow_eq_closed (n : ℕ) : BN3F ^ n = BN3_pow_closed n := by
  induction' n with n ih;
  · native_decide +revert;
  · simp_all +decide [ pow_succ, BN3_pow_closed ];
    simp +decide [ BN3F, Matrix.vecMul ] ; ring_nf ; aesop;

/-- Verification at n=0,1,2,3 -/
theorem BN3_pow_closed_check :
    BN3F ^ 0 = BN3_pow_closed 0 ∧
    BN3F ^ 1 = BN3_pow_closed 1 ∧
    BN3F ^ 2 = BN3_pow_closed 2 ∧
    BN3F ^ 3 = BN3_pow_closed 3 := by
  native_decide

/-- C-branch iteration via B3 -/
def C_iterF : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => let t := C_iterF n
    (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- C-branch closed form -/
def C_closedF (n : ℕ) : ℤ × ℤ × ℤ :=
  ((2 * ↑n + 1) * (2 * ↑n + 3), 4 * (↑n + 1), 4 * (↑n : ℤ) ^ 2 + 8 * ↑n + 5)

/-
The C-branch iteration matches the closed form for ALL n
-/
theorem C_iter_eq_closedF (n : ℕ) : C_iterF n = C_closedF n := by
  induction' n with n ih <;> norm_num [ C_iterF, C_closedF ] at * ; ring_nf at *;
  grind

/-- C-branch Pythagorean property for ALL n -/
theorem C_closed_pythagoreanF (n : ℕ) :
    (C_closedF n).1 ^ 2 + (C_closedF n).2.1 ^ 2 = (C_closedF n).2.2 ^ 2 := by
  simp only [C_closedF]; ring

/-- C-branch gap: c - a = 2 for ALL n -/
theorem C_branch_gapF (n : ℕ) : (C_closedF n).2.2 - (C_closedF n).1 = 2 := by
  simp only [C_closedF]; ring
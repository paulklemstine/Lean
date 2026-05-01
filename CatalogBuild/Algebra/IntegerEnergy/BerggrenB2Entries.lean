/-! # CatalogBuild.Algebra.IntegerEnergy.BerggrenB2Entries

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 9
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenB2Entries
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 9] -/
def BN2E : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- Cayley-Hamilton for B2: B2^3 = 5*B2^2 + 5*B2 - I -/
theorem BN2E_cayley : BN2E ^ 3 = 5 • BN2E ^ 2 + 5 • BN2E - 1 := by native_decide


theorem BN2E_entry_recurrence (i j : Fin 3) (n : ℕ) :
    (BN2E ^ (n + 3)) i j =
    5 * (BN2E ^ (n + 2)) i j + 5 * (BN2E ^ (n + 1)) i j -
    (BN2E ^ n) i j := by
  -- From BN2E_cayley: BN2E^3 = 5 • BN2E^2 + 5 • BN2E - 1. Multiply by BN2E^n on the right: BN2E^(n+3) = 5 • BN2E^(n+2) + 5 • BN2E^(n+1) - BN2E^n.
  have h_mul : BN2E^(n+3) = 5 • BN2E^(n+2) + 5 • BN2E^(n+1) - BN2E^n := by
    induction n <;> simp_all +decide [ pow_succ, mul_comm ];
    simp_all +decide [ mul_assoc, add_mul, sub_mul ];
  convert congr_arg ( fun m : Matrix _ _ ℤ => m i j ) h_mul using 1


theorem BN2E_nonneg (n : ℕ) (i j : Fin 3) : 0 ≤ (BN2E ^ n) i j := by
  induction' n with n ih generalizing i j <;> norm_num [ pow_succ ] at *;
  · decide +revert;
  · simp +decide only [mul_apply];
    exact Finset.sum_nonneg fun k _ => mul_nonneg ( ih _ _ ) ( by fin_cases k <;> fin_cases j <;> decide )


/-- B2 has eigenvector (1,-1,0) with eigenvalue -1 -/
theorem BN2E_eigenvector : BN2E.mulVec ![1, -1, 0] = (-1 : ℤ) • ![1, -1, 0] := by
  native_decide


theorem BN2E_eigenvector_pow (n : ℕ) :
    (BN2E ^ n).mulVec ![1, -1, 0] = ((-1 : ℤ) ^ n) • ![1, -1, 0] := by
  induction n <;> simp_all +decide [ pow_succ' ];
  simp_all +decide [ ← Matrix.mulVec_mulVec, BN2E_eigenvector ];
  ext i; fin_cases i <;> norm_num [ Matrix.mulVec ] ;
  · simp +decide [ BN2E ] ; ring!;
  · unfold BN2E; norm_num [ vecHead, vecTail ] ; ring;
  · ring!


theorem BN2E_row_diff_0 (n : ℕ) :
    (BN2E ^ n) 0 0 - (BN2E ^ n) 0 1 = (-1) ^ n := by
  convert congr_arg ( fun x : Fin 3 → ℤ => x 0 ) ( BN2E_eigenvector_pow n ) using 1 ; simp +decide [ Matrix.mulVec ];
  · exact?;
  · rw [ Pi.smul_apply ] ; norm_num


theorem BN2E_row_diff_1 (n : ℕ) :
    (BN2E ^ n) 1 0 - (BN2E ^ n) 1 1 = -((-1) ^ n) := by
  convert congr_arg ( fun x : Fin 3 → ℤ => x 1 ) ( BN2E_eigenvector_pow n ) using 1 ; simp +decide [ Matrix.mulVec ];
  · ring!;
  · rw [ Pi.smul_apply ] ; norm_num


theorem BN2E_row_diff_2 (n : ℕ) :
    (BN2E ^ n) 2 0 - (BN2E ^ n) 2 1 = 0 := by
  induction' n with n ih;
  · rfl;
  · simp_all +decide [ pow_succ, Matrix.mul_apply ];
    simp_all +decide [ Fin.sum_univ_three, BN2E ];
    linarith


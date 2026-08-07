import Mathlib

/-! # CatalogBuild.Shared.Chi4_three

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 4
-/


noncomputable section

/-- The character χ_{-4}. -/
def chi4 (n : ℤ) : ℤ :=
  if n % 2 = 0 then 0
  else if n % 4 = 1 then 1
  else -1


/-- χ₄(3) = -1. -/
theorem chi4_three : chi4 3 = -1 := by native_decide


/-- χ₄(1) = 1. -/
theorem chi4_one : chi4 1 = 1 := by native_decide


theorem chi4_mul_odd (a b : ℤ) (ha : a % 2 = 1) (hb : b % 2 = 1) :
    chi4 (a * b) = chi4 a * chi4 b := by
  unfold chi4;
  rw [ ← Int.emod_add_mul_ediv a 2, ← Int.emod_add_mul_ediv b 2, ha, hb ] ; ring_nf; norm_num;
  grind


end
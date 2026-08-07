import Mathlib

/-! # CatalogBuild.Shared.Chi4_three

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 4

The generated source listed the definition `chi4` after the theorems using it,
and closed the two evaluation lemmas with `native_decide`; the definition is
moved to the front and the evaluations are discharged by kernel reduction
(`decide`) instead.  The multiplicativity proof is completed by a case analysis
on the residues mod 4.
-/

noncomputable section

namespace Chi4

/-- The character χ_{-4}. -/
def chi4 (n : ℤ) : ℤ :=
  if n % 2 = 0 then 0
  else if n % 4 = 1 then 1
  else -1

/-- χ₄(1) = 1. -/
theorem chi4_one : chi4 1 = 1 := by decide

/-- χ₄(3) = -1. -/
theorem chi4_three : chi4 3 = -1 := by decide

/-- χ₄ is multiplicative on odd arguments. -/
theorem chi4_mul_odd (a b : ℤ) (ha : a % 2 = 1) (hb : b % 2 = 1) :
    chi4 (a * b) = chi4 a * chi4 b := by
  unfold chi4
  have hda : ¬ (2 ∣ a) := by omega
  have hdb : ¬ (2 ∣ b) := by omega
  have h4a : a % 4 = 1 ∨ a % 4 = 3 := by omega
  have h4b : b % 4 = 1 ∨ b % 4 = 3 := by omega
  have hab2 : ¬ (2 ∣ (a * b)) := by
    have h : (a * b) % 2 = 1 := by rw [Int.mul_emod, ha, hb]; norm_num
    omega
  have hab4 : (a * b) % 4 = (a % 4) * (b % 4) % 4 := Int.mul_emod a b 4
  rcases h4a with h1 | h1 <;> rcases h4b with h2 | h2 <;>
    rw [h1, h2] at hab4 <;> norm_num at hab4 <;>
    simp [h1, h2, hab2, hab4, hda, hdb]

end Chi4

end
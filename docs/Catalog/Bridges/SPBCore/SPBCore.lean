import Mathlib

/-! # CatalogBuild.Bridges.SPBCore

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

noncomputable section

/-- SPB over an arbitrary field. -/
def spbF {F : Type*} [Field F] (x y : F) : F := (x + y) / (1 - x * y)

/-- SPB over a field is commutative. -/
theorem spbF_comm {F : Type*} [Field F] (x y : F) : spbF x y = spbF y x := by
  simp [spbF, add_comm, mul_comm]

/-- SPB over a field has identity 0. -/
theorem spbF_zero_right {F : Type*} [Field F] (x : F) : spbF x 0 = x := by
  simp [spbF]

/-- SPB inverse over a field. -/
theorem spbF_neg_self {F : Type*} [Field F] (x : F) : spbF x (-x) = 0 := by
  simp [spbF]

/-- [Section: # CatalogBuild.Bridges.SPBCore
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5] -/
theorem spbF_assoc {F : Type*} [Field F] (x y z : F)
    (hxy : x * y ≠ 1) (hyz : y * z ≠ 1)
    (hxyz : x * spbF y z ≠ 1) (hxyz' : spbF x y * z ≠ 1) :
    spbF (spbF x y) z = spbF x (spbF y z) := by
  unfold spbF at *;
  by_cases h1 : 1 - x * y = 0 <;> by_cases h2 : 1 - y * z = 0 <;> simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, sub_eq_iff_eq_add, add_eq_zero_iff_eq_neg ];
  rw [ div_add', div_div, div_eq_div_iff ];
  · grind;
  · grind;
  · exact sub_ne_zero_of_ne ( Ne.symm hxyz );
  · exact sub_ne_zero_of_ne h1

end

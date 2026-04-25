/-! # CatalogBuild.EML.SPBTropicalAlgebra

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9
-/

import Mathlib

noncomputable section

/-- Tropical SPB: tropicalization of (x+y)/(1-xy). -/
def tropSPB' (x y : ℝ) : ℝ := min x y - max 0 (x + y)


/-- [Section: # CatalogBuild.EML.SPBTropicalAlgebra
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9] -/
theorem tropSPB_eq_neg_max_abs (a b : ℝ) :
    tropSPB' a b = -max (|a|) (|b|) := by
  unfold tropSPB';
  cases max_cases ( |a| ) ( |b| ) <;> cases abs_cases a <;> cases abs_cases b <;> cases max_cases 0 ( a + b ) <;> cases min_cases a b <;> linarith


/-- Tropical SPB is commutative. -/
theorem tropSPB'_comm (x y : ℝ) : tropSPB' x y = tropSPB' y x := by
  simp [tropSPB', min_comm, add_comm]


/-- 0 is NOT the identity for tropical SPB. -/
theorem tropSPB_zero_not_identity : ∃ x : ℝ, tropSPB' x 0 ≠ x := by
  use 1; simp [tropSPB']; norm_num


/-- tropSPB(x, 0) for positive x equals -x. -/
theorem tropSPB_zero_pos (x : ℝ) (hx : 0 < x) : tropSPB' x 0 = -x := by
  simp [tropSPB', min_eq_right (le_of_lt hx), max_eq_right (le_of_lt hx)]


/-- [Section: # CatalogBuild.EML.SPBTropicalAlgebra
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9] -/
theorem tropSPB_no_identity : ¬∃ e : ℝ, ∀ x : ℝ, tropSPB' x e = x := by
  intro h
  obtain ⟨e, he⟩ := h
  have := he (-1)
  have := he 1
  simp at *;
  unfold tropSPB' at *;
  cases max_cases ( 0 : ℝ ) ( -1 + e ) <;> cases max_cases ( 0 : ℝ ) ( 1 + e ) <;> cases min_cases ( -1 : ℝ ) e <;> cases min_cases ( 1 : ℝ ) e <;> linarith


/-- For negative x, tropSPB(x, x) = x (idempotent). -/
theorem tropSPB_idempotent_neg (x : ℝ) (hx : x < 0) :
    tropSPB' x x = x := by
  unfold tropSPB'
  simp [max_eq_left (show x + x ≤ 0 by linarith)]


/-- For positive x, tropSPB(x, x) = -x. -/
theorem tropSPB_not_idempotent_pos (x : ℝ) (hx : 0 < x) :
    tropSPB' x x = -x := by
  unfold tropSPB'
  simp [max_eq_right (show 0 ≤ x + x by linarith)]


/-- Tropical SPB has no left-identity. -/
theorem tropSPB_no_left_identity : ¬∃ e : ℝ, ∀ x : ℝ, tropSPB' e x = x := by
  intro ⟨e, he⟩
  exact tropSPB_no_identity ⟨e, fun x => by rw [tropSPB'_comm]; exact he x⟩


end

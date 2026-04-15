/-! # CatalogBuild.Computation.DynamicalSystem

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 10
-/

import Mathlib

noncomputable section

def EML_dyn (a b : ℝ) : ℝ := Real.exp a - Real.log b


def trEML (p : ℝ × ℝ) : ℝ := EML_dyn p.1 p.2 + EML_dyn p.2 p.1


def PhiIter : ℕ → ℝ × ℝ → ℝ × ℝ
  | 0, p => p
  | n + 1, p => Phi (PhiIter n p)


theorem trEML_formula (x y : ℝ) :
    trEML (x, y) = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  simp [trEML, EML_dyn]; ring


theorem trEML_symm (x y : ℝ) : trEML (x, y) = trEML (y, x) := by
  simp [trEML, EML_dyn]; ring


theorem trEML_ge_four (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    trEML (x, y) ≥ 4 := by
  rw [trEML_formula]
  linarith [Real.add_one_le_exp x, Real.add_one_le_exp y,
            Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy]


theorem Phi_ordering (x y : ℝ) (hy : 0 < y) (hxy : x > y) :
    EML_dyn x y > EML_dyn y x := by
  simp [EML_dyn]
  linarith [Real.exp_lt_exp.mpr hxy, Real.log_lt_log hy hxy]


theorem Phi_antisymmetric (x y : ℝ) :
    EML_dyn x y - EML_dyn y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  simp [EML_dyn]; ring


theorem Phi_max_component_bound (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    max (EML_dyn x y) (EML_dyn y x) ≥ Real.exp (min x y) - max x y := by
  by_cases hxy : x ≤ y
  · rw [min_eq_left hxy, max_eq_right hxy]
    have h : EML_dyn x y ≥ Real.exp x - y := by
      unfold EML_dyn; linarith [Real.log_le_sub_one_of_pos hy]
    linarith [le_max_left (EML_dyn x y) (EML_dyn y x)]
  · push_neg at hxy
    rw [min_eq_right (le_of_lt hxy), max_eq_left (le_of_lt hxy)]
    have h : EML_dyn y x ≥ Real.exp y - x := by
      unfold EML_dyn; linarith [Real.log_le_sub_one_of_pos hx]
    linarith [le_max_right (EML_dyn x y) (EML_dyn y x)]


theorem Phi_max_grows (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hmax : max x y ≥ 2) :
    max (Phi (x, y)).1 (Phi (x, y)).2 > max x y := by
  simp only [Phi]
  by_cases hxy : x ≥ y
  · have hm : max x y = x := max_eq_left hxy
    rw [hm] at hmax ⊢
    have : EML_dyn x y > x := by
      unfold EML_dyn
      nlinarith [quadratic_le_exp_of_nonneg hx.le, Real.log_le_sub_one_of_pos hy, sq_nonneg x]
    exact lt_of_lt_of_le this (le_max_left _ _)
  · push_neg at hxy
    have hm : max x y = y := max_eq_right (le_of_lt hxy)
    rw [hm] at hmax ⊢
    have : EML_dyn y x > y := by
      unfold EML_dyn
      nlinarith [quadratic_le_exp_of_nonneg hy.le, Real.log_le_sub_one_of_pos hx, sq_nonneg y]
    exact lt_of_lt_of_le this (le_max_right _ _)


end

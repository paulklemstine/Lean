/-! # CatalogBuild.Speculative.OISCC.TropicalLimit

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 11
-/

import Mathlib

noncomputable section

/-- The tropical diagonal map. -/
def d_trop (x : ℝ) : ℝ := max x (-x)


/-- The tropical 2D map. -/
def Phi_trop (x y : ℝ) : ℝ × ℝ := (EML_trop x y, EML_trop y x)


/-- The tropical diagonal is |x|. -/
theorem d_trop_eq_abs (x : ℝ) : d_trop x = |x| := by
  simp [d_trop, abs_eq_max_neg]


/-- [Section: # CatalogBuild.Speculative.OISCC.TropicalLimit
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 11] -/
theorem tropical_sum_nonneg (x y : ℝ) :
    EML_trop x y + EML_trop y x ≥ 0 := by
  unfold EML_trop
  cases max_cases x ( -y ) <;> cases max_cases y ( -x ) <;> linarith


/-- Tropical fixed point: d_trop(x) = x iff x ≥ 0. -/
theorem d_trop_fixed_iff (x : ℝ) : d_trop x = x ↔ x ≥ 0 := by
  rw [d_trop_eq_abs, abs_eq_self]


/-- d_trop(x) ≥ 0 for all x. -/
theorem d_trop_nonneg (x : ℝ) : d_trop x ≥ 0 := by
  rw [d_trop_eq_abs]; exact abs_nonneg x


/-- d_trop(x) ≥ x for all x. -/
theorem d_trop_ge_id (x : ℝ) : d_trop x ≥ x := by
  unfold d_trop; exact le_max_left x (-x)


/-- Tropical EML is monotone in the first argument. -/
theorem EML_trop_monotone_first (y : ℝ) : Monotone (fun x => EML_trop x y) := by
  intro a b hab; unfold EML_trop; exact max_le_max_right _ hab


/-- Tropical EML is antitone in the second argument. -/
theorem EML_trop_antitone_second (x : ℝ) : Antitone (fun y => EML_trop x y) := by
  intro a b hab; unfold EML_trop; exact max_le_max_left _ (neg_le_neg hab)


/-- The tropical Phi preserves non-negativity of sum. -/
theorem Phi_trop_sum_nonneg (x y : ℝ) :
    (Phi_trop x y).1 + (Phi_trop x y).2 ≥ 0 :=
  tropical_sum_nonneg x y


/-- EML(0, exp(ty)) = 1 - ty (exact). -/
theorem tropical_exact_second (t y : ℝ) :
    Real.exp 0 - Real.log (Real.exp (t * y)) = 1 - t * y := by
  rw [Real.exp_zero, Real.log_exp]


end

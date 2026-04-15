/-! # CatalogBuild.Speculative.OpenProblems.SPBCauchyMeasure

Auto-generated from theorem catalog database.
Domain: Speculative/OpenProblems
Declarations: 4
-/

import Mathlib

noncomputable section

/-- Key algebraic identity for Cauchy invariance. -/
theorem cauchy_transform_identity (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 - x * a) ^ 2 * (1 + spbC x a ^ 2) = (1 + x ^ 2) * (1 + a ^ 2) := by
  unfold spbC; field_simp; ring


theorem cauchy_pullback (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / ((1 + spbC x a ^ 2) * (1 - x * a) ^ 2) = 1 / (1 + x ^ 2) := by
  field_simp;
  grind +suggestions


theorem arctan_spb_addition (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spbC x y) = arctan x + arctan y := by
  -- Apply the Real.arctan_add theorem with the condition 0 < 1 - x * y.
  apply Eq.symm; exact (by
  convert Real.arctan_add _ using 1;
  linarith)


/-- SPB scaling: spb(sx, sy) = s(x+y)/(1-s²xy). -/
theorem spb_equal_scale (s x y : ℝ) :
    spbC (s * x) (s * y) = s * (x + y) / (1 - s ^ 2 * (x * y)) := by
  unfold spbC; congr 1 <;> ring


end
